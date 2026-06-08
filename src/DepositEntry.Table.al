table 50111 "BSB Deposit Entry"
{
    Caption = 'Deposit Entry';
    DataClassification = CustomerContent;
    DrillDownPageId = "BSB Deposit Entries";
    LookupPageId = "BSB Deposit Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "BSB Lease Contract";
        }
        field(11; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(12; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            TableRelation = "BSB Real Estate Project";
        }
        field(20; "Entry Type"; Enum "BSB Deposit Entry Type")
        {
            Caption = 'Entry Type';
        }
        field(21; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(22; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(23; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(30; Amount; Decimal)
        {
            Caption = 'Amount';
            AutoFormatType = 1;
        }
        field(31; "Running Balance"; Decimal)
        {
            Caption = 'Running Balance';
            AutoFormatType = 1;
            Editable = false;
        }
        field(40; Holder; Enum "BSB Deposit Holder Type")
        {
            Caption = 'Holder';
        }
        field(41; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account";
        }
        field(42; "Created By"; Code[50])
        {
            Caption = 'Created By';
            Editable = false;
        }
        field(43; "Created On"; DateTime)
        {
            Caption = 'Created On';
            Editable = false;
        }
        field(50; Reversed; Boolean)
        {
            Caption = 'Reversed';
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Contract; "Contract No.", "Posting Date") { }
        key(Customer; "Customer No.") { }
        key(EntryType; "Entry Type") { }
    }

    trigger OnInsert()
    begin
        if "Created On" = 0DT then
            "Created On" := CurrentDateTime();
        if "Created By" = '' then
            "Created By" := CopyStr(UserId(), 1, MaxStrLen("Created By"));
    end;
}

table 50112 "BSB Property Tax Entry"
{
    Caption = 'Property Tax (IBI) Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Property No."; Code[20])
        {
            Caption = 'Property No.';
            TableRelation = "BSB Property";
        }
        field(11; "Effective Date"; Date)
        {
            Caption = 'Effective Date';
        }
        field(12; "Annual Amount"; Decimal)
        {
            Caption = 'Annual Amount';
            AutoFormatType = 1;
            MinValue = 0;
        }
        field(13; "Period"; Enum "BSB Tax Period Type")
        {
            Caption = 'Period';
        }
        field(20; "Created By"; Code[50])
        {
            Caption = 'Created By';
            Editable = false;
        }
        field(21; "Created On"; DateTime)
        {
            Caption = 'Created On';
            Editable = false;
        }
        field(30; "Previous Annual Amount"; Decimal)
        {
            Caption = 'Previous Annual Amount';
            AutoFormatType = 1;
        }
        field(31; Notes; Text[250])
        {
            Caption = 'Notes';
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Property; "Property No.", "Effective Date") { }
    }

    trigger OnInsert()
    begin
        if "Created On" = 0DT then
            "Created On" := CurrentDateTime();
        if "Created By" = '' then
            "Created By" := CopyStr(UserId(), 1, MaxStrLen("Created By"));
    end;
}

table 50113 "BSB Rent Update Entry"
{
    Caption = 'Rent Update Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "BSB Lease Contract";
        }
        field(11; "Effective Date"; Date)
        {
            Caption = 'Effective Date';
        }
        field(20; "Previous Rent"; Decimal)
        {
            Caption = 'Previous Rent';
            AutoFormatType = 1;
        }
        field(21; "New Rent"; Decimal)
        {
            Caption = 'New Rent';
            AutoFormatType = 1;
        }
        field(22; "Update %"; Decimal)
        {
            Caption = 'Update %';
            DecimalPlaces = 0 : 5;
        }
        field(23; "Update Type"; Option)
        {
            Caption = 'Update Type';
            OptionMembers = Indexation,"Fixed Amount","Renewal";
            OptionCaption = 'Indexation,Fixed Amount,Renewal';
        }
        field(30; "Previous End Date"; Date)
        {
            Caption = 'Previous End Date';
        }
        field(31; "New End Date"; Date)
        {
            Caption = 'New End Date';
        }
        field(40; "Created By"; Code[50])
        {
            Caption = 'Created By';
            Editable = false;
        }
        field(41; "Created On"; DateTime)
        {
            Caption = 'Created On';
            Editable = false;
        }
        field(42; Notes; Text[250])
        {
            Caption = 'Notes';
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Contract; "Contract No.", "Effective Date") { }
    }

    trigger OnInsert()
    begin
        if "Created On" = 0DT then
            "Created On" := CurrentDateTime();
        if "Created By" = '' then
            "Created By" := CopyStr(UserId(), 1, MaxStrLen("Created By"));
    end;
}

table 50114 "BSB Audit Log Entry"
{
    Caption = 'Audit Log Entry';
    DataClassification = CustomerContent;
    LookupPageId = "BSB Audit Log";
    DrillDownPageId = "BSB Audit Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Table No."; Integer)
        {
            Caption = 'Table No.';
        }
        field(11; "Record ID"; Code[60])
        {
            Caption = 'Record ID';
        }
        field(12; "Action"; Enum "BSB Audit Action Type")
        {
            Caption = 'Action';
        }
        field(13; "Action Description"; Text[250])
        {
            Caption = 'Action Description';
        }
        field(20; "User ID"; Code[50])
        {
            Caption = 'User ID';
        }
        field(21; "Action DateTime"; DateTime)
        {
            Caption = 'Action DateTime';
        }
        field(30; "Old Value"; Text[250])
        {
            Caption = 'Old Value';
        }
        field(31; "New Value"; Text[250])
        {
            Caption = 'New Value';
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Record; "Table No.", "Record ID") { }
        key(Date; "Action DateTime") { }
    }
}
