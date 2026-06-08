table 50100 "BSB Real Estate Setup"
{
    Caption = 'Real Estate Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(10; "Project Nos."; Code[20])
        {
            Caption = 'Project Nos.';
            TableRelation = "No. Series";
        }
        field(11; "Property Nos."; Code[20])
        {
            Caption = 'Property Nos.';
            TableRelation = "No. Series";
        }
        field(12; "Contract Nos."; Code[20])
        {
            Caption = 'Contract Nos.';
            TableRelation = "No. Series";
        }
        field(13; "Template Nos."; Code[20])
        {
            Caption = 'Contract Template Nos.';
            TableRelation = "No. Series";
        }
        field(14; "Deposit Entry Nos."; Code[20])
        {
            Caption = 'Deposit Entry Nos.';
            TableRelation = "No. Series";
        }
        field(20; "Deposit G/L Account"; Code[20])
        {
            Caption = 'Deposit Liability G/L Account';
            TableRelation = "G/L Account";
        }
        field(21; "External Agency G/L Account"; Code[20])
        {
            Caption = 'External Agency G/L Account';
            TableRelation = "G/L Account";
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
        field(30; "Audit Log Enabled"; Boolean)
        {
            Caption = 'Audit Log Enabled';
            InitValue = true;
        }
        field(31; "Lock Critical After Sign"; Boolean)
        {
            Caption = 'Lock Critical Fields After Signature';
            InitValue = true;
        }
        field(32; "Require Tenant Customer Link"; Boolean)
        {
            Caption = 'Require Tenant Customer Link';
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }

    procedure GetSetup()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
