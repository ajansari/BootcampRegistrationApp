namespace OCPF.BootcampRegistration;

using Microsoft.Finance.RoleCenters;

pageextension 60841 "ocpfBusinessMgrRCExt" extends "Business Manager Role Center"
{
    actions
    {
        addlast(sections)
        {
            group(ocpfBootcamps)
            {
                Caption = 'Bootcamps';

                action(ocpfBootcampListAction)
                {
                    ApplicationArea = All;
                    Caption = 'Bootcamps';
                    Image = Users;
                    RunObject = page "ocpfBootcampList";
                    ToolTip = 'Open the list of bootcamps.';
                }
                action(ocpfAttendeeListAction)
                {
                    ApplicationArea = All;
                    Caption = 'Bootcamp Attendees';
                    Image = ContactPerson;
                    RunObject = page "ocpfAttendeeList";
                    ToolTip = 'Open the list of bootcamp attendees.';
                }
                action(ocpfBootcampSetupAction)
                {
                    ApplicationArea = All;
                    Caption = 'Bootcamp Registration Setup';
                    Image = Setup;
                    RunObject = page "ocpfBootcampRegSetup";
                    ToolTip = 'Open the Bootcamp Registration Setup.';
                }
            }
        }
    }
}
