// =============================================================================
// PAGE 50101 "Training Registration Card"  (Card page)
// -----------------------------------------------------------------------------
// Shows ONE registration for creating and editing. It opens from the
// "Training Registrations" list (that page's CardPageId points here).
//
// What this page adds on top of the table:
//   - Fields arranged in groups (General / Participant / Training).
//   - Red mandatory markers on the fields needed for confirmation.
//   - Locking: participant, course and training date become read-only once
//     the registration is Confirmed. This is the "page behaviour" half of the
//     requirement; the table and codeunit enforce the same rule underneath.
//   - Confirm, Cancel and Print actions.
// =============================================================================
page 50101 "Training Registration Card"
{
    PageType = Card;
    SourceTable = "Training Registration";
    Caption = 'Training Registration Card';
    ApplicationArea = All;
    // None = the card is not listed in search; users reach it from the list.
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            // Each group appears as a collapsible section (FastTab) on the card.
            group(General)
            {
                Caption = 'General';

                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique registration number. Enter it manually; duplicate numbers are rejected.';
                    // DetailsEditable is false when Confirmed (see SetControlState).
                    Editable = DetailsEditable;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the registration status. Use the Confirm and Cancel actions to change it.';
                    // Already read-only because the table field is Editable = false.
                    StyleExpr = StatusStyle;
                }
                field("Registration Date"; Rec."Registration Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date the registration was created. It defaults to the work date.';
                }
            }
            group(Participant)
            {
                Caption = 'Participant';

                field("Participant Name"; Rec."Participant Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the full name of the participant. Required before confirmation.';
                    // Shows a red asterisk while the field is empty. It is only a
                    // visual hint; the actual check runs at confirmation.
                    ShowMandatory = true;
                    Editable = DetailsEditable;  // locked when Confirmed
                }
                field("Mobile Number"; Rec."Mobile Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the participant''s mobile number. Required before confirmation.';
                    ShowMandatory = true;
                    // Not locked: the requirement only protects participant,
                    // course and training date.
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the participant''s email address. Optional; the format is checked when entered.';
                }
                field(Organisation; Rec.Organisation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the organisation the participant belongs to.';
                }
            }
            group(Training)
            {
                Caption = 'Training';

                field("Course Name"; Rec."Course Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the training course. Required before confirmation.';
                    ShowMandatory = true;
                    Editable = DetailsEditable;  // locked when Confirmed
                }
                field("Training Date"; Rec."Training Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the scheduled training date. Required before confirmation and cannot be in the past.';
                    ShowMandatory = true;
                    Editable = DetailsEditable;  // locked when Confirmed
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any additional information about the registration.';
                    // Shows a larger, multi-line text box.
                    MultiLine = true;
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
                ToolTip = 'Check that the registration is complete and change its status to Confirmed.';
                Enabled = IsOpen;  // only available while the status is Open

                trigger OnAction()
                begin
                    // Save anything the user has just typed BEFORE confirming,
                    // so the checks see the latest values (and a brand-new
                    // record is inserted first).
                    CurrPage.SaveRecord();
                    // Runs all checks; stops with an error if any fail.
                    TrainingRegistrationMgt.ConfirmRegistration(Rec);
                    // Refresh the page: new status shows and fields lock.
                    CurrPage.Update(false);
                    Message(ConfirmedMsg, Rec."Registration No.");
                end;
            }
            action(CancelRegistration)
            {
                Caption = 'Cancel Registration';
                ApplicationArea = All;
                Image = Cancel;
                ToolTip = 'Cancel this registration. You are asked to confirm before the status changes.';
                Enabled = CanCancel;

                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    // Returns false if the user answers No: nothing changes.
                    if TrainingRegistrationMgt.CancelRegistration(Rec) then begin
                        CurrPage.Update(false);
                        Message(CancelledMsg, Rec."Registration No.");
                    end;
                end;
            }
        }
        area(Reporting)
        {
            action(PrintRegistration)
            {
                Caption = 'Print Registration';
                ApplicationArea = All;
                Image = Print;
                ToolTip = 'Preview or print this registration using the Training Registration List report.';

                trigger OnAction()
                var
                    TrainingRegistration: Record "Training Registration";
                begin
                    // Filter the report to just the registration on screen.
                    TrainingRegistration.SetRange("Registration No.", Rec."Registration No.");
                    Report.RunModal(Report::"Training Registration List", true, false, TrainingRegistration);
                end;
            }
        }
        // Puts the actions on the action bar at the top of the card.
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(ConfirmRegistration_Promoted; ConfirmRegistration)
                {
                }
                actionref(CancelRegistration_Promoted; CancelRegistration)
                {
                }
            }
            group(Category_Report)
            {
                Caption = 'Report';

                actionref(PrintRegistration_Promoted; PrintRegistration)
                {
                }
            }
        }
    }

    var
        TrainingRegistrationMgt: Codeunit "Training Registration Mgt.";
        // Page variables used by the Editable, Enabled and StyleExpr properties.
        // When they change, BC updates the controls the next time the page refreshes.
        DetailsEditable: Boolean;
        IsOpen: Boolean;
        CanCancel: Boolean;
        StatusStyle: Text;
        ConfirmedMsg: Label 'Training registration %1 has been confirmed.', Comment = '%1 = Registration No.';
        CancelledMsg: Label 'Training registration %1 has been cancelled.', Comment = '%1 = Registration No.';

    // Runs once when the page opens.
    trigger OnOpenPage()
    begin
        DetailsEditable := true;
    end;

    // Runs when the user starts a new, empty record on the card.
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetControlState();
    end;

    // Runs each time the record on screen is loaded or refreshed, for example
    // after CurrPage.Update() in the actions above.
    trigger OnAfterGetCurrRecord()
    begin
        SetControlState();
    end;

    // Works out what is editable or enabled, and the status colour, from the
    // current status.
    local procedure SetControlState()
    begin
        // Lock participant, course, training date (and the number) when Confirmed.
        DetailsEditable := Rec.Status <> Rec.Status::Confirmed;
        // Confirm is only allowed from Open.
        IsOpen := Rec.Status = Rec.Status::Open;
        // Cancel is allowed unless already cancelled, and only for a record
        // that has a number (not an empty new card).
        CanCancel := (Rec.Status <> Rec.Status::Cancelled) and (Rec."Registration No." <> '');

        case Rec.Status of
            Rec.Status::Confirmed:
                StatusStyle := 'Favorable';    // green
            Rec.Status::Cancelled:
                StatusStyle := 'Unfavorable';  // red
            else
                StatusStyle := 'Standard';
        end;
    end;
}
