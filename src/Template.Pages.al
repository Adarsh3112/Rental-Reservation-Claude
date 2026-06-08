page 50111 "BSB Contract Templates"
{
    Caption = 'Contract Templates';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "BSB Contract Template";
    CardPageId = "BSB Contract Template Card";

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Project No."; Rec."Project No.") { ApplicationArea = All; }
                field("Default Term (Months)"; Rec."Default Term (Months)") { ApplicationArea = All; }
                field("Default Billing Frequency"; Rec."Default Billing Frequency") { ApplicationArea = All; }
                field("Required Signatories"; Rec."Required Signatories") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
        }
    }
}

page 50112 "BSB Contract Template Card"
{
    Caption = 'Contract Template Card';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "BSB Contract Template";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Project No."; Rec."Project No.") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
            group(Defaults)
            {
                Caption = 'Defaults';
                field("Default Term (Months)"; Rec."Default Term (Months)") { ApplicationArea = All; }
                field("Default Billing Frequency"; Rec."Default Billing Frequency") { ApplicationArea = All; }
                field("Default Deposit Months"; Rec."Default Deposit Months") { ApplicationArea = All; }
                field("Default Payment Terms"; Rec."Default Payment Terms") { ApplicationArea = All; }
                field("Default Payment Method"; Rec."Default Payment Method") { ApplicationArea = All; }
            }
            group(Legal)
            {
                Caption = 'Legal';
                field("Required Signatories"; Rec."Required Signatories") { ApplicationArea = All; }
                field("Requires Witness"; Rec."Requires Witness") { ApplicationArea = All; }
                field("Requires Guarantor"; Rec."Requires Guarantor") { ApplicationArea = All; }
            }
        }
    }
}

page 50113 "BSB Signatories"
{
    Caption = 'Signatories';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "BSB Real Estate Signatory";

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field("Full Name"; Rec."Full Name") { ApplicationArea = All; }
                field("Tax Identifier"; Rec."Tax Identifier") { ApplicationArea = All; }
                field("Default Role"; Rec."Default Role") { ApplicationArea = All; }
                field("Project No."; Rec."Project No.") { ApplicationArea = All; }
                field(Email; Rec.Email) { ApplicationArea = All; }
                field("Phone No."; Rec."Phone No.") { ApplicationArea = All; }
                field("Authorization Active"; Rec."Authorization Active") { ApplicationArea = All; }
                field("Authorization From"; Rec."Authorization From") { ApplicationArea = All; }
                field("Authorization To"; Rec."Authorization To") { ApplicationArea = All; }
            }
        }
    }
}
