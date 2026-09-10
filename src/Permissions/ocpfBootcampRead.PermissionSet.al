namespace OCPF.BootcampRegistration;

permissionset 60890 "OCPF - Bootcamp Read"
{
    Assignable = true;
    Caption = 'OCPF - Bootcamp Read';

    Permissions =
        tabledata "ocpfBootcampRegSetup" = R,
        tabledata "ocpfBootcamp" = R,
        tabledata "ocpfAttendee" = R;
}
