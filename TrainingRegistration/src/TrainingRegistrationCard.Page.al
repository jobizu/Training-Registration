
page 50102 "Training Registration Card"
{
    PageType = Card;
    SourceTable = "Training Registration";
    Caption = 'Training Registration Card';
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter a unique registration number.';
                }

                field("Participant Name"; Rec."Participant Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the full name of the participant.';
                }

                field("Mobile Number"; Rec."Mobile Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the participant mobile number.';
                }

                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter a valid email address if available.';
                }

                field(Organisation; Rec.Organisation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the participant organisation.';
                }

                field("Course Name"; Rec."Course Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the name of the training course.';
                }

                field("Training Date"; Rec."Training Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the scheduled training date.';
                }

                field("Registration Date"; Rec."Registration Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Displays the date the registration was created.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Displays the current registration status. Status is changed through registration actions.';
                }

                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Enter any additional registration information.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ConfirmRegistration)
            {
                Caption = 'Confirm Registration';
                ApplicationArea = All;
                Image = Approve;
                ToolTip = 'Validate and confirm this training registration.';

                Enabled = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                begin
                    Rec.ConfirmRegistration();

                    Message('Training registration %1 has been confirmed.',
                        Rec."Registration No.");
                end;
            }
        }
    }
}
