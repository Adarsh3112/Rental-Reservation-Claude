page 50105 "BSB Lease Contracts"
{
    Caption = 'Lease Contracts';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "BSB Lease Contract";
    CardPageId = "BSB Lease Contract Card";

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Project No."; Rec."Project No.") { ApplicationArea = All; }
                field("Tenant Customer No."; Rec."Tenant Customer No.") { ApplicationArea = All; }
                field("Tenant Name"; Rec."Tenant Name") { ApplicationArea = All; }
                field("Start Date"; Rec."Start Date") { ApplicationArea = All; }
                field("End Date"; Rec."End Date") { ApplicationArea = All; }
                field("Base Rent"; Rec."Base Rent") { ApplicationArea = All; }
                field("Billing Frequency"; Rec."Billing Frequency") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; StyleExpr = StatusStyle; }
                field("Is Sublease"; Rec."Is Sublease") { ApplicationArea = All; }
                field(Signed; Rec.Signed) { ApplicationArea = All; }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Draft:
                StatusStyle := 'Subordinate';
            Rec.Status::Active:
                StatusStyle := 'Favorable';
            Rec.Status::"In Cancellation":
                StatusStyle := 'Ambiguous';
            Rec.Status::Closed:
                StatusStyle := 'Unfavorable';
            else
                StatusStyle := 'Standard';
        end;
    end;

    var
        StatusStyle: Text;
}

page 50106 "BSB Lease Contract Card"
{
    Caption = 'Lease Contract Card';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "BSB Lease Contract";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Project No."; Rec."Project No.") { ApplicationArea = All; }
                field("Contract Template Code"; Rec."Contract Template Code") { ApplicationArea = All; }
                field("Tenant Customer No."; Rec."Tenant Customer No.") { ApplicationArea = All; }
                field("Tenant Name"; Rec."Tenant Name") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; Editable = false; }
                field(Signed; Rec.Signed) { ApplicationArea = All; Editable = false; }
            }
            group(Dates)
            {
                Caption = 'Dates';
                field("Start Date"; Rec."Start Date") { ApplicationArea = All; }
                field("End Date"; Rec."End Date") { ApplicationArea = All; }
                field("Original End Date"; Rec."Original End Date") { ApplicationArea = All; }
                field("Last Rent Update Date"; Rec."Last Rent Update Date") { ApplicationArea = All; }
                field("Next Billing Date"; Rec."Next Billing Date") { ApplicationArea = All; }
                field("Last Billed Through"; Rec."Last Billed Through") { ApplicationArea = All; }
                field("Termination Date"; Rec."Termination Date") { ApplicationArea = All; }
                field("Termination Reason"; Rec."Termination Reason") { ApplicationArea = All; }
            }
            group(Financial)
            {
                Caption = 'Financial';
                field("Base Rent"; Rec."Base Rent") { ApplicationArea = All; }
                field("Billing Frequency"; Rec."Billing Frequency") { ApplicationArea = All; }
                field("Billing Day of Month"; Rec."Billing Day of Month") { ApplicationArea = All; }
                field("Deposit Amount"; Rec."Deposit Amount") { ApplicationArea = All; }
                field("Deposit Holder"; Rec."Deposit Holder") { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field("Payment Terms Code"; Rec."Payment Terms Code") { ApplicationArea = All; }
                field("Payment Method Code"; Rec."Payment Method Code") { ApplicationArea = All; }
                field("Bank Account Code"; Rec."Bank Account Code") { ApplicationArea = All; }
                field("IBI Recharge Active"; Rec."IBI Recharge Active") { ApplicationArea = All; }
            }
            group(Sublease)
            {
                Caption = 'Sublease';
                field("Is Sublease"; Rec."Is Sublease") { ApplicationArea = All; }
                field("Parent Contract No."; Rec."Parent Contract No.") { ApplicationArea = All; }
            }
            part(Properties; "BSB Contract Properties Sub")
            {
                ApplicationArea = All;
                Caption = 'Properties';
                SubPageLink = "Contract No." = field("No.");
                UpdatePropagation = Both;
            }
            part(Tenants; "BSB Contract Tenants Sub")
            {
                ApplicationArea = All;
                Caption = 'Tenants';
                SubPageLink = "Contract No." = field("No.");
                UpdatePropagation = Both;
            }
            part(BillingConcepts; "BSB Contract Billing Sub")
            {
                ApplicationArea = All;
                Caption = 'Billing Concepts';
                SubPageLink = "Contract No." = field("No.");
                UpdatePropagation = Both;
            }
            part(Signatories; "BSB Contract Signatory Sub")
            {
                ApplicationArea = All;
                Caption = 'Signatories';
                SubPageLink = "Contract No." = field("No.");
                UpdatePropagation = Both;
            }
            group(Stats)
            {
                Caption = 'Statistics';
                field("Property Count"; Rec."Property Count") { ApplicationArea = All; }
                field("Tenant Count"; Rec."Tenant Count") { ApplicationArea = All; }
                field("Signed Signatory Count"; Rec."Signed Signatory Count") { ApplicationArea = All; }
                field("Required Signatory Count"; Rec."Required Signatory Count") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Lifecycle)
            {
                Caption = 'Lifecycle';
                action(SignContract)
                {
                    Caption = 'Sign Contract';
                    Image = Approval;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        Lifecycle: Codeunit "BSB Lease Lifecycle";
                    begin
                        Lifecycle.SignContract(Rec);
                    end;
                }
                action(ActivateContract)
                {
                    Caption = 'Activate';
                    Image = Start;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        Lifecycle: Codeunit "BSB Lease Lifecycle";
                    begin
                        Lifecycle.ActivateContract(Rec);
                    end;
                }
                action(StartTermination)
                {
                    Caption = 'Start Termination';
                    Image = Cancel;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        Lifecycle: Codeunit "BSB Lease Lifecycle";
                    begin
                        Lifecycle.StartTermination(Rec);
                    end;
                }
                action(CloseContract)
                {
                    Caption = 'Close Contract';
                    Image = Close;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        Termination: Codeunit "BSB Termination Mgmt";
                    begin
                        Termination.CloseContract(Rec);
                    end;
                }
            }
            group(Billing)
            {
                Caption = 'Billing';
                action(GenerateSchedule)
                {
                    Caption = 'Generate Installments';
                    Image = CalculateLines;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        Billing: Codeunit "BSB Recurring Billing";
                    begin
                        Billing.GenerateInstallments(Rec, false);
                    end;
                }
                action(SimulateBilling)
                {
                    Caption = 'Simulate Billing';
                    Image = Worksheet;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        Billing: Codeunit "BSB Recurring Billing";
                    begin
                        Billing.SimulateContractBilling(Rec);
                    end;
                }
                action(CreateInvoices)
                {
                    Caption = 'Create Invoices';
                    Image = Invoice;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        Billing: Codeunit "BSB Recurring Billing";
                    begin
                        Billing.CreateInvoicesForContract(Rec);
                    end;
                }
            }
            group(Deposit)
            {
                Caption = 'Deposit';
                action(PostInitialDeposit)
                {
                    Caption = 'Post Initial Deposit';
                    Image = BankAccount;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        DepositMgmt: Codeunit "BSB Deposit Mgmt";
                    begin
                        DepositMgmt.PostInitialDeposit(Rec);
                    end;
                }
                action(TransferToAgency)
                {
                    Caption = 'Transfer to External Agency';
                    Image = TransferToGeneralJournal;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        DepositMgmt: Codeunit "BSB Deposit Mgmt";
                    begin
                        DepositMgmt.TransferToAgency(Rec);
                    end;
                }
                action(SettleDeposit)
                {
                    Caption = 'Settle / Refund Deposit';
                    Image = ReturnReceipt;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        DepositMgmt: Codeunit "BSB Deposit Mgmt";
                    begin
                        DepositMgmt.SettleDeposit(Rec);
                    end;
                }
            }
            group(Updates)
            {
                Caption = 'Updates';
                action(RentIndexation)
                {
                    Caption = 'Apply Rent Indexation';
                    Image = Reconcile;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        RentUpdate: Codeunit "BSB Rent Update Mgmt";
                    begin
                        RentUpdate.ApplyIndexationUI(Rec);
                    end;
                }
                action(RenewContract)
                {
                    Caption = 'Renew Contract';
                    Image = Refresh;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        RentUpdate: Codeunit "BSB Rent Update Mgmt";
                    begin
                        RentUpdate.RenewContractUI(Rec);
                    end;
                }
                action(RecalculateTaxFutureCharges)
                {
                    Caption = 'Recalculate Future IBI';
                    Image = Calculate;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        TaxMgmt: Codeunit "BSB Tax Recharge";
                    begin
                        TaxMgmt.RecalculateFutureChargesForContract(Rec);
                    end;
                }
            }
        }
        area(Navigation)
        {
            action(Installments)
            {
                Caption = 'Installments';
                Image = List;
                ApplicationArea = All;
                RunObject = page "BSB Lease Installments";
                RunPageLink = "Contract No." = field("No.");
            }
            action(DepositEntries)
            {
                Caption = 'Deposit Entries';
                Image = BankAccount;
                ApplicationArea = All;
                RunObject = page "BSB Deposit Entries";
                RunPageLink = "Contract No." = field("No.");
            }
            action(RentUpdates)
            {
                Caption = 'Rent Update History';
                Image = History;
                ApplicationArea = All;
                RunObject = page "BSB Rent Update History";
                RunPageLink = "Contract No." = field("No.");
            }
            action(Subleases)
            {
                Caption = 'Subleases';
                Image = ContactPerson;
                ApplicationArea = All;
                RunObject = page "BSB Lease Contracts";
                RunPageLink = "Parent Contract No." = field("No.");
            }
        }
    }
}

page 50107 "BSB Contract Properties Sub"
{
    Caption = 'Properties';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "BSB Lease Contract Property";
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("Property No."; Rec."Property No.") { ApplicationArea = All; }
                field("Property Description"; Rec."Property Description") { ApplicationArea = All; }
                field("Property Area (sqm)"; Rec."Property Area (sqm)") { ApplicationArea = All; }
                field("Area Used (sqm)"; Rec."Area Used (sqm)") { ApplicationArea = All; }
                field("Rent Allocation %"; Rec."Rent Allocation %") { ApplicationArea = All; }
            }
        }
    }
}

page 50108 "BSB Contract Tenants Sub"
{
    Caption = 'Tenants';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "BSB Lease Contract Tenant";
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Tenant Name"; Rec."Tenant Name") { ApplicationArea = All; }
                field("Tax Identifier"; Rec."Tax Identifier") { ApplicationArea = All; }
                field("Share %"; Rec."Share %") { ApplicationArea = All; }
                field("Is Primary"; Rec."Is Primary") { ApplicationArea = All; }
            }
        }
    }
}

page 50109 "BSB Contract Billing Sub"
{
    Caption = 'Billing Concepts';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "BSB Lease Contract Billing";
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("Concept Type"; Rec."Concept Type") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field("Billing Frequency"; Rec."Billing Frequency") { ApplicationArea = All; }
                field("G/L Account No."; Rec."G/L Account No.") { ApplicationArea = All; }
                field("Start Date"; Rec."Start Date") { ApplicationArea = All; }
                field("End Date"; Rec."End Date") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
                field("One-Time Already Charged"; Rec."One-Time Already Charged") { ApplicationArea = All; }
            }
        }
    }
}

page 50114 "BSB Contract Signatory Sub"
{
    Caption = 'Signatories';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "BSB Contract Signatory";
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("Signatory Code"; Rec."Signatory Code") { ApplicationArea = All; }
                field("Full Name"; Rec."Full Name") { ApplicationArea = All; }
                field(Role; Rec.Role) { ApplicationArea = All; }
                field("Tax Identifier"; Rec."Tax Identifier") { ApplicationArea = All; }
                field("Has Signed"; Rec."Has Signed") { ApplicationArea = All; }
                field("Signed On"; Rec."Signed On") { ApplicationArea = All; }
                field("Signed By User"; Rec."Signed By User") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(MarkSigned)
            {
                Caption = 'Mark Signed';
                ApplicationArea = All;
                Image = Approval;

                trigger OnAction()
                var
                    Lifecycle: Codeunit "BSB Lease Lifecycle";
                begin
                    Lifecycle.MarkSignatorySigned(Rec);
                end;
            }
        }
    }
}

page 50110 "BSB Lease Installments"
{
    Caption = 'Lease Installments';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "BSB Lease Installment";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Installment No."; Rec."Installment No.") { ApplicationArea = All; }
                field("Concept Type"; Rec."Concept Type") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Period Start"; Rec."Period Start") { ApplicationArea = All; }
                field("Period End"; Rec."Period End") { ApplicationArea = All; }
                field("Due Date"; Rec."Due Date") { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Posted Invoice No."; Rec."Posted Invoice No.") { ApplicationArea = All; }
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
            }
        }
    }
}
