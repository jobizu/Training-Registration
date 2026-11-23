
page 50101 "Training Registration List"
{
    PageType = List;
    SourceTable = "Training Registration";
    Caption = 'Training Registrations';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Training Registration Card";

    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique registration number.';
                }

                field("Participant Name"; Rec."Participant Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the training participant.';
                }

                field("Mobile Number"; Rec."Mobile Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the participant mobile number.';
                }

                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the participant email address.';
                }

                field(Organisation; Rec.Organisation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the participant organisation.';
                }

                field("Course Name"; Rec."Course Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the training course.';
                }

                field("Training Date"; Rec."Training Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the scheduled training date.';
                }

                field("Registration Date"; Rec."Registration Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date the participant registered.';
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the registration status.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewRegistration)
            {
                Caption = 'New Registration';
                ApplicationArea = All;
                ToolTip = 'Create a new training registration.';
                Image = New;

                RunObject = page "Training Registration Card";
                RunPageMode = Create;
            }
        }
    }
}
