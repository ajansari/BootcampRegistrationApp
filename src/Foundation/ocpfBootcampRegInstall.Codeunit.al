namespace OCPF.BootcampRegistration;

using System.Environment.Configuration;
using System.Media;

codeunit 60803 "ocpfBootcampRegInstall"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        EnsureSetup();
        RegisterAssistedSetup();
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

    local procedure RegisterAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"ocpfBootcampRegSetupWizard") then
            exit;
        GuidedExperience.InsertAssistedSetup(
            SetupTitleTxt, CopyStr(SetupTitleTxt, 1, 50), SetupDescTxt, 5,
            ObjectType::Page, Page::"ocpfBootcampRegSetupWizard",
            "Assisted Setup Group"::Extensions,
            '', "Video Category"::Uncategorized, '');
    end;

    var
        SetupTitleTxt: Label 'Set up Bootcamp Registration Tracking';
        SetupDescTxt: Label 'Choose the number series for bootcamps and attendees, and optionally create sample bootcamps.';
}
