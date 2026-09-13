namespace OCPF.BootcampRegistration;

using Microsoft.RoleCenters;

tableextension 60842 "ocpfActivitiesCueExt" extends "Activities Cue"
{
    fields
    {
        field(60800; "OCPF Active Bootcamps"; Integer)
        {
            Caption = 'Active Bootcamps';
            ToolTip = 'Specifies the number of bootcamps currently marked Active.';
            CalcFormula = count("ocpfBootcamp" where(Status = const(Active)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(60801; "OCPF Unpaid Registrations"; Integer)
        {
            Caption = 'Unpaid Registrations';
            ToolTip = 'Specifies the number of attendee registrations not yet marked as paid.';
            CalcFormula = count("ocpfAttendee" where(Paid = const(false)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(60802; "OCPF Below Min Seats"; Integer)
        {
            Caption = 'Below Min Seats (Go/No-Go)';
            ToolTip = 'Specifies the number of active, upcoming bootcamps with fewer registered attendees than their Min Seats (Go/No-Go) threshold.';
            Editable = false;
        }
        field(60803; "OCPF Registrations This Month"; Integer)
        {
            Caption = 'Registrations This Month';
            ToolTip = 'Specifies the number of attendee registrations created this month.';
            Editable = false;
        }
        field(60804; "OCPF Revenue This Month"; Decimal)
        {
            Caption = 'Bootcamp Revenue This Month';
            ToolTip = 'Specifies the total amount paid by attendees registered this month.';
            AutoFormatType = 1;
            Editable = false;
        }
    }
}
