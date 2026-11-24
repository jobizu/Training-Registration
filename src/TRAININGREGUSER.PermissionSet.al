// =============================================================================
// PERMISSION SET 50100 "TRAINING REG USER"
// -----------------------------------------------------------------------------
// A permission set is a list of what a user is allowed to do with each object.
// Assign it to a user under Users > User Card > Permission Sets, together with
// a base set (for example D365 BASIC) so they can sign in and navigate. SUPER
// is not needed.
//
// The object name is limited to 20 characters, so it is abbreviated. The
// Caption is the full name users see in the client.
//
// Permission letters:
//   For tabledata (the records stored in a table):
//     R = Read    I = Insert    M = Modify    D = Delete
//   For objects (tables, pages, reports, codeunits):
//     X = Execute (allowed to open or run the object)
// =============================================================================
permissionset 50100 "TRAINING REG USER"
{
    Caption = 'Training Registration User';
    // Assignable = true: the set can be assigned directly to users. (false
    // would make it a building block that only other sets can include.)
    Assignable = true;

    Permissions =
        // Permission to use the table object itself...
        table "Training Registration" = X,
        // ...and full access to its records: view, create, edit and delete.
        tabledata "Training Registration" = RIMD,
        // Open the list and the card.
        page "Training Registrations" = X,
        page "Training Registration Card" = X,
        // Run the registration list report.
        report "Training Registration List" = X,
        // Run the business logic behind Confirm/Cancel and field validation.
        codeunit "Training Registration Mgt." = X,
        // Install codeunit (runs when the extension is installed).
        codeunit "Training Registration Install" = X;
}
