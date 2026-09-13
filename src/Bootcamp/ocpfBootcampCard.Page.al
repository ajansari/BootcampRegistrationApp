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
            }
            group(CapacityAndPricing)
            {
                Caption = 'Capacity & Pricing';

                field("Price"; Rec."Price")
                {
                    ApplicationArea = All;
                }
                field("Max Seats"; Rec."Max Seats")
                {
                    ApplicationArea = All;
                }
                field("Min Seats"; Rec."Min Seats")
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
