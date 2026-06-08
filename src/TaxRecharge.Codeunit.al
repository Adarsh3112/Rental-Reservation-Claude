codeunit 50103 "BSB Tax Recharge"
{
    procedure RecordIBIUpdateUI(var Property: Record "BSB Property")
    var
        TaxEntry: Record "BSB Property Tax Entry";
        NewAmount: Decimal;
        InputAmount: Text[30];
        EffectiveDate: Date;
        InputDate: Text[30];
    begin
        InputAmount := Format(Property."Annual Property Tax (IBI)");
        if not Dialog.Confirm('Update IBI for property %1? Current annual amount: %2', false,
                Property."No.", Property."Annual Property Tax (IBI)") then
            exit;

        EffectiveDate := WorkDate();
        InputDate := Format(EffectiveDate);
        NewAmount := Property."Annual Property Tax (IBI)";

        RecordIBIUpdate(Property."No.", EffectiveDate, NewAmount, Property."Tax Period",
                        'IBI update recorded from property card.');
        TaxEntry.SetRange("Property No.", Property."No.");
        if TaxEntry.FindLast() then;
        Message('IBI history entry %1 created for property %2.', TaxEntry."Entry No.", Property."No.");
    end;

    procedure RecordIBIUpdate(PropertyNo: Code[20]; EffectiveDate: Date; NewAnnualAmount: Decimal;
                              Period: Enum "BSB Tax Period Type"; Notes: Text)
    var
        Property: Record "BSB Property";
        TaxEntry: Record "BSB Property Tax Entry";
        AuditMgmt: Codeunit "BSB Audit Log Mgmt";
        Previous: Decimal;
    begin
        if not Property.Get(PropertyNo) then
            Error('Property %1 not found.', PropertyNo);
        Previous := Property."Annual Property Tax (IBI)";

        TaxEntry.Init();
        TaxEntry."Property No." := PropertyNo;
        TaxEntry."Effective Date" := EffectiveDate;
        TaxEntry."Previous Annual Amount" := Previous;
        TaxEntry."Annual Amount" := NewAnnualAmount;
        TaxEntry.Period := Period;
        TaxEntry.Notes := CopyStr(Notes, 1, MaxStrLen(TaxEntry.Notes));
        TaxEntry.Insert();

        Property."Annual Property Tax (IBI)" := NewAnnualAmount;
        Property."Tax Period" := Period;
        Property.Modify();

        AuditMgmt.LogAction(
            Database::"BSB Property",
            PropertyNo,
            Enum::"BSB Audit Action Type"::"Tax Update",
            StrSubstNo('IBI changed from %1 to %2 effective %3', Previous, NewAnnualAmount, EffectiveDate));

        RecalculateFutureChargesForProperty(PropertyNo, EffectiveDate);
    end;

    procedure RecalculateFutureChargesForProperty(PropertyNo: Code[20]; EffectiveDate: Date)
    var
        ContractProperty: Record "BSB Lease Contract Property";
        Contract: Record "BSB Lease Contract";
    begin
        ContractProperty.SetRange("Property No.", PropertyNo);
        if ContractProperty.FindSet() then
            repeat
                if Contract.Get(ContractProperty."Contract No.") then
                    if Contract.Status in [Contract.Status::Active, Contract.Status::"In Cancellation"] then
                        if Contract."IBI Recharge Active" then
                            RecalculateFutureChargesForContract(Contract);
            until ContractProperty.Next() = 0;
    end;

    procedure RecalculateFutureChargesForContract(var Contract: Record "BSB Lease Contract")
    var
        BillingLine: Record "BSB Lease Contract Billing";
        Installment: Record "BSB Lease Installment";
        ContractProperty: Record "BSB Lease Contract Property";
        Property: Record "BSB Property";
        TotalAnnual: Decimal;
        PerPeriod: Decimal;
        EffectiveDate: Date;
        TaxConceptFound: Boolean;
        Billing: Codeunit "BSB Recurring Billing";
        LastBilled: Date;
    begin
        if not Contract."IBI Recharge Active" then
            exit;
        TotalAnnual := 0;
        ContractProperty.SetRange("Contract No.", Contract."No.");
        if ContractProperty.FindSet() then
            repeat
                if Property.Get(ContractProperty."Property No.") then
                    TotalAnnual += Property."Annual Property Tax (IBI)";
            until ContractProperty.Next() = 0;

        BillingLine.SetRange("Contract No.", Contract."No.");
        BillingLine.SetRange("Concept Type", BillingLine."Concept Type"::"Property Tax (IBI)");
        if BillingLine.FindFirst() then begin
            TaxConceptFound := true;
            PerPeriod := AnnualToPeriod(TotalAnnual, BillingLine."Billing Frequency");
            BillingLine.Amount := PerPeriod;
            BillingLine.Modify();
        end else begin
            CreateTaxBillingLine(Contract, TotalAnnual, BillingLine);
            PerPeriod := BillingLine.Amount;
            TaxConceptFound := true;
        end;

        if not TaxConceptFound then
            exit;

        LastBilled := Contract."Last Billed Through";
        EffectiveDate := WorkDate();
        if LastBilled > EffectiveDate then
            EffectiveDate := LastBilled + 1;

        Installment.SetRange("Contract No.", Contract."No.");
        Installment.SetRange("Billing Line No.", BillingLine."Line No.");
        Installment.SetRange(Status, Installment.Status::Open);
        Installment.SetFilter("Period Start", '>=%1', EffectiveDate);
        if Installment.FindSet() then
            repeat
                Installment.Amount := PerPeriod;
                Installment.Modify();
            until Installment.Next() = 0;

        Billing.GenerateInstallments(Contract, false);
    end;

    local procedure CreateTaxBillingLine(Contract: Record "BSB Lease Contract"; AnnualAmount: Decimal;
                                          var BillingLine: Record "BSB Lease Contract Billing")
    var
        Last: Record "BSB Lease Contract Billing";
        NextLineNo: Integer;
    begin
        Last.SetRange("Contract No.", Contract."No.");
        if Last.FindLast() then
            NextLineNo := Last."Line No." + 10000
        else
            NextLineNo := 10000;
        BillingLine.Init();
        BillingLine."Contract No." := Contract."No.";
        BillingLine."Line No." := NextLineNo;
        BillingLine."Concept Type" := BillingLine."Concept Type"::"Property Tax (IBI)";
        BillingLine.Description := 'Property Tax (IBI) Recharge';
        BillingLine."Billing Frequency" := BillingLine."Billing Frequency"::Annual;
        BillingLine.Amount := AnnualAmount;
        BillingLine."Start Date" := Contract."Start Date";
        BillingLine."End Date" := Contract."End Date";
        BillingLine.Active := true;
        BillingLine.Insert();
    end;

    local procedure AnnualToPeriod(AnnualAmount: Decimal; Frequency: Enum "BSB Billing Frequency"): Decimal
    begin
        case Frequency of
            Frequency::Monthly:
                exit(AnnualAmount / 12);
            Frequency::Quarterly:
                exit(AnnualAmount / 4);
            Frequency::"Semi-Annual":
                exit(AnnualAmount / 2);
            Frequency::Annual:
                exit(AnnualAmount);
            else
                exit(AnnualAmount);
        end;
    end;
}
