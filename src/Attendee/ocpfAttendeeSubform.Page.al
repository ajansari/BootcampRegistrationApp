namespace OCPF.BootcampRegistration;

page 60822 "ocpfAttendeeSubform"
{
    PageType = ListPart;
    SourceTable = "ocpfAttendee";
    ApplicationArea = All;
    Caption = 'Attendees';
    DelayedInsert = true;
    AutoSplitKey = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Bootcamp No."; Rec."Bootcamp No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Name"; Rec."Name")
                {
                    ApplicationArea = All;
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                }
                field("Phone Number"; Rec."Phone Number")
                {
                    ApplicationArea = All;
                }
                field("Company"; Rec."Company")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Paid"; Rec."Paid")
                {
                    ApplicationArea = All;
                }
                field("Payment Date"; Rec."Payment Date")
                {
                    ApplicationArea = All;
                }
                field("Amount Paid"; Rec."Amount Paid")
                {
                    ApplicationArea = All;
                }
                field("Attended"; Rec."Attended")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        PrevFilterGroup: Integer;
        BootcampNoFilter: Text;
    begin
        if Rec."Bootcamp No." <> '' then
            exit;
        // SubPageLink filters live in filter group 4 ("Link"), not the default group 0 —
        // a plain Rec.GetFilter() reads group 0 and misses it entirely.
        PrevFilterGroup := Rec.FilterGroup();
        Rec.FilterGroup(4);
        BootcampNoFilter := Rec.GetFilter("Bootcamp No.");
        Rec.FilterGroup(PrevFilterGroup);
        // Validate, not a plain assignment — Amount Paid is now seeded solely from
        // "Bootcamp No."'s OnValidate (Step 09 BP-1), which a plain field assignment would
        // silently skip. A blank filter is left blank exactly as before (no-op either way);
        // OnInsert's TestField still catches that case loudly.
        if BootcampNoFilter <> '' then
            Rec.Validate("Bootcamp No.", CopyStr(BootcampNoFilter, 1, MaxStrLen(Rec."Bootcamp No.")));
    end;
}
