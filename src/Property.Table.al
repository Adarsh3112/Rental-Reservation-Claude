table 50102 "BSB Property"
{
    Caption = 'Property';
    DataClassification = CustomerContent;
    LookupPageId = "BSB Properties";
    DrillDownPageId = "BSB Properties";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(10; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            TableRelation = "BSB Real Estate Project";
            NotBlank = true;
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(12; "Property Type"; Enum "BSB Property Type")
        {
            Caption = 'Property Type';
        }
        field(13; "Rental Status"; Enum "BSB Property Rental Status")
        {
            Caption = 'Rental Status';

            trigger OnValidate()
            var
                AuditMgmt: Codeunit "BSB Audit Log Mgmt";
            begin
                if Rec."Rental Status" <> xRec."Rental Status" then
                    AuditMgmt.LogStatusChange(Database::"BSB Property", Rec."No.", Format(xRec."Rental Status"), Format(Rec."Rental Status"));
            end;
        }
        field(20; Address; Text[100])
        {
            Caption = 'Address';
        }
        field(21; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(22; City; Text[50])
        {
            Caption = 'City';
        }
        field(23; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            TableRelation = "Post Code";
        }
        field(24; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(30; "Area (sqm)"; Decimal)
        {
            Caption = 'Area (sqm)';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
        }
        field(31; "Usable Area (sqm)"; Decimal)
        {
            Caption = 'Usable Area (sqm)';
            DecimalPlaces = 0 : 2;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Usable Area (sqm)" > "Area (sqm)" then
                    Error('Usable area cannot exceed total area.');
            end;
        }
        field(32; "Number of Rooms"; Integer)
        {
            Caption = 'Number of Rooms';
            MinValue = 0;
        }
        field(33; "Number of Bathrooms"; Integer)
        {
            Caption = 'Number of Bathrooms';
            MinValue = 0;
        }
        field(34; "Year Built"; Integer)
        {
            Caption = 'Year Built';
            MinValue = 0;
        }
        field(40; "Cadastral Reference"; Code[30])
        {
            Caption = 'Cadastral Reference';
        }
        field(41; "Land Registry No."; Code[30])
        {
            Caption = 'Land Registry No.';
        }
        field(42; "Land Registry Section"; Text[30])
        {
            Caption = 'Land Registry Section';
        }
        field(50; "Appraisal Value"; Decimal)
        {
            Caption = 'Appraisal Value';
            AutoFormatType = 1;
            MinValue = 0;
        }
        field(51; "Appraisal Date"; Date)
        {
            Caption = 'Appraisal Date';
        }
        field(52; "Annual Property Tax (IBI)"; Decimal)
        {
            Caption = 'Annual Property Tax (IBI)';
            AutoFormatType = 1;
            MinValue = 0;

            trigger OnValidate()
            var
                AuditMgmt: Codeunit "BSB Audit Log Mgmt";
            begin
                if Rec."Annual Property Tax (IBI)" <> xRec."Annual Property Tax (IBI)" then
                    AuditMgmt.LogAction(
                        Database::"BSB Property",
                        Rec."No.",
                        Enum::"BSB Audit Action Type"::"Tax Update",
                        StrSubstNo('IBI changed from %1 to %2', xRec."Annual Property Tax (IBI)", Rec."Annual Property Tax (IBI)"));
            end;
        }
        field(53; "Tax Period"; Enum "BSB Tax Period Type")
        {
            Caption = 'Tax Period';
        }
        field(60; "Energy Certificate"; Enum "BSB Energy Certificate")
        {
            Caption = 'Energy Certificate';
        }
        field(61; "Energy Cert. Expiry"; Date)
        {
            Caption = 'Energy Certificate Expiry Date';
        }
        field(62; "Energy Cert. No."; Code[30])
        {
            Caption = 'Energy Certificate No.';
        }
        field(70; "Suggested Monthly Rent"; Decimal)
        {
            Caption = 'Suggested Monthly Rent';
            AutoFormatType = 1;
            MinValue = 0;
        }
        field(71; "Available From"; Date)
        {
            Caption = 'Available From';
        }
        field(72; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(80; "Current Contract No."; Code[20])
        {
            Caption = 'Current Active Contract No.';
            FieldClass = FlowField;
            CalcFormula = lookup("BSB Lease Contract Property"."Contract No." where("Property No." = field("No.")));
            Editable = false;
        }
        field(81; "Has Active Contract"; Boolean)
        {
            Caption = 'Has Active Contract';
            FieldClass = FlowField;
            CalcFormula = exist("BSB Lease Contract Property" where("Property No." = field("No."), "Contract Active" = const(true)));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
        key(Project; "Project No.") { }
        key(Status; "Rental Status") { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, City, "Rental Status") { }
        fieldgroup(Brick; "No.", Description, City, "Rental Status", "Area (sqm)") { }
    }

    trigger OnInsert()
    var
        Project: Record "BSB Real Estate Project";
        Setup: Record "BSB Real Estate Setup";
        NoSeries: Codeunit "No. Series";
        SeriesCode: Code[20];
    begin
        if "No." = '' then begin
            SeriesCode := '';
            if Project.Get("Project No.") then
                SeriesCode := Project."Property Nos.";
            if SeriesCode = '' then begin
                Setup.GetSetup();
                Setup.TestField("Property Nos.");
                SeriesCode := Setup."Property Nos.";
            end;
            "No." := NoSeries.GetNextNo(SeriesCode, WorkDate());
        end;
    end;

    trigger OnDelete()
    var
        ContractProperty: Record "BSB Lease Contract Property";
    begin
        ContractProperty.SetRange("Property No.", "No.");
        if not ContractProperty.IsEmpty() then
            Error('Cannot delete property %1: it is linked to one or more contracts.', "No.");
    end;
}
