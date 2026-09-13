namespace OCPF.BootcampRegistration;

page 60821 "ocpfAttendeeList"
{
    PageType = List;
    SourceTable = "ocpfAttendee";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = true;
    DelayedInsert = true;
    Caption = 'Attendees';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Bootcamp No."; Rec."Bootcamp No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Name"; Rec."Name")
                {
                    ApplicationArea = All;
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                }
                field("Phone Number"; Rec."Phone Number")
                {
                    ApplicationArea = All;
                }
                field("Company"; Rec."Company")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Paid"; Rec."Paid")
                {
                    ApplicationArea = All;
                }
                field("Payment Date"; Rec."Payment Date")
                {
                    ApplicationArea = All;
                }
                field("Amount Paid"; Rec."Amount Paid")
                {
                    ApplicationArea = All;
                }
                field("Attended"; Rec."Attended")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
