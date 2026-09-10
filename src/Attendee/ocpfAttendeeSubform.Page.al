namespace OCPF.BootcampRegistration;

page 60822 "ocpfAttendeeSubform"
{
    PageType = ListPart;
    SourceTable = "ocpfAttendee";
    ApplicationArea = All;
    Caption = 'Attendees';
    DelayedInsert = true;
    AutoSplitKey = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Name"; Rec."Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the full name of the attendee.';
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the email address used to contact the attendee about the bootcamp.';
                }
                field("Phone Number"; Rec."Phone Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the phone number used to contact the attendee.';
                }
                field("Company"; Rec."Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the organization the attendee represents.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an optional link to the customer record for this attendee or their organization.';
                }
                field("Paid"; Rec."Paid")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether payment for this registration has been received.';
                }
                field("Payment Date"; Rec."Payment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date payment was received.';
                }
                field("Amount Paid"; Rec."Amount Paid")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount received for this registration. It is seeded from the bootcamp price and can be changed.';
                }
                field("Attended"; Rec."Attended")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the attendee actually attended the bootcamp.';
                }
            }
        }
    }
}
