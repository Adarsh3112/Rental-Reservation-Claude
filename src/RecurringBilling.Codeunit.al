codeunit 50102 "BSB Recurring Billing"
{
    procedure EnsureInstallmentsGenerated(var Contract: Record "BSB Lease Contract")
    var
        Installment: Record "BSB Lease Installment";
    begin
        Installment.SetRange("Contract No.", Contract."No.");
        if Installment.IsEmpty() then
            GenerateInstallments(Contract, false);
    end;

    procedure GenerateInstallments(var Contract: Record "BSB Lease Contract"; Regenerate: Boolean)
    var
        BillingLine: Record "BSB Lease Contract Billing";
        Installment: Record "BSB Lease Installment";
        PeriodStart: Date;
        PeriodEnd: Date;
        NextInstallmentNo: Integer;
        TenantNo: Code[20];
        BillingEnd: Date;
        BaseConceptLineCreated: Boolean;
    begin
        Contract.TestField(Status);
        Contract.TestField("Start Date");
        Contract.TestField("End Date");
        Contract.TestField("Billing Frequency");
        if Contract."Billing Frequency" = Contract."Billing Frequency"::"One-Time" then
            Error('Use one-time concepts via billing concept lines rather than the header billing frequency.');

        if Regenerate then begin
            Installment.SetRange("Contract No.", Contract."No.");
            Installment.SetRange(Status, Installment.Status::Open);
            Installment.DeleteAll();
        end;

        TenantNo := Contract."Tenant Customer No.";
        NextInstallmentNo := GetNextInstallmentNo(Contract."No.");
        BaseConceptLineCreated := EnsureBaseRentBillingLine(Contract);

        BillingLine.SetRange("Contract No.", Contract."No.");
        BillingLine.SetRange(Active, true);
        if BillingLine.FindSet() then
            repeat
                if (BillingLine."Concept Type" = BillingLine."Concept Type"::"Base Rent") and BaseConceptLineCreated then begin
                    BillingLine."Billing Frequency" := Contract."Billing Frequency";
                    BillingLine.Amount := Contract."Base Rent";
                    BillingLine.Modify();
                end;

                if BillingLine."Billing Frequency" = BillingLine."Billing Frequency"::"One-Time" then begin
                    if not BillingLine."One-Time Already Charged" then begin
                        CreateInstallment(Contract, BillingLine, Contract."Start Date", Contract."Start Date",
                                          BillingLine.Amount, TenantNo, NextInstallmentNo);
                        NextInstallmentNo += 1;
                        BillingLine."One-Time Already Charged" := true;
                        BillingLine.Modify();
                    end;
                end else begin
                    PeriodStart := GetEffectiveStart(Contract, BillingLine);
                    BillingEnd := GetEffectiveEnd(Contract, BillingLine);
                    while PeriodStart <= BillingEnd do begin
                        PeriodEnd := CalcPeriodEnd(PeriodStart, BillingLine."Billing Frequency", BillingEnd);
                        if not ExistsInstallment(Contract."No.", BillingLine."Line No.", PeriodStart) then begin
                            CreateInstallment(Contract, BillingLine, PeriodStart, PeriodEnd,
                                              CalcPeriodAmount(BillingLine, PeriodStart, PeriodEnd),
                                              TenantNo, NextInstallmentNo);
                            NextInstallmentNo += 1;
                        end;
                        PeriodStart := CalcNextPeriodStart(PeriodStart, BillingLine."Billing Frequency");
                    end;
                end;
            until BillingLine.Next() = 0;
    end;

    local procedure GetNextInstallmentNo(ContractNo: Code[20]): Integer
    var
        Installment: Record "BSB Lease Installment";
    begin
        Installment.SetRange("Contract No.", ContractNo);
        if Installment.FindLast() then
            exit(Installment."Installment No." + 1);
        exit(1);
    end;

    local procedure EnsureBaseRentBillingLine(Contract: Record "BSB Lease Contract"): Boolean
    var
        BillingLine: Record "BSB Lease Contract Billing";
        LastLine: Record "BSB Lease Contract Billing";
        NextLineNo: Integer;
        Created: Boolean;
    begin
        BillingLine.SetRange("Contract No.", Contract."No.");
        BillingLine.SetRange("Concept Type", BillingLine."Concept Type"::"Base Rent");
        if not BillingLine.IsEmpty() then
            exit(false);
        LastLine.SetRange("Contract No.", Contract."No.");
        if LastLine.FindLast() then
            NextLineNo := LastLine."Line No." + 10000
        else
            NextLineNo := 10000;
        BillingLine.Init();
        BillingLine."Contract No." := Contract."No.";
        BillingLine."Line No." := NextLineNo;
        BillingLine."Concept Type" := BillingLine."Concept Type"::"Base Rent";
        BillingLine.Description := 'Base Rent';
        BillingLine.Amount := Contract."Base Rent";
        BillingLine."Billing Frequency" := Contract."Billing Frequency";
        BillingLine."Start Date" := Contract."Start Date";
        BillingLine."End Date" := Contract."End Date";
        BillingLine.Active := true;
        BillingLine.Insert();
        Created := true;
        exit(Created);
    end;

    local procedure GetEffectiveStart(Contract: Record "BSB Lease Contract"; BillingLine: Record "BSB Lease Contract Billing"): Date
    begin
        if BillingLine."Start Date" <> 0D then
            exit(BillingLine."Start Date");
        exit(Contract."Start Date");
    end;

    local procedure GetEffectiveEnd(Contract: Record "BSB Lease Contract"; BillingLine: Record "BSB Lease Contract Billing"): Date
    begin
        if BillingLine."End Date" <> 0D then
            exit(BillingLine."End Date");
        exit(Contract."End Date");
    end;

    local procedure CalcPeriodEnd(PeriodStart: Date; Frequency: Enum "BSB Billing Frequency"; HardEnd: Date): Date
    var
        Candidate: Date;
    begin
        case Frequency of
            Frequency::Monthly:
                Candidate := CalcDate('<+1M-1D>', PeriodStart);
            Frequency::Quarterly:
                Candidate := CalcDate('<+3M-1D>', PeriodStart);
            Frequency::"Semi-Annual":
                Candidate := CalcDate('<+6M-1D>', PeriodStart);
            Frequency::Annual:
                Candidate := CalcDate('<+1Y-1D>', PeriodStart);
            else
                Candidate := PeriodStart;
        end;
        if Candidate > HardEnd then
            Candidate := HardEnd;
        exit(Candidate);
    end;

    local procedure CalcNextPeriodStart(PeriodStart: Date; Frequency: Enum "BSB Billing Frequency"): Date
    begin
        case Frequency of
            Frequency::Monthly:
                exit(CalcDate('<+1M>', PeriodStart));
            Frequency::Quarterly:
                exit(CalcDate('<+3M>', PeriodStart));
            Frequency::"Semi-Annual":
                exit(CalcDate('<+6M>', PeriodStart));
            Frequency::Annual:
                exit(CalcDate('<+1Y>', PeriodStart));
            else
                exit(CalcDate('<+9999Y>', PeriodStart));
        end;
    end;

    local procedure CalcPeriodAmount(BillingLine: Record "BSB Lease Contract Billing"; PeriodStart: Date; PeriodEnd: Date): Decimal
    begin
        exit(BillingLine.Amount);
    end;

    local procedure ExistsInstallment(ContractNo: Code[20]; BillingLineNo: Integer; PeriodStart: Date): Boolean
    var
        Installment: Record "BSB Lease Installment";
    begin
        Installment.SetRange("Contract No.", ContractNo);
        Installment.SetRange("Billing Line No.", BillingLineNo);
        Installment.SetRange("Period Start", PeriodStart);
        exit(not Installment.IsEmpty());
    end;

    local procedure CreateInstallment(Contract: Record "BSB Lease Contract"; BillingLine: Record "BSB Lease Contract Billing";
                                       PeriodStart: Date; PeriodEnd: Date; Amount: Decimal;
                                       TenantNo: Code[20]; var InstallmentNo: Integer)
    var
        Installment: Record "BSB Lease Installment";
        DueDate: Date;
    begin
        DueDate := CalcDueDate(Contract, PeriodStart);
        Installment.Init();
        Installment."Contract No." := Contract."No.";
        Installment."Installment No." := InstallmentNo;
        Installment."Billing Line No." := BillingLine."Line No.";
        Installment."Concept Type" := BillingLine."Concept Type";
        Installment.Description := BillingLine.Description;
        Installment."Period Start" := PeriodStart;
        Installment."Period End" := PeriodEnd;
        Installment."Due Date" := DueDate;
        Installment.Amount := Amount;
        Installment.Status := Installment.Status::Open;
        Installment."Customer No." := TenantNo;
        Installment.Insert();
    end;

    local procedure CalcDueDate(Contract: Record "BSB Lease Contract"; PeriodStart: Date): Date
    var
        BillingDay: Integer;
        Year: Integer;
        Month: Integer;
        DayInMonth: Integer;
    begin
        BillingDay := Contract."Billing Day of Month";
        if BillingDay <= 0 then
            exit(PeriodStart);
        Year := Date2DMY(PeriodStart, 3);
        Month := Date2DMY(PeriodStart, 2);
        DayInMonth := BillingDay;
        if DayInMonth > 28 then
            DayInMonth := 28;
        exit(DMY2Date(DayInMonth, Month, Year));
    end;

    procedure SimulateContractBilling(var Contract: Record "BSB Lease Contract")
    var
        Installment: Record "BSB Lease Installment";
        TotalAmount: Decimal;
        OpenCount: Integer;
    begin
        EnsureInstallmentsGenerated(Contract);
        Installment.SetRange("Contract No.", Contract."No.");
        Installment.SetRange(Status, Installment.Status::Open);
        OpenCount := Installment.Count();
        if Installment.FindSet() then
            repeat
                TotalAmount += Installment.Amount;
            until Installment.Next() = 0;
        Message('Simulation for contract %1:\Open installments: %2\Total amount: %3', Contract."No.", OpenCount, TotalAmount);
    end;

    procedure CreateInvoicesForContract(var Contract: Record "BSB Lease Contract")
    var
        Installment: Record "BSB Lease Installment";
        InvoiceCount: Integer;
        ContractsForInvoicing: Record "BSB Lease Contract";
    begin
        if Contract.Status <> Contract.Status::Active then
            Error('Only active contracts can be invoiced. Current status: %1.', Contract.Status);
        Installment.SetRange("Contract No.", Contract."No.");
        Installment.SetRange(Status, Installment.Status::Open);
        Installment.SetFilter("Due Date", '<=%1', WorkDate());
        InvoiceCount := PostInstallments(Installment);
        ContractsForInvoicing := Contract;
        UpdateContractBilledThrough(ContractsForInvoicing);
        Message('%1 installment(s) posted as invoices for contract %2.', InvoiceCount, Contract."No.");
    end;

    procedure CreateInvoicesBatch(ProjectNo: Code[20]; AsOfDate: Date)
    var
        Contract: Record "BSB Lease Contract";
        Installment: Record "BSB Lease Installment";
        TotalCount: Integer;
        ContractCount: Integer;
    begin
        Contract.SetRange(Status, Contract.Status::Active);
        if ProjectNo <> '' then
            Contract.SetRange("Project No.", ProjectNo);
        if Contract.FindSet() then
            repeat
                Installment.Reset();
                Installment.SetRange("Contract No.", Contract."No.");
                Installment.SetRange(Status, Installment.Status::Open);
                Installment.SetFilter("Due Date", '<=%1', AsOfDate);
                TotalCount += PostInstallments(Installment);
                UpdateContractBilledThrough(Contract);
                ContractCount += 1;
            until Contract.Next() = 0;
        Message('Batch billing complete. %1 installment(s) posted for %2 contract(s).', TotalCount, ContractCount);
    end;

    local procedure PostInstallments(var Installment: Record "BSB Lease Installment") Count: Integer
    var
        DocNo: Code[20];
    begin
        if Installment.FindSet() then
            repeat
                DocNo := GenerateInvoiceDocNo(Installment);
                Installment.Status := Installment.Status::Invoiced;
                Installment."Posted Invoice No." := DocNo;
                Installment."Posting Date" := WorkDate();
                Installment.Modify();
                Count += 1;
            until Installment.Next() = 0;
    end;

    local procedure GenerateInvoiceDocNo(Installment: Record "BSB Lease Installment"): Code[20]
    begin
        exit(CopyStr(Installment."Contract No." + '-' + Format(Installment."Installment No."), 1, 20));
    end;

    local procedure UpdateContractBilledThrough(var Contract: Record "BSB Lease Contract")
    var
        Installment: Record "BSB Lease Installment";
        ContractToUpdate: Record "BSB Lease Contract";
    begin
        Installment.SetRange("Contract No.", Contract."No.");
        Installment.SetRange(Status, Installment.Status::Invoiced);
        Installment.SetCurrentKey("Period End");
        Installment.Ascending(false);
        if Installment.FindFirst() then begin
            ContractToUpdate.Get(Contract."No.");
            ContractToUpdate."Last Billed Through" := Installment."Period End";
            Installment.Reset();
            Installment.SetRange("Contract No.", Contract."No.");
            Installment.SetRange(Status, Installment.Status::Open);
            Installment.SetCurrentKey("Due Date");
            if Installment.FindFirst() then
                ContractToUpdate."Next Billing Date" := Installment."Due Date"
            else
                ContractToUpdate."Next Billing Date" := 0D;
            ContractToUpdate.Modify();
        end;
    end;

    procedure CancelFutureOpenInstallments(ContractNo: Code[20]; FromDate: Date)
    var
        Installment: Record "BSB Lease Installment";
    begin
        Installment.SetRange("Contract No.", ContractNo);
        Installment.SetRange(Status, Installment.Status::Open);
        Installment.SetFilter("Period Start", '>=%1', FromDate);
        if Installment.FindSet() then
            repeat
                Installment.Status := Installment.Status::Cancelled;
                Installment.Modify();
            until Installment.Next() = 0;
    end;
}
