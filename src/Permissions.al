permissionset 50000 "RE Rental Mgt"
{
    Assignable = true;
    Caption = 'Rental Management';

    Permissions =
        tabledata "RE Project" = RIMD,
        tabledata "RE Project Signatory" = RIMD,
        tabledata "RE Contract Template" = RIMD,
        tabledata "RE Property" = RIMD,
        tabledata "RE Tenant" = RIMD,
        tabledata "RE Contract" = RIMD,
        tabledata "RE Contract Property" = RIMD,
        tabledata "RE Contract Tenant" = RIMD,
        tabledata "RE Billing Schedule" = RIMD,
        tabledata "RE Deposit Entry" = RIMD,
        tabledata "RE Rent History" = RIMD,
        tabledata "RE IBI Entry" = RIMD,
        tabledata "RE Audit Entry" = RIMD;
}
