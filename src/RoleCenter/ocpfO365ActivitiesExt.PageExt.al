namespace OCPF.BootcampRegistration;

pageextension 60844 "ocpfO365ActivitiesExt" extends "O365 Activities"
{
    layout
    {
        addlast(content)
        {
            cuegroup(ocpfBootcamps)
            {
                Caption = 'Bootcamps';

                field("OCPF Active Bootcamps"; Rec."OCPF Active Bootcamps")
                {
                    ApplicationArea = All;
                    Caption = 'Active Bootcamps';
                    ToolTip = 'Specifies the number of bootcamps with an Active status.';

                    trigger OnDrillDown()
                    var
                        Bootcamp: Record "ocpfBootcamp";
                    begin
                        Bootcamp.SetRange(Status, Bootcamp.Status::Active);
                        Page.Run(Page::"ocpfBootcampList", Bootcamp);
                    end;
                }
                field("OCPF Unpaid Registrations"; Rec."OCPF Unpaid Registrations")
                {
                    ApplicationArea = All;
                    Caption = 'Unpaid Registrations';
                    ToolTip = 'Specifies the number of attendee registrations that have not been marked as paid.';

                    trigger OnDrillDown()
                    var
                        Attendee: Record "ocpfAttendee";
                    begin
                        Attendee.SetRange(Paid, false);
                        Page.Run(Page::"ocpfAttendeeList", Attendee);
                    end;
                }
                field("OCPF Below Min Seats"; Rec."OCPF Below Min Seats")
                {
                    ApplicationArea = All;
                    Caption = 'Below Min Seats (Go/No-Go)';
                    ToolTip = 'Specifies the number of active bootcamps that currently have fewer registered attendees than their Min Seats (Go/No-Go) target.';

                    trigger OnDrillDown()
                    var
                        Bootcamp: Record "ocpfBootcamp";
                    begin
                        Bootcamp.SetRange(Status, Bootcamp.Status::Active);
                        Page.Run(Page::"ocpfBootcampList", Bootcamp);
                    end;
                }
                field("OCPF Registrations This Month"; Rec."OCPF Registrations This Month")
                {
                    ApplicationArea = All;
                    Caption = 'Registrations This Month';
                    ToolTip = 'Specifies how many attendees were registered this calendar month.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"ocpfAttendeeList");
                    end;
                }
                field("OCPF Revenue This Month"; Rec."OCPF Revenue This Month")
                {
                    ApplicationArea = All;
                    Caption = 'Bootcamp Revenue This Month';
                    ToolTip = 'Specifies the total amount paid by attendees this calendar month.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"ocpfAttendeeList");
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ActivityCueMgt.UpdateCues(Rec);
    end;

    var
        ActivityCueMgt: Codeunit "ocpfActivityCueMgt";
}
