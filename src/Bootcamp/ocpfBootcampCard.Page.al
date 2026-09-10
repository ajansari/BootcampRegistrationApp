namespace OCPF.BootcampRegistration;

page 60812 "ocpfBootcampCard"
{
    PageType = Card;
    SourceTable = "ocpfBootcamp";
    ApplicationArea = All;
    UsageCategory = None;
    Caption = 'Bootcamp';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of the bootcamp. It is assigned from the bootcamp number series when left blank.';
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
                    ToolTip = 'Specifies the lifecycle state of the bootcamp. It is set manually and is not changed by any automated process.';
                }
            }
            group(CapacityAndPricing)
            {
                Caption = 'Capacity & Pricing';

                field("Price"; Rec."Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount charged to attend the bootcamp. It is used to seed the amount paid on new attendee registrations.';
                }
                field("Max Seats"; Rec."Max Seats")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of attendees the bootcamp can hold. Leave it at zero for no limit.';
                }
                field("Min Seats"; Rec."Min Seats")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the minimum number of attendees needed for the bootcamp to run. It is informational only.';
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
            }
            part(Attendees; "ocpfAttendeeSubform")
            {
                ApplicationArea = All;
                Caption = 'Attendees';
                SubPageLink = "Bootcamp No." = field("No.");
                UpdatePropagation = Both;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Registered Attendees");
    end;
}
