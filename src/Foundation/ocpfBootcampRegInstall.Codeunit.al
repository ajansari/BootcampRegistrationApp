namespace OCPF.BootcampRegistration;

codeunit 60803 "ocpfBootcampRegInstall"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        EnsureSetup();
    end;

    local procedure EnsureSetup()
    var
        BootcampRegSetup: Record "ocpfBootcampRegSetup";
    begin
        if not BootcampRegSetup.Get() then begin
            BootcampRegSetup.Init();
            BootcampRegSetup.Insert();
        end;
    end;
}
