table 50000 "RE Project"
{
    Caption = 'Real Estate Project';
    DataClassification = CustomerContent;
    LookupPageId = "RE Project List";
    DrillDownPageId = "RE Project List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Property Nos."; Code[20])
        {
            Caption = 'Property Nos.';
            TableRelation = "No. Series";
        }
        field(4; "Contract Nos."; Code[20])
        {
            Caption = 'Contract Nos.';
            TableRelation = "No. Series";
        }
        field(5; "Tenant Nos."; Code[20])
        {
            Caption = 'Tenant Nos.';
            TableRelation = "No. Series";
        }
        field(6; "Default Bank Account No."; Code[20])
        {
            Caption = 'Default Bank Account No.';
            TableRelation = "Bank Account";
        }
        field(7; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";
        }
        field(8; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
        }
        field(9; "Rent G/L Account No."; Code[20])
        {
            Caption = 'Rent G/L Account No.';
            TableRelation = "G/L Account";
        }
        field(10; "Deposit G/L Account No."; Code[20])
        {
            Caption = 'Deposit G/L Account No.';
            TableRelation = "G/L Account";
        }
        field(11; "Tax G/L Account No."; Code[20])
        {
            Caption = 'Tax G/L Account No.';
            TableRelation = "G/L Account";
        }
        field(12; "Fee G/L Account No."; Code[20])
        {
            Caption = 'Fee G/L Account No.';
            TableRelation = "G/L Account";
        }
        field(13; "Require Two Signatories"; Boolean)
        {
            Caption = 'Require Two Signatories';
        }
        field(14; "Default Holding Type"; Enum "RE Deposit Holding Type")
        {
            Caption = 'Default Deposit Holding Type';
        }
        field(15; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}

table 50001 "RE Project Signatory"
{
    Caption = 'Project Signatory';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            TableRelation = "RE Project";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Signatory Code"; Code[20])
        {
            Caption = 'Signatory Code';
            NotBlank = true;
        }
        field(4; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(5; Role; Text[50])
        {
            Caption = 'Role';
        }
        field(6; Required; Boolean)
        {
            Caption = 'Required';
            InitValue = true;
        }
        field(7; "Valid From"; Date)
        {
            Caption = 'Valid From';
        }
        field(8; "Valid To"; Date)
        {
            Caption = 'Valid To';
        }
    }

    keys
    {
        key(PK; "Project No.", "Line No.") { Clustered = true; }
        key(Code; "Project No.", "Signatory Code") { }
    }
}

table 50002 "RE Contract Template"
{
    Caption = 'Contract Template';
    DataClassification = CustomerContent;
    LookupPageId = "RE Contract Template List";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            TableRelation = "RE Project";
        }
        field(4; Active; Boolean)
        {
            Caption = 'Active';
            InitValue = true;
        }
        field(5; "Requires Legal Review"; Boolean)
        {
            Caption = 'Requires Legal Review';
        }
        field(6; "Template Version"; Code[20])
        {
            Caption = 'Template Version';
        }
        field(7; "Mandatory Clauses Confirmed"; Boolean)
        {
            Caption = 'Mandatory Clauses Confirmed';
        }
        field(8; "Default Term Months"; Integer)
        {
            Caption = 'Default Term (Months)';
            MinValue = 0;
        }
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
        key(Project; "Project No.", Active) { }
    }
}

table 50003 "RE Property"
{
    Caption = 'Property';
    DataClassification = CustomerContent;
    LookupPageId = "RE Property List";
    DrillDownPageId = "RE Property List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            TableRelation = "RE Project";
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(4; "Property Type"; Enum "RE Property Type")
        {
            Caption = 'Property Type';
        }
        field(5; "Rental Status"; Enum "RE Rental Status")
        {
            Caption = 'Rental Status';
        }
        field(6; Address; Text[100])
        {
            Caption = 'Address';
        }
        field(7; City; Text[50])
        {
            Caption = 'City';
        }
        field(8; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
        }
        field(9; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(10; "Area Sqm"; Decimal)
        {
            Caption = 'Area (Sqm)';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(11; "Technical Specs"; Text[250])
        {
            Caption = 'Technical Specifications';
        }
        field(12; "Registry No."; Text[50])
        {
            Caption = 'Land Registry No.';
        }
        field(13; "Cadastral Reference"; Text[50])
        {
            Caption = 'Cadastral Reference';
        }
        field(14; "Appraisal Value"; Decimal)
        {
            Caption = 'Appraisal Value';
            AutoFormatType = 1;
            MinValue = 0;
        }
        field(15; "Appraisal Date"; Date)
        {
            Caption = 'Appraisal Date';
        }
        field(16; "Energy Rating"; Code[10])
        {
            Caption = 'Energy Rating';
        }
        field(17; "Energy Certificate No."; Text[50])
        {
            Caption = 'Energy Certificate No.';
        }
        field(18; "Energy Certificate Expiry"; Date)
        {
            Caption = 'Energy Certificate Expiry';
        }
        field(19; "Annual IBI Amount"; Decimal)
        {
            Caption = 'Annual IBI Amount';
            AutoFormatType = 1;
            MinValue = 0;
        }
        field(20; "Available Sublease Area Sqm"; Decimal)
        {
            Caption = 'Available Sublease Area (Sqm)';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(21; "Last Status Change"; DateTime)
        {
            Caption = 'Last Status Change';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
        key(ProjectStatus; "Project No.", "Rental Status") { }
        key(Type; "Property Type", "Rental Status") { }
    }
}

table 50004 "RE Tenant"
{
    Caption = 'Tenant';
    DataClassification = CustomerContent;
    LookupPageId = "RE Tenant List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(3; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(4; "E-Mail"; Text[80])
        {
            Caption = 'Email';
            ExtendedDatatype = EMail;
        }
        field(5; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(6; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
        }
        field(7; "Identification No."; Text[30])
        {
            Caption = 'Identification No.';
        }
        field(8; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
        key(Customer; "Customer No.") { }
    }
}

table 50005 "RE Contract"
{
    Caption = 'Lease Contract';
    DataClassification = CustomerContent;
    LookupPageId = "RE Contract List";
    DrillDownPageId = "RE Contract List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;

            trigger OnValidate()
            begin
                CheckEditableCriticalField(FieldCaption("No."));
            end;
        }
        field(2; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            TableRelation = "RE Project";

            trigger OnValidate()
            begin
                CheckEditableCriticalField(FieldCaption("Project No."));
            end;
        }
        field(3; "Primary Tenant No."; Code[20])
        {
            Caption = 'Primary Tenant No.';
            TableRelation = "RE Tenant";

            trigger OnValidate()
            var
                Tenant: Record "RE Tenant";
            begin
                CheckEditableCriticalField(FieldCaption("Primary Tenant No."));
                if Tenant.Get("Primary Tenant No.") then
                    "Customer No." := Tenant."Customer No.";
            end;
        }
        field(4; "Primary Property No."; Code[20])
        {
            Caption = 'Primary Property No.';
            TableRelation = "RE Property";

            trigger OnValidate()
            begin
                CheckEditableCriticalField(FieldCaption("Primary Property No."));
            end;
        }
        field(5; "Start Date"; Date)
        {
            Caption = 'Start Date';

            trigger OnValidate()
            begin
                CheckEditableCriticalField(FieldCaption("Start Date"));
            end;
        }
        field(6; "End Date"; Date)
        {
            Caption = 'End Date';

            trigger OnValidate()
            begin
                CheckEditableCriticalField(FieldCaption("End Date"));
                if ("End Date" <> 0D) and ("Start Date" <> 0D) and ("End Date" < "Start Date") then
                    Error(EndBeforeStartErr);
            end;
        }
        field(7; Status; Enum "RE Contract Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(8; "Base Rent"; Decimal)
        {
            Caption = 'Base Rent';
            AutoFormatType = 1;
            MinValue = 0;

            trigger OnValidate()
            begin
                CheckEditableCriticalField(FieldCaption("Base Rent"));
            end;
        }
        field(9; "Billing Frequency Months"; Integer)
        {
            Caption = 'Billing Frequency (Months)';
            InitValue = 1;
            MinValue = 1;
            MaxValue = 12;
        }
        field(10; "Deposit Amount"; Decimal)
        {
            Caption = 'Deposit Amount';
            AutoFormatType = 1;
            MinValue = 0;

            trigger OnValidate()
            begin
                CheckEditableCriticalField(FieldCaption("Deposit Amount"));
            end;
        }
        field(11; "Deposit Holding Type"; Enum "RE Deposit Holding Type")
        {
            Caption = 'Deposit Holding Type';
        }
        field(12; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";
        }
        field(13; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
        }
        field(14; "Contract Template Code"; Code[20])
        {
            Caption = 'Contract Template Code';
            TableRelation = "RE Contract Template".Code where("Project No." = field("Project No."), Active = const(true));

            trigger OnValidate()
            begin
                CheckEditableCriticalField(FieldCaption("Contract Template Code"));
            end;
        }
        field(15; Signed; Boolean)
        {
            Caption = 'Signed';
            Editable = false;
        }
        field(16; "Signed Date"; Date)
        {
            Caption = 'Signed Date';
            Editable = false;
        }
        field(17; "Legal Review Completed"; Boolean)
        {
            Caption = 'Legal Review Completed';
        }
        field(18; "Signatory 1 Code"; Code[20])
        {
            Caption = 'Signatory 1 Code';

            trigger OnValidate()
            begin
                CheckEditableCriticalField(FieldCaption("Signatory 1 Code"));
            end;
        }
        field(19; "Signatory 2 Code"; Code[20])
        {
            Caption = 'Signatory 2 Code';

            trigger OnValidate()
            begin
                CheckEditableCriticalField(FieldCaption("Signatory 2 Code"));
            end;
        }
        field(20; "Parent Contract No."; Code[20])
        {
            Caption = 'Parent Contract No.';
            TableRelation = "RE Contract";

            trigger OnValidate()
            begin
                if "Parent Contract No." = "No." then
                    Error(SelfParentErr);
            end;
        }
        field(21; "Is Sublease"; Boolean)
        {
            Caption = 'Is Sublease';
        }
        field(22; "Sublease Area Sqm"; Decimal)
        {
            Caption = 'Sublease Area (Sqm)';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(23; "Last Billing Date"; Date)
        {
            Caption = 'Last Billing Date';
            Editable = false;
        }
        field(24; "Termination Date"; Date)
        {
            Caption = 'Termination Date';
        }
        field(25; "Termination Reason"; Text[100])
        {
            Caption = 'Termination Reason';
        }
        field(26; "Termination Type"; Enum "RE Termination Type")
        {
            Caption = 'Termination Type';
        }
        field(27; "Renewal Count"; Integer)
        {
            Caption = 'Renewal Count';
            Editable = false;
        }
        field(28; "Last Rent Update Date"; Date)
        {
            Caption = 'Last Rent Update Date';
            Editable = false;
        }
        field(29; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            Editable = false;
        }
        field(30; "Entry Right Fee"; Decimal)
        {
            Caption = 'Entry Right Fee';
            AutoFormatType = 1;
            MinValue = 0;
        }
        field(31; "Entry Right Posted"; Boolean)
        {
            Caption = 'Entry Right Posted';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
        key(PropertyDates; "Primary Property No.", "Start Date", "End Date", Status) { }
        key(Parent; "Parent Contract No.", "Is Sublease") { }
        key(Tenant; "Primary Tenant No.", Status) { }
    }

    trigger OnInsert()
    begin
        Status := Status::Draft;
        if "Billing Frequency Months" = 0 then
            "Billing Frequency Months" := 1;
    end;

    var
        EndBeforeStartErr: Label 'End Date cannot be before Start Date.';
        SelfParentErr: Label 'A contract cannot be its own parent.';
        LockedFieldErr: Label '%1 cannot be changed after the contract has been signed or activated.', Comment = '%1 = field caption';

    local procedure CheckEditableCriticalField(FieldName: Text)
    begin
        if IsTemporary then
            exit;
        if xRec."No." = '' then
            exit;
        if xRec.Signed or (xRec.Status in [xRec.Status::Active, xRec.Status::"Cancellation Process", xRec.Status::Closed]) then
            Error(LockedFieldErr, FieldName);
    end;
}

table 50006 "RE Contract Property"
{
    Caption = 'Contract Property';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "RE Contract";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Property No."; Code[20])
        {
            Caption = 'Property No.';
            TableRelation = "RE Property";
        }
        field(4; "Area Sqm"; Decimal)
        {
            Caption = 'Area (Sqm)';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(5; "Base Rent Share"; Decimal)
        {
            Caption = 'Base Rent Share';
            AutoFormatType = 1;
            MinValue = 0;
        }
        field(6; Released; Boolean)
        {
            Caption = 'Released';
        }
    }

    keys
    {
        key(PK; "Contract No.", "Line No.") { Clustered = true; }
        key(Property; "Property No.") { }
    }
}

table 50007 "RE Contract Tenant"
{
    Caption = 'Contract Tenant';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "RE Contract";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Tenant No."; Code[20])
        {
            Caption = 'Tenant No.';
            TableRelation = "RE Tenant";
        }
        field(4; "Responsibility %"; Decimal)
        {
            Caption = 'Responsibility %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;
        }
        field(5; Primary; Boolean)
        {
            Caption = 'Primary';
        }
    }

    keys
    {
        key(PK; "Contract No.", "Line No.") { Clustered = true; }
        key(Tenant; "Tenant No.") { }
    }
}

table 50008 "RE Billing Schedule"
{
    Caption = 'Rental Billing Schedule';
    DataClassification = CustomerContent;
    LookupPageId = "RE Billing Schedule List";

    fields
    {
        field(1; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "RE Contract";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Billing Date"; Date)
        {
            Caption = 'Billing Date';
        }
        field(4; "Period Start"; Date)
        {
            Caption = 'Period Start';
        }
        field(5; "Period End"; Date)
        {
            Caption = 'Period End';
        }
        field(6; "Concept Type"; Enum "RE Billing Concept Type")
        {
            Caption = 'Concept Type';
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; Amount; Decimal)
        {
            Caption = 'Amount';
            AutoFormatType = 1;
        }
        field(9; Status; Enum "RE Billing Status")
        {
            Caption = 'Status';
        }
        field(10; "Sales Invoice No."; Code[20])
        {
            Caption = 'Sales Invoice No.';
            Editable = false;
        }
        field(11; Simulated; Boolean)
        {
            Caption = 'Simulated';
        }
        field(12; "Posted Invoice No."; Code[20])
        {
            Caption = 'Posted Invoice No.';
            Editable = false;
        }
        field(13; "Tax Year"; Integer)
        {
            Caption = 'Tax Year';
        }
    }

    keys
    {
        key(PK; "Contract No.", "Line No.") { Clustered = true; }
        key(Billing; Status, "Billing Date") { }
        key(NoDoubleBilling; "Contract No.", "Concept Type", "Period Start", "Period End") { }
    }
}

table 50009 "RE Deposit Entry"
{
    Caption = 'Rental Deposit Entry';
    DataClassification = CustomerContent;
    LookupPageId = "RE Deposit Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "RE Contract";
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(4; "Entry Type"; Enum "RE Deposit Entry Type")
        {
            Caption = 'Entry Type';
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
            AutoFormatType = 1;
        }
        field(6; "External Agency"; Boolean)
        {
            Caption = 'External Agency';
        }
        field(7; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(8; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account";
        }
        field(9; Reversed; Boolean)
        {
            Caption = 'Reversed';
        }
        field(10; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Contract; "Contract No.", "Posting Date") { }
    }
}

table 50010 "RE Rent History"
{
    Caption = 'Rent History';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "RE Contract";
        }
        field(3; "Effective Date"; Date)
        {
            Caption = 'Effective Date';
        }
        field(4; "Old Rent"; Decimal)
        {
            Caption = 'Old Rent';
            AutoFormatType = 1;
        }
        field(5; "New Rent"; Decimal)
        {
            Caption = 'New Rent';
            AutoFormatType = 1;
        }
        field(6; "Update Method"; Text[50])
        {
            Caption = 'Update Method';
        }
        field(7; "Index Code"; Code[20])
        {
            Caption = 'Index Code';
        }
        field(8; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Contract; "Contract No.", "Effective Date") { }
    }
}

table 50011 "RE IBI Entry"
{
    Caption = 'IBI Recharge Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Property No."; Code[20])
        {
            Caption = 'Property No.';
            TableRelation = "RE Property";
        }
        field(3; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "RE Contract";
        }
        field(4; "Tax Year"; Integer)
        {
            Caption = 'Tax Year';
        }
        field(5; "Effective Date"; Date)
        {
            Caption = 'Effective Date';
        }
        field(6; "Annual Amount"; Decimal)
        {
            Caption = 'Annual Amount';
            AutoFormatType = 1;
        }
        field(7; "Already Billed Amount"; Decimal)
        {
            Caption = 'Already Billed Amount';
            AutoFormatType = 1;
        }
        field(8; "Catch-up Amount"; Decimal)
        {
            Caption = 'Catch-up Amount';
            AutoFormatType = 1;
        }
        field(9; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(PropertyYear; "Property No.", "Tax Year") { }
        key(ContractYear; "Contract No.", "Tax Year") { }
    }
}

table 50012 "RE Audit Entry"
{
    Caption = 'Rental Audit Entry';
    DataClassification = CustomerContent;
    LookupPageId = "RE Audit Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
        }
        field(3; "Record No."; Code[20])
        {
            Caption = 'Record No.';
        }
        field(4; "Action"; Text[50])
        {
            Caption = 'Action';
        }
        field(5; "Field Name"; Text[50])
        {
            Caption = 'Field Name';
        }
        field(6; "Old Value"; Text[250])
        {
            Caption = 'Old Value';
        }
        field(7; "New Value"; Text[250])
        {
            Caption = 'New Value';
        }
        field(8; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(9; "Created At"; DateTime)
        {
            Caption = 'Created At';
        }
        field(10; Comment; Text[250])
        {
            Caption = 'Comment';
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Record; "Table No.", "Record No.") { }
        key(CreatedAt; "Created At") { }
    }
}
