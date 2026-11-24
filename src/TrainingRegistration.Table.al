// =============================================================================
// TABLE 50100 "Training Registration"
// -----------------------------------------------------------------------------
// The table is where the data lives: one row per participant registration.
// Business Central creates a SQL table for it when the extension is published,
// so records survive closing and reopening the client.
//
// Design rule used throughout this project: the table only *calls* the rules;
// the rules themselves live in codeunit "Training Registration Mgt." so they can
// be reused by pages, reports and other code.
// =============================================================================
table 50100 "Training Registration"
{
    Caption = 'Training Registration';

    // Tells BC what kind of data this is (for privacy/GDPR tools).
    // CustomerContent = data entered by the customer's users.
    DataClassification = CustomerContent;

    // Page used when a user looks up or drills down into this table from
    // another page (for example the "..." button on a field).
    LookupPageId = "Training Registrations";
    DrillDownPageId = "Training Registrations";

    fields
    {
        // field(<ID>; <Name>; <Type>)
        // The ID is permanent: never renumber a field once data exists.

        field(1; "Registration No."; Code[20])
        {
            Caption = 'Registration No.';
            // NotBlank: BC refuses to save the record if this is empty.
            NotBlank = true;

            // OnValidate runs when the user types a value in a page, or when
            // code calls Rec.Validate("Registration No.", ...).
            // xRec holds the value *before* the change, so we only check for a
            // duplicate when the number actually changed.
            trigger OnValidate()
            begin
                if "Registration No." <> xRec."Registration No." then
                    TrainingRegistrationMgt.CheckRegistrationNoIsUnique("Registration No.");
            end;
        }
        field(2; "Participant Name"; Text[100])
        {
            Caption = 'Participant Name';

            // Protected field: blocked once the registration is Confirmed.
            trigger OnValidate()
            begin
                TrainingRegistrationMgt.TestFieldChangeAllowed(Rec, FieldCaption("Participant Name"));
            end;
        }
        field(3; "Mobile Number"; Text[30])
        {
            Caption = 'Mobile Number';
            // Makes the value clickable as a phone number in the web client.
            ExtendedDatatype = PhoneNo;

            trigger OnValidate()
            begin
                TrainingRegistrationMgt.ValidateMobileNumber("Mobile Number");
            end;
        }
        field(4; "Email Address"; Text[100])
        {
            Caption = 'Email Address';
            // Makes the value clickable as an email link in the web client.
            ExtendedDatatype = EMail;

            // Optional field: the codeunit exits immediately when it is blank,
            // and only checks the format when something is entered.
            trigger OnValidate()
            begin
                TrainingRegistrationMgt.ValidateEmailAddress("Email Address");
            end;
        }
        field(5; Organisation; Text[100])
        {
            Caption = 'Organisation';
        }
        field(6; "Course Name"; Text[100])
        {
            Caption = 'Course Name';

            // Protected field: blocked once the registration is Confirmed.
            trigger OnValidate()
            begin
                TrainingRegistrationMgt.TestFieldChangeAllowed(Rec, FieldCaption("Course Name"));
            end;
        }
        field(7; "Training Date"; Date)
        {
            Caption = 'Training Date';

            // Protected field: blocked once the registration is Confirmed.
            trigger OnValidate()
            begin
                TrainingRegistrationMgt.TestFieldChangeAllowed(Rec, FieldCaption("Training Date"));
            end;
        }
        field(8; "Registration Date"; Date)
        {
            Caption = 'Registration Date';
            // Filled automatically in OnInsert; users cannot type in it.
            Editable = false;
        }
        field(9; Status; Enum "Training Registration Status")
        {
            Caption = 'Status';
            // Value given to every new record before the user types anything.
            InitValue = Open;
            // Users cannot pick a status directly. It only changes through the
            // Confirm/Cancel actions, which run the checks in the codeunit.
            Editable = false;
        }
        field(10; Remarks; Text[250])
        {
            Caption = 'Remarks';
        }
    }

    keys
    {
        // Primary key: uniquely identifies a record. BC itself also rejects a
        // second record with the same number when it is inserted.
        key(PK; "Registration No.")
        {
            Clustered = true;
        }
        // Secondary key: speeds up sorting/filtering by date and course,
        // which is what the report filters on.
        key(TrainingDate; "Training Date", "Course Name")
        {
        }
    }

    fieldgroups
    {
        // DropDown: columns shown when this table is looked up from a field.
        fieldgroup(DropDown; "Registration No.", "Participant Name", "Course Name", "Training Date", Status)
        {
        }
        // Brick: fields shown when the list is displayed as tiles.
        fieldgroup(Brick; "Registration No.", "Participant Name", "Course Name", "Training Date", Status)
        {
        }
    }

    var
        // Global variable: one instance of the business-logic codeunit that
        // every trigger and procedure in this table can use.
        TrainingRegistrationMgt: Codeunit "Training Registration Mgt.";

    // Runs when a new record is inserted with Insert(true), which includes
    // every record created from a page.
    trigger OnInsert()
    begin
        // Requirement: Registration Date defaults to the work date.
        if "Registration Date" = 0D then
            "Registration Date" := WorkDate();
    end;

    // Runs when the primary key (Registration No.) of an existing record is
    // changed. xRec is the record with its OLD key.
    trigger OnRename()
    begin
        TrainingRegistrationMgt.CheckRenameAllowed(xRec);
    end;

    // Convenience methods so code can write Rec.ConfirmRegistration() instead
    // of calling the codeunit directly. Both just forward to the codeunit.
    procedure ConfirmRegistration()
    begin
        TrainingRegistrationMgt.ConfirmRegistration(Rec);
    end;

    procedure CancelRegistration(): Boolean
    begin
        exit(TrainingRegistrationMgt.CancelRegistration(Rec));
    end;
}
