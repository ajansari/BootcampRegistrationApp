namespace OCPF.BootcampRegistration;

page 60830 "ocpfBootcamps"
{
    PageType = API;
    Caption = 'Bootcamps';
    APIPublisher = 'onlyCopilotFans';
    APIGroup = 'ocpfBootcampRegistration';
    APIVersion = 'v1.0';
    EntityName = 'ocpfBootcamp';
    EntitySetName = 'ocpfBootcamps';
    EntityCaption = 'Bootcamp';
    EntitySetCaption = 'Bootcamps';
    SourceTable = "ocpfBootcamp";
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
                field(topic; Rec."Topic")
                {
                    Caption = 'Topic';
                }
                field(location; Rec."Location")
                {
                    Caption = 'Location';
                }
                field(bootcampDate; Rec."Bootcamp Date")
                {
                    Caption = 'Bootcamp Date';
                }
                field(price; Rec."Price")
                {
                    Caption = 'Price';
                }
                field(maxSeats; Rec."Max Seats")
                {
                    Caption = 'Max Seats';
                }
                field(minSeats; Rec."Min Seats")
                {
                    Caption = 'Min Seats';
                }
                field(registeredAttendees; Rec."Registered Attendees")
                {
                    Caption = 'Registered Attendees';
                    Editable = false;
                }
                field(seatsRemaining; Rec."Seats Remaining")
                {
                    Caption = 'Seats Remaining';
                    Editable = false;
                }
                field(status; Rec."Status")
                {
                    Caption = 'Status';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time';
                    Editable = false;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Registered Attendees");
    end;
}
