codeunit 50104 "BSB Deposit Mgmt"
{
    procedure PostInitialDeposit(var Contract: Record "BSB Lease Contract")
    var
        Setup: Record "BSB Real Estate Setup";
        DepositEntry: Record "BSB Deposit Entry";
        Existing: Record "BSB Deposit Entry";
        AuditMgmt: Codeunit "BSB Audit Log Mgmt";
        DocNo: Code[20];
    begin
        Contract.TestField("Deposit Amount");
        if Contract.Status = Contract.Status::Closed then
            Error('Cannot post deposit on closed contract %1.', Contract."No.");

        Existing.SetRange("Contract No.", Contract."No.");
        Existing.SetRange("Entry Type", Existing."Entry Type"::Initial);
        Existing.SetRange(Reversed, false);
        if not Existing.IsEmpty() then
            Error('Initial deposit for contract %1 is already posted.', Contract."No.");

        Setup.GetSetup();
        DocNo := CopyStr('DEP-' + Contract."No.", 1, 20);

        DepositEntry.Init();
        DepositEntry."Contract No." := Contract."No.";
        DepositEntry."Customer No." := Contract."Tenant Customer No.";
        DepositEntry."Project No." := Contract."Project No.";
        DepositEntry."Entry Type" := DepositEntry."Entry Type"::Initial;
        DepositEntry.Description := StrSubstNo('Initial deposit for contract %1', Contract."No.");
        DepositEntry."Posting Date" := WorkDate();
        DepositEntry."Document No." := DocNo;
        DepositEntry.Amount := Contract."Deposit Amount";
        DepositEntry.Holder := Contract."Deposit Holder";
        DepositEntry."G/L Account No." := ResolveDepositAccount(Contract);
        DepositEntry."Running Balance" := CalcRunningBalance(Contract."No.") + Contract."Deposit Amount";
        DepositEntry.Insert(true);

        AuditMgmt.LogAction(
            Database::"BSB Lease Contract",
            Contract."No.",
            Enum::"BSB Audit Action Type"::Modify,
            StrSubstNo('Initial deposit posted: %1', Contract."Deposit Amount"));
    end;

    procedure TransferToAgency(var Contract: Record "BSB Lease Contract")
    var
        DepositEntry: Record "BSB Deposit Entry";
        Setup: Record "BSB Real Estate Setup";
        Balance: Decimal;
        DocNo: Code[20];
    begin
        if Contract."Deposit Holder" <> Contract."Deposit Holder"::"External Agency" then
            Error('Contract %1 does not require external agency holding.', Contract."No.");
        Balance := CalcRunningBalance(Contract."No.");
        if Balance <= 0 then
            Error('No deposit balance available to transfer for contract %1.', Contract."No.");

        Setup.GetSetup();
        DocNo := CopyStr('DEP-TR-' + Contract."No.", 1, 20);

        DepositEntry.Init();
        DepositEntry."Contract No." := Contract."No.";
        DepositEntry."Customer No." := Contract."Tenant Customer No.";
        DepositEntry."Project No." := Contract."Project No.";
        DepositEntry."Entry Type" := DepositEntry."Entry Type"::"Transfer to Agency";
        DepositEntry.Description := StrSubstNo('Transfer deposit to external agency for contract %1', Contract."No.");
        DepositEntry."Posting Date" := WorkDate();
        DepositEntry."Document No." := DocNo;
        DepositEntry.Amount := -Balance;
        DepositEntry.Holder := DepositEntry.Holder::"External Agency";
        DepositEntry."G/L Account No." := Setup."External Agency G/L Account";
        DepositEntry."Running Balance" := 0;
        DepositEntry.Insert(true);

        DepositEntry.Init();
        DepositEntry."Contract No." := Contract."No.";
        DepositEntry."Customer No." := Contract."Tenant Customer No.";
        DepositEntry."Project No." := Contract."Project No.";
        DepositEntry."Entry Type" := DepositEntry."Entry Type"::"Transfer to Agency";
        DepositEntry.Description := StrSubstNo('Receipt at external agency for contract %1', Contract."No.");
        DepositEntry."Posting Date" := WorkDate();
        DepositEntry."Document No." := DocNo;
        DepositEntry.Amount := Balance;
        DepositEntry.Holder := DepositEntry.Holder::"External Agency";
        DepositEntry."G/L Account No." := Setup."External Agency G/L Account";
        DepositEntry."Running Balance" := Balance;
        DepositEntry.Insert(true);
    end;

    procedure SettleDeposit(var Contract: Record "BSB Lease Contract")
    var
        Setup: Record "BSB Real Estate Setup";
        DepositEntry: Record "BSB Deposit Entry";
        Balance: Decimal;
        DocNo: Code[20];
    begin
        Balance := CalcRunningBalance(Contract."No.");
        if Balance < 0 then
            Error('Deposit balance for contract %1 is negative (%2). Cannot settle.', Contract."No.", Balance);
        if Balance = 0 then begin
            Message('No deposit balance to settle for contract %1.', Contract."No.");
            exit;
        end;

        if Contract.Status <> Contract.Status::Closed then
            if not Dialog.Confirm('Contract %1 is not closed (status: %2). Settle deposit anyway?', false,
                    Contract."No.", Contract.Status) then
                exit;

        Setup.GetSetup();
        DocNo := CopyStr('DEP-SETT-' + Contract."No.", 1, 20);

        if Contract."Deposit Holder" = Contract."Deposit Holder"::"External Agency" then begin
            DepositEntry.Init();
            DepositEntry."Contract No." := Contract."No.";
            DepositEntry."Customer No." := Contract."Tenant Customer No.";
            DepositEntry."Project No." := Contract."Project No.";
            DepositEntry."Entry Type" := DepositEntry."Entry Type"::"Return from Agency";
            DepositEntry.Description := StrSubstNo('Return of deposit from external agency for contract %1', Contract."No.");
            DepositEntry."Posting Date" := WorkDate();
            DepositEntry."Document No." := DocNo;
            DepositEntry.Amount := -Balance;
            DepositEntry.Holder := DepositEntry.Holder::"External Agency";
            DepositEntry."G/L Account No." := Setup."External Agency G/L Account";
            DepositEntry."Running Balance" := 0;
            DepositEntry.Insert(true);
        end;

        DepositEntry.Init();
        DepositEntry."Contract No." := Contract."No.";
        DepositEntry."Customer No." := Contract."Tenant Customer No.";
        DepositEntry."Project No." := Contract."Project No.";
        DepositEntry."Entry Type" := DepositEntry."Entry Type"::Refund;
        DepositEntry.Description := StrSubstNo('Refund of deposit balance to tenant of contract %1', Contract."No.");
        DepositEntry."Posting Date" := WorkDate();
        DepositEntry."Document No." := DocNo;
        DepositEntry.Amount := -Balance;
        DepositEntry.Holder := Contract."Deposit Holder";
        DepositEntry."G/L Account No." := ResolveDepositAccount(Contract);
        DepositEntry."Running Balance" := 0;
        DepositEntry.Insert(true);
    end;

    procedure RecordDeduction(ContractNo: Code[20]; Amount: Decimal; Description: Text)
    var
        Contract: Record "BSB Lease Contract";
        DepositEntry: Record "BSB Deposit Entry";
        Balance: Decimal;
    begin
        if not Contract.Get(ContractNo) then
            Error('Contract %1 not found.', ContractNo);
        if Amount <= 0 then
            Error('Deduction amount must be positive.');
        Balance := CalcRunningBalance(ContractNo);
        if Amount > Balance then
            Error('Deduction amount (%1) exceeds available deposit balance (%2).', Amount, Balance);

        DepositEntry.Init();
        DepositEntry."Contract No." := ContractNo;
        DepositEntry."Customer No." := Contract."Tenant Customer No.";
        DepositEntry."Project No." := Contract."Project No.";
        DepositEntry."Entry Type" := DepositEntry."Entry Type"::"Settlement Deduction";
        DepositEntry.Description := CopyStr(Description, 1, MaxStrLen(DepositEntry.Description));
        DepositEntry."Posting Date" := WorkDate();
        DepositEntry."Document No." := CopyStr('DEP-DED-' + ContractNo, 1, 20);
        DepositEntry.Amount := -Amount;
        DepositEntry.Holder := Contract."Deposit Holder";
        DepositEntry."G/L Account No." := ResolveDepositAccount(Contract);
        DepositEntry."Running Balance" := Balance - Amount;
        DepositEntry.Insert(true);
    end;

    procedure CalcRunningBalance(ContractNo: Code[20]): Decimal
    var
        DepositEntry: Record "BSB Deposit Entry";
        Total: Decimal;
    begin
        DepositEntry.SetRange("Contract No.", ContractNo);
        DepositEntry.SetRange(Reversed, false);
        DepositEntry.SetFilter("Entry Type", '<>%1&<>%2',
            DepositEntry."Entry Type"::"Transfer to Agency",
            DepositEntry."Entry Type"::"Return from Agency");
        if DepositEntry.FindSet() then
            repeat
                Total += DepositEntry.Amount;
            until DepositEntry.Next() = 0;
        exit(Total);
    end;

    local procedure ResolveDepositAccount(Contract: Record "BSB Lease Contract"): Code[20]
    var
        Project: Record "BSB Real Estate Project";
        Setup: Record "BSB Real Estate Setup";
    begin
        if Project.Get(Contract."Project No.") then
            if Project."Default Deposit G/L Account" <> '' then
                exit(Project."Default Deposit G/L Account");
        Setup.GetSetup();
        exit(Setup."Deposit G/L Account");
    end;
}
