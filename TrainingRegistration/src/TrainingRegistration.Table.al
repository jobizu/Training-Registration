
table 50100 "Training Registration"
{
    Caption = 'Training Registration';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Registration No."; Code[20])
        {
            Caption = 'Registration No.';
            NotBlank = true;
        }

        field(2; "Participant Name"; Text[100])
        {
            Caption = 'Participant Name';
        }

        field(3; "Mobile Number"; Text[30])
        {
            Caption = 'Mobile Number';
        }

        field(4; "Email Address"; Text[100])
        {
            Caption = 'Email Address';

            trigger OnValidate()
            var
                AtPosition: Integer;
                Domain: Text;
            begin
                if "Email Address" = '' then
                    exit;

                AtPosition := StrPos("Email Address", '@');

                if (AtPosition <= 1) or
                   (StrPos(CopyStr("Email Address", AtPosition + 1), '@') > 0) or
                   (StrPos("Email Address", ' ') > 0) then
                    Error('Please enter a valid email address.');

                Domain := CopyStr("Email Address", AtPosition + 1);

                if (StrPos(Domain, '.') <= 1) or
                   (Domain[StrLen(Domain)] = '.') then
                    Error('Please enter a valid email address.');
            end;
        }

        field(5; Organisation; Text[100])
        {
            Caption = 'Organisation';
        }

        field(6; "Course Name"; Text[100])
        {
            Caption = 'Course Name';
        }

        field(7; "Training Date"; Date)
        {
            Caption = 'Training Date';
        }

        field(8; "Registration Date"; Date)
        {
            Caption = 'Registration Date';
            Editable = false;
        }

        field(9; Status; Enum "Training Registration Status")
        {
            Caption = 'Status';
            InitValue = Open;
            Editable = false;
        }

        field(10; Remarks; Text[250])
        {
            Caption = 'Remarks';
        }
    }

    keys
    {
        key(PK; "Registration No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "Registration Date" = 0D then
            "Registration Date" := WorkDate();
    end;

    procedure ConfirmRegistration()
    begin
        if Status <> Status::Open then
            Error('Only open registrations can be confirmed.');

        if "Participant Name" = '' then
            Error('Participant Name is required before confirmation.');

        if "Mobile Number" = '' then
            Error('Mobile Number is required before confirmation.');

        if "Course Name" = '' then
            Error('Course Name is required before confirmation.');

        if "Training Date" = 0D then
            Error('Training Date is required before confirmation.');

        if "Training Date" < WorkDate() then
            Error('Training Date cannot be in the past.');

        Validate(Status, "Training Registration Status"::Confirmed);
        Modify(true);
    end;
}
