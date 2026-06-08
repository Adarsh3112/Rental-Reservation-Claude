page 50100 "BSB Real Estate Setup"
{
    Caption = 'Real Estate Setup';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "BSB Real Estate Setup";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(NumberSeries)
            {
                Caption = 'Number Series';
                field("Project Nos."; Rec."Project Nos.") { ApplicationArea = All; }
                field("Property Nos."; Rec."Property Nos.") { ApplicationArea = All; }
                field("Contract Nos."; Rec."Contract Nos.") { ApplicationArea = All; }
                field("Template Nos."; Rec."Template Nos.") { ApplicationArea = All; }
                field("Deposit Entry Nos."; Rec."Deposit Entry Nos.") { ApplicationArea = All; }
            }
            group(Accounting)
            {
                Caption = 'Accounting Defaults';
                field("Deposit G/L Account"; Rec."Deposit G/L Account") { ApplicationArea = All; }
                field("External Agency G/L Account"; Rec."External Agency G/L Account") { ApplicationArea = All; }
                field("Default Bank Account"; Rec."Default Bank Account") { ApplicationArea = All; }
                field("Default Payment Terms"; Rec."Default Payment Terms") { ApplicationArea = All; }
                field("Default Payment Method"; Rec."Default Payment Method") { ApplicationArea = All; }
            }
            group(Compliance)
            {
                Caption = 'Compliance';
                field("Audit Log Enabled"; Rec."Audit Log Enabled") { ApplicationArea = All; }
                field("Lock Critical After Sign"; Rec."Lock Critical After Sign") { ApplicationArea = All; }
                field("Require Tenant Customer Link"; Rec."Require Tenant Customer Link") { ApplicationArea = All; }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}

page 50101 "BSB Real Estate Projects"
{
    Caption = 'Real Estate Projects';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "BSB Real Estate Project";
    CardPageId = "BSB Real Estate Project Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Location; Rec.Location) { ApplicationArea = All; }
                field(City; Rec.City) { ApplicationArea = All; }
                field("Property Count"; Rec."Property Count") { ApplicationArea = All; }
                field("Active Contract Count"; Rec."Active Contract Count") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
        }
    }
}

page 50102 "BSB Real Estate Project Card"
{
    Caption = 'Real Estate Project Card';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "BSB Real Estate Project";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Location; Rec.Location) { ApplicationArea = All; }
                field(City; Rec.City) { ApplicationArea = All; }
                field("Country/Region Code"; Rec."Country/Region Code") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
            group(NumberSeries)
            {
                Caption = 'Number Series';
                field("Property Nos."; Rec."Property Nos.") { ApplicationArea = All; }
                field("Contract Nos."; Rec."Contract Nos.") { ApplicationArea = All; }
            }
            group(Accounting)
            {
                Caption = 'Accounting & Defaults';
                field("Default Bank Account"; Rec."Default Bank Account") { ApplicationArea = All; }
                field("Default Payment Terms"; Rec."Default Payment Terms") { ApplicationArea = All; }
                field("Default Payment Method"; Rec."Default Payment Method") { ApplicationArea = All; }
                field("Default Contract Template"; Rec."Default Contract Template") { ApplicationArea = All; }
                field("Default Deposit G/L Account"; Rec."Default Deposit G/L Account") { ApplicationArea = All; }
            }
            group(Stats)
            {
                Caption = 'Statistics';
                field("Property Count"; Rec."Property Count") { ApplicationArea = All; }
                field("Active Contract Count"; Rec."Active Contract Count") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Properties)
            {
                Caption = 'Properties';
                Image = Document;
                ApplicationArea = All;
                RunObject = page "BSB Properties";
                RunPageLink = "Project No." = field("No.");
            }
            action(Contracts)
            {
                Caption = 'Contracts';
                Image = ContactPerson;
                ApplicationArea = All;
                RunObject = page "BSB Lease Contracts";
                RunPageLink = "Project No." = field("No.");
            }
            action(Signatories)
            {
                Caption = 'Signatories';
                Image = User;
                ApplicationArea = All;
                RunObject = page "BSB Signatories";
                RunPageLink = "Project No." = field("No.");
            }
        }
    }
}
