namespace OCPF.BootcampRegistration;

using Microsoft.RoleCenters;

codeunit 60843 "ocpfActivityCueMgt"
{
    procedure UpdateCues(var ActivitiesCue: Record "Activities Cue")
    var
        MonthStart: Date;
        MonthEnd: Date;
    begin
        MonthStart := CalcDate('<-CM>', Today());
        MonthEnd := CalcDate('<CM>', Today());
        ActivitiesCue."OCPF Below Min Seats" := CountBelowMinSeats();
        ActivitiesCue."OCPF Registrations This Month" := CountRegistrationsThisMonth(MonthStart, MonthEnd);
        ActivitiesCue."OCPF Revenue This Month" := SumRevenueThisMonth(MonthStart, MonthEnd);
    end;

    local procedure CountBelowMinSeats(): Integer
    var
        Bootcamp: Record "ocpfBootcamp";
        BelowMinCount: Integer;
    begin
        Bootcamp.SetRange(Status, Bootcamp.Status::Active);
        if Bootcamp.FindSet() then
            repeat
                Bootcamp.CalcFields("Registered Attendees");
                if Bootcamp."Registered Attendees" < Bootcamp."Min Seats" then
                    BelowMinCount += 1;
            until Bootcamp.Next() = 0;
        exit(BelowMinCount);
    end;

    local procedure CountRegistrationsThisMonth(MonthStart: Date; MonthEnd: Date): Integer
    var
        Attendee: Record "ocpfAttendee";
    begin
        Attendee.SetRange(SystemCreatedAt, CreateDateTime(MonthStart, 0T), CreateDateTime(MonthEnd, 235959T));
        exit(Attendee.Count());
    end;

    local procedure SumRevenueThisMonth(MonthStart: Date; MonthEnd: Date): Decimal
    var
        Attendee: Record "ocpfAttendee";
    begin
        Attendee.SetRange(Paid, true);
        Attendee.SetRange("Payment Date", MonthStart, MonthEnd);
        Attendee.CalcSums("Amount Paid");
        exit(Attendee."Amount Paid");
    end;
}
