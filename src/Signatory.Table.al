table 50109 "BSB Real Estate Signatory"
{
    Caption = 'Real Estate Signatory';
    DataClassification = CustomerContent;
    LookupPageId = "BSB Signatories";
    DrillDownPageId = "BSB Signatories";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10; "Full Name"; Text[100])
        {
            Caption = 'Full Name';
        }
        field(11; "Tax Identifier"; Code[30])
        {
            Caption = 'Tax Identifier';
        }
        field(12; "Default Role"; Enum "BSB Signatory Role")
        {
            Caption = 'Default Role';
        }
        field(13; "Project No."; Code[20])
        {
            Caption = 'Project No. (if scoped)';
            TableRelation = "BSB Real Estate Project";
        }
        field(20; "Email"; Text[80])
        {
            Caption = 'E-Mail';
            ExtendedDatatype = EMail;
        }
        field(21; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(30; "Authorization Active"; Boolean)
        {
            Caption = 'Authorization Active';
            InitValue = true;
        }
        field(31; "Authorization From"; Date)
        {
            Caption = 'Authorization From';
        }
        field(32; "Authorization To"; Date)
        {
            Caption = 'Authorization To';
        }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
        key(Project; "Project No.") { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", "Full Name", "Default Role") { }
    }
}

table 50110 "BSB Contract Signatory"
{
    Caption = 'Contract Signatory';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "BSB Lease Contract";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; "Signatory Code"; Code[20])
        {
            Caption = 'Signatory Code';
            TableRelation = "BSB Real Estate Signatory";

            trigger OnValidate()
            var
                Signatory: Record "BSB Real Estate Signatory";
            begin
                if Signatory.Get("Signatory Code") then begin
                    "Full Name" := Signatory."Full Name";
                    "Tax Identifier" := Signatory."Tax Identifier";
                    Role := Signatory."Default Role";
                end;
            end;
        }
        field(11; "Full Name"; Text[100])
        {
            Caption = 'Full Name';
        }
        field(12; "Tax Identifier"; Code[30])
        {
            Caption = 'Tax Identifier';
        }
        field(13; Role; Enum "BSB Signatory Role")
        {
            Caption = 'Role';
        }
        field(20; "Has Signed"; Boolean)
        {
            Caption = 'Has Signed';
        }
        field(21; "Signed On"; DateTime)
        {
            Caption = 'Signed On';
            Editable = false;
        }
        field(22; "Signed By User"; Code[50])
        {
            Caption = 'Signed By User';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Contract No.", "Line No.") { Clustered = true; }
        key(Signatory; "Signatory Code") { }
    }
}
