// =============================================================================
// ENUM 50100 "Training Registration Status"
// -----------------------------------------------------------------------------
// An enum is a fixed list of named values. It is used as the type of the
// Status field, so users see a dropdown of these three options. The database
// stores the number, and users see the caption.
//
// Lifecycle:   Open --Confirm--> Confirmed
//              Open/Confirmed --Cancel--> Cancelled
// The changes are made only by codeunit "Training Registration Mgt.".
// =============================================================================
enum 50100 "Training Registration Status"
{
    // false = other extensions cannot add more values to this list.
    Extensible = false;

    // value(<number stored in the database>; <name used in code>)
    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; Confirmed)
    {
        Caption = 'Confirmed';
    }
    value(2; Cancelled)
    {
        Caption = 'Cancelled';
    }
}
