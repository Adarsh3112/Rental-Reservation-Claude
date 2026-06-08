codeunit 50108 "BSB Audit Log Mgmt"
{
    procedure LogAction(TableNo: Integer; RecordIdentifier: Code[60]; ActionType: Enum "BSB Audit Action Type"; Description: Text)
    var
        Setup: Record "BSB Real Estate Setup";
        Entry: Record "BSB Audit Log Entry";
    begin
        if not Setup.Get() then
            exit;
        if not Setup."Audit Log Enabled" then
            exit;
        Entry.Init();
        Entry."Table No." := TableNo;
        Entry."Record ID" := RecordIdentifier;
        Entry.Action := ActionType;
        Entry."Action Description" := CopyStr(Description, 1, MaxStrLen(Entry."Action Description"));
        Entry."User ID" := CopyStr(UserId(), 1, MaxStrLen(Entry."User ID"));
        Entry."Action DateTime" := CurrentDateTime();
        Entry.Insert();
    end;

    procedure LogStatusChange(TableNo: Integer; RecordIdentifier: Code[60]; OldValue: Text; NewValue: Text)
    var
        Setup: Record "BSB Real Estate Setup";
        Entry: Record "BSB Audit Log Entry";
    begin
        if not Setup.Get() then
            exit;
        if not Setup."Audit Log Enabled" then
            exit;
        Entry.Init();
        Entry."Table No." := TableNo;
        Entry."Record ID" := RecordIdentifier;
        Entry.Action := Enum::"BSB Audit Action Type"::"Status Change";
        Entry."Action Description" := CopyStr(StrSubstNo('Status %1 -> %2', OldValue, NewValue), 1, MaxStrLen(Entry."Action Description"));
        Entry."Old Value" := CopyStr(OldValue, 1, MaxStrLen(Entry."Old Value"));
        Entry."New Value" := CopyStr(NewValue, 1, MaxStrLen(Entry."New Value"));
        Entry."User ID" := CopyStr(UserId(), 1, MaxStrLen(Entry."User ID"));
        Entry."Action DateTime" := CurrentDateTime();
        Entry.Insert();
    end;
}
