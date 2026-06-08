page 50103 "BSB Properties"
{
    Caption = 'Properties';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "BSB Property";
    CardPageId = "BSB Property Card";

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Project No."; Rec."Project No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Property Type"; Rec."Property Type") { ApplicationArea = All; }
                field("Rental Status"; Rec."Rental Status") { ApplicationArea = All; }
                field(City; Rec.City) { ApplicationArea = All; }
                field("Area (sqm)"; Rec."Area (sqm)") { ApplicationArea = All; }
                field("Energy Certificate"; Rec."Energy Certificate") { ApplicationArea = All; }
                field("Suggested Monthly Rent"; Rec."Suggested Monthly Rent") { ApplicationArea = All; }
                field("Has Active Contract"; Rec."Has Active Contract") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(MassStatusUpdate)
            {
                Caption = 'Mass Update Rental Status';
                ApplicationArea = All;
                Image = Status;

                trigger OnAction()
                var
                    RentalMgmt: Codeunit "BSB Rental Mgmt";
                begin
                    RentalMgmt.MassUpdateRentalStatus(Rec);
                end;
            }
        }
    }
}

page 50104 "BSB Property Card"
{
    Caption = 'Property Card';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "BSB Property";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Project No."; Rec."Project No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Property Type"; Rec."Property Type") { ApplicationArea = All; }
                field("Rental Status"; Rec."Rental Status") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
                field("Available From"; Rec."Available From") { ApplicationArea = All; }
            }
            group(Location)
            {
                Caption = 'Location';
                field(Address; Rec.Address) { ApplicationArea = All; }
                field("Address 2"; Rec."Address 2") { ApplicationArea = All; }
                field(City; Rec.City) { ApplicationArea = All; }
                field("Post Code"; Rec."Post Code") { ApplicationArea = All; }
                field("Country/Region Code"; Rec."Country/Region Code") { ApplicationArea = All; }
            }
            group(Specs)
            {
                Caption = 'Technical Specifications';
                field("Area (sqm)"; Rec."Area (sqm)") { ApplicationArea = All; }
                field("Usable Area (sqm)"; Rec."Usable Area (sqm)") { ApplicationArea = All; }
                field("Number of Rooms"; Rec."Number of Rooms") { ApplicationArea = All; }
                field("Number of Bathrooms"; Rec."Number of Bathrooms") { ApplicationArea = All; }
                field("Year Built"; Rec."Year Built") { ApplicationArea = All; }
            }
            group(Legal)
            {
                Caption = 'Legal / Registry';
                field("Cadastral Reference"; Rec."Cadastral Reference") { ApplicationArea = All; }
                field("Land Registry No."; Rec."Land Registry No.") { ApplicationArea = All; }
                field("Land Registry Section"; Rec."Land Registry Section") { ApplicationArea = All; }
            }
            group(Valuation)
            {
                Caption = 'Valuation & Tax';
                field("Appraisal Value"; Rec."Appraisal Value") { ApplicationArea = All; }
                field("Appraisal Date"; Rec."Appraisal Date") { ApplicationArea = All; }
                field("Annual Property Tax (IBI)"; Rec."Annual Property Tax (IBI)") { ApplicationArea = All; }
                field("Tax Period"; Rec."Tax Period") { ApplicationArea = All; }
            }
            group(Energy)
            {
                Caption = 'Energy Certification';
                field("Energy Certificate"; Rec."Energy Certificate") { ApplicationArea = All; }
                field("Energy Cert. No."; Rec."Energy Cert. No.") { ApplicationArea = All; }
                field("Energy Cert. Expiry"; Rec."Energy Cert. Expiry") { ApplicationArea = All; }
            }
            group(Commercial)
            {
                Caption = 'Commercialization';
                field("Suggested Monthly Rent"; Rec."Suggested Monthly Rent") { ApplicationArea = All; }
                field("Current Contract No."; Rec."Current Contract No.") { ApplicationArea = All; }
                field("Has Active Contract"; Rec."Has Active Contract") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RecordTaxUpdate)
            {
                Caption = 'Record IBI Update';
                ApplicationArea = All;
                Image = Calculate;

                trigger OnAction()
                var
                    TaxMgmt: Codeunit "BSB Tax Recharge";
                begin
                    TaxMgmt.RecordIBIUpdateUI(Rec);
                end;
            }
        }
        area(Navigation)
        {
            action(IBIHistory)
            {
                Caption = 'IBI History';
                ApplicationArea = All;
                Image = History;
                RunObject = page "BSB Property Tax Entries";
                RunPageLink = "Property No." = field("No.");
            }
        }
    }
}
