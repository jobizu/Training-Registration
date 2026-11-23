
codeunit 50100 "Training Registration Mgt"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InsertSampleRegistration(
            'TR0001', 'John Kamau', '0712000001',
            'john.kamau@gmail.com', 'ABC Technologies',
            'Microsoft Business Central', WorkDate() + 30,
            'Initial registration');

        InsertSampleRegistration(
            'TR0002', 'Mary Wanjiku', '0712000002',
            'mary.wanjiku@gmail.com', 'XYZ Solutions',
            'Advanced Excel', WorkDate() + 35,
            'Corporate training');

        InsertSampleRegistration(
            'TR0003', 'Peter Otieno', '0712000003',
            'peter.otieno@gmail.com', 'Tech Africa',
            'Python Programming', WorkDate() + 40,
            'Beginner level');

        InsertSampleRegistration(
            'TR0004', 'Grace Achieng', '0712000004',
            'grace.achieng@gmail.com', 'Digital Hub',
            'Web Development', WorkDate() + 45,
            'Interested in frontend development');

        InsertSampleRegistration(
            'TR0005', 'David Mwangi', '0712000005',
            'david.mwangi@gmail.com', 'Nairobi Enterprises',
            'Database Management', WorkDate() + 50,
            'SQL training');

        InsertSampleRegistration(
            'TR0006', 'Faith Njeri', '0712000006',
            'faith.njeri@gmail.com', 'Smart Solutions',
            'Cybersecurity Fundamentals', WorkDate() + 55,
            'Security awareness training');

        InsertSampleRegistration(
            'TR0007', 'Brian Kiptoo', '0712000007',
            'brian.kiptoo@gmail.com', 'Kenya Digital',
            'Cloud Computing', WorkDate() + 60,
            'Cloud fundamentals');

        InsertSampleRegistration(
            'TR0008', 'Lucy Atieno', '0712000008',
            'lucy.atieno@gmail.com', 'Innovate Ltd',
            'Data Analytics', WorkDate() + 65,
            'Data analysis training');

        InsertSampleRegistration(
            'TR0009', 'Samuel Maina', '0712000009',
            'samuel.maina@gmail.com', 'Business Systems Ltd',
            'Power BI', WorkDate() + 70,
            'Reporting and visualization');

        InsertSampleRegistration(
            'TR0010', 'Esther Wambui', '0712000010',
            'esther.wambui@gmail.com', 'Future Technologies',
            'Microsoft Azure', WorkDate() + 75,
            'Cloud certification preparation');
    end;

    local procedure InsertSampleRegistration(
        RegistrationNo: Code[20];
        ParticipantName: Text[100];
        MobileNumber: Text[30];
        EmailAddress: Text[100];
        OrganisationName: Text[100];
        CourseName: Text[100];
        TrainingDate: Date;
        RemarksText: Text[250])
    var
        TrainingRegistration: Record "Training Registration";
    begin
        if TrainingRegistration.Get(RegistrationNo) then
            exit;

        TrainingRegistration.Init();

        TrainingRegistration."Registration No." := RegistrationNo;
        TrainingRegistration."Participant Name" := ParticipantName;
        TrainingRegistration."Mobile Number" := MobileNumber;
        TrainingRegistration.Validate("Email Address", EmailAddress);
        TrainingRegistration.Organisation := OrganisationName;
        TrainingRegistration."Course Name" := CourseName;
        TrainingRegistration."Training Date" := TrainingDate;
        TrainingRegistration.Remarks := RemarksText;

        TrainingRegistration.Insert(true);
    end;
}
