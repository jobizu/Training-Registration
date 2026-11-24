// =============================================================================
// CODEUNIT 50100 "Training Registration Mgt."
// -----------------------------------------------------------------------------
// A codeunit is a container for AL code (procedures) with no data or screen of
// its own. This one holds ALL the business rules of the module:
//
//   1. Field validation     - duplicate numbers, email and mobile formats
//   2. Record protection    - confirmed registrations cannot be changed
//   3. Status changes       - Confirm and Cancel, with their checks
//
// The table and both pages call these procedures, so every rule is written
// once. To change a rule, change it here.
//
// Key AL ideas used below:
//   - Error(...)  stops the code, rolls back any changes made so far and shows
//                 the message to the user. Nothing after an Error() runs.
//   - Label       a translatable text constant. %1, %2 ... are placeholders
//                 filled in by Error()/Message()/Confirm(). The Comment explains
//                 each placeholder to translators.
//   - var param   "var TrainingRegistration" means the procedure works on the
//                 caller's record itself, so changes are visible to the caller.
//                 Without "var" it receives a copy.
// =============================================================================
codeunit 50100 "Training Registration Mgt."
{
    var
        // ----- Messages shown to the user. Naming convention: ...Err for
        // errors, ...Qst for Yes/No questions, ...Msg for information. -----
        DuplicateRegistrationNoErr: Label 'Registration No. %1 already exists. Enter a different registration number.', Comment = '%1 = Registration No.';
        MissingFieldsErr: Label 'Registration %1 cannot be confirmed. Fill in the following fields first: %2.', Comment = '%1 = Registration No., %2 = comma-separated list of field captions';
        PastTrainingDateErr: Label 'Registration %1 cannot be confirmed because the training date %2 is in the past. Enter a training date on or after %3.', Comment = '%1 = Registration No., %2 = Training Date, %3 = Today';
        OnlyOpenCanBeConfirmedErr: Label 'Registration %1 cannot be confirmed because its status is %2. Only registrations with status Open can be confirmed.', Comment = '%1 = Registration No., %2 = Status';
        AlreadyCancelledErr: Label 'Registration %1 is already cancelled.', Comment = '%1 = Registration No.';
        CancelQst: Label 'Do you want to cancel registration %1 for %2?', Comment = '%1 = Registration No., %2 = Participant Name';
        ProtectedFieldErr: Label 'You cannot change %1 on registration %2 because the registration is confirmed. Confirmed registrations are locked for participant, course and training date.', Comment = '%1 = Field caption, %2 = Registration No.';
        ProtectedFieldsModifiedErr: Label 'Registration %1 is confirmed. The participant name, course name and training date cannot be changed.', Comment = '%1 = Registration No.';
        RenameConfirmedErr: Label 'Registration %1 is confirmed and cannot be renumbered.', Comment = '%1 = Registration No.';
        InvalidEmailErr: Label '%1 is not a valid email address. Enter an address that contains a single @ followed by a domain name with a dot, or leave the field blank.', Comment = '%1 = Email Address';
        InvalidMobileErr: Label '%1 is not a valid mobile number. Use at least 7 digits, optionally starting with +. Spaces and hyphens are allowed.', Comment = '%1 = Mobile Number';

    // =========================================================================
    // 1. FIELD VALIDATION (called from the table's OnValidate triggers)
    // =========================================================================

    // Rejects a registration number that is already used.
    // Called while the user is typing, so they get a clear message straight
    // away instead of BC's generic "record already exists" error on save.
    procedure CheckRegistrationNoIsUnique(RegistrationNo: Code[20])
    var
        TrainingRegistration: Record "Training Registration";
    begin
        if RegistrationNo = '' then
            exit;

        // Get() looks up a record by primary key; it returns true if found.
        if TrainingRegistration.Get(RegistrationNo) then
            Error(DuplicateRegistrationNoErr, RegistrationNo);
    end;

    // Simple email format check: one "@", something before it, and a domain
    // containing a dot after it (for example name@company.com).
    procedure ValidateEmailAddress(EmailAddress: Text)
    var
        LocalPart: Text;   // the part before the @
        Domain: Text;      // the part after the @
        AtPosition: Integer;
    begin
        // Email is optional, so a blank value is always accepted.
        if EmailAddress = '' then
            exit;

        // StrPos returns the position of the first '@' (0 if none).
        // Position 1 would mean nothing before the '@'. Spaces are not allowed.
        AtPosition := StrPos(EmailAddress, '@');
        if (AtPosition <= 1) or (StrPos(EmailAddress, ' ') > 0) then
            Error(InvalidEmailErr, EmailAddress);

        LocalPart := CopyStr(EmailAddress, 1, AtPosition - 1);
        Domain := CopyStr(EmailAddress, AtPosition + 1);

        // Rejected if: a second '@'; no dot in the domain or a dot right after
        // the '@'; the domain ends with a dot; two dots in a row; or the part
        // before the '@' starts or ends with a dot.
        if (StrPos(Domain, '@') > 0) or
           (StrPos(Domain, '.') <= 1) or
           (Domain[StrLen(Domain)] = '.') or
           (StrPos(Domain, '..') > 0) or
           (LocalPart[1] = '.') or
           (LocalPart[StrLen(LocalPart)] = '.')
        then
            Error(InvalidEmailErr, EmailAddress);
    end;

    // Accepts digits, an optional "+" at the start, spaces and hyphens,
    // with at least 7 digits in total. Examples: 0712000001, +254 712 000 001.
    procedure ValidateMobileNumber(MobileNumber: Text)
    var
        Digits: Text;  // collects only the digits, to count them at the end
        i: Integer;
    begin
        // Blank is allowed here; it is required only at confirmation time.
        if MobileNumber = '' then
            exit;

        // Check each character one at a time.
        for i := 1 to StrLen(MobileNumber) do
            case MobileNumber[i] of
                '0' .. '9':
                    Digits += Format(MobileNumber[i]);
                '+':
                    if i <> 1 then  // "+" is only valid as the first character
                        Error(InvalidMobileErr, MobileNumber);
                ' ', '-':
                    ; // allowed as separators; nothing to do
                else
                    Error(InvalidMobileErr, MobileNumber);
            end;

        if StrLen(Digits) < 7 then
            Error(InvalidMobileErr, MobileNumber);
    end;

    // =========================================================================
    // 2. PROTECTION OF CONFIRMED RECORDS
    // -------------------------------------------------------------------------
    // Requirement: participant, course and training date cannot change while a
    // registration is Confirmed. It is enforced in three layers:
    //   a) The card page makes those fields read-only (what the user sees).
    //   b) TestFieldChangeAllowed: runs when a field is validated (typed in).
    //   c) CheckProtectedFieldsUnchanged: runs before EVERY save, even from
    //      code that skips validation, so the rule cannot be bypassed.
    // =========================================================================

    // Layer (b): called from OnValidate of each protected field in the table.
    procedure TestFieldChangeAllowed(TrainingRegistration: Record "Training Registration"; FieldCaption: Text)
    begin
        if TrainingRegistration.Status = TrainingRegistration.Status::Confirmed then
            Error(ProtectedFieldErr, FieldCaption, TrainingRegistration."Registration No.");
    end;

    // Layer (c): compares the record being saved with the version currently
    // stored in the database. If the stored one is Confirmed and a protected
    // field differs, the save is rejected.
    procedure CheckProtectedFieldsUnchanged(TrainingRegistration: Record "Training Registration")
    var
        StoredRegistration: Record "Training Registration";
    begin
        // Temporary records exist only in memory, so there is nothing to protect.
        if TrainingRegistration.IsTemporary() then
            exit;

        // Read the current database version of the same record.
        if not StoredRegistration.Get(TrainingRegistration."Registration No.") then
            exit;

        if StoredRegistration.Status <> StoredRegistration.Status::Confirmed then
            exit;

        if (TrainingRegistration."Participant Name" <> StoredRegistration."Participant Name") or
           (TrainingRegistration."Course Name" <> StoredRegistration."Course Name") or
           (TrainingRegistration."Training Date" <> StoredRegistration."Training Date")
        then
            Error(ProtectedFieldsModifiedErr, TrainingRegistration."Registration No.");
    end;

    // Called from the table's OnRename trigger: a confirmed registration
    // cannot get a new registration number.
    procedure CheckRenameAllowed(OldTrainingRegistration: Record "Training Registration")
    begin
        if OldTrainingRegistration.Status = OldTrainingRegistration.Status::Confirmed then
            Error(RenameConfirmedErr, OldTrainingRegistration."Registration No.");
    end;

    // EVENT SUBSCRIBER: BC raises "OnBeforeModifyEvent" automatically just
    // before any Training Registration record is saved, including when code
    // calls Modify(false), which skips the table's own OnModify trigger.
    // Subscribing to it is what makes layer (c) impossible to bypass.
    [EventSubscriber(ObjectType::Table, Database::"Training Registration", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModifyTrainingRegistration(var Rec: Record "Training Registration")
    begin
        CheckProtectedFieldsUnchanged(Rec);
    end;

    // =========================================================================
    // 3. STATUS CHANGES (called from the Confirm/Cancel actions on the pages)
    // =========================================================================

    // Open -> Confirmed. All checks run first; if any fails, Error() stops
    // here and the status stays Open.
    procedure ConfirmRegistration(var TrainingRegistration: Record "Training Registration")
    begin
        if TrainingRegistration.Status <> TrainingRegistration.Status::Open then
            Error(OnlyOpenCanBeConfirmedErr, TrainingRegistration."Registration No.", TrainingRegistration.Status);

        CheckMandatoryFieldsForConfirmation(TrainingRegistration);
        CheckTrainingDateNotInPast(TrainingRegistration);

        TrainingRegistration.Status := TrainingRegistration.Status::Confirmed;
        // Modify(true) saves the record AND runs the table's OnModify trigger.
        TrainingRegistration.Modify(true);
    end;

    // Open/Confirmed -> Cancelled, after asking the user.
    // Returns true if cancelled, false if the user answered No, so the page
    // knows whether to show the "has been cancelled" message.
    procedure CancelRegistration(var TrainingRegistration: Record "Training Registration"): Boolean
    begin
        if TrainingRegistration.Status = TrainingRegistration.Status::Cancelled then
            Error(AlreadyCancelledErr, TrainingRegistration."Registration No.");

        // Confirm() shows a Yes/No dialog. The "false" makes No the default
        // button, so pressing Enter does not cancel by accident.
        if not Confirm(CancelQst, false, TrainingRegistration."Registration No.", TrainingRegistration."Participant Name") then
            exit(false);  // user said No: leave the status unchanged

        TrainingRegistration.Status := TrainingRegistration.Status::Cancelled;
        TrainingRegistration.Modify(true);
        exit(true);
    end;

    // Collects ALL missing mandatory fields and reports them in one message,
    // so the user can fix everything at once instead of one error at a time.
    procedure CheckMandatoryFieldsForConfirmation(TrainingRegistration: Record "Training Registration")
    var
        MissingFields: Text;
    begin
        // FieldCaption() returns the field's display name ('Participant Name'),
        // which is translated if the user runs BC in another language.
        if TrainingRegistration."Participant Name" = '' then
            AddToList(MissingFields, TrainingRegistration.FieldCaption("Participant Name"));
        if TrainingRegistration."Mobile Number" = '' then
            AddToList(MissingFields, TrainingRegistration.FieldCaption("Mobile Number"));
        if TrainingRegistration."Course Name" = '' then
            AddToList(MissingFields, TrainingRegistration.FieldCaption("Course Name"));
        if TrainingRegistration."Training Date" = 0D then  // 0D = empty date
            AddToList(MissingFields, TrainingRegistration.FieldCaption("Training Date"));

        if MissingFields <> '' then
            Error(MissingFieldsErr, TrainingRegistration."Registration No.", MissingFields);
    end;

    // A training date before today cannot be confirmed.
    // Today() is the real calendar date. WorkDate() is NOT used here because
    // users can set their work date to any date in My Settings.
    procedure CheckTrainingDateNotInPast(TrainingRegistration: Record "Training Registration")
    begin
        if TrainingRegistration."Training Date" < Today() then
            Error(PastTrainingDateErr, TrainingRegistration."Registration No.", TrainingRegistration."Training Date", Today());
    end;

    // Helper: appends Item to a comma-separated list.
    // "local" means only this codeunit can call it.
    local procedure AddToList(var List: Text; Item: Text)
    begin
        if List <> '' then
            List += ', ';
        List += Item;
    end;
}
