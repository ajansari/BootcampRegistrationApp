namespace OCPF.BootcampRegistration;

using Microsoft.Foundation.NoSeries;
using System.Environment.Configuration;

page 60840 "ocpfBootcampRegSetupWizard"
{
    PageType = NavigatePage;
    SourceTable = "ocpfBootcampRegSetup";
    Caption = 'Bootcamp Registration Setup';
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(WelcomeStep)
            {
                Caption = '';
                Visible = CurrentStep = CurrentStep::Welcome;

                group(Welcome)
                {
                    Caption = 'Welcome';

                    label(WelcomeText)
                    {
                        ApplicationArea = All;
                        Caption = 'This wizard sets up the number series used for bootcamps and attendees, and can optionally create sample bootcamps so you can see how the app works.';
                    }
                }
            }
            group(NumberingStep)
            {
                Caption = '';
                Visible = CurrentStep = CurrentStep::Numbering;

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
            group(SampleDataStep)
            {
                Caption = '';
                Visible = CurrentStep = CurrentStep::SampleData;

                group(SampleData)
                {
                    Caption = 'Sample Data';

                    field(CreateSamples; CreateSamplesVar)
                    {
                        ApplicationArea = All;
                        Caption = 'Create two sample bootcamps so I can see how this works';
                        ToolTip = 'Specifies whether to create two sample bootcamps you can explore after finishing the setup.';
                    }
                }
            }
            group(FinishStep)
            {
                Caption = '';
                Visible = CurrentStep = CurrentStep::Finish;

                group(Finish)
                {
                    Caption = 'Finish';

                    label(FinishText)
                    {
                        ApplicationArea = All;
                        Caption = 'Choose Finish to save the numbering setup and, if selected, create the sample bootcamps.';
                    }
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Image = PreviousRecord;
                InFooterBar = true;
                Enabled = BackEnabled;

                trigger OnAction()
                begin
                    CurrentStep := CurrentStep - 1;
                    UpdateStepControls();
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Image = NextRecord;
                InFooterBar = true;
                Enabled = NextEnabled;

                trigger OnAction()
                begin
                    if CurrentStep = CurrentStep::Numbering then
                        OfferDefaultSeriesIfBlank();
                    CurrentStep := CurrentStep + 1;
                    UpdateStepControls();
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Image = Approve;
                InFooterBar = true;
                Enabled = FinishEnabled;

                trigger OnAction()
                begin
                    FinishSetup();
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        CurrentStep := CurrentStep::Welcome;
        UpdateStepControls();
    end;

    local procedure UpdateStepControls()
    begin
        BackEnabled := CurrentStep <> CurrentStep::Welcome;
        NextEnabled := CurrentStep <> CurrentStep::Finish;
        FinishEnabled := CurrentStep = CurrentStep::Finish;
    end;

    local procedure OfferDefaultSeriesIfBlank()
    begin
        CreateDefaultSeriesIfBlank(Rec."Bootcamp Nos.", 'BOOTCAMP', BootcampSeriesDescTxt, 'BC00001');
        CreateDefaultSeriesIfBlank(Rec."Attendee Nos.", 'ATTENDEE', AttendeeSeriesDescTxt, 'ATT00001');
    end;

    local procedure CreateDefaultSeriesIfBlank(var SeriesCode: Code[20]; DefaultCode: Code[20]; DefaultDescription: Text[100]; DefaultStartingNo: Code[20])
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if SeriesCode <> '' then
            exit;
        if not GuiAllowed() then
            exit;
        if not Confirm(CreateSeriesQst, true, DefaultCode) then
            exit;
        if not NoSeries.Get(DefaultCode) then begin
            NoSeries.Init();
            NoSeries."Code" := DefaultCode;
            NoSeries.Description := DefaultDescription;
            NoSeries."Default Nos." := true;
            NoSeries.Insert(true);
        end;
        NoSeriesLine.SetRange("Series Code", DefaultCode);
        if NoSeriesLine.IsEmpty() then begin
            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := DefaultCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := DefaultStartingNo;
            NoSeriesLine.Insert(true);
        end;
        SeriesCode := DefaultCode;
        Rec.Modify(true);
    end;

    local procedure FinishSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        Rec.Modify(true);
        if CreateSamplesVar then
            CreateSampleBootcamps();
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"ocpfBootcampRegSetupWizard");
    end;

    local procedure CreateSampleBootcamps()
    var
        Bootcamp: Record "ocpfBootcamp";
    begin
        Bootcamp.Init();
        Bootcamp."No." := '';
        Bootcamp."Topic" := SampleTopic1Txt;
        Bootcamp."Bootcamp Date" := CalcDate('<+30D>', Today());
        Bootcamp."Price" := 1500;
        Bootcamp."Max Seats" := 20;
        Bootcamp."Min Seats" := 6;
        Bootcamp.Insert(true);

        Bootcamp.Init();
        Bootcamp."No." := '';
        Bootcamp."Topic" := SampleTopic2Txt;
        Bootcamp."Bootcamp Date" := CalcDate('<+60D>', Today());
        Bootcamp."Price" := 1500;
        Bootcamp."Max Seats" := 20;
        Bootcamp."Min Seats" := 6;
        Bootcamp.Insert(true);
    end;

    var
        CurrentStep: Option Welcome,Numbering,SampleData,Finish;
        CreateSamplesVar: Boolean;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        FinishEnabled: Boolean;
        CreateSeriesQst: Label 'No number series is selected yet. Create a default series (%1) now?', Comment = '%1 = the default number series code, e.g. BOOTCAMP';
        BootcampSeriesDescTxt: Label 'Bootcamp Numbers';
        AttendeeSeriesDescTxt: Label 'Bootcamp Attendee Numbers';
        SampleTopic1Txt: Label 'AL Extension Development';
        SampleTopic2Txt: Label 'Business Central for Consultants';
}
