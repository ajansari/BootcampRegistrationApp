namespace OCPF.BootcampRegistration;

permissionset 60890 "OCPF - Bootcamp Read"
{
    Assignable = true;
    Caption = 'OCPF - Bootcamp Read';

    // Object-execute grants added at Step 09 (Standards §7.3, finding SC-1): tabledata alone
    // was the only grant here; §7.3 requires the read-only set to also grant execute on all of
    // this extension's own pages, defensively, rather than relying on tabledata-implied page
    // access. Pageextensions/tableextensions on standard objects (Business Manager Role Center,
    // O365 Activities, Activities Cue) need no grant of their own — they ride on the base
    // object's own standard permission coverage.
    Permissions =
        tabledata "ocpfBootcampRegSetup" = R,
        tabledata "ocpfBootcamp" = R,
        tabledata "ocpfAttendee" = R,
        page "ocpfBootcampRegSetup" = X,
        page "ocpfBootcampList" = X,
        page "ocpfBootcampCard" = X,
        page "ocpfAttendeeList" = X,
        page "ocpfAttendeeSubform" = X,
        page "ocpfBootcampRegSetupWizard" = X,
        page "ocpfBootcamps" = X,
        page "ocpfAttendees" = X;
}
