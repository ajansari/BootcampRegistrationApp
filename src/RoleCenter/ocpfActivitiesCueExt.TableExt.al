namespace OCPF.BootcampRegistration;

using Microsoft.RoleCenters;

tableextension 60842 "ocpfActivitiesCueExt" extends "Activities Cue"
{
    fields
    {
        field(60800; "OCPF Active Bootcamps"; Integer)
        {
            Caption = 'Active Bootcamps';
            CalcFormula = count("ocpfBootcamp" where(Status = const(Active)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(60801; "OCPF Unpaid Registrations"; Integer)
        {
            Caption = 'Unpaid Registrations';
            CalcFormula = count("ocpfAttendee" where(Paid = const(false)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(60802; "OCPF Below Min Seats"; Integer)
        {
            Caption = 'Below Min Seats (Go/No-Go)';
            Editable = false;
        }
        field(60803; "OCPF Registrations This Month"; Integer)
        {
            Caption = 'Registrations This Month';
            Editable = false;
        }
        field(60804; "OCPF Revenue This Month"; Decimal)
        {
            Caption = 'Bootcamp Revenue This Month';
            AutoFormatType = 1;
            Editable = false;
        }
    }
}
