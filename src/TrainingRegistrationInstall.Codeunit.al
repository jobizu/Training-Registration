// =============================================================================
// CODEUNIT 50101 "Training Registration Install"
// -----------------------------------------------------------------------------
// Inserts the 10 sample registrations (TR0001-TR0010) the assignment asks for.
//
// Subtype = Install means BC runs this codeunit automatically when the
// extension is INSTALLED. It does not run when you republish the same
// version from VS Code. To reload the sample data, uninstall and reinstall the
// extension (Extension Management page).
// =============================================================================
codeunit 50101 "Training Registration Install"
{
    Subtype = Install;

    // Runs once for each company in the database during installation.
    trigger OnInstallAppPerCompany()
    begin
        InsertSampleData();
    end;

    procedure InsertSampleData()
    begin
        InsertSampleRegistration('TR0001', 'John Kamau', '0712000001', 'john.kamau@example.com', 'ABC Technologies', 'Microsoft Business Central', WorkDate() + 30, 'Initial registration');
        InsertSampleRegistration('TR0002', 'Mary Wanjiku', '0712000002', 'mary.wanjiku@example.com', 'XYZ Solutions', 'Advanced Excel', WorkDate() + 35, 'Corporate training');
        InsertSampleRegistration('TR0003', 'Peter Otieno', '0712000003', 'peter.otieno@example.com', 'Tech Africa', 'Python Programming', WorkDate() + 40, 'Beginner level');
        InsertSampleRegistration('TR0004', 'Grace Achieng', '0712000004', 'grace.achieng@example.com', 'Digital Hub', 'Web Development', WorkDate() + 45, 'Interested in frontend development');
        InsertSampleRegistration('TR0005', 'David Mwangi', '0712000005', 'david.mwangi@example.com', 'Nairobi Enterprises', 'Database Management', WorkDate() + 50, 'SQL training');
        InsertSampleRegistration('TR0006', 'Faith Njeri', '0712000006', 'faith.njeri@example.com', 'Smart Solutions', 'Cybersecurity Fundamentals', WorkDate() + 55, 'Security awareness training');
        InsertSampleRegistration('TR0007', 'Brian Kiptoo', '0712000007', 'brian.kiptoo@example.com', 'Kenya Digital', 'Cloud Computing', WorkDate() + 60, 'Cloud fundamentals');
        InsertSampleRegistration('TR0008', 'Lucy Atieno', '0712000008', 'lucy.atieno@example.com', 'Innovate Ltd', 'Data Analytics', WorkDate() + 65, 'Data analysis training');
        InsertSampleRegistration('TR0009', 'Samuel Maina', '0712000009', 'samuel.maina@example.com', 'Business Systems Ltd', 'Power BI', WorkDate() + 70, 'Reporting and visualization');
        InsertSampleRegistration('TR0010', 'Esther Wambui', '0712000010', 'esther.wambui@example.com', 'Future Technologies', 'Microsoft Azure', WorkDate() + 75, 'Cloud certification preparation');
    end;

    local procedure InsertSampleRegistration(RegistrationNo: Code[20]; ParticipantName: Text[100]; MobileNumber: Text[30]; EmailAddress: Text[100]; OrganisationName: Text[100]; CourseName: Text[100]; TrainingDate: Date; RemarksText: Text[250])
    var
        TrainingRegistration: Record "Training Registration";
    begin
        // Skip numbers that already exist, so reinstalling creates no duplicates.
        if TrainingRegistration.Get(RegistrationNo) then
            exit;

        // Init() clears the record and applies InitValue (Status = Open).
        // Validate() runs each field's OnValidate checks, as if a user typed it.
        // Insert(true) runs the table's OnInsert trigger, which sets Registration Date.
        TrainingRegistration.Init();
        TrainingRegistration.Validate("Registration No.", RegistrationNo);
        TrainingRegistration.Validate("Participant Name", ParticipantName);
        TrainingRegistration.Validate("Mobile Number", MobileNumber);
        TrainingRegistration.Validate("Email Address", EmailAddress);
        TrainingRegistration.Validate(Organisation, OrganisationName);
        TrainingRegistration.Validate("Course Name", CourseName);
        TrainingRegistration.Validate("Training Date", TrainingDate);
        TrainingRegistration.Validate(Remarks, RemarksText);
        TrainingRegistration.Insert(true);
    end;
}
