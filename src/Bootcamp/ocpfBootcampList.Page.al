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
                    ToolTip = 'Specifies the unique identifier of the bootcamp.';
                }
                field("Topic"; Rec."Topic")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the subject the bootcamp covers.';
                }
                field("Location"; Rec."Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the venue or city where the bootcamp is held.';
                }
                field("Bootcamp Date"; Rec."Bootcamp Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the single day on which the bootcamp takes place.';
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the lifecycle state of the bootcamp. It is set manually.';
                }
                field("Max Seats"; Rec."Max Seats")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of attendees the bootcamp can hold. Zero means no limit.';
                }
                field("Registered Attendees"; Rec."Registered Attendees")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many attendees are currently registered for the bootcamp.';
                }
                field("Seats Remaining"; Rec."Seats Remaining")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of unused seats, calculated as Max Seats minus Registered Attendees.';
                }
                field("Min Seats"; Rec."Min Seats")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the minimum number of attendees needed for the bootcamp to run. It is informational only.';
                }
                field("Price"; Rec."Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount charged to attend the bootcamp.';
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
