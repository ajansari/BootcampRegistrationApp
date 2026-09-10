namespace OCPF.BootcampRegistration;

using Microsoft.Foundation.NoSeries;

table 60801 "ocpfBootcampRegSetup"
{
    Caption = 'Bootcamp Registration Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            ToolTip = 'Specifies the primary key of the single Bootcamp Registration Setup record.';
        }
        field(10; "Bootcamp Nos."; Code[20])
        {
            Caption = 'Bootcamp Nos.';
            ToolTip = 'Specifies the number series that is used to assign numbers to bootcamps.';
            TableRelation = "No. Series";
        }
        field(20; "Attendee Nos."; Code[20])
        {
            Caption = 'Attendee Nos.';
            ToolTip = 'Specifies the number series that is used to assign numbers to bootcamp attendees.';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
