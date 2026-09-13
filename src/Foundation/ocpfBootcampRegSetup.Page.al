namespace OCPF.BootcampRegistration;

using System.Environment.Configuration;

page 60802 "ocpfBootcampRegSetup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "ocpfBootcampRegSetup";
    Caption = 'Bootcamp Registration Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    AboutTitle = 'About Bootcamp Registration Setup';
    AboutText = 'Choose the number series that assign numbers to bootcamps and attendees. You can also run the assisted setup to configure this quickly.';

    layout
    {
        area(Content)
        {
            group(Numbering)
            {
                Caption = 'Numbering';

                field("Bootcamp Nos."; Rec."Bootcamp Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series that is used to assign numbers to bootcamps.';
                }
                field("Attendee Nos."; Rec."Attendee Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series that is used to assign numbers to bootcamp attendees.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RunAssistedSetup)
            {
                ApplicationArea = All;
                Caption = 'Assisted Setup';
                Image = Setup;
                ToolTip = 'Run the guided setup to choose number series and optionally create sample bootcamps.';

                trigger OnAction()
                var
                    GuidedExperience: Codeunit "Guided Experience";
                begin
                    GuidedExperience.Run("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"ocpfBootcampRegSetupWizard");
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
