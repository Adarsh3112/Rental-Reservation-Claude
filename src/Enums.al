enum 50100 "BSB Property Type"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; Residential) { Caption = 'Residential'; }
    value(2; Commercial) { Caption = 'Commercial'; }
    value(3; Office) { Caption = 'Office'; }
    value(4; Industrial) { Caption = 'Industrial'; }
    value(5; Retail) { Caption = 'Retail'; }
    value(6; Parking) { Caption = 'Parking'; }
    value(7; Storage) { Caption = 'Storage'; }
    value(8; Land) { Caption = 'Land'; }
    value(9; Other) { Caption = 'Other'; }
}

enum 50101 "BSB Property Rental Status"
{
    Extensible = true;

    value(0; Available) { Caption = 'Available'; }
    value(1; Reserved) { Caption = 'Reserved'; }
    value(2; Leased) { Caption = 'Leased'; }
    value(3; "Under Maintenance") { Caption = 'Under Maintenance'; }
    value(4; "Not Commercializable") { Caption = 'Not Commercializable'; }
    value(5; "Partially Leased") { Caption = 'Partially Leased'; }
}

enum 50102 "BSB Contract Status"
{
    Extensible = true;

    value(0; Draft) { Caption = 'Draft / Pending'; }
    value(1; Active) { Caption = 'Active'; }
    value(2; "In Cancellation") { Caption = 'In Cancellation Process'; }
    value(3; Closed) { Caption = 'Historical / Closed'; }
    value(4; Rejected) { Caption = 'Rejected'; }
}

enum 50103 "BSB Billing Concept Type"
{
    Extensible = true;

    value(0; "Base Rent") { Caption = 'Base Rent'; }
    value(1; "Property Tax (IBI)") { Caption = 'Property Tax (IBI)'; }
    value(2; "Entry Right") { Caption = 'Entry Right'; }
    value(3; "Transfer Fee") { Caption = 'Transfer Fee'; }
    value(4; "Common Expenses") { Caption = 'Common Expenses'; }
    value(5; Utilities) { Caption = 'Utilities'; }
    value(6; Insurance) { Caption = 'Insurance'; }
    value(7; "Other Recurring") { Caption = 'Other Recurring'; }
    value(8; "Other One-Time") { Caption = 'Other One-Time'; }
}

enum 50104 "BSB Billing Frequency"
{
    Extensible = true;

    value(0; "One-Time") { Caption = 'One-Time'; }
    value(1; Monthly) { Caption = 'Monthly'; }
    value(2; Quarterly) { Caption = 'Quarterly'; }
    value(3; "Semi-Annual") { Caption = 'Semi-Annual'; }
    value(4; Annual) { Caption = 'Annual'; }
}

enum 50105 "BSB Deposit Holder Type"
{
    Extensible = true;

    value(0; Internal) { Caption = 'Internal (Company)'; }
    value(1; "External Agency") { Caption = 'External Agency'; }
}

enum 50106 "BSB Deposit Entry Type"
{
    Extensible = true;

    value(0; Initial) { Caption = 'Initial Posting'; }
    value(1; "Transfer to Agency") { Caption = 'Transfer to External Agency'; }
    value(2; "Return from Agency") { Caption = 'Return from External Agency'; }
    value(3; Adjustment) { Caption = 'Adjustment'; }
    value(4; "Settlement Deduction") { Caption = 'Settlement Deduction'; }
    value(5; Refund) { Caption = 'Refund to Tenant'; }
}

enum 50107 "BSB Tax Period Type"
{
    Extensible = true;

    value(0; Annual) { Caption = 'Annual'; }
    value(1; "Semi-Annual") { Caption = 'Semi-Annual'; }
    value(2; Quarterly) { Caption = 'Quarterly'; }
}

enum 50108 "BSB Signatory Role"
{
    Extensible = true;

    value(0; Landlord) { Caption = 'Landlord'; }
    value(1; Tenant) { Caption = 'Tenant'; }
    value(2; Witness) { Caption = 'Witness'; }
    value(3; "Legal Representative") { Caption = 'Legal Representative'; }
    value(4; Guarantor) { Caption = 'Guarantor'; }
}

enum 50109 "BSB Audit Action Type"
{
    Extensible = true;

    value(0; Create) { Caption = 'Create'; }
    value(1; Modify) { Caption = 'Modify'; }
    value(2; Delete) { Caption = 'Delete'; }
    value(3; "Status Change") { Caption = 'Status Change'; }
    value(4; Sign) { Caption = 'Sign'; }
    value(5; "Rent Update") { Caption = 'Rent Update'; }
    value(6; "Tax Update") { Caption = 'Tax Update'; }
    value(7; "Locked Field Attempt") { Caption = 'Locked Field Change Attempt'; }
}

enum 50110 "BSB Energy Certificate"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "A+") { Caption = 'A+'; }
    value(2; A) { Caption = 'A'; }
    value(3; B) { Caption = 'B'; }
    value(4; C) { Caption = 'C'; }
    value(5; D) { Caption = 'D'; }
    value(6; E) { Caption = 'E'; }
    value(7; F) { Caption = 'F'; }
    value(8; G) { Caption = 'G'; }
    value(9; Exempt) { Caption = 'Exempt'; }
}

enum 50111 "BSB Installment Status"
{
    Extensible = true;

    value(0; Open) { Caption = 'Open'; }
    value(1; Invoiced) { Caption = 'Invoiced'; }
    value(2; Cancelled) { Caption = 'Cancelled'; }
    value(3; "On Hold") { Caption = 'On Hold'; }
}
