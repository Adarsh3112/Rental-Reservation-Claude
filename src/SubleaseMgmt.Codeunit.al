codeunit 50105 "BSB Sublease Mgmt"
{
    procedure ValidateSubleaseScope(SubContract: Record "BSB Lease Contract")
    var
        Parent: Record "BSB Lease Contract";
        ParentProperty: Record "BSB Lease Contract Property";
        SubProperty: Record "BSB Lease Contract Property";
        OtherSubContract: Record "BSB Lease Contract";
        OtherSubProperty: Record "BSB Lease Contract Property";
        AvailableArea: Decimal;
        UsedArea: Decimal;
    begin
        if not SubContract."Is Sublease" then
            exit;
        if SubContract."Parent Contract No." = '' then
            Error('Sublease contract %1 must specify a Parent Contract No.', SubContract."No.");
        if not Parent.Get(SubContract."Parent Contract No.") then
            Error('Parent contract %1 not found.', SubContract."Parent Contract No.");
        if Parent."Is Sublease" then
            Error('Sub-subleasing is not permitted. Parent contract %1 is itself a sublease.', Parent."No.");
        if Parent.Status <> Parent.Status::Active then
            Error('Parent contract %1 must be Active. Current status: %2.', Parent."No.", Parent.Status);

        if (SubContract."Start Date" < Parent."Start Date") or
           ((Parent."End Date" <> 0D) and (SubContract."End Date" <> 0D) and (SubContract."End Date" > Parent."End Date"))
        then
            Error('Sublease dates (%1 - %2) must fall inside parent contract dates (%3 - %4).',
                  SubContract."Start Date", SubContract."End Date", Parent."Start Date", Parent."End Date");

        SubProperty.SetRange("Contract No.", SubContract."No.");
        if SubProperty.FindSet() then
            repeat
                ParentProperty.Reset();
                ParentProperty.SetRange("Contract No.", Parent."No.");
                ParentProperty.SetRange("Property No.", SubProperty."Property No.");
                if not ParentProperty.FindFirst() then
                    Error('Sublease references property %1 which is not part of parent contract %2.',
                        SubProperty."Property No.", Parent."No.");

                AvailableArea := ParentProperty."Area Used (sqm)";
                UsedArea := 0;
                OtherSubContract.Reset();
                OtherSubContract.SetRange("Parent Contract No.", Parent."No.");
                OtherSubContract.SetFilter("No.", '<>%1', SubContract."No.");
                OtherSubContract.SetFilter(Status, '<>%1', OtherSubContract.Status::Rejected);
                if OtherSubContract.FindSet() then
                    repeat
                        OtherSubProperty.Reset();
                        OtherSubProperty.SetRange("Contract No.", OtherSubContract."No.");
                        OtherSubProperty.SetRange("Property No.", SubProperty."Property No.");
                        if OtherSubProperty.FindFirst() then
                            UsedArea += OtherSubProperty."Area Used (sqm)";
                    until OtherSubContract.Next() = 0;
                if SubProperty."Area Used (sqm)" + UsedArea > AvailableArea then
                    Error('Sublease area (%1) for property %2 plus other subleases (%3) exceeds parent allocation (%4).',
                        SubProperty."Area Used (sqm)", SubProperty."Property No.", UsedArea, AvailableArea);
            until SubProperty.Next() = 0;
    end;
}
