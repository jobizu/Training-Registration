// =============================================================================
// PAGE 50100 "Training Registrations"  (List page)
// -----------------------------------------------------------------------------
// Shows all registrations in a grid. Users search, sort and filter here, then
// open a record to edit it on the Card page.
//
// The list itself is read-only (Editable = false): editing happens on the
// card, where the field-locking rules for confirmed records are shown.
// =============================================================================
page 50100 "Training Registrations"
{
    PageType = List;
    // SourceTable: the table whose records this page displays. Inside the page,
    // "Rec" means the record currently selected.
    SourceTable = "Training Registration";
    Caption = 'Training Registrations';

    // ApplicationArea + UsageCategory make the page appear in "Tell me" search
    // (Alt+Q). Lists = it is listed under the "Lists" heading in the results.
    ApplicationArea = All;
    UsageCategory = Lists;
    // Extra words that also find this page in search.
    AdditionalSearchTerms = 'Training, Course Registration, Participants, Training Sessions';

    // Requirement: the list opens the card. Double-clicking a row, or choosing
    // New/Edit/View, opens this card page.
    CardPageId = "Training Registration Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            // repeater = one row per record.
            repeater(General)
            {
                // field(<control name>; <source expression>)
                // ToolTip = help text shown when hovering over the column.
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
                    // Two single quotes ('') = one apostrophe inside AL text.
                    ToolTip = 'Specifies the participant''s mobile number.';
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the participant''s email address.';
                }
                field(Organisation; Rec.Organisation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the participant''s organisation.';
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
                    ToolTip = 'Specifies the date the registration was created.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the registration is open, confirmed or cancelled.';
                    // Colours the status: green = Confirmed, red = Cancelled.
                    // StatusStyle is set per row in OnAfterGetRecord below.
                    StyleExpr = StatusStyle;
                }
            }
        }
    }

    actions
    {
        // Processing = buttons that do something to the data.
        area(Processing)
        {
            action(NewRegistration)
            {
                Caption = 'New Registration';
                ApplicationArea = All;
                ToolTip = 'Create a new training registration.';
                Image = New;
                // No code needed: opens the card ready for a new record.
                RunObject = page "Training Registration Card";
                RunPageMode = Create;
            }
            action(ConfirmRegistration)
            {
                Caption = 'Confirm Registration';
                ApplicationArea = All;
                Image = Approve;
                ToolTip = 'Check that the selected registration is complete and change its status to Confirmed.';
                // Greyed out unless the selected row is Open (see OnAfterGetCurrRecord).
                Enabled = IsOpen;

                trigger OnAction()
                begin
                    // All checks are in the codeunit. If one fails it raises
                    // an Error, and the two lines below never run.
                    TrainingRegistrationMgt.ConfirmRegistration(Rec);
                    // Refresh the page so the new status shows. false = do not
                    // save the record again (the codeunit already saved it).
                    CurrPage.Update(false);
                    Message(ConfirmedMsg, Rec."Registration No.");
                end;
            }
            action(CancelRegistration)
            {
                Caption = 'Cancel Registration';
                ApplicationArea = All;
                Image = Cancel;
                ToolTip = 'Cancel the selected registration. You are asked to confirm before the status changes.';
                Enabled = CanCancel;

                trigger OnAction()
                begin
                    // The codeunit asks "Do you want to cancel...?" and returns
                    // false if the user answers No; then nothing happens.
                    if TrainingRegistrationMgt.CancelRegistration(Rec) then begin
                        CurrPage.Update(false);
                        Message(CancelledMsg, Rec."Registration No.");
                    end;
                end;
            }
        }
        // Reporting = buttons that run reports.
        area(Reporting)
        {
            action(PrintRegistrationList)
            {
                Caption = 'Print Registration List';
                ApplicationArea = All;
                Image = Print;
                ToolTip = 'Preview or print the training registration list. The filters on this page are carried over and can be changed on the request page.';

                trigger OnAction()
                var
                    TrainingRegistration: Record "Training Registration";
                begin
                    // Copy the filters the user set on this list, so the report
                    // starts with the same selection.
                    TrainingRegistration.CopyFilters(Rec);
                    // RunModal(report, show request page?, use system printer?, records)
                    Report.RunModal(Report::"Training Registration List", true, false, TrainingRegistration);
                end;
            }
        }
        // Promoted = which actions appear as buttons on the action bar at the
        // top of the page, and in which group. actionref points to an action
        // defined above; it does not duplicate the code.
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(NewRegistration_Promoted; NewRegistration)
                {
                }
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

                actionref(PrintRegistrationList_Promoted; PrintRegistrationList)
                {
                }
            }
        }
    }

    var
        TrainingRegistrationMgt: Codeunit "Training Registration Mgt.";
        // Page variables used by the Enabled and StyleExpr properties above.
        IsOpen: Boolean;
        CanCancel: Boolean;
        StatusStyle: Text;
        ConfirmedMsg: Label 'Training registration %1 has been confirmed.', Comment = '%1 = Registration No.';
        CancelledMsg: Label 'Training registration %1 has been cancelled.', Comment = '%1 = Registration No.';

    // Runs for EVERY row as it is loaded into the grid, so each row gets its
    // own status colour.
    trigger OnAfterGetRecord()
    begin
        StatusStyle := GetStatusStyle();
    end;

    // Runs whenever the user selects a different row; decides which action
    // buttons are available for that row.
    trigger OnAfterGetCurrRecord()
    begin
        IsOpen := Rec.Status = Rec.Status::Open;
        CanCancel := Rec.Status <> Rec.Status::Cancelled;
    end;

    // Returns a built-in BC style name: Favorable = green, Unfavorable = red,
    // Standard = normal text.
    local procedure GetStatusStyle(): Text
    begin
        case Rec.Status of
            Rec.Status::Confirmed:
                exit('Favorable');
            Rec.Status::Cancelled:
                exit('Unfavorable');
        end;
        exit('Standard');
    end;
}
