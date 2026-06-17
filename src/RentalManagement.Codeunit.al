codeunit 50000 "RE Rental Management"
{
    var
        OverlapErr: Label 'Property %1 is already allocated to contract %2 for an overlapping period (%3..%4).', Comment = '%1=property, %2=contract, %3=start, %4=end';
        DoubleBillingErr: Label 'A billing schedule already exists for contract %1, concept %2, period %3..%4.', Comment = '%1=contract, %2=concept, %3=start, %4=end';
        SubSubleaseErr: Label 'Sub-subleasing is not allowed. The parent contract is itself a sublease.';
        SubleasePeriodErr: Label 'The sublease period must fall within the primary contract period.';
        SubleaseAreaErr: Label 'Sublease area (%1) exceeds the available sublease area (%2) for property %3.', Comment = '%1=requested, %2=available, %3=property';
        DepositSettlementErr: Label 'Settlement (%1) plus refund (%2) must equal the contract deposit amount (%3).', Comment = '%1=settlement, %2=refund, %3=deposit';
        NewRentInvalidErr: Label 'New rent must be greater than zero.';
        RenewalEndErr: Label 'The renewal end date must be later than the current end date.';
        ProjectBlockedErr: Label 'Project %1 is blocked.', Comment = '%1=project';
        TenantBlockedErr: Label 'Tenant %1 is blocked.', Comment = '%1=tenant';
        LegalReviewErr: Label 'Legal review must be completed before activation.';
        MandatoryClausesErr: Label 'Mandatory contract clauses must be confirmed on template %1.', Comment = '%1=template';
        TemplateInactiveErr: Label 'Contract template %1 is not active.', Comment = '%1=template';
        MissingGLAccountErr: Label 'A G/L account must be configured on project %1 for billing concept %2.', Comment = '%1=project, %2=concept';
        DocumentNoRequiredErr: Label 'Document No. is required for deposit accounting entries.';
        DepositAlreadyPostedErr: Label 'Initial deposit has already been posted for contract %1.', Comment = '%1=contract';
        DepositNotPostedErr: Label 'The initial deposit must be posted before transferring to the external agency.';
        TransferAlreadyDoneErr: Label 'Deposit has already been transferred to the external agency for contract %1.', Comment = '%1=contract';
        EntryRightAlreadyPostedErr: Label 'The entry-right fee has already been billed for contract %1.', Comment = '%1=contract';
        NoBillablePeriodErr: Label 'There is no billable period between %1 and %2 for contract %3.', Comment = '%1=from, %2=to, %3=contract';
        PropertyUnavailableErr: Label 'Property %1 is not available for allocation (current status: %2).', Comment = '%1=property, %2=status';
        ParentNotActiveErr: Label 'The parent contract %1 must be Active to create a sublease.', Comment = '%1=parent';

    // ============================================================
    // Contract Lifecycle
    // ============================================================

    procedure ActivateContract(var Contract: Record "RE Contract")
    var
        Property: Record "RE Property";
    begin
        ValidateContractReady(Contract);
        PreventOverlappingAllocation(Contract);
        ValidateSublease(Contract);

        Contract.Status := Contract.Status::Active;
        Contract.Signed := true;
        if Contract."Signed Date" = 0D then
            Contract."Signed Date" := WorkDate();
        Contract.Modify(true);

        if Property.Get(Contract."Primary Property No.") then begin
            Property."Rental Status" := Property."Rental Status"::Leased;
            Property."Last Status Change" := CurrentDateTime();
            Property.Modify(true);
        end;

        LogAudit(Database::"RE Contract", Contract."No.", 'Activate', '', '', Format(Contract.Status), 'Contract activated');
    end;

    procedure StartCancellation(var Contract: Record "RE Contract"; TerminationDate: Date; Reason: Text[100]; TerminationType: Enum "RE Termination Type")
    begin
        Contract.TestField(Status, Contract.Status::Active);
        if TerminationDate = 0D then
            TerminationDate := WorkDate();
        Contract."Termination Date" := TerminationDate;
        Contract."Termination Reason" := Reason;
        Contract."Termination Type" := TerminationType;
        Contract.Status := Contract.Status::"Cancellation Process";
        Contract.Modify(true);
        LogAudit(Database::"RE Contract", Contract."No.", 'StartCancellation', 'Status', Format(Contract.Status::Active), Format(Contract.Status), Reason);
    end;

    procedure CloseContract(var Contract: Record "RE Contract")
    var
        Property: Record "RE Property";
        ContractProperty: Record "RE Contract Property";
    begin
        Contract.TestField(Status, Contract.Status::"Cancellation Process");
        Contract.Status := Contract.Status::Closed;
        Contract.Modify(true);

        if Property.Get(Contract."Primary Property No.") then
            ReleaseProperty(Property);

        ContractProperty.SetRange("Contract No.", Contract."No.");
        ContractProperty.SetRange(Released, false);
        if ContractProperty.FindSet(true) then
            repeat
                if Property.Get(ContractProperty."Property No.") then
                    ReleaseProperty(Property);
                ContractProperty.Released := true;
                ContractProperty.Modify(true);
            until ContractProperty.Next() = 0;

        LogAudit(Database::"RE Contract", Contract."No.", 'Close', 'Status', Format(Contract.Status::"Cancellation Process"), Format(Contract.Status), '');
    end;

    local procedure ReleaseProperty(var Property: Record "RE Property")
    begin
        if Property."Rental Status" in [Property."Rental Status"::Maintenance, Property."Rental Status"::Blocked] then
            exit;
        Property."Rental Status" := Property."Rental Status"::Available;
        Property."Last Status Change" := CurrentDateTime();
        Property.Modify(true);
    end;

    procedure RenewContract(var Contract: Record "RE Contract"; NewEndDate: Date)
    var
        OldEndDate: Date;
    begin
        Contract.TestField(Status, Contract.Status::Active);
        if NewEndDate <= Contract."End Date" then
            Error(RenewalEndErr);

        OldEndDate := Contract."End Date";
        Contract."End Date" := NewEndDate;
        Contract."Renewal Count" += 1;
        Contract.Modify(true);
        LogAudit(Database::"RE Contract", Contract."No.", 'Renewal', Contract.FieldCaption("End Date"), Format(OldEndDate), Format(NewEndDate), '');
    end;

    // ============================================================
    // Property batch operations
    // ============================================================

    procedure MassSetPropertyStatus(ProjectNo: Code[20]; NewStatus: Enum "RE Rental Status")
    var
        Property: Record "RE Property";
        OldStatus: Enum "RE Rental Status";
        Counter: Integer;
    begin
        Property.SetRange("Project No.", ProjectNo);
        if Property.FindSet(true) then
            repeat
                OldStatus := Property."Rental Status";
                Property."Rental Status" := NewStatus;
                Property."Last Status Change" := CurrentDateTime();
                Property.Modify(true);
                LogAudit(Database::"RE Property", Property."No.", 'Mass Status Update', Property.FieldCaption("Rental Status"), Format(OldStatus), Format(NewStatus), '');
                Counter += 1;
            until Property.Next() = 0;
        Message('%1 properties updated.', Counter);
    end;

    procedure AssertPropertyAvailableForContract(PropertyNo: Code[20]): Boolean
    var
        Property: Record "RE Property";
    begin
        if not Property.Get(PropertyNo) then
            exit(false);
        exit(Property."Rental Status" in [Property."Rental Status"::Available, Property."Rental Status"::Reserved]);
    end;

    // ============================================================
    // Billing
    // ============================================================

    procedure GenerateBillingSchedule(var Contract: Record "RE Contract"; FromDate: Date; ToDate: Date; Simulate: Boolean)
    var
        Billing: Record "RE Billing Schedule";
        PeriodStart: Date;
        PeriodEnd: Date;
        NextLineNo: Integer;
        Frequency: Integer;
        FrequencyTok: Text;
        FromCount: Integer;
    begin
        Contract.TestField(Status, Contract.Status::Active);
        Contract.TestField("Base Rent");

        if FromDate = 0D then
            FromDate := Contract."Start Date";
        if ToDate = 0D then
            ToDate := Contract."End Date";
        if ToDate < FromDate then
            Error(NoBillablePeriodErr, FromDate, ToDate, Contract."No.");

        Frequency := Contract."Billing Frequency Months";
        if Frequency <= 0 then
            Frequency := 1;
        FrequencyTok := StrSubstNo('<%1M>', Frequency);

        Billing.SetRange("Contract No.", Contract."No.");
        if Billing.FindLast() then
            NextLineNo := Billing."Line No." + 10000
        else
            NextLineNo := 10000;

        PeriodStart := CalcDate('<-CM>', FromDate);
        while PeriodStart <= ToDate do begin
            if Frequency = 1 then
                PeriodEnd := CalcDate('<CM>', PeriodStart)
            else
                PeriodEnd := CalcDate('<CM>', CalcDate(StrSubstNo('<%1M>', Frequency - 1), PeriodStart));
            if PeriodEnd > Contract."End Date" then
                PeriodEnd := Contract."End Date";
            if PeriodEnd > ToDate then
                PeriodEnd := ToDate;

            if not BillingExists(Contract."No.", "RE Billing Concept Type"::Rent, PeriodStart, PeriodEnd) then begin
                InsertScheduleLine(Contract, NextLineNo, PeriodStart, PeriodEnd, "RE Billing Concept Type"::Rent, StrSubstNo('Rent %1..%2', PeriodStart, PeriodEnd), Contract."Base Rent" * Frequency, Simulate);
                NextLineNo += 10000;
                FromCount += 1;
            end;

            PeriodStart := CalcDate(FrequencyTok, PeriodStart);
        end;

        if FromCount = 0 then
            Message('No new billing lines were generated for contract %1.', Contract."No.")
        else
            Message('%1 billing lines generated for contract %2.', FromCount, Contract."No.");
    end;

    procedure GenerateOneTimeBilling(var Contract: Record "RE Contract"; ConceptType: Enum "RE Billing Concept Type"; ChargeDate: Date; Description: Text[100]; Amount: Decimal)
    begin
        Contract.TestField(Status, Contract.Status::Active);
        if ChargeDate = 0D then
            ChargeDate := WorkDate();
        if BillingExists(Contract."No.", ConceptType, ChargeDate, ChargeDate) then
            Error(DoubleBillingErr, Contract."No.", ConceptType, ChargeDate, ChargeDate);
        InsertOneTimeBilling(Contract, ConceptType, ChargeDate, ChargeDate, Description, Amount);
    end;

    procedure PostEntryRightFee(var Contract: Record "RE Contract"; DocumentDate: Date)
    begin
        Contract.TestField(Status, Contract.Status::Active);
        if Contract."Entry Right Posted" then
            Error(EntryRightAlreadyPostedErr, Contract."No.");
        if Contract."Entry Right Fee" <= 0 then
            exit;
        if DocumentDate = 0D then
            DocumentDate := WorkDate();

        InsertOneTimeBilling(Contract, "RE Billing Concept Type"::Fee, DocumentDate, DocumentDate, 'Entry rights fee', Contract."Entry Right Fee");
        Contract."Entry Right Posted" := true;
        Contract.Modify(true);
        LogAudit(Database::"RE Contract", Contract."No.", 'EntryRightPosted', '', '', Format(Contract."Entry Right Fee"), '');
    end;

    procedure SimulateBatch(ProjectNo: Code[20]; FromDate: Date; ToDate: Date)
    var
        Contract: Record "RE Contract";
    begin
        Contract.SetRange("Project No.", ProjectNo);
        Contract.SetRange(Status, Contract.Status::Active);
        if Contract.FindSet(true) then
            repeat
                GenerateBillingSchedule(Contract, FromDate, ToDate, true);
            until Contract.Next() = 0;
    end;

    procedure CreateBatchInvoices(ProjectNo: Code[20]; UpToDate: Date)
    var
        Billing: Record "RE Billing Schedule";
        Contract: Record "RE Contract";
        Created: Integer;
    begin
        Contract.SetRange("Project No.", ProjectNo);
        Contract.SetRange(Status, Contract.Status::Active);
        if Contract.FindSet() then
            repeat
                Billing.SetRange("Contract No.", Contract."No.");
                Billing.SetRange(Status, Billing.Status::Open);
                Billing.SetFilter("Billing Date", '..%1', UpToDate);
                if Billing.FindSet(true) then
                    repeat
                        CreateSalesInvoiceForBilling(Billing);
                        Created += 1;
                    until Billing.Next() = 0;
            until Contract.Next() = 0;
        Message('%1 invoices created.', Created);
    end;

    procedure CreateSalesInvoiceForBilling(var Billing: Record "RE Billing Schedule")
    var
        Contract: Record "RE Contract";
        Project: Record "RE Project";
        Tenant: Record "RE Tenant";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GLAccountNo: Code[20];
    begin
        Billing.TestField(Status, Billing.Status::Open);
        Contract.Get(Billing."Contract No.");
        Contract.TestField(Status, Contract.Status::Active);
        Tenant.Get(Contract."Primary Tenant No.");
        Tenant.TestField("Customer No.");
        Project.Get(Contract."Project No.");

        GLAccountNo := ResolveGLAccount(Project, Billing."Concept Type");
        if GLAccountNo = '' then
            Error(MissingGLAccountErr, Project."No.", Billing."Concept Type");

        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Tenant."Customer No.");
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Validate("Document Date", Billing."Billing Date");
        if Contract."Payment Terms Code" <> '' then
            SalesHeader.Validate("Payment Terms Code", Contract."Payment Terms Code");
        if Contract."Payment Method Code" <> '' then
            SalesHeader.Validate("Payment Method Code", Contract."Payment Method Code");
        SalesHeader.Modify(true);

        SalesLine.Init();
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine."Line No." := 10000;
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", GLAccountNo);
        SalesLine.Validate(Description, Billing.Description);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", Billing.Amount);
        SalesLine.Insert(true);

        Billing.Status := Billing.Status::Invoiced;
        Billing."Sales Invoice No." := SalesHeader."No.";
        Billing.Simulated := false;
        Billing.Modify(true);

        if (Contract."Last Billing Date" = 0D) or (Billing."Period End" > Contract."Last Billing Date") then begin
            Contract."Last Billing Date" := Billing."Period End";
            Contract.Modify(true);
        end;

        LogAudit(Database::"RE Billing Schedule", Billing."Contract No.", 'Invoice Created', Billing.FieldCaption("Sales Invoice No."), '', SalesHeader."No.", Format(Billing."Concept Type"));
    end;

    local procedure ResolveGLAccount(Project: Record "RE Project"; ConceptType: Enum "RE Billing Concept Type"): Code[20]
    begin
        case ConceptType of
            ConceptType::Rent:
                exit(Project."Rent G/L Account No.");
            ConceptType::TaxIBI:
                exit(Project."Tax G/L Account No.");
            ConceptType::Deposit, ConceptType::Settlement:
                exit(Project."Deposit G/L Account No.");
            ConceptType::Fee, ConceptType::OneTime:
                if Project."Fee G/L Account No." <> '' then
                    exit(Project."Fee G/L Account No.")
                else
                    exit(Project."Rent G/L Account No.");
            else
                exit(Project."Rent G/L Account No.");
        end;
    end;

    // ============================================================
    // Deposit handling
    // ============================================================

    procedure PostInitialDeposit(var Contract: Record "RE Contract"; DocumentNo: Code[20])
    var
        DepositEntry: Record "RE Deposit Entry";
        Project: Record "RE Project";
    begin
        Contract.TestField(Status, Contract.Status::Active);
        Contract.TestField("Deposit Amount");
        if DocumentNo = '' then
            Error(DocumentNoRequiredErr);

        DepositEntry.SetRange("Contract No.", Contract."No.");
        DepositEntry.SetRange("Entry Type", DepositEntry."Entry Type"::Initial);
        DepositEntry.SetRange(Reversed, false);
        if not DepositEntry.IsEmpty() then
            Error(DepositAlreadyPostedErr, Contract."No.");

        Project.Get(Contract."Project No.");
        if Project."Deposit G/L Account No." = '' then
            Error(MissingGLAccountErr, Project."No.", "RE Billing Concept Type"::Deposit);

        CreateDepositEntry(Contract, "RE Deposit Entry Type"::Initial, Contract."Deposit Amount", DocumentNo, Project."Deposit G/L Account No.", 'Initial deposit');
    end;

    procedure TransferDepositToAgency(var Contract: Record "RE Contract"; DocumentNo: Code[20])
    var
        DepositEntry: Record "RE Deposit Entry";
        Project: Record "RE Project";
    begin
        Contract.TestField("Deposit Holding Type", Contract."Deposit Holding Type"::ExternalAgency);
        if DocumentNo = '' then
            Error(DocumentNoRequiredErr);

        DepositEntry.SetRange("Contract No.", Contract."No.");
        DepositEntry.SetRange("Entry Type", DepositEntry."Entry Type"::Initial);
        DepositEntry.SetRange(Reversed, false);
        if DepositEntry.IsEmpty() then
            Error(DepositNotPostedErr);

        DepositEntry.SetRange("Entry Type", DepositEntry."Entry Type"::Transfer);
        if not DepositEntry.IsEmpty() then
            Error(TransferAlreadyDoneErr, Contract."No.");

        Project.Get(Contract."Project No.");
        CreateDepositEntry(Contract, "RE Deposit Entry Type"::Transfer, -Contract."Deposit Amount", DocumentNo, Project."Deposit G/L Account No.", 'Transfer to agency');
    end;

    procedure SettleDeposit(var Contract: Record "RE Contract"; SettlementAmount: Decimal; RefundAmount: Decimal; DocumentNo: Code[20])
    var
        Project: Record "RE Project";
    begin
        Contract.TestField(Status, Contract.Status::"Cancellation Process");
        if DocumentNo = '' then
            Error(DocumentNoRequiredErr);
        if Round(SettlementAmount + RefundAmount, 0.01) <> Round(Contract."Deposit Amount", 0.01) then
            Error(DepositSettlementErr, SettlementAmount, RefundAmount, Contract."Deposit Amount");
        if (SettlementAmount < 0) or (RefundAmount < 0) then
            Error(DepositSettlementErr, SettlementAmount, RefundAmount, Contract."Deposit Amount");

        Project.Get(Contract."Project No.");
        if SettlementAmount > 0 then
            CreateDepositEntry(Contract, "RE Deposit Entry Type"::Settlement, -SettlementAmount, DocumentNo, Project."Deposit G/L Account No.", 'Deposit settlement');
        if RefundAmount > 0 then
            CreateDepositEntry(Contract, "RE Deposit Entry Type"::Refund, -RefundAmount, DocumentNo, Project."Deposit G/L Account No.", 'Deposit refund');
    end;

    procedure GetDepositBalance(ContractNo: Code[20]): Decimal
    var
        DepositEntry: Record "RE Deposit Entry";
        Balance: Decimal;
    begin
        DepositEntry.SetRange("Contract No.", ContractNo);
        DepositEntry.SetRange(Reversed, false);
        if DepositEntry.FindSet() then
            repeat
                if DepositEntry."Entry Type" in
                    [DepositEntry."Entry Type"::Initial,
                     DepositEntry."Entry Type"::Settlement,
                     DepositEntry."Entry Type"::Refund]
                then
                    Balance += DepositEntry.Amount;
            until DepositEntry.Next() = 0;
        exit(Balance);
    end;

    // ============================================================
    // Rent updates
    // ============================================================

    procedure ApplyRentUpdate(var Contract: Record "RE Contract"; NewRent: Decimal; EffectiveDate: Date; Method: Text[50]; IndexCode: Code[20])
    var
        RentHistory: Record "RE Rent History";
        OldRent: Decimal;
    begin
        Contract.TestField(Status, Contract.Status::Active);
        if NewRent <= 0 then
            Error(NewRentInvalidErr);
        if EffectiveDate = 0D then
            EffectiveDate := WorkDate();
        OldRent := Contract."Base Rent";

        RentHistory.Init();
        RentHistory."Contract No." := Contract."No.";
        RentHistory."Effective Date" := EffectiveDate;
        RentHistory."Old Rent" := OldRent;
        RentHistory."New Rent" := NewRent;
        RentHistory."Update Method" := Method;
        RentHistory."Index Code" := IndexCode;
        RentHistory."User ID" := CopyStr(UserId(), 1, MaxStrLen(RentHistory."User ID"));
        RentHistory.Insert(true);

        Contract."Base Rent" := NewRent;
        Contract."Last Rent Update Date" := EffectiveDate;
        Contract.Modify(true);
        LogAudit(Database::"RE Contract", Contract."No.", 'Rent Update', Contract.FieldCaption("Base Rent"), Format(OldRent), Format(NewRent), Method);
    end;

    procedure ApplyRentIndexation(var Contract: Record "RE Contract"; IndexPercentage: Decimal; EffectiveDate: Date; IndexCode: Code[20])
    var
        NewRent: Decimal;
    begin
        if IndexPercentage = 0 then
            exit;
        NewRent := Round(Contract."Base Rent" * (1 + IndexPercentage / 100), 0.01);
        ApplyRentUpdate(Contract, NewRent, EffectiveDate, StrSubstNo('Index %1%%', IndexPercentage), IndexCode);
    end;

    // ============================================================
    // IBI / Tax recharge
    // ============================================================

    procedure UpdateIBIRecharge(var Contract: Record "RE Contract"; AnnualAmount: Decimal; EffectiveDate: Date)
    var
        Billing: Record "RE Billing Schedule";
        IBIEntry: Record "RE IBI Entry";
        CatchUpAmount: Decimal;
        TaxYear: Integer;
        AlreadyBilled: Decimal;
    begin
        Contract.TestField(Status, Contract.Status::Active);
        if EffectiveDate = 0D then
            EffectiveDate := WorkDate();
        TaxYear := Date2DMY(EffectiveDate, 3);

        Billing.SetRange("Contract No.", Contract."No.");
        Billing.SetRange("Concept Type", "RE Billing Concept Type"::TaxIBI);
        Billing.SetFilter(Status, '%1|%2', Billing.Status::Invoiced, Billing.Status::Open);
        Billing.SetFilter("Period Start", '%1..%2', DMY2Date(1, 1, TaxYear), DMY2Date(31, 12, TaxYear));
        if Billing.FindSet() then
            repeat
                AlreadyBilled += Billing.Amount;
            until Billing.Next() = 0;

        CatchUpAmount := AnnualAmount - AlreadyBilled;

        IBIEntry.Init();
        IBIEntry."Property No." := Contract."Primary Property No.";
        IBIEntry."Contract No." := Contract."No.";
        IBIEntry."Tax Year" := TaxYear;
        IBIEntry."Effective Date" := EffectiveDate;
        IBIEntry."Annual Amount" := AnnualAmount;
        IBIEntry."Already Billed Amount" := AlreadyBilled;
        IBIEntry."Catch-up Amount" := CatchUpAmount;
        IBIEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(IBIEntry."User ID"));
        IBIEntry.Insert(true);

        if CatchUpAmount > 0 then
            InsertOneTimeBilling(Contract, "RE Billing Concept Type"::TaxIBI, EffectiveDate, EffectiveDate, StrSubstNo('IBI catch-up %1', TaxYear), CatchUpAmount);

        LogAudit(Database::"RE Contract", Contract."No.", 'IBI Update', '', Format(AlreadyBilled), Format(AnnualAmount), StrSubstNo('Year %1, catch-up %2', TaxYear, CatchUpAmount));
    end;

    // ============================================================
    // Sublease handling
    // ============================================================

    procedure SubleasedAreaUsed(ParentContractNo: Code[20]): Decimal
    var
        SubContract: Record "RE Contract";
        Used: Decimal;
    begin
        SubContract.SetRange("Parent Contract No.", ParentContractNo);
        SubContract.SetRange("Is Sublease", true);
        SubContract.SetFilter(Status, '%1|%2|%3', SubContract.Status::Draft, SubContract.Status::Active, SubContract.Status::"Cancellation Process");
        if SubContract.FindSet() then
            repeat
                Used += SubContract."Sublease Area Sqm";
            until SubContract.Next() = 0;
        exit(Used);
    end;

    // ============================================================
    // Validation helpers
    // ============================================================

    local procedure ValidateContractReady(Contract: Record "RE Contract")
    var
        Project: Record "RE Project";
        Template: Record "RE Contract Template";
        Tenant: Record "RE Tenant";
        Property: Record "RE Property";
        Signatory: Record "RE Project Signatory";
    begin
        Contract.TestField("Project No.");
        Contract.TestField("Primary Property No.");
        Contract.TestField("Primary Tenant No.");
        Contract.TestField("Start Date");
        Contract.TestField("End Date");
        Contract.TestField("Base Rent");
        Contract.TestField("Contract Template Code");

        if Contract."End Date" < Contract."Start Date" then
            Error('The contract end date cannot be before the start date.');

        Project.Get(Contract."Project No.");
        if Project.Blocked then
            Error(ProjectBlockedErr, Project."No.");

        Template.Get(Contract."Contract Template Code");
        if not Template.Active then
            Error(TemplateInactiveErr, Template.Code);
        if Template."Requires Legal Review" and not Contract."Legal Review Completed" then
            Error(LegalReviewErr);
        if not Template."Mandatory Clauses Confirmed" then
            Error(MandatoryClausesErr, Template.Code);

        Tenant.Get(Contract."Primary Tenant No.");
        if Tenant.Blocked then
            Error(TenantBlockedErr, Tenant."No.");
        Tenant.TestField("Customer No.");

        Property.Get(Contract."Primary Property No.");
        if not Contract."Is Sublease" then
            if not (Property."Rental Status" in [Property."Rental Status"::Available, Property."Rental Status"::Reserved]) then
                Error(PropertyUnavailableErr, Property."No.", Property."Rental Status");

        Contract.TestField("Signatory 1 Code");
        Signatory.SetRange("Project No.", Contract."Project No.");
        Signatory.SetRange("Signatory Code", Contract."Signatory 1 Code");
        if Signatory.IsEmpty() then
            Error('Signatory 1 %1 is not registered on project %2.', Contract."Signatory 1 Code", Contract."Project No.");

        if Project."Require Two Signatories" then begin
            Contract.TestField("Signatory 2 Code");
            if Contract."Signatory 2 Code" = Contract."Signatory 1 Code" then
                Error('Signatory 1 and Signatory 2 must be different.');
            Signatory.SetRange("Signatory Code", Contract."Signatory 2 Code");
            if Signatory.IsEmpty() then
                Error('Signatory 2 %1 is not registered on project %2.', Contract."Signatory 2 Code", Contract."Project No.");
        end;
    end;

    local procedure PreventOverlappingAllocation(Contract: Record "RE Contract")
    var
        OtherContract: Record "RE Contract";
    begin
        if Contract."Is Sublease" then
            exit;

        OtherContract.SetRange("Primary Property No.", Contract."Primary Property No.");
        OtherContract.SetFilter("No.", '<>%1', Contract."No.");
        OtherContract.SetFilter(Status, '%1|%2', OtherContract.Status::Active, OtherContract.Status::"Cancellation Process");
        OtherContract.SetRange("Is Sublease", false);
        if OtherContract.FindSet() then
            repeat
                if DatesOverlap(Contract."Start Date", Contract."End Date", OtherContract."Start Date", OtherContract."End Date") then
                    Error(OverlapErr, Contract."Primary Property No.", OtherContract."No.", OtherContract."Start Date", OtherContract."End Date");
            until OtherContract.Next() = 0;
    end;

    local procedure ValidateSublease(Contract: Record "RE Contract")
    var
        ParentContract: Record "RE Contract";
        Property: Record "RE Property";
        UsedArea: Decimal;
        AvailableArea: Decimal;
    begin
        if not Contract."Is Sublease" then
            exit;

        Contract.TestField("Parent Contract No.");
        Contract.TestField("Sublease Area Sqm");
        ParentContract.Get(Contract."Parent Contract No.");

        if ParentContract."Is Sublease" then
            Error(SubSubleaseErr);
        if ParentContract.Status <> ParentContract.Status::Active then
            Error(ParentNotActiveErr, ParentContract."No.");
        if (Contract."Start Date" < ParentContract."Start Date") or (Contract."End Date" > ParentContract."End Date") then
            Error(SubleasePeriodErr);

        Property.Get(Contract."Primary Property No.");
        if Property."No." <> ParentContract."Primary Property No." then
            Error('Sublease must target the same property as the parent contract.');

        UsedArea := SubleasedAreaUsedExcluding(ParentContract."No.", Contract."No.");
        AvailableArea := Property."Available Sublease Area Sqm" - UsedArea;
        if Contract."Sublease Area Sqm" > AvailableArea then
            Error(SubleaseAreaErr, Contract."Sublease Area Sqm", AvailableArea, Property."No.");
    end;

    local procedure SubleasedAreaUsedExcluding(ParentContractNo: Code[20]; ExcludeContractNo: Code[20]): Decimal
    var
        SubContract: Record "RE Contract";
        Used: Decimal;
    begin
        SubContract.SetRange("Parent Contract No.", ParentContractNo);
        SubContract.SetRange("Is Sublease", true);
        SubContract.SetFilter("No.", '<>%1', ExcludeContractNo);
        SubContract.SetFilter(Status, '%1|%2', SubContract.Status::Active, SubContract.Status::"Cancellation Process");
        if SubContract.FindSet() then
            repeat
                Used += SubContract."Sublease Area Sqm";
            until SubContract.Next() = 0;
        exit(Used);
    end;

    local procedure DatesOverlap(StartDate: Date; EndDate: Date; OtherStartDate: Date; OtherEndDate: Date): Boolean
    begin
        exit((StartDate <= OtherEndDate) and (EndDate >= OtherStartDate));
    end;

    local procedure BillingExists(ContractNo: Code[20]; ConceptType: Enum "RE Billing Concept Type"; PeriodStart: Date; PeriodEnd: Date): Boolean
    var
        Billing: Record "RE Billing Schedule";
    begin
        Billing.SetRange("Contract No.", ContractNo);
        Billing.SetRange("Concept Type", ConceptType);
        Billing.SetRange("Period Start", PeriodStart);
        Billing.SetRange("Period End", PeriodEnd);
        Billing.SetFilter(Status, '<>%1', Billing.Status::Cancelled);
        exit(not Billing.IsEmpty());
    end;

    local procedure InsertScheduleLine(Contract: Record "RE Contract"; LineNo: Integer; PeriodStart: Date; PeriodEnd: Date; ConceptType: Enum "RE Billing Concept Type"; Description: Text[100]; Amount: Decimal; Simulate: Boolean)
    var
        Billing: Record "RE Billing Schedule";
    begin
        Billing.Init();
        Billing."Contract No." := Contract."No.";
        Billing."Line No." := LineNo;
        Billing."Billing Date" := PeriodStart;
        Billing."Period Start" := PeriodStart;
        Billing."Period End" := PeriodEnd;
        Billing."Concept Type" := ConceptType;
        Billing.Description := Description;
        Billing.Amount := Amount;
        Billing.Simulated := Simulate;
        if Simulate then
            Billing.Status := Billing.Status::Simulated
        else
            Billing.Status := Billing.Status::Open;
        Billing.Insert(true);
    end;

    local procedure InsertOneTimeBilling(Contract: Record "RE Contract"; ConceptType: Enum "RE Billing Concept Type"; PeriodStart: Date; PeriodEnd: Date; Description: Text[100]; Amount: Decimal)
    var
        Billing: Record "RE Billing Schedule";
        NextLineNo: Integer;
    begin
        if BillingExists(Contract."No.", ConceptType, PeriodStart, PeriodEnd) then
            Error(DoubleBillingErr, Contract."No.", ConceptType, PeriodStart, PeriodEnd);

        Billing.SetRange("Contract No.", Contract."No.");
        if Billing.FindLast() then
            NextLineNo := Billing."Line No." + 10000
        else
            NextLineNo := 10000;

        InsertScheduleLine(Contract, NextLineNo, PeriodStart, PeriodEnd, ConceptType, Description, Amount, false);
    end;

    local procedure CreateDepositEntry(Contract: Record "RE Contract"; EntryType: Enum "RE Deposit Entry Type"; Amount: Decimal; DocumentNo: Code[20]; GLAccountNo: Code[20]; Descr: Text[100])
    var
        DepositEntry: Record "RE Deposit Entry";
    begin
        DepositEntry.Init();
        DepositEntry."Contract No." := Contract."No.";
        DepositEntry."Posting Date" := WorkDate();
        DepositEntry."Entry Type" := EntryType;
        DepositEntry.Amount := Amount;
        DepositEntry."External Agency" := Contract."Deposit Holding Type" = Contract."Deposit Holding Type"::ExternalAgency;
        DepositEntry."Document No." := DocumentNo;
        DepositEntry."G/L Account No." := GLAccountNo;
        DepositEntry.Description := Descr;
        DepositEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(DepositEntry."User ID"));
        DepositEntry.Insert(true);
        LogAudit(Database::"RE Deposit Entry", Contract."No.", Format(EntryType), DepositEntry.FieldCaption(Amount), '', Format(Amount), DocumentNo);
    end;

    procedure LogAudit(TableNo: Integer; RecordNo: Code[20]; ActionText: Text[50]; FieldName: Text[50]; OldValue: Text; NewValue: Text; CommentText: Text[250])
    var
        AuditEntry: Record "RE Audit Entry";
    begin
        AuditEntry.Init();
        AuditEntry."Table No." := TableNo;
        AuditEntry."Record No." := RecordNo;
        AuditEntry.Action := ActionText;
        AuditEntry."Field Name" := FieldName;
        AuditEntry."Old Value" := CopyStr(OldValue, 1, MaxStrLen(AuditEntry."Old Value"));
        AuditEntry."New Value" := CopyStr(NewValue, 1, MaxStrLen(AuditEntry."New Value"));
        AuditEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(AuditEntry."User ID"));
        AuditEntry."Created At" := CurrentDateTime();
        AuditEntry.Comment := CommentText;
        AuditEntry.Insert(true);
    end;
}
