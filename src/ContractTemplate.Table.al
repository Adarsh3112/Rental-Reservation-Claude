table 50108 "BSB Contract Template"
{
    Caption = 'Contract Template';
    DataClassification = CustomerContent;
    LookupPageId = "BSB Contract Templates";
    DrillDownPageId = "BSB Contract Templates";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(11; "Project No."; Code[20])
        {
            Caption = 'Project No. (optional)';
            TableRelation = "BSB Real Estate Project";
        }
        field(12; "Default Term (Months)"; Integer)
        {
            Caption = 'Default Term (Months)';
            MinValue = 0;
        }
        field(13; "Default Billing Frequency"; Enum "BSB Billing Frequency")
        {
            Caption = 'Default Billing Frequency';
        }
        field(14; "Default Deposit Months"; Decimal)
        {
            Caption = 'Default Deposit (Months of Rent)';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
        }
        field(15; "Default Payment Terms"; Code[10])
        {
            Caption = 'Default Payment Terms';
            TableRelation = "Payment Terms";
        }
        field(16; "Default Payment Method"; Code[10])
        {
            Caption = 'Default Payment Method';
            TableRelation = "Payment Method";
        }
        field(20; "Required Signatories"; Integer)
        {
            Caption = 'Required Signatories';
            MinValue = 0;
            InitValue = 2;
        }
        field(21; "Requires Witness"; Boolean)
        {
            Caption = 'Requires Witness';
        }
        field(22; "Requires Guarantor"; Boolean)
        {
            Caption = 'Requires Guarantor';
        }
        field(30; "Document Body"; Blob)
        {
            Caption = 'Document Body';
        }
        field(31; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description, "Default Term (Months)") { }
    }

    trigger OnInsert()
    var
        Setup: Record "BSB Real Estate Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "Code" = '' then begin
            Setup.GetSetup();
            if Setup."Template Nos." <> '' then
                "Code" := NoSeries.GetNextNo(Setup."Template Nos.", WorkDate());
        end;
    end;
}
