namespace OCPF.BootcampRegistration;

page 60802 "ocpfBootcampRegSetup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
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

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
