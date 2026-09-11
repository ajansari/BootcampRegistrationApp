namespace OCPF.BootcampRegistration;

page 60831 "ocpfAttendees"
{
    PageType = API;
    Caption = 'Attendees';
    APIPublisher = 'onlyCopilotFans';
    APIGroup = 'ocpfBootcampRegistration';
    APIVersion = 'v1.0';
    EntityName = 'ocpfAttendee';
    EntitySetName = 'ocpfAttendees';
    EntityCaption = 'Attendee';
    EntitySetCaption = 'Attendees';
    SourceTable = "ocpfAttendee";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    Extensible = false;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'System Id';
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'Number';
                }
                field(bootcampNo; Rec."Bootcamp No.")
                {
                    Caption = 'Bootcamp No.';
                }
                field(name; Rec."Name")
                {
                    Caption = 'Name';
                }
                field(email; Rec."Email Address")
                {
                    Caption = 'Email';
                }
                field(phoneNumber; Rec."Phone Number")
                {
                    Caption = 'Phone Number';
                }
                field(company; Rec."Company")
                {
                    Caption = 'Company';
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.';
                }
                field(paid; Rec."Paid")
                {
                    Caption = 'Paid';
                }
                field(paymentDate; Rec."Payment Date")
                {
                    Caption = 'Payment Date';
                }
                field(amountPaid; Rec."Amount Paid")
                {
                    Caption = 'Amount Paid';
                }
                field(attended; Rec."Attended")
                {
                    Caption = 'Attended';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time';
                    Editable = false;
                }
            }
        }
    }
}
