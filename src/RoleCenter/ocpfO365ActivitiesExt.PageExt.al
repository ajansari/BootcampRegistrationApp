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
                Visible = OcpfCuesVisible;

                field("OCPF Active Bootcamps"; Rec."OCPF Active Bootcamps")
                {
                    ApplicationArea = All;
                    Caption = 'Active Bootcamps';

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

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"ocpfAttendeeList");
                    end;
                }
                field("OCPF Revenue This Month"; Rec."OCPF Revenue This Month")
                {
                    ApplicationArea = All;
                    Caption = 'Bootcamp Revenue This Month';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"ocpfAttendeeList");
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        Bootcamp: Record "ocpfBootcamp";
    begin
        // Step 09 finding BP-3: a guard inside UpdateCues alone isn't sufficient — two of the
        // five cue fields are FlowFields the platform calculates when the cuegroup renders,
        // never going through UpdateCues at all. Hiding the whole cuegroup for a user without
        // read access to this extension's own tables covers both the FlowField cues and the
        // plain ones in one place.
        OcpfCuesVisible := Bootcamp.ReadPermission();
    end;

    trigger OnAfterGetRecord()
    begin
        if OcpfCuesVisible then
            ActivityCueMgt.UpdateCues(Rec);
    end;

    var
        ActivityCueMgt: Codeunit "ocpfActivityCueMgt";
        OcpfCuesVisible: Boolean;
}
