enum 50000 "RE Rental Status"
{
    Extensible = true;

    value(0; Available) { Caption = 'Available'; }
    value(1; Reserved) { Caption = 'Reserved'; }
    value(2; Leased) { Caption = 'Leased'; }
    value(3; Maintenance) { Caption = 'Maintenance'; }
    value(4; Blocked) { Caption = 'Blocked'; }
}

enum 50001 "RE Contract Status"
{
    Extensible = true;

    value(0; Draft) { Caption = 'Pending / Draft'; }
    value(1; Active) { Caption = 'Active'; }
    value(2; "Cancellation Process") { Caption = 'In Cancellation Process'; }
    value(3; Closed) { Caption = 'Historical / Closed'; }
}

enum 50002 "RE Deposit Holding Type"
{
    Extensible = true;

    value(0; Internal) { Caption = 'Internal Holding'; }
    value(1; ExternalAgency) { Caption = 'External Agency'; }
}

enum 50003 "RE Billing Concept Type"
{
    Extensible = true;

    value(0; Rent) { Caption = 'Rent'; }
    value(1; TaxIBI) { Caption = 'Property Tax / IBI'; }
    value(2; Fee) { Caption = 'Fee'; }
    value(3; Deposit) { Caption = 'Deposit'; }
    value(4; OneTime) { Caption = 'One-Time Charge'; }
    value(5; Settlement) { Caption = 'Settlement'; }
}

enum 50004 "RE Billing Status"
{
    Extensible = true;

    value(0; Open) { Caption = 'Open'; }
    value(1; Simulated) { Caption = 'Simulated'; }
    value(2; Invoiced) { Caption = 'Invoiced'; }
    value(3; Cancelled) { Caption = 'Cancelled'; }
}

enum 50005 "RE Deposit Entry Type"
{
    Extensible = true;

    value(0; Initial) { Caption = 'Initial Posting'; }
    value(1; Transfer) { Caption = 'Transfer to Agency'; }
    value(2; Settlement) { Caption = 'Settlement'; }
    value(3; Refund) { Caption = 'Refund'; }
    value(4; Reversal) { Caption = 'Reversal'; }
}

enum 50006 "RE Property Type"
{
    Extensible = true;

    value(0; Apartment) { Caption = 'Apartment'; }
    value(1; House) { Caption = 'House'; }
    value(2; Office) { Caption = 'Office'; }
    value(3; Commercial) { Caption = 'Commercial'; }
    value(4; Industrial) { Caption = 'Industrial'; }
    value(5; ParkingSpace) { Caption = 'Parking Space'; }
    value(6; Storage) { Caption = 'Storage'; }
    value(7; Land) { Caption = 'Land'; }
}

enum 50007 "RE Termination Type"
{
    Extensible = true;

    value(0; Natural) { Caption = 'Natural End'; }
    value(1; Early) { Caption = 'Early Termination'; }
    value(2; Renunciation) { Caption = 'Tenant Renunciation'; }
    value(3; Breach) { Caption = 'Breach of Contract'; }
}
