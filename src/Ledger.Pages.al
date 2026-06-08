page 50115 "BSB Deposit Entries"
{
    Caption = 'Deposit Entries';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "BSB Deposit Entry";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
                field("Document No."; Rec."Document No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Entry Type"; Rec."Entry Type") { ApplicationArea = All; }
                field(Holder; Rec.Holder) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field("Running Balance"; Rec."Running Balance") { ApplicationArea = All; }
                field("G/L Account No."; Rec."G/L Account No.") { ApplicationArea = All; }
                field("Created By"; Rec."Created By") { ApplicationArea = All; }
                field("Created On"; Rec."Created On") { ApplicationArea = All; }
                field(Reversed; Rec.Reversed) { ApplicationArea = All; }
            }
        }
    }
}

page 50116 "BSB Property Tax Entries"
{
    Caption = 'Property Tax (IBI) Entries';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "BSB Property Tax Entry";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Property No."; Rec."Property No.") { ApplicationArea = All; }
                field("Effective Date"; Rec."Effective Date") { ApplicationArea = All; }
                field("Previous Annual Amount"; Rec."Previous Annual Amount") { ApplicationArea = All; }
                field("Annual Amount"; Rec."Annual Amount") { ApplicationArea = All; }
                field(Period; Rec.Period) { ApplicationArea = All; }
                field(Notes; Rec.Notes) { ApplicationArea = All; }
                field("Created By"; Rec."Created By") { ApplicationArea = All; }
                field("Created On"; Rec."Created On") { ApplicationArea = All; }
            }
        }
    }
}

page 50117 "BSB Rent Update History"
{
    Caption = 'Rent Update History';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "BSB Rent Update Entry";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Effective Date"; Rec."Effective Date") { ApplicationArea = All; }
                field("Update Type"; Rec."Update Type") { ApplicationArea = All; }
                field("Previous Rent"; Rec."Previous Rent") { ApplicationArea = All; }
                field("New Rent"; Rec."New Rent") { ApplicationArea = All; }
                field("Update %"; Rec."Update %") { ApplicationArea = All; }
                field("Previous End Date"; Rec."Previous End Date") { ApplicationArea = All; }
                field("New End Date"; Rec."New End Date") { ApplicationArea = All; }
                field(Notes; Rec.Notes) { ApplicationArea = All; }
                field("Created By"; Rec."Created By") { ApplicationArea = All; }
                field("Created On"; Rec."Created On") { ApplicationArea = All; }
            }
        }
    }
}

page 50118 "BSB Audit Log"
{
    Caption = 'Audit Log';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "BSB Audit Log Entry";
    Editable = false;
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Action DateTime"; Rec."Action DateTime") { ApplicationArea = All; }
                field("User ID"; Rec."User ID") { ApplicationArea = All; }
                field("Table No."; Rec."Table No.") { ApplicationArea = All; }
                field("Record ID"; Rec."Record ID") { ApplicationArea = All; }
                field(Action; Rec.Action) { ApplicationArea = All; }
                field("Action Description"; Rec."Action Description") { ApplicationArea = All; }
                field("Old Value"; Rec."Old Value") { ApplicationArea = All; }
                field("New Value"; Rec."New Value") { ApplicationArea = All; }
            }
        }
    }
}
