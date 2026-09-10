namespace OCPF.BootcampRegistration;

enum 60800 "ocpfBootcampStatus"
{
    Extensible = false;
    Caption = 'Bootcamp Status';

    value(0; "Active")
    {
        Caption = 'Active';
    }
    value(1; "Inactive")
    {
        Caption = 'Inactive';
    }
    value(2; "Completed")
    {
        Caption = 'Completed';
    }
    value(3; "Canceled")
    {
        Caption = 'Canceled';
    }
}
