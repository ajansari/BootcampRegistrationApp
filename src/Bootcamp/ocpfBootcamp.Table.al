namespace OCPF.BootcampRegistration;

using Microsoft.Foundation.NoSeries;

table 60810 "ocpfBootcamp"
{
    Caption = 'Bootcamp';
    DataClassification = CustomerContent;
    LookupPageId = "ocpfBootcampList";
    DrillDownPageId = "ocpfBootcampList";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            ToolTip = 'Specifies the unique identifier of the bootcamp. It is assigned from the bootcamp number series when left blank.';

            trigger OnValidate()
            begin
                if Rec."No." <> xRec."No." then begin
                    BootcampRegMgt.TestBootcampManualNo();
                    Rec."No. Series" := '';
                end;
            end;
        }
        field(2; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            ToolTip = 'Specifies the number series that was used to assign the number to this bootcamp.';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(3; "Topic"; Text[100])
        {
            Caption = 'Topic';
            ToolTip = 'Specifies the subject the bootcamp covers.';
        }
        field(4; "Location"; Text[100])
        {
            Caption = 'Location';
            ToolTip = 'Specifies the venue or city where the bootcamp is held. This is free text and is not linked to warehouse locations.';
        }
        field(5; "Bootcamp Date"; Date)
        {
            Caption = 'Bootcamp Date';
            ToolTip = 'Specifies the single day on which the bootcamp takes place.';
        }
        field(6; "Price"; Decimal)
        {
            Caption = 'Price';
            ToolTip = 'Specifies the amount charged to attend the bootcamp. It is used to seed the amount paid on new attendee registrations.';
            AutoFormatType = 1;
            MinValue = 0;
        }
        field(7; "Max Seats"; Integer)
        {
            Caption = 'Max Seats';
            ToolTip = 'Specifies the number of attendees the bootcamp can hold. Leave it at zero for no limit. Registrations beyond this number are warned about but still allowed.';
            MinValue = 0;

            trigger OnValidate()
            begin
                // Compute in memory, on Rec itself — never re-Get() this same record from the
                // database inside its own OnValidate. The DB still holds the pre-change row, so
                // a separate Get()/Modify() pair here would read stale data and then be silently
                // overwritten by the platform's own pending write for the field just validated
                // (ChangeLog STEP08-01, finding G-12). Guard on "No." <> '': before the record's
                // first insert, CalcFields would filter the FlowField on a blank key and could
                // match orphaned rows; OnInsert seeds the value correctly for that case instead.
                if Rec."No." <> '' then begin
                    Rec.CalcFields("Registered Attendees");
                    Rec."Seats Remaining" := Rec."Max Seats" - Rec."Registered Attendees";
                end;
            end;
        }
        field(8; "Min Seats"; Integer)
        {
            Caption = 'Min Seats (Go/No-Go)';
            ToolTip = 'Specifies the minimum number of attendees needed for the bootcamp to run. It is informational only and does not block registrations.';
            MinValue = 0;
        }
        field(9; "Registered Attendees"; Integer)
        {
            Caption = 'Registered Attendees';
            ToolTip = 'Specifies how many attendees are currently registered for the bootcamp.';
            FieldClass = FlowField;
            CalcFormula = count("ocpfAttendee" where("Bootcamp No." = field("No.")));
            Editable = false;
        }
        field(10; "Seats Remaining"; Integer)
        {
            Caption = 'Seats Remaining';
            ToolTip = 'Specifies the number of unused seats, calculated as Max Seats minus Registered Attendees. It is maintained automatically.';
            Editable = false;
        }
        field(11; "Status"; Enum "ocpfBootcampStatus")
        {
            Caption = 'Status';
            ToolTip = 'Specifies the lifecycle state of the bootcamp. It is set manually and is not changed by any automated process.';
            InitValue = "Active";
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if Rec."No." = '' then
            BootcampRegMgt.InitBootcampNo(Rec);
        Rec."Seats Remaining" := Rec."Max Seats";
    end;

    trigger OnDelete()
    var
        Attendee: Record "ocpfAttendee";
        CannotDeleteBootcampErr: Label 'You cannot delete bootcamp %1 because attendee registrations exist for it. Delete the registrations first.', Comment = '%1 = Bootcamp No.';
    begin
        Attendee.SetRange("Bootcamp No.", Rec."No.");
        if not Attendee.IsEmpty() then
            Error(CannotDeleteBootcampErr, Rec."No.");
    end;

    var
        BootcampRegMgt: Codeunit "ocpfBootcampRegMgt";
}
