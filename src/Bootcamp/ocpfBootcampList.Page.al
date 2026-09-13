namespace OCPF.BootcampRegistration;

page 60811 "ocpfBootcampList"
{
    PageType = List;
    SourceTable = "ocpfBootcamp";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "ocpfBootcampCard";
    Editable = true;
    Caption = 'Bootcamps';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Topic"; Rec."Topic")
                {
                    ApplicationArea = All;
                }
                field("Location"; Rec."Location")
                {
                    ApplicationArea = All;
                }
                field("Bootcamp Date"; Rec."Bootcamp Date")
                {
                    ApplicationArea = All;
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                }
                field("Max Seats"; Rec."Max Seats")
                {
                    ApplicationArea = All;
                }
                field("Registered Attendees"; Rec."Registered Attendees")
                {
                    ApplicationArea = All;
                }
                field("Seats Remaining"; Rec."Seats Remaining")
                {
                    ApplicationArea = All;
                }
                field("Min Seats"; Rec."Min Seats")
                {
                    ApplicationArea = All;
                }
                field("Price"; Rec."Price")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Attendees)
            {
                ApplicationArea = All;
                Caption = 'Attendees';
                Image = Users;
                RunObject = page "ocpfAttendeeList";
                RunPageLink = "Bootcamp No." = field("No.");
                ToolTip = 'Open the attendees registered for the selected bootcamp.';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Registered Attendees");
    end;
}
