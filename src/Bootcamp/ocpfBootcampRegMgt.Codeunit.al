namespace OCPF.BootcampRegistration;

using Microsoft.Foundation.NoSeries;

codeunit 60813 "ocpfBootcampRegMgt"
{
    procedure InitBootcampNo(var Bootcamp: Record "ocpfBootcamp")
    var
        ExistingBootcamp: Record "ocpfBootcamp";
        CandidateNo: Code[20];
    begin
        GetSetup();
        Setup.TestField("Bootcamp Nos.");
        Bootcamp."No. Series" := Setup."Bootcamp Nos.";
        CandidateNo := NoSeries.GetNextNo(Setup."Bootcamp Nos.");
        while ExistingBootcamp.Get(CandidateNo) do
            CandidateNo := NoSeries.GetNextNo(Setup."Bootcamp Nos.");
        Bootcamp."No." := CandidateNo;
    end;

    procedure InitAttendeeNo(var Attendee: Record "ocpfAttendee")
    var
        ExistingAttendee: Record "ocpfAttendee";
        CandidateNo: Code[20];
    begin
        GetSetup();
        Setup.TestField("Attendee Nos.");
        Attendee."No. Series" := Setup."Attendee Nos.";
        CandidateNo := NoSeries.GetNextNo(Setup."Attendee Nos.");
        while ExistingAttendee.Get(CandidateNo) do
            CandidateNo := NoSeries.GetNextNo(Setup."Attendee Nos.");
        Attendee."No." := CandidateNo;
    end;

    procedure TestBootcampManualNo()
    begin
        GetSetup();
        NoSeries.TestManual(Setup."Bootcamp Nos.");
    end;

    procedure TestAttendeeManualNo()
    begin
        GetSetup();
        NoSeries.TestManual(Setup."Attendee Nos.");
    end;

    procedure SeedAmountPaid(var Attendee: Record "ocpfAttendee")
    var
        Bootcamp: Record "ocpfBootcamp";
    begin
        if Attendee."Amount Paid" <> 0 then
            exit;
        if Attendee."Bootcamp No." = '' then
            exit;
        if not Bootcamp.Get(Attendee."Bootcamp No.") then
            exit;
        Attendee."Amount Paid" := Bootcamp."Price";
    end;

    procedure ConfirmOverbookingIfNeeded(var Attendee: Record "ocpfAttendee")
    var
        Bootcamp: Record "ocpfBootcamp";
        OverbookingQst: Label 'Bootcamp %1 is full (%2 of %3 seats used). Register %4 anyway?', Comment = '%1 = Bootcamp No., %2 = seats used, %3 = Max Seats, %4 = Attendee name';
    begin
        if Attendee."Bootcamp No." = '' then
            exit;
        if not GuiAllowed() then
            exit;
        if not Bootcamp.Get(Attendee."Bootcamp No.") then
            exit;
        if Bootcamp."Max Seats" <= 0 then
            exit;
        Bootcamp.CalcFields("Registered Attendees");
        if Bootcamp."Registered Attendees" + 1 <= Bootcamp."Max Seats" then
            exit;
        if not Confirm(OverbookingQst, false, Bootcamp."No.", Bootcamp."Registered Attendees", Bootcamp."Max Seats", Attendee."Name") then
            Error('');
    end;

    procedure UpdateSeatsRemaining(BootcampNo: Code[20])
    var
        Bootcamp: Record "ocpfBootcamp";
    begin
        if BootcampNo = '' then
            exit;
        if not Bootcamp.Get(BootcampNo) then
            exit;
        Bootcamp.CalcFields("Registered Attendees");
        Bootcamp."Seats Remaining" := Bootcamp."Max Seats" - Bootcamp."Registered Attendees";
        Bootcamp.Modify(false);
    end;

    local procedure GetSetup()
    begin
        if SetupLoaded then
            exit;
        if not Setup.Get() then begin
            Setup.Init();
            Setup.Insert();
        end;
        SetupLoaded := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"ocpfAttendee", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertAttendee(var Rec: Record "ocpfAttendee")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateSeatsRemaining(Rec."Bootcamp No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"ocpfAttendee", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyAttendee(var Rec: Record "ocpfAttendee"; var xRec: Record "ocpfAttendee")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateSeatsRemaining(Rec."Bootcamp No.");
        if xRec."Bootcamp No." <> Rec."Bootcamp No." then
            UpdateSeatsRemaining(xRec."Bootcamp No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"ocpfAttendee", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteAttendee(var Rec: Record "ocpfAttendee")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateSeatsRemaining(Rec."Bootcamp No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"ocpfAttendee", 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterRenameAttendee(var Rec: Record "ocpfAttendee")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateSeatsRemaining(Rec."Bootcamp No.");
    end;

    var
        Setup: Record "ocpfBootcampRegSetup";
        NoSeries: Codeunit "No. Series";
        SetupLoaded: Boolean;
}
