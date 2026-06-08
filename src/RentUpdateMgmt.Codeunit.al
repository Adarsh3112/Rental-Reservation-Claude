codeunit 50106 "BSB Rent Update Mgmt"
{
    procedure ApplyIndexationUI(var Contract: Record "BSB Lease Contract")
    var
        Pct: Decimal;
        InputPct: Text[30];
        EffectiveDate: Date;
    begin
        if Contract.Status <> Contract.Status::Active then
            Error('Only active contracts can be indexed.');
        if not Dialog.Confirm('Apply default 2%% indexation to contract %1 effective today?', false, Contract."No.") then
            exit;
        Pct := 2;
        EffectiveDate := WorkDate();
        ApplyIndexation(Contract, EffectiveDate, Pct, 'Standard indexation');
    end;

    procedure ApplyIndexation(var Contract: Record "BSB Lease Contract"; EffectiveDate: Date; Pct: Decimal; Notes: Text)
    var
        BillingLine: Record "BSB Lease Contract Billing";
        Installment: Record "BSB Lease Installment";
        UpdateEntry: Record "BSB Rent Update Entry";
        AuditMgmt: Codeunit "BSB Audit Log Mgmt";
        OldRent: Decimal;
        NewRent: Decimal;
        OldAmount: Decimal;
        NewAmount: Decimal;
    begin
        if Pct = 0 then
            exit;
        OldRent := Contract."Base Rent";
        NewRent := Round(OldRent * (1 + Pct / 100), 0.01);

        BillingLine.SetRange("Contract No.", Contract."No.");
        BillingLine.SetRange("Concept Type", BillingLine."Concept Type"::"Base Rent");
        if BillingLine.FindFirst() then begin
            OldAmount := BillingLine.Amount;
            NewAmount := Round(OldAmount * (1 + Pct / 100), 0.01);
            BillingLine.Amount := NewAmount;
            BillingLine.Modify();
        end;

        Contract."Base Rent" := NewRent;
        Contract."Last Rent Update Date" := EffectiveDate;
        Contract.Modify();

        UpdateEntry.Init();
        UpdateEntry."Contract No." := Contract."No.";
        UpdateEntry."Effective Date" := EffectiveDate;
        UpdateEntry."Previous Rent" := OldRent;
        UpdateEntry."New Rent" := NewRent;
        UpdateEntry."Update %" := Pct;
        UpdateEntry."Update Type" := UpdateEntry."Update Type"::Indexation;
        UpdateEntry.Notes := CopyStr(Notes, 1, MaxStrLen(UpdateEntry.Notes));
        UpdateEntry.Insert();

        Installment.SetRange("Contract No.", Contract."No.");
        if BillingLine."Line No." <> 0 then
            Installment.SetRange("Billing Line No.", BillingLine."Line No.");
        Installment.SetRange(Status, Installment.Status::Open);
        Installment.SetFilter("Period Start", '>=%1', EffectiveDate);
        if Installment.FindSet() then
            repeat
                Installment.Amount := Round(Installment.Amount * (1 + Pct / 100), 0.01);
                Installment.Modify();
            until Installment.Next() = 0;

        AuditMgmt.LogAction(
            Database::"BSB Lease Contract",
            Contract."No.",
            Enum::"BSB Audit Action Type"::"Rent Update",
            StrSubstNo('Rent indexation %1%% from %2 to %3', Pct, OldRent, NewRent));
    end;

    procedure RenewContractUI(var Contract: Record "BSB Lease Contract")
    var
        Months: Integer;
        NewEndDate: Date;
    begin
        if Contract.Status <> Contract.Status::Active then
            Error('Only active contracts can be renewed.');
        if not Dialog.Confirm('Renew contract %1 for 12 months?', false, Contract."No.") then
            exit;
        Months := 12;
        NewEndDate := CalcDate(StrSubstNo('<+%1M>', Months), Contract."End Date");
        RenewContract(Contract, NewEndDate, 'Renewal +12M');
    end;

    procedure RenewContract(var Contract: Record "BSB Lease Contract"; NewEndDate: Date; Notes: Text)
    var
        UpdateEntry: Record "BSB Rent Update Entry";
        AuditMgmt: Codeunit "BSB Audit Log Mgmt";
        Billing: Codeunit "BSB Recurring Billing";
        OldEndDate: Date;
    begin
        if NewEndDate <= Contract."End Date" then
            Error('New end date %1 must be after current end date %2.', NewEndDate, Contract."End Date");

        OldEndDate := Contract."End Date";
        Contract."End Date" := NewEndDate;
        Contract.Modify();

        UpdateEntry.Init();
        UpdateEntry."Contract No." := Contract."No.";
        UpdateEntry."Effective Date" := WorkDate();
        UpdateEntry."Previous Rent" := Contract."Base Rent";
        UpdateEntry."New Rent" := Contract."Base Rent";
        UpdateEntry."Previous End Date" := OldEndDate;
        UpdateEntry."New End Date" := NewEndDate;
        UpdateEntry."Update Type" := UpdateEntry."Update Type"::Renewal;
        UpdateEntry.Notes := CopyStr(Notes, 1, MaxStrLen(UpdateEntry.Notes));
        UpdateEntry.Insert();

        Billing.GenerateInstallments(Contract, false);

        AuditMgmt.LogAction(
            Database::"BSB Lease Contract",
            Contract."No.",
            Enum::"BSB Audit Action Type"::"Status Change",
            StrSubstNo('Renewal: end date %1 -> %2', OldEndDate, NewEndDate));
    end;
}
