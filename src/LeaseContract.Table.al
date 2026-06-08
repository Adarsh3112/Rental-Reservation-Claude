table 50103 "BSB Lease Contract"
{
    Caption = 'Lease Contract';
    DataClassification = CustomerContent;
    LookupPageId = "BSB Lease Contracts";
    DrillDownPageId = "BSB Lease Contracts";

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

            trigger OnValidate()
            var
                Project: Record "BSB Real Estate Project";
            begin
                TestNotLocked(FieldNo("Project No."));
                if Project.Get("Project No.") then begin
                    if "Payment Terms Code" = '' then
                        "Payment Terms Code" := Project."Default Payment Terms";
                    if "Payment Method Code" = '' then
                        "Payment Method Code" := Project."Default Payment Method";
                    if "Contract Template Code" = '' then
                        "Contract Template Code" := Project."Default Contract Template";
                    if "Bank Account Code" = '' then
                        "Bank Account Code" := Project."Default Bank Account";
                end;
            end;
        }
        field(11; "Contract Template Code"; Code[20])
        {
            Caption = 'Contract Template Code';
            TableRelation = "BSB Contract Template";

            trigger OnValidate()
            begin
                TestNotLocked(FieldNo("Contract Template Code"));
            end;
        }
        field(12; "Tenant Customer No."; Code[20])
        {
            Caption = 'Primary Tenant (Customer)';
            TableRelation = Customer;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                TestNotLocked(FieldNo("Tenant Customer No."));
                if Customer.Get("Tenant Customer No.") then
                    "Tenant Name" := Customer.Name;
            end;
        }
        field(13; "Tenant Name"; Text[100])
        {
            Caption = 'Tenant Name';
        }
        field(20; "Start Date"; Date)
        {
            Caption = 'Start Date';

            trigger OnValidate()
            begin
                TestNotLocked(FieldNo("Start Date"));
                if ("End Date" <> 0D) and ("Start Date" > "End Date") then
                    Error('Start date cannot be later than end date.');
            end;
        }
        field(21; "End Date"; Date)
        {
            Caption = 'End Date';

            trigger OnValidate()
            begin
                if ("Start Date" <> 0D) and ("End Date" <> 0D) and ("End Date" < "Start Date") then
                    Error('End date cannot be earlier than start date.');
            end;
        }
        field(22; "Original End Date"; Date)
        {
            Caption = 'Original End Date';
            Editable = false;
        }
        field(23; "Termination Date"; Date)
        {
            Caption = 'Termination Date';
            Editable = false;
        }
        field(24; "Termination Reason"; Text[100])
        {
            Caption = 'Termination Reason';
        }
        field(30; Status; Enum "BSB Contract Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(31; "Is Sublease"; Boolean)
        {
            Caption = 'Is Sublease';
        }
        field(32; "Parent Contract No."; Code[20])
        {
            Caption = 'Parent Contract No.';
            TableRelation = "BSB Lease Contract";

            trigger OnValidate()
            var
                Parent: Record "BSB Lease Contract";
            begin
                if "Parent Contract No." = '' then
                    exit;
                if "Parent Contract No." = "No." then
                    Error('A contract cannot be its own parent.');
                Parent.Get("Parent Contract No.");
                if Parent."Is Sublease" then
                    Error('Sub-subleasing is not permitted. Contract %1 is already a sublease.', Parent."No.");
                "Is Sublease" := true;
            end;
        }
        field(40; "Base Rent"; Decimal)
        {
            Caption = 'Base Rent (per Period)';
            AutoFormatType = 1;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestNotLocked(FieldNo("Base Rent"));
            end;
        }
        field(41; "Billing Frequency"; Enum "BSB Billing Frequency")
        {
            Caption = 'Billing Frequency';

            trigger OnValidate()
            begin
                TestNotLocked(FieldNo("Billing Frequency"));
            end;
        }
        field(42; "Billing Day of Month"; Integer)
        {
            Caption = 'Billing Day of Month';
            MinValue = 0;
            MaxValue = 31;
        }
        field(43; "Deposit Amount"; Decimal)
        {
            Caption = 'Deposit Amount';
            AutoFormatType = 1;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestNotLocked(FieldNo("Deposit Amount"));
            end;
        }
        field(44; "Deposit Holder"; Enum "BSB Deposit Holder Type")
        {
            Caption = 'Deposit Holder';

            trigger OnValidate()
            begin
                TestNotLocked(FieldNo("Deposit Holder"));
            end;
        }
        field(45; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(50; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";
        }
        field(51; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
        }
        field(52; "Bank Account Code"; Code[20])
        {
            Caption = 'Bank Account Code';
            TableRelation = "Bank Account";
        }
        field(53; "IBI Recharge Active"; Boolean)
        {
            Caption = 'IBI Recharge Active';
        }
        field(60; "Signed"; Boolean)
        {
            Caption = 'Contract Signed';
            Editable = false;
        }
        field(61; "Signed On"; DateTime)
        {
            Caption = 'Signed On';
            Editable = false;
        }
        field(62; "Activated On"; DateTime)
        {
            Caption = 'Activated On';
            Editable = false;
        }
        field(63; "Activated By"; Code[50])
        {
            Caption = 'Activated By';
            Editable = false;
        }
        field(64; "Closed On"; DateTime)
        {
            Caption = 'Closed On';
            Editable = false;
        }
        field(65; "Closed By"; Code[50])
        {
            Caption = 'Closed By';
            Editable = false;
        }
        field(70; "Last Rent Update Date"; Date)
        {
            Caption = 'Last Rent Update Date';
            Editable = false;
        }
        field(71; "Next Billing Date"; Date)
        {
            Caption = 'Next Billing Date';
            Editable = false;
        }
        field(72; "Last Billed Through"; Date)
        {
            Caption = 'Last Billed Through';
            Editable = false;
        }
        field(80; "Property Count"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Property Count';
            CalcFormula = count("BSB Lease Contract Property" where("Contract No." = field("No.")));
            Editable = false;
        }
        field(81; "Tenant Count"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Tenant Count';
            CalcFormula = count("BSB Lease Contract Tenant" where("Contract No." = field("No.")));
            Editable = false;
        }
        field(82; "Signed Signatory Count"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Signed Signatories';
            CalcFormula = count("BSB Contract Signatory" where("Contract No." = field("No."), "Has Signed" = const(true)));
            Editable = false;
        }
        field(83; "Required Signatory Count"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Required Signatories';
            CalcFormula = count("BSB Contract Signatory" where("Contract No." = field("No.")));
            Editable = false;
        }
        field(84; "Sublease Area (sqm)"; Decimal)
        {
            FieldClass = FlowField;
            Caption = 'Sublease Area (sqm)';
            CalcFormula = sum("BSB Lease Contract Property"."Area Used (sqm)" where("Contract No." = field("No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
        key(Project; "Project No.") { }
        key(Status; Status) { }
        key(Tenant; "Tenant Customer No.") { }
        key(Parent; "Parent Contract No.") { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Tenant Name", "Project No.", Status) { }
        fieldgroup(Brick; "No.", "Tenant Name", "Project No.", Status, "Base Rent") { }
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
                SeriesCode := Project."Contract Nos.";
            if SeriesCode = '' then begin
                Setup.GetSetup();
                Setup.TestField("Contract Nos.");
                SeriesCode := Setup."Contract Nos.";
            end;
            "No." := NoSeries.GetNextNo(SeriesCode, WorkDate());
        end;
    end;

    trigger OnDelete()
    begin
        if Status in [Status::Active, Status::"In Cancellation"] then
            Error('Cannot delete a contract in status %1.', Status);
        DeleteRelatedRecords();
    end;

    local procedure DeleteRelatedRecords()
    var
        PropertyLine: Record "BSB Lease Contract Property";
        TenantLine: Record "BSB Lease Contract Tenant";
        BillingLine: Record "BSB Lease Contract Billing";
        Installment: Record "BSB Lease Installment";
        Signatory: Record "BSB Contract Signatory";
    begin
        PropertyLine.SetRange("Contract No.", "No.");
        PropertyLine.DeleteAll(true);
        TenantLine.SetRange("Contract No.", "No.");
        TenantLine.DeleteAll(true);
        BillingLine.SetRange("Contract No.", "No.");
        BillingLine.DeleteAll(true);
        Installment.SetRange("Contract No.", "No.");
        Installment.DeleteAll(true);
        Signatory.SetRange("Contract No.", "No.");
        Signatory.DeleteAll(true);
    end;

    procedure IsLocked(): Boolean
    var
        Setup: Record "BSB Real Estate Setup";
    begin
        Setup.GetSetup();
        if not Setup."Lock Critical After Sign" then
            exit(false);
        exit(Signed and (Status in [Status::Active, Status::"In Cancellation", Status::Closed]));
    end;

    local procedure TestNotLocked(ChangedFieldNo: Integer)
    var
        AuditMgmt: Codeunit "BSB Audit Log Mgmt";
    begin
        if IsLocked() then begin
            AuditMgmt.LogAction(
                Database::"BSB Lease Contract",
                "No.",
                Enum::"BSB Audit Action Type"::"Locked Field Attempt",
                StrSubstNo('Attempt to modify locked field %1', ChangedFieldNo));
            Error('Contract %1 is signed and active. Field cannot be changed.', "No.");
        end;
    end;
}

table 50104 "BSB Lease Contract Property"
{
    Caption = 'Lease Contract Property';
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
        field(10; "Property No."; Code[20])
        {
            Caption = 'Property No.';
            TableRelation = "BSB Property";
            NotBlank = true;

            trigger OnValidate()
            var
                Property: Record "BSB Property";
            begin
                if Property.Get("Property No.") then begin
                    "Property Description" := Property.Description;
                    "Project No." := Property."Project No.";
                    "Property Area (sqm)" := Property."Area (sqm)";
                    if "Area Used (sqm)" = 0 then
                        "Area Used (sqm)" := Property."Area (sqm)";
                end;
            end;
        }
        field(11; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            TableRelation = "BSB Real Estate Project";
            Editable = false;
        }
        field(12; "Property Description"; Text[100])
        {
            Caption = 'Property Description';
            Editable = false;
        }
        field(13; "Property Area (sqm)"; Decimal)
        {
            Caption = 'Property Area (sqm)';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(14; "Area Used (sqm)"; Decimal)
        {
            Caption = 'Area Used (sqm)';
            DecimalPlaces = 0 : 2;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Property Area (sqm)" > 0 then
                    if "Area Used (sqm)" > "Property Area (sqm)" then
                        Error('Area used (%1) cannot exceed property area (%2).', "Area Used (sqm)", "Property Area (sqm)");
            end;
        }
        field(20; "Rent Allocation %"; Decimal)
        {
            Caption = 'Rent Allocation %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;
        }
        field(30; "Contract Active"; Boolean)
        {
            Caption = 'Contract Active';
            FieldClass = FlowField;
            CalcFormula = exist("BSB Lease Contract" where("No." = field("Contract No."), Status = const(Active)));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Contract No.", "Line No.") { Clustered = true; }
        key(Property; "Property No.") { }
    }
}

table 50105 "BSB Lease Contract Tenant"
{
    Caption = 'Lease Contract Tenant';
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
        field(10; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if Customer.Get("Customer No.") then begin
                    "Tenant Name" := Customer.Name;
                    "Tax Identifier" := Customer."VAT Registration No.";
                end;
            end;
        }
        field(11; "Tenant Name"; Text[100])
        {
            Caption = 'Tenant Name';
        }
        field(12; "Tax Identifier"; Code[30])
        {
            Caption = 'Tax Identifier';
        }
        field(13; "Share %"; Decimal)
        {
            Caption = 'Share %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;
        }
        field(14; "Is Primary"; Boolean)
        {
            Caption = 'Is Primary Tenant';
        }
    }

    keys
    {
        key(PK; "Contract No.", "Line No.") { Clustered = true; }
        key(Customer; "Customer No.") { }
    }
}

table 50106 "BSB Lease Contract Billing"
{
    Caption = 'Lease Contract Billing Concept';
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
        field(10; "Concept Type"; Enum "BSB Billing Concept Type")
        {
            Caption = 'Concept Type';
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(12; Amount; Decimal)
        {
            Caption = 'Amount';
            AutoFormatType = 1;
            MinValue = 0;
        }
        field(13; "Billing Frequency"; Enum "BSB Billing Frequency")
        {
            Caption = 'Billing Frequency';
        }
        field(14; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account";
        }
        field(15; "Tax Group Code"; Code[20])
        {
            Caption = 'Tax Group Code';
            TableRelation = "Tax Group";
        }
        field(16; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(20; "Active"; Boolean)
        {
            Caption = 'Active';
            InitValue = true;
        }
        field(21; "One-Time Already Charged"; Boolean)
        {
            Caption = 'One-Time Already Charged';
            Editable = false;
        }
        field(22; "Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(23; "End Date"; Date)
        {
            Caption = 'End Date';
        }
    }

    keys
    {
        key(PK; "Contract No.", "Line No.") { Clustered = true; }
        key(Type; "Concept Type") { }
    }
}

table 50107 "BSB Lease Installment"
{
    Caption = 'Lease Installment';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "BSB Lease Contract";
        }
        field(2; "Installment No."; Integer)
        {
            Caption = 'Installment No.';
        }
        field(10; "Billing Line No."; Integer)
        {
            Caption = 'Billing Line No.';
        }
        field(11; "Concept Type"; Enum "BSB Billing Concept Type")
        {
            Caption = 'Concept Type';
        }
        field(12; "Description"; Text[100])
        {
            Caption = 'Description';
        }
        field(20; "Period Start"; Date)
        {
            Caption = 'Period Start';
        }
        field(21; "Period End"; Date)
        {
            Caption = 'Period End';
        }
        field(22; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(30; Amount; Decimal)
        {
            Caption = 'Amount';
            AutoFormatType = 1;
            MinValue = 0;
        }
        field(40; Status; Enum "BSB Installment Status")
        {
            Caption = 'Status';
        }
        field(41; "Posted Invoice No."; Code[20])
        {
            Caption = 'Posted Invoice No.';
            Editable = false;
        }
        field(42; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            Editable = false;
        }
        field(50; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
    }

    keys
    {
        key(PK; "Contract No.", "Installment No.") { Clustered = true; }
        key(DueDate; "Due Date", Status) { }
        key(PeriodStart; "Period Start") { }
        key(Status; Status) { }
    }
}
