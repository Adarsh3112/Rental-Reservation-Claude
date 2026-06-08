codeunit 50100 "BSB Rental Mgmt"
{
    procedure MassUpdateRentalStatus(var Property: Record "BSB Property")
    var
        FilteredProperty: Record "BSB Property";
        AuditMgmt: Codeunit "BSB Audit Log Mgmt";
        NewStatus: Enum "BSB Property Rental Status";
        Count: Integer;
    begin
        if not Dialog.Confirm('Mark filtered properties as Available?', false) then
            exit;
        NewStatus := NewStatus::Available;
        FilteredProperty.CopyFilters(Property);
        if FilteredProperty.FindSet() then
            repeat
                if FilteredProperty."Has Active Contract" then
                    ; // skip
                if not FilteredProperty."Has Active Contract" then begin
                    FilteredProperty."Rental Status" := NewStatus;
                    FilteredProperty.Modify(true);
                    Count += 1;
                end;
            until FilteredProperty.Next() = 0;
        Message('Updated %1 property(ies) to status %2.', Count, NewStatus);
    end;

    procedure CreatePropertyBatch(ProjectNo: Code[20]; PrefixOrNo: Code[20]; Quantity: Integer)
    var
        Property: Record "BSB Property";
        Index: Integer;
    begin
        if Quantity <= 0 then
            Error('Quantity must be positive.');
        for Index := 1 to Quantity do begin
            Property.Init();
            Property."Project No." := ProjectNo;
            Property.Description := StrSubstNo('Unit %1', Index);
            Property.Insert(true);
        end;
        Message('%1 properties created for project %2.', Quantity, ProjectNo);
    end;
}
