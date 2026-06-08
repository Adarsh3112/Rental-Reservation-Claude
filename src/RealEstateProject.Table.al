table 50101 "BSB Real Estate Project"
{
    Caption = 'Real Estate Project';
    DataClassification = CustomerContent;
    LookupPageId = "BSB Real Estate Projects";
    DrillDownPageId = "BSB Real Estate Projects";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(10; "Description"; Text[100])
        {
            Caption = 'Description';
        }
        field(11; "Location"; Text[100])
        {
            Caption = 'Location';
        }
        field(12; City; Text[50])
        {
            Caption = 'City';
        }
        field(13; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(20; "Property Nos."; Code[20])
        {
            Caption = 'Property Nos.';
            TableRelation = "No. Series";
        }
        field(21; "Contract Nos."; Code[20])
        {
            Caption = 'Contract Nos.';
            TableRelation = "No. Series";
        }
        field(22; "Default Bank Account"; Code[20])
        {
            Caption = 'Default Bank Account';
            TableRelation = "Bank Account";
        }
        field(23; "Default Payment Terms"; Code[10])
        {
            Caption = 'Default Payment Terms';
            TableRelation = "Payment Terms";
        }
        field(24; "Default Payment Method"; Code[10])
        {
            Caption = 'Default Payment Method';
            TableRelation = "Payment Method";
        }
        field(25; "Default Contract Template"; Code[20])
        {
            Caption = 'Default Contract Template';
            TableRelation = "BSB Contract Template";
        }
        field(26; "Default Deposit G/L Account"; Code[20])
        {
            Caption = 'Default Deposit G/L Account';
            TableRelation = "G/L Account";
        }
        field(30; "Property Count"; Integer)
        {
            Caption = 'Property Count';
            FieldClass = FlowField;
            CalcFormula = count("BSB Property" where("Project No." = field("No.")));
            Editable = false;
        }
        field(31; "Active Contract Count"; Integer)
        {
            Caption = 'Active Contract Count';
            FieldClass = FlowField;
            CalcFormula = count("BSB Lease Contract" where("Project No." = field("No."), Status = const(Active)));
            Editable = false;
        }
        field(40; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, City) { }
        fieldgroup(Brick; "No.", Description, City, "Property Count") { }
    }

    trigger OnInsert()
    var
        Setup: Record "BSB Real Estate Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "No." = '' then begin
            Setup.GetSetup();
            Setup.TestField("Project Nos.");
            "No." := NoSeries.GetNextNo(Setup."Project Nos.", WorkDate());
        end;
    end;

    trigger OnDelete()
    var
        Property: Record "BSB Property";
        Contract: Record "BSB Lease Contract";
    begin
        Property.SetRange("Project No.", "No.");
        if not Property.IsEmpty() then
            Error('Cannot delete project %1: it has linked properties.', "No.");
        Contract.SetRange("Project No.", "No.");
        if not Contract.IsEmpty() then
            Error('Cannot delete project %1: it has linked contracts.', "No.");
    end;
}
