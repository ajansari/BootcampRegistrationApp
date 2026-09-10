namespace OCPF.BootcampRegistration;

permissionset 60891 "OCPF - Bootcamp Edit"
{
    Assignable = true;
    Caption = 'OCPF - Bootcamp Edit';
    IncludedPermissionSets = "OCPF - Bootcamp Read";

    Permissions =
        tabledata "ocpfBootcampRegSetup" = IMD;
}
