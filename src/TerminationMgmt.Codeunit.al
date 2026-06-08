codeunit 50107 "BSB Termination Mgmt"
{
    procedure CloseContract(var Contract: Record "BSB Lease Contract")
    var
        PropertyLine: Record "BSB Lease Contract Property";
        Property: Record "BSB Property";
        Billing: Codeunit "BSB Recurring Billing";
        DepositMgmt: Codeunit "BSB Deposit Mgmt";
        AuditMgmt: Codeunit "BSB Audit Log Mgmt";
        SubleaseContract: Record "BSB Lease Contract";
        OldStatus: Enum "BSB Contract Status";
        TerminationDate: Date;
    begin
        if Contract.Status = Contract.Status::Closed then
            exit;
        if not (Contract.Status in [Contract.Status::"In Cancellation", Contract.Status::Active]) then
            Error('Contract %1 cannot be closed from status %2.', Contract."No.", Contract.Status);

        SubleaseContract.SetRange("Parent Contract No.", Contract."No.");
        SubleaseContract.SetFilter(Status, '%1|%2',
            SubleaseContract.Status::Active, SubleaseContract.Status::"In Cancellation");
        if not SubleaseContract.IsEmpty() then
            Error('Cannot close parent contract %1: there are active subleases.', Contract."No.");

        OldStatus := Contract.Status;
        TerminationDate := WorkDate();
        if Contract."Termination Date" <> 0D then
            TerminationDate := Contract."Termination Date";

        Billing.CancelFutureOpenInstallments(Contract."No.", TerminationDate + 1);

        Contract.Status := Contract.Status::Closed;
        Contract."Termination Date" := TerminationDate;
        Contract."Closed On" := CurrentDateTime();
        Contract."Closed By" := CopyStr(UserId(), 1, MaxStrLen(Contract."Closed By"));
        Contract.Modify(true);

        PropertyLine.SetRange("Contract No.", Contract."No.");
        if PropertyLine.FindSet() then
            repeat
                if Property.Get(PropertyLine."Property No.") then begin
                    if not OtherActiveAllocation(Property."No.", Contract."No.") then begin
                        Property."Rental Status" := Property."Rental Status"::Available;
                        Property.Modify(true);
                    end;
                end;
            until PropertyLine.Next() = 0;

        AuditMgmt.LogStatusChange(
            Database::"BSB Lease Contract",
            Contract."No.",
            Format(OldStatus),
            Format(Contract.Status));

        if Contract."Deposit Amount" > 0 then
            if DepositMgmt.CalcRunningBalance(Contract."No.") > 0 then
                Message('Contract %1 closed. Remaining deposit balance: %2. Run Settle/Refund Deposit to settle.',
                    Contract."No.", DepositMgmt.CalcRunningBalance(Contract."No."));
    end;

    local procedure OtherActiveAllocation(PropertyNo: Code[20]; ExcludeContractNo: Code[20]): Boolean
    var
        Allocation: Record "BSB Lease Contract Property";
        Contract: Record "BSB Lease Contract";
    begin
        Allocation.SetRange("Property No.", PropertyNo);
        Allocation.SetFilter("Contract No.", '<>%1', ExcludeContractNo);
        if Allocation.FindSet() then
            repeat
                if Contract.Get(Allocation."Contract No.") then
                    if Contract.Status in [Contract.Status::Active, Contract.Status::"In Cancellation"] then
                        exit(true);
            until Allocation.Next() = 0;
        exit(false);
    end;
}
