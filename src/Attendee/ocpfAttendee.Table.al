namespace OCPF.BootcampRegistration;

using Microsoft.Foundation.NoSeries;
using Microsoft.Sales.Customer;

table 60820 "ocpfAttendee"
{
    Caption = 'Attendee';
    DataClassification = CustomerContent;
    LookupPageId = "ocpfAttendeeList";
    DrillDownPageId = "ocpfAttendeeList";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            ToolTip = 'Specifies the unique identifier of the attendee registration. It is assigned from the attendee number series when left blank.';

            trigger OnValidate()
            begin
                if Rec."No." <> xRec."No." then begin
                    BootcampRegMgt.TestAttendeeManualNo();
                    Rec."No. Series" := '';
                end;
            end;
        }
        field(2; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            ToolTip = 'Specifies the number series that was used to assign the number to this registration.';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(3; "Bootcamp No."; Code[20])
        {
            Caption = 'Bootcamp No.';
            ToolTip = 'Specifies the bootcamp this person is registered for.';
            NotBlank = true;
            TableRelation = "ocpfBootcamp";

            trigger OnValidate()
            begin
                if Rec."Bootcamp No." <> xRec."Bootcamp No." then
                    BootcampRegMgt.SeedAmountPaid(Rec);
            end;
        }
        field(10; "Name"; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the full name of the attendee.';
        }
        field(11; "Email Address"; Text[80])
        {
            Caption = 'Email Address';
            ToolTip = 'Specifies the email address used to contact the attendee about the bootcamp.';
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                Email: Text;
                AtPos: Integer;
                InvalidEmailErr: Label 'The email address "%1" is not valid. Enter a name, an at sign, and a domain that contains a dot.', Comment = '%1 = the email address that was entered';
            begin
                Email := Rec."Email Address";
                if Email = '' then
                    exit;
                AtPos := StrPos(Email, '@');
                if (AtPos = 0) or
                   (StrLen(Email) - StrLen(DelChr(Email, '=', '@')) <> 1) or
                   (StrPos(Email, ' ') <> 0) or
                   (StrPos(CopyStr(Email, AtPos + 1), '.') = 0)
                then
                    Error(InvalidEmailErr, Email);
            end;
        }
        field(12; "Phone Number"; Text[30])
        {
            Caption = 'Phone Number';
            ToolTip = 'Specifies the phone number used to contact the attendee.';
            ExtendedDatatype = PhoneNo;
        }
        field(13; "Company"; Text[100])
        {
            Caption = 'Company';
            ToolTip = 'Specifies the organization the attendee represents.';
        }
        field(14; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            ToolTip = 'Specifies an optional link to the customer record for this attendee or their organization. It does not copy any values from the customer.';
            TableRelation = Customer;
        }
        field(20; "Paid"; Boolean)
        {
            Caption = 'Paid';
            ToolTip = 'Specifies whether payment for this registration has been received.';
        }
        field(21; "Payment Date"; Date)
        {
            Caption = 'Payment Date';
            ToolTip = 'Specifies the date payment was received. It is not validated against the Paid check box.';
        }
        field(22; "Amount Paid"; Decimal)
        {
            Caption = 'Amount Paid';
            ToolTip = 'Specifies the amount received for this registration. It is seeded from the bootcamp price on a new registration and can be changed. An entered value, including zero, is never overwritten.';
            AutoFormatType = 1;
            MinValue = 0;
        }
        field(30; "Attended"; Boolean)
        {
            Caption = 'Attended';
            ToolTip = 'Specifies whether the attendee actually attended the bootcamp.';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(BootcampNo; "Bootcamp No.")
        {
        }
    }

    trigger OnInsert()
    begin
        Rec.TestField("Bootcamp No.");
        if Rec."No." = '' then
            BootcampRegMgt.InitAttendeeNo(Rec);
        // Amount Paid is seeded solely from "Bootcamp No."'s OnValidate above (Step 09 BP-1) —
        // seeded once, at bootcamp-selection time, never re-seeded here. The old unconditional
        // call here used "Amount Paid = 0" as its guard, which can't tell "not yet supplied"
        // from "deliberately zero" (a comped registration) and silently re-billed the latter.
        BootcampRegMgt.ConfirmOverbookingIfNeeded(Rec);
    end;

    var
        BootcampRegMgt: Codeunit "ocpfBootcampRegMgt";
}
