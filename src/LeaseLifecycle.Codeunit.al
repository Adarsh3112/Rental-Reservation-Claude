codeunit 50101 "BSB Lease Lifecycle"
{
    procedure SignContract(var Contract: Record "BSB Lease Contract")
    var
        Signatory: Record "BSB Contract Signatory";
        Template: Record "BSB Contract Template";
        AuditMgmt: Codeunit "BSB Audit Log Mgmt";
        SignedCount: Integer;
        TenantSigned: Boolean;
        LandlordSigned: Boolean;
        RequiredCount: Integer;
    begin
        if Contract.Status <> Contract.Status::Draft then
            Error('Only draft contracts can be signed. Current status: %1.', Contract.Status);
        ValidateContractReadyForSign(Contract);

        Signatory.SetRange("Contract No.", Contract."No.");
        Signatory.SetRange("Has Signed", true);
        SignedCount := Signatory.Count();

        Signatory.SetRange("Has Signed");
        Signatory.SetRange(Role, Signatory.Role::Tenant);
        Signatory.SetRange("Has Signed", true);
        TenantSigned := not Signatory.IsEmpty();
        Signatory.SetRange(Role, Signatory.Role::Landlord);
        Signatory.SetRange("Has Signed", true);
        LandlordSigned := not Signatory.IsEmpty();
        Signatory.SetRange(Role);
        Signatory.SetRange("Has Signed");

        if not (TenantSigned and LandlordSigned) then
            Error('Both Tenant and Landlord signatories must have signed before the contract can be signed.');

        RequiredCount := 2;
        if Template.Get(Contract."Contract Template Code") then
            RequiredCount := Template."Required Signatories";
        if SignedCount < RequiredCount then
            Error('Contract requires %1 signatories; only %2 have signed.', RequiredCount, SignedCount);

        Contract.Signed := true;
        Contract."Signed On" := CurrentDateTime();
        if Contract."Original End Date" = 0D then
            Contract."Original End Date" := Contract."End Date";
        Contract.Modify(true);

        AuditMgmt.LogAction(
            Database::"BSB Lease Contract",
            Contract."No.",
            Enum::"BSB Audit Action Type"::Sign,
            StrSubstNo('Contract %1 signed', Contract."No."));
    end;

    procedure MarkSignatorySigned(var Sig: Record "BSB Contract Signatory")
    var
        AuditMgmt: Codeunit "BSB Audit Log Mgmt";
    begin
        if Sig."Has Signed" then
            exit;
        Sig."Has Signed" := true;
        Sig."Signed On" := CurrentDateTime();
        Sig."Signed By User" := CopyStr(UserId(), 1, MaxStrLen(Sig."Signed By User"));
        Sig.Modify(true);

        AuditMgmt.LogAction(
            Database::"BSB Contract Signatory",
            Sig."Contract No.",
            Enum::"BSB Audit Action Type"::Sign,
            StrSubstNo('%1 signed contract %2', Sig."Full Name", Sig."Contract No."));
    end;

    local procedure ValidateContractReadyForSign(Contract: Record "BSB Lease Contract")
    var
        PropertyLine: Record "BSB Lease Contract Property";
        TenantLine: Record "BSB Lease Contract Tenant";
        Signatory: Record "BSB Contract Signatory";
        Template: Record "BSB Contract Template";
    begin
        Contract.TestField("Project No.");
        Contract.TestField("Tenant Customer No.");
        Contract.TestField("Start Date");
        Contract.TestField("End Date");
        Contract.TestField("Base Rent");
        Contract.TestField("Billing Frequency");
        Contract.TestField("Contract Template Code");

        PropertyLine.SetRange("Contract No.", Contract."No.");
        if PropertyLine.IsEmpty() then
            Error('Contract must have at least one property line.');

        TenantLine.SetRange("Contract No.", Contract."No.");
        if TenantLine.IsEmpty() then
            Error('Contract must have at least one tenant line.');

        Signatory.SetRange("Contract No.", Contract."No.");
        if Template.Get(Contract."Contract Template Code") then begin
            if Signatory.Count() < Template."Required Signatories" then
                Error('Contract has %1 signatory lines; template %2 requires %3.',
                    Signatory.Count(), Template.Code, Template."Required Signatories");
            if Template."Requires Witness" then
                if not HasSignatoryRole(Contract."No.", Enum::"BSB Signatory Role"::Witness) then
                    Error('Template %1 requires a Witness signatory.', Template.Code);
            if Template."Requires Guarantor" then
                if not HasSignatoryRole(Contract."No.", Enum::"BSB Signatory Role"::Guarantor) then
                    Error('Template %1 requires a Guarantor signatory.', Template.Code);
        end;

        if Contract."Is Sublease" then
            ValidateSubleaseConstraints(Contract);

        ValidatePropertyAvailability(Contract);
    end;

    local procedure HasSignatoryRole(ContractNo: Code[20]; SignatoryRole: Enum "BSB Signatory Role"): Boolean
    var
        Signatory: Record "BSB Contract Signatory";
    begin
        Signatory.SetRange("Contract No.", ContractNo);
        Signatory.SetRange(Role, SignatoryRole);
        exit(not Signatory.IsEmpty());
    end;

    local procedure ValidateSubleaseConstraints(Contract: Record "BSB Lease Contract")
    var
        SubleaseMgmt: Codeunit "BSB Sublease Mgmt";
    begin
        SubleaseMgmt.ValidateSubleaseScope(Contract);
    end;

    local procedure ValidatePropertyAvailability(Contract: Record "BSB Lease Contract")
    var
        PropertyLine: Record "BSB Lease Contract Property";
        Property: Record "BSB Property";
        OverlappingProperty: Record "BSB Lease Contract Property";
        OverlappingContract: Record "BSB Lease Contract";
    begin
        if Contract."Is Sublease" then
            exit;
        PropertyLine.SetRange("Contract No.", Contract."No.");
        if PropertyLine.FindSet() then
            repeat
                if Property.Get(PropertyLine."Property No.") then
                    if Property.Blocked then
                        Error('Property %1 is blocked.', Property."No.");
                OverlappingProperty.Reset();
                OverlappingProperty.SetRange("Property No.", PropertyLine."Property No.");
                OverlappingProperty.SetFilter("Contract No.", '<>%1', Contract."No.");
                if OverlappingProperty.FindSet() then
                    repeat
                        if OverlappingContract.Get(OverlappingProperty."Contract No.") then
                            if OverlappingContract.Status in [OverlappingContract.Status::Active, OverlappingContract.Status::"In Cancellation"] then
                                if DateRangesOverlap(Contract."Start Date", Contract."End Date", OverlappingContract."Start Date", OverlappingContract."End Date") then
                                    if not OverlappingContract."Is Sublease" then
                                        Error('Property %1 is already allocated to active contract %2 in an overlapping date range.',
                                            PropertyLine."Property No.", OverlappingContract."No.");
                    until OverlappingProperty.Next() = 0;
            until PropertyLine.Next() = 0;
    end;

    local procedure DateRangesOverlap(StartA: Date; EndA: Date; StartB: Date; EndB: Date): Boolean
    begin
        if StartA = 0D then StartA := 00000101D;
        if StartB = 0D then StartB := 00000101D;
        if EndA = 0D then EndA := DMY2Date(31, 12, 9999);
        if EndB = 0D then EndB := DMY2Date(31, 12, 9999);
        exit((StartA <= EndB) and (StartB <= EndA));
    end;

    procedure ActivateContract(var Contract: Record "BSB Lease Contract")
    var
        PropertyLine: Record "BSB Lease Contract Property";
        Property: Record "BSB Property";
        AuditMgmt: Codeunit "BSB Audit Log Mgmt";
        Billing: Codeunit "BSB Recurring Billing";
        OldStatus: Enum "BSB Contract Status";
    begin
        if Contract.Status = Contract.Status::Active then
            exit;
        if Contract.Status <> Contract.Status::Draft then
            Error('Only draft contracts can be activated. Current status: %1.', Contract.Status);
        if not Contract.Signed then
            Error('Contract must be signed before activation.');

        OldStatus := Contract.Status;
        Contract.Status := Contract.Status::Active;
        Contract."Activated On" := CurrentDateTime();
        Contract."Activated By" := CopyStr(UserId(), 1, MaxStrLen(Contract."Activated By"));
        if Contract."Next Billing Date" = 0D then
            Contract."Next Billing Date" := Contract."Start Date";
        Contract.Modify(true);

        PropertyLine.SetRange("Contract No.", Contract."No.");
        if PropertyLine.FindSet() then
            repeat
                if Property.Get(PropertyLine."Property No.") then begin
                    if (Property."Area (sqm)" > 0) and (PropertyLine."Area Used (sqm)" < Property."Area (sqm)") then
                        Property."Rental Status" := Property."Rental Status"::"Partially Leased"
                    else
                        Property."Rental Status" := Property."Rental Status"::Leased;
                    Property.Modify(true);
                end;
            until PropertyLine.Next() = 0;

        AuditMgmt.LogStatusChange(Database::"BSB Lease Contract", Contract."No.", Format(OldStatus), Format(Contract.Status));

        Billing.EnsureInstallmentsGenerated(Contract);
    end;

    procedure StartTermination(var Contract: Record "BSB Lease Contract")
    var
        AuditMgmt: Codeunit "BSB Audit Log Mgmt";
        OldStatus: Enum "BSB Contract Status";
    begin
        if Contract.Status <> Contract.Status::Active then
            Error('Only active contracts can enter termination. Current status: %1.', Contract.Status);
        OldStatus := Contract.Status;
        Contract.Status := Contract.Status::"In Cancellation";
        Contract.Modify(true);
        AuditMgmt.LogStatusChange(Database::"BSB Lease Contract", Contract."No.", Format(OldStatus), Format(Contract.Status));
    end;
}
