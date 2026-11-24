// =============================================================================
// REPORT 50100 "Training Registration List"
// -----------------------------------------------------------------------------
// A report has two parts:
//   1. dataset  (this file): WHICH data is sent. Each "column" becomes a field
//               the layout can use.
//   2. layout   (TrainingRegistrationReport.rdlc): HOW it looks on paper.
//
// The request page (shown before the report runs) lets users filter on
// Training Date, Course Name and Status, and set the report title.
// The layout shows the record count at the top and in a total row.
// =============================================================================
report 50100 "Training Registration List"
{
    Caption = 'Training Registration List';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = TrainingRegistrationRDLC;

    dataset
    {
        dataitem(Registration; "Training Registration")
        {
            DataItemTableView = sorting("Registration No.");
            // These three fields appear as filter boxes on the request page.
            RequestFilterFields = "Training Date", "Course Name", Status;
            RequestFilterHeading = 'Training Registration';

            column(ReportTitle; ReportTitle)
            {
            }
            // IncludeCaption = true also sends the field's caption, which the
            // layout uses as the column heading (Parameters!...Caption).
            column(RegistrationNo; "Registration No.")
            {
                IncludeCaption = true;
            }
            column(ParticipantName; "Participant Name")
            {
                IncludeCaption = true;
            }
            column(Organisation; Organisation)
            {
                IncludeCaption = true;
            }
            column(MobileNumber; "Mobile Number")
            {
                IncludeCaption = true;
            }
            column(CourseName; "Course Name")
            {
                IncludeCaption = true;
            }
            column(TrainingDate; Format("Training Date"))
            {
            }
            column(RegistrationStatus; Status)
            {
            }
            column(RecordCount; RecordCount)
            {
            }
            column(Remarks; Remarks)
            {
            }

            trigger OnPreDataItem()
            begin
                RecordCount := 0;
            end;

            // Runs once for each registration that passes the filters.
            trigger OnAfterGetRecord()
            begin
                RecordCount += 1;
            end;
        }
    }

    requestpage
    {
        Caption = 'Training Registration List';
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(ReportTitleField; ReportTitle)
                    {
                        ApplicationArea = All;
                        Caption = 'Report Title';
                        ToolTip = 'Specifies the title printed at the top of the report.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if ReportTitle = '' then
                ReportTitle := DefaultTitleLbl;
        end;
    }

    rendering
    {
        layout(TrainingRegistrationRDLC)
        {
            Type = RDLC;
            LayoutFile = './src/TrainingRegistrationReport.rdlc';
            Caption = 'Training Registration List (RDLC)';
            Summary = 'Lists registrations with participant, course, training date and status, plus a record count.';
        }
    }

    trigger OnPreReport()
    begin
        if ReportTitle = '' then
            ReportTitle := DefaultTitleLbl;
    end;

    var
        ReportTitle: Text[100];
        RecordCount: Integer;
        DefaultTitleLbl: Label 'Training Registration List';
}
