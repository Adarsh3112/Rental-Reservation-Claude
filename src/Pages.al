page 50000 "RE Project List"
{
    Caption = 'Real Estate Projects';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "RE Project";
    CardPageId = "RE Project Card";

    layout
    {
        area(content)
        {
            repeater(Projects)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Default Bank Account No."; Rec."Default Bank Account No.") { ApplicationArea = All; }
                field("Payment Terms Code"; Rec."Payment Terms Code") { ApplicationArea = All; }
                field("Payment Method Code"; Rec."Payment Method Code") { ApplicationArea = All; }
                field("Require Two Signatories"; Rec."Require Two Signatories") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
        }
    }
}

page 50001 "RE Project Card"
{
    Caption = 'Real Estate Project';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "RE Project";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
            group(Numbering)
            {
                field("Property Nos."; Rec."Property Nos.") { ApplicationArea = All; }
                field("Contract Nos."; Rec."Contract Nos.") { ApplicationArea = All; }
                field("Tenant Nos."; Rec."Tenant Nos.") { ApplicationArea = All; }
            }
            group(Defaults)
            {
                field("Default Bank Account No."; Rec."Default Bank Account No.") { ApplicationArea = All; }
                field("Payment Terms Code"; Rec."Payment Terms Code") { ApplicationArea = All; }
                field("Payment Method Code"; Rec."Payment Method Code") { ApplicationArea = All; }
                field("Default Holding Type"; Rec."Default Holding Type") { ApplicationArea = All; }
            }
            group(Accounting)
            {
                field("Rent G/L Account No."; Rec."Rent G/L Account No.") { ApplicationArea = All; }
                field("Deposit G/L Account No."; Rec."Deposit G/L Account No.") { ApplicationArea = All; }
                field("Tax G/L Account No."; Rec."Tax G/L Account No.") { ApplicationArea = All; }
                field("Fee G/L Account No."; Rec."Fee G/L Account No.") { ApplicationArea = All; }
            }
            group(Signing)
            {
                field("Require Two Signatories"; Rec."Require Two Signatories") { ApplicationArea = All; }
            }
            part(Signatories; "RE Project Signatories")
            {
                ApplicationArea = All;
                SubPageLink = "Project No." = field("No.");
            }
        }
    }
}

page 50002 "RE Project Signatories"
{
    Caption = 'Project Signatories';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "RE Project Signatory";
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            repeater(Signatories)
            {
                field("Signatory Code"; Rec."Signatory Code") { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field(Role; Rec.Role) { ApplicationArea = All; }
                field(Required; Rec.Required) { ApplicationArea = All; }
                field("Valid From"; Rec."Valid From") { ApplicationArea = All; }
                field("Valid To"; Rec."Valid To") { ApplicationArea = All; }
            }
        }
    }
}

page 50003 "RE Contract Template List"
{
    Caption = 'Contract Templates';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "RE Contract Template";

    layout
    {
        area(content)
        {
            repeater(Templates)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Project No."; Rec."Project No.") { ApplicationArea = All; }
                field("Template Version"; Rec."Template Version") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
                field("Requires Legal Review"; Rec."Requires Legal Review") { ApplicationArea = All; }
                field("Mandatory Clauses Confirmed"; Rec."Mandatory Clauses Confirmed") { ApplicationArea = All; }
                field("Default Term Months"; Rec."Default Term Months") { ApplicationArea = All; }
            }
        }
    }
}

page 50004 "RE Property List"
{
    Caption = 'Properties';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "RE Property";
    CardPageId = "RE Property Card";

    layout
    {
        area(content)
        {
            repeater(Properties)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Project No."; Rec."Project No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Property Type"; Rec."Property Type") { ApplicationArea = All; }
                field("Rental Status"; Rec."Rental Status") { ApplicationArea = All; }
                field(City; Rec.City) { ApplicationArea = All; }
                field("Area Sqm"; Rec."Area Sqm") { ApplicationArea = All; }
                field("Annual IBI Amount"; Rec."Annual IBI Amount") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(MassMarkBlocked)
            {
                Caption = 'Mass Set Status: Blocked';
                ApplicationArea = All;
                Image = Stop;

                trigger OnAction()
                var
                    RentalMgt: Codeunit "RE Rental Management";
                begin
                    if Rec."Project No." <> '' then
                        RentalMgt.MassSetPropertyStatus(Rec."Project No.", Rec."Rental Status"::Blocked);
                end;
            }
        }
    }
}

page 50005 "RE Property Card"
{
    Caption = 'Property';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "RE Property";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Project No."; Rec."Project No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Property Type"; Rec."Property Type") { ApplicationArea = All; }
                field("Rental Status"; Rec."Rental Status") { ApplicationArea = All; }
                field("Last Status Change"; Rec."Last Status Change") { ApplicationArea = All; }
            }
            group(Location)
            {
                field(Address; Rec.Address) { ApplicationArea = All; }
                field(City; Rec.City) { ApplicationArea = All; }
                field("Post Code"; Rec."Post Code") { ApplicationArea = All; }
                field("Country/Region Code"; Rec."Country/Region Code") { ApplicationArea = All; }
            }
            group(Technical)
            {
                field("Area Sqm"; Rec."Area Sqm") { ApplicationArea = All; }
                field("Technical Specs"; Rec."Technical Specs") { ApplicationArea = All; }
                field("Appraisal Value"; Rec."Appraisal Value") { ApplicationArea = All; }
                field("Appraisal Date"; Rec."Appraisal Date") { ApplicationArea = All; }
            }
            group(Legal)
            {
                field("Registry No."; Rec."Registry No.") { ApplicationArea = All; }
                field("Cadastral Reference"; Rec."Cadastral Reference") { ApplicationArea = All; }
            }
            group(Compliance)
            {
                field("Energy Rating"; Rec."Energy Rating") { ApplicationArea = All; }
                field("Energy Certificate No."; Rec."Energy Certificate No.") { ApplicationArea = All; }
                field("Energy Certificate Expiry"; Rec."Energy Certificate Expiry") { ApplicationArea = All; }
            }
            group(Charges)
            {
                field("Annual IBI Amount"; Rec."Annual IBI Amount") { ApplicationArea = All; }
                field("Available Sublease Area Sqm"; Rec."Available Sublease Area Sqm") { ApplicationArea = All; }
            }
        }
    }
}

page 50006 "RE Tenant List"
{
    Caption = 'Tenants';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "RE Tenant";
    CardPageId = "RE Tenant Card";

    layout
    {
        area(content)
        {
            repeater(Tenants)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("E-Mail"; Rec."E-Mail") { ApplicationArea = All; }
                field("Phone No."; Rec."Phone No.") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
        }
    }
}

page 50007 "RE Tenant Card"
{
    Caption = 'Tenant';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "RE Tenant";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
            group(Contact)
            {
                field("E-Mail"; Rec."E-Mail") { ApplicationArea = All; }
                field("Phone No."; Rec."Phone No.") { ApplicationArea = All; }
            }
            group(Tax)
            {
                field("VAT Registration No."; Rec."VAT Registration No.") { ApplicationArea = All; }
                field("Identification No."; Rec."Identification No.") { ApplicationArea = All; }
            }
        }
    }
}

page 50008 "RE Contract List"
{
    Caption = 'Lease Contracts';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "RE Contract";
    CardPageId = "RE Contract Card";

    layout
    {
        area(content)
        {
            repeater(Contracts)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Project No."; Rec."Project No.") { ApplicationArea = All; }
                field("Primary Tenant No."; Rec."Primary Tenant No.") { ApplicationArea = All; }
                field("Primary Property No."; Rec."Primary Property No.") { ApplicationArea = All; }
                field("Start Date"; Rec."Start Date") { ApplicationArea = All; }
                field("End Date"; Rec."End Date") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Base Rent"; Rec."Base Rent") { ApplicationArea = All; }
                field("Is Sublease"; Rec."Is Sublease") { ApplicationArea = All; }
                field("Renewal Count"; Rec."Renewal Count") { ApplicationArea = All; }
            }
        }
    }
}

page 50009 "RE Contract Card"
{
    Caption = 'Lease Contract';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "RE Contract";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Project No."; Rec."Project No.") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Contract Template Code"; Rec."Contract Template Code") { ApplicationArea = All; }
            }
            group(Parties)
            {
                field("Primary Tenant No."; Rec."Primary Tenant No.") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Primary Property No."; Rec."Primary Property No.") { ApplicationArea = All; }
            }
            group(Terms)
            {
                field("Start Date"; Rec."Start Date") { ApplicationArea = All; }
                field("End Date"; Rec."End Date") { ApplicationArea = All; }
                field("Base Rent"; Rec."Base Rent") { ApplicationArea = All; }
                field("Billing Frequency Months"; Rec."Billing Frequency Months") { ApplicationArea = All; }
                field("Entry Right Fee"; Rec."Entry Right Fee") { ApplicationArea = All; }
                field("Entry Right Posted"; Rec."Entry Right Posted") { ApplicationArea = All; }
                field("Payment Terms Code"; Rec."Payment Terms Code") { ApplicationArea = All; }
                field("Payment Method Code"; Rec."Payment Method Code") { ApplicationArea = All; }
            }
            group(Deposit)
            {
                field("Deposit Amount"; Rec."Deposit Amount") { ApplicationArea = All; }
                field("Deposit Holding Type"; Rec."Deposit Holding Type") { ApplicationArea = All; }
            }
            group(Signature)
            {
                field("Legal Review Completed"; Rec."Legal Review Completed") { ApplicationArea = All; }
                field(Signed; Rec.Signed) { ApplicationArea = All; }
                field("Signed Date"; Rec."Signed Date") { ApplicationArea = All; }
                field("Signatory 1 Code"; Rec."Signatory 1 Code") { ApplicationArea = All; }
                field("Signatory 2 Code"; Rec."Signatory 2 Code") { ApplicationArea = All; }
            }
            group(Sublease)
            {
                field("Is Sublease"; Rec."Is Sublease") { ApplicationArea = All; }
                field("Parent Contract No."; Rec."Parent Contract No.") { ApplicationArea = All; }
                field("Sublease Area Sqm"; Rec."Sublease Area Sqm") { ApplicationArea = All; }
            }
            group(Termination)
            {
                field("Termination Date"; Rec."Termination Date") { ApplicationArea = All; }
                field("Termination Type"; Rec."Termination Type") { ApplicationArea = All; }
                field("Termination Reason"; Rec."Termination Reason") { ApplicationArea = All; }
            }
            group(History)
            {
                field("Renewal Count"; Rec."Renewal Count") { ApplicationArea = All; }
                field("Last Billing Date"; Rec."Last Billing Date") { ApplicationArea = All; }
                field("Last Rent Update Date"; Rec."Last Rent Update Date") { ApplicationArea = All; }
            }
            part(Properties; "RE Contract Properties")
            {
                ApplicationArea = All;
                SubPageLink = "Contract No." = field("No.");
            }
            part(Tenants; "RE Contract Tenants")
            {
                ApplicationArea = All;
                SubPageLink = "Contract No." = field("No.");
            }
            part(BillingSchedulePart; "RE Billing Schedule Part")
            {
                Caption = 'Billing';
                ApplicationArea = All;
                SubPageLink = "Contract No." = field("No.");
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

                action(Activate)
                {
                    Caption = 'Activate';
                    ApplicationArea = All;
                    Image = ReleaseDoc;

                    trigger OnAction()
                    var
                        RentalMgt: Codeunit "RE Rental Management";
                    begin
                        RentalMgt.ActivateContract(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(StartCancellation)
                {
                    Caption = 'Start Cancellation';
                    ApplicationArea = All;
                    Image = Cancel;

                    trigger OnAction()
                    var
                        RentalMgt: Codeunit "RE Rental Management";
                        TerminationDate: Date;
                    begin
                        TerminationDate := Rec."Termination Date";
                        if TerminationDate = 0D then
                            TerminationDate := WorkDate();
                        RentalMgt.StartCancellation(Rec, TerminationDate, Rec."Termination Reason", Rec."Termination Type");
                        CurrPage.Update(false);
                    end;
                }
                action(CloseContract)
                {
                    Caption = 'Close';
                    ApplicationArea = All;
                    Image = Close;

                    trigger OnAction()
                    var
                        RentalMgt: Codeunit "RE Rental Management";
                    begin
                        RentalMgt.CloseContract(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(RenewContract)
                {
                    Caption = 'Renew';
                    ApplicationArea = All;
                    Image = Refresh;

                    trigger OnAction()
                    var
                        RentalMgt: Codeunit "RE Rental Management";
                    begin
                        RentalMgt.RenewContract(Rec, CalcDate('<1Y>', Rec."End Date"));
                        CurrPage.Update(false);
                    end;
                }
            }
            group(Billing)
            {
                Caption = 'Billing';

                action(GenerateSchedule)
                {
                    Caption = 'Generate Billing Schedule';
                    ApplicationArea = All;
                    Image = CreateLinesFromJob;

                    trigger OnAction()
                    var
                        RentalMgt: Codeunit "RE Rental Management";
                    begin
                        RentalMgt.GenerateBillingSchedule(Rec, Rec."Start Date", Rec."End Date", false);
                        CurrPage.Update(false);
                    end;
                }
                action(SimulateSchedule)
                {
                    Caption = 'Simulate Billing Schedule';
                    ApplicationArea = All;
                    Image = TestFile;

                    trigger OnAction()
                    var
                        RentalMgt: Codeunit "RE Rental Management";
                    begin
                        RentalMgt.GenerateBillingSchedule(Rec, Rec."Start Date", Rec."End Date", true);
                        CurrPage.Update(false);
                    end;
                }
                action(PostEntryRights)
                {
                    Caption = 'Bill Entry Rights';
                    ApplicationArea = All;
                    Image = Currency;

                    trigger OnAction()
                    var
                        RentalMgt: Codeunit "RE Rental Management";
                    begin
                        RentalMgt.PostEntryRightFee(Rec, WorkDate());
                        CurrPage.Update(false);
                    end;
                }
            }
            group(Deposits)
            {
                Caption = 'Deposits';

                action(PostDeposit)
                {
                    Caption = 'Post Initial Deposit';
                    ApplicationArea = All;
                    Image = DepositSlip;

                    trigger OnAction()
                    var
                        RentalMgt: Codeunit "RE Rental Management";
                    begin
                        RentalMgt.PostInitialDeposit(Rec, Rec."No.");
                        CurrPage.Update(false);
                    end;
                }
                action(TransferDeposit)
                {
                    Caption = 'Transfer Deposit to Agency';
                    ApplicationArea = All;
                    Image = TransferToGeneralJournal;

                    trigger OnAction()
                    var
                        RentalMgt: Codeunit "RE Rental Management";
                    begin
                        RentalMgt.TransferDepositToAgency(Rec, Rec."No.");
                        CurrPage.Update(false);
                    end;
                }
                action(SettleDeposit)
                {
                    Caption = 'Settle Deposit (Refund Full)';
                    ApplicationArea = All;
                    Image = ReturnOrder;

                    trigger OnAction()
                    var
                        RentalMgt: Codeunit "RE Rental Management";
                    begin
                        RentalMgt.SettleDeposit(Rec, 0, Rec."Deposit Amount", Rec."No.");
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(Navigation)
        {
            action(RentHistory)
            {
                Caption = 'Rent History';
                ApplicationArea = All;
                Image = History;
                RunObject = page "RE Rent History List";
                RunPageLink = "Contract No." = field("No.");
            }
            action(DepositEntries)
            {
                Caption = 'Deposit Entries';
                ApplicationArea = All;
                Image = Ledger;
                RunObject = page "RE Deposit Entries";
                RunPageLink = "Contract No." = field("No.");
            }
            action(IBIEntries)
            {
                Caption = 'IBI Entries';
                ApplicationArea = All;
                Image = Aging;
                RunObject = page "RE IBI Entries";
                RunPageLink = "Contract No." = field("No.");
            }
            action(AuditEntries)
            {
                Caption = 'Audit Trail';
                ApplicationArea = All;
                Image = Log;
                RunObject = page "RE Audit Entries";
            }
        }
    }
}

page 50010 "RE Contract Properties"
{
    Caption = 'Contract Properties';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "RE Contract Property";
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            repeater(Properties)
            {
                field("Property No."; Rec."Property No.") { ApplicationArea = All; }
                field("Area Sqm"; Rec."Area Sqm") { ApplicationArea = All; }
                field("Base Rent Share"; Rec."Base Rent Share") { ApplicationArea = All; }
                field(Released; Rec.Released) { ApplicationArea = All; }
            }
        }
    }
}

page 50011 "RE Contract Tenants"
{
    Caption = 'Contract Tenants';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "RE Contract Tenant";
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            repeater(Tenants)
            {
                field("Tenant No."; Rec."Tenant No.") { ApplicationArea = All; }
                field("Responsibility %"; Rec."Responsibility %") { ApplicationArea = All; }
                field(Primary; Rec.Primary) { ApplicationArea = All; }
            }
        }
    }
}

page 50012 "RE Billing Schedule Part"
{
    Caption = 'Billing Schedule';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "RE Billing Schedule";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Billing)
            {
                field("Billing Date"; Rec."Billing Date") { ApplicationArea = All; }
                field("Period Start"; Rec."Period Start") { ApplicationArea = All; }
                field("Period End"; Rec."Period End") { ApplicationArea = All; }
                field("Concept Type"; Rec."Concept Type") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field(Simulated; Rec.Simulated) { ApplicationArea = All; }
                field("Sales Invoice No."; Rec."Sales Invoice No.") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateInvoice)
            {
                Caption = 'Create Sales Invoice';
                ApplicationArea = All;
                Image = SalesInvoice;

                trigger OnAction()
                var
                    RentalMgt: Codeunit "RE Rental Management";
                begin
                    RentalMgt.CreateSalesInvoiceForBilling(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}

page 50013 "RE Billing Schedule List"
{
    Caption = 'Rental Billing Schedules';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "RE Billing Schedule";

    layout
    {
        area(content)
        {
            repeater(Billing)
            {
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Billing Date"; Rec."Billing Date") { ApplicationArea = All; }
                field("Period Start"; Rec."Period Start") { ApplicationArea = All; }
                field("Period End"; Rec."Period End") { ApplicationArea = All; }
                field("Concept Type"; Rec."Concept Type") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Sales Invoice No."; Rec."Sales Invoice No.") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateInvoice)
            {
                Caption = 'Create Sales Invoice';
                ApplicationArea = All;
                Image = SalesInvoice;

                trigger OnAction()
                var
                    RentalMgt: Codeunit "RE Rental Management";
                begin
                    RentalMgt.CreateSalesInvoiceForBilling(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}

page 50014 "RE Deposit Entries"
{
    Caption = 'Rental Deposit Entries';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = "RE Deposit Entry";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Entries)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
                field("Entry Type"; Rec."Entry Type") { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field("External Agency"; Rec."External Agency") { ApplicationArea = All; }
                field("Document No."; Rec."Document No.") { ApplicationArea = All; }
                field("G/L Account No."; Rec."G/L Account No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Reversed; Rec.Reversed) { ApplicationArea = All; }
                field("User ID"; Rec."User ID") { ApplicationArea = All; }
            }
        }
    }
}

page 50015 "RE Audit Entries"
{
    Caption = 'Rental Audit Entries';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = "RE Audit Entry";
    Editable = false;
    SourceTableView = sorting("Created At") order(descending);

    layout
    {
        area(content)
        {
            repeater(Entries)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Created At"; Rec."Created At") { ApplicationArea = All; }
                field("Table No."; Rec."Table No.") { ApplicationArea = All; }
                field("Record No."; Rec."Record No.") { ApplicationArea = All; }
                field(Action; Rec.Action) { ApplicationArea = All; }
                field("Field Name"; Rec."Field Name") { ApplicationArea = All; }
                field("Old Value"; Rec."Old Value") { ApplicationArea = All; }
                field("New Value"; Rec."New Value") { ApplicationArea = All; }
                field("User ID"; Rec."User ID") { ApplicationArea = All; }
                field(Comment; Rec.Comment) { ApplicationArea = All; }
            }
        }
    }
}

page 50016 "RE Rent History List"
{
    Caption = 'Rent History';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = "RE Rent History";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(History)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Effective Date"; Rec."Effective Date") { ApplicationArea = All; }
                field("Old Rent"; Rec."Old Rent") { ApplicationArea = All; }
                field("New Rent"; Rec."New Rent") { ApplicationArea = All; }
                field("Update Method"; Rec."Update Method") { ApplicationArea = All; }
                field("Index Code"; Rec."Index Code") { ApplicationArea = All; }
                field("User ID"; Rec."User ID") { ApplicationArea = All; }
            }
        }
    }
}

page 50017 "RE IBI Entries"
{
    Caption = 'IBI Recharge Entries';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = "RE IBI Entry";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Entries)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Property No."; Rec."Property No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Tax Year"; Rec."Tax Year") { ApplicationArea = All; }
                field("Effective Date"; Rec."Effective Date") { ApplicationArea = All; }
                field("Annual Amount"; Rec."Annual Amount") { ApplicationArea = All; }
                field("Already Billed Amount"; Rec."Already Billed Amount") { ApplicationArea = All; }
                field("Catch-up Amount"; Rec."Catch-up Amount") { ApplicationArea = All; }
                field("User ID"; Rec."User ID") { ApplicationArea = All; }
            }
        }
    }
}

page 50018 "RE Rental Role Center"
{
    Caption = 'Rental Management';
    PageType = RoleCenter;
    ApplicationArea = All;

    layout
    {
        area(rolecenter)
        {
        }
    }

    actions
    {
        area(Sections)
        {
            group(Setup)
            {
                Caption = 'Setup';

                action(Projects)
                {
                    Caption = 'Real Estate Projects';
                    ApplicationArea = All;
                    RunObject = page "RE Project List";
                }
                action(Templates)
                {
                    Caption = 'Contract Templates';
                    ApplicationArea = All;
                    RunObject = page "RE Contract Template List";
                }
            }
            group(Master)
            {
                Caption = 'Master Data';

                action(Properties)
                {
                    Caption = 'Properties';
                    ApplicationArea = All;
                    RunObject = page "RE Property List";
                }
                action(Tenants)
                {
                    Caption = 'Tenants';
                    ApplicationArea = All;
                    RunObject = page "RE Tenant List";
                }
                action(Contracts)
                {
                    Caption = 'Lease Contracts';
                    ApplicationArea = All;
                    RunObject = page "RE Contract List";
                }
            }
            group(Operations)
            {
                Caption = 'Operations';

                action(BillingList)
                {
                    Caption = 'Billing Schedules';
                    ApplicationArea = All;
                    RunObject = page "RE Billing Schedule List";
                }
                action(Deposits)
                {
                    Caption = 'Deposit Entries';
                    ApplicationArea = All;
                    RunObject = page "RE Deposit Entries";
                }
                action(IBI)
                {
                    Caption = 'IBI Entries';
                    ApplicationArea = All;
                    RunObject = page "RE IBI Entries";
                }
                action(RentHistory)
                {
                    Caption = 'Rent History';
                    ApplicationArea = All;
                    RunObject = page "RE Rent History List";
                }
                action(Audit)
                {
                    Caption = 'Audit Trail';
                    ApplicationArea = All;
                    RunObject = page "RE Audit Entries";
                }
            }
        }
    }
}
