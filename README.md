# Training Registration: Business Central 29.1 Extension

Registers participants for training sessions, confirms or cancels registrations
with validation, protects confirmed records, and prints a filtered registration
list with a record count.

| | |
|---|---|
| **Platform** | Dynamics 365 Business Central 29.1 on-premises (runtime 18.0) |
| **Server instance** | `BC290` at `http://localhost:8080`, Windows authentication |
| **Object ID range** | 50100–50149 |
| **Package** | `Default Publisher_TrainingRegistration_1.0.0.0.app` |

---

## 1. How the module fits together

```
 Training Registrations (List, 50100) ──opens──▶ Training Registration Card (50101)
          │  Confirm / Cancel / Print                 │  Confirm / Cancel / Print
          └──────────────┬────────────────────────────┘
                         ▼
          Training Registration Mgt. (Codeunit 50100)   ◀── all business rules
                         │
                         ▼
          Training Registration (Table 50100)  ── Status uses ──▶ Enum 50100
                         │
                         ▼
          Training Registration List (Report 50100 + RDLC layout)
```

The pages and the table only **call** the rules; the rules themselves are
written once, in the codeunit.

## 2. Objects

| File (`src/`) | Object | Purpose |
|---|---|---|
| `TrainingRegistration.Table.al` | Table 50100 *Training Registration* | Stores registrations; triggers call the codeunit |
| `TrainingRegistrationStatus.Enum.al` | Enum 50100 *Training Registration Status* | Open, Confirmed, Cancelled |
| `TrainingRegistrations.Page.al` | Page 50100 *Training Registrations* (List) | Search, filter, run actions; opens the card |
| `TrainingRegistrationCard.Page.al` | Page 50101 *Training Registration Card* | Create/edit one record; locks fields when confirmed |
| `TrainingRegistrationMgt.Codeunit.al` | Codeunit 50100 *Training Registration Mgt.* | Validation, protection, confirm/cancel |
| `TrainingRegistrationInstall.Codeunit.al` | Codeunit 50101 *Training Registration Install* | Inserts 10 sample records on install |
| `TrainingRegistrationList.Report.al` + `.rdlc` | Report 50100 *Training Registration List* | Filtered list with record count |
| `TRAININGREGUSER.PermissionSet.al` | Permission set 50100 *TRAINING REG USER* | Access for non-SUPER users |

Each file starts with a comment block explaining what it does and the AL concepts it uses.

## 3. Table fields

| Field | Type | Rule |
|---|---|---|
| Registration No. | Code[20] | Primary key, entered manually; duplicates rejected |
| Participant Name | Text[100] | Required to confirm · locked when confirmed |
| Mobile Number | Text[30] | Required to confirm · digits, optional leading `+`, spaces/hyphens, min. 7 digits |
| Email Address | Text[100] | Optional · format checked when entered |
| Organisation | Text[100] | – |
| Course Name | Text[100] | Required to confirm · locked when confirmed |
| Training Date | Date | Required to confirm · must not be before **today** · locked when confirmed |
| Registration Date | Date | Set to the **work date** on insert · read-only |
| Status | Enum | Defaults to Open · changed only by actions |
| Remarks | Text[250] | – |

## 4. Business rules

**Status lifecycle**

```
Open ──Confirm──▶ Confirmed
  └──────Cancel (Yes/No prompt)──────▶ Cancelled ◀── Cancel ── Confirmed
```

- **Confirm** works only from *Open*. It lists every missing mandatory field in
  one message, and rejects a training date before today's calendar date. The
  work date is not used for this check because each user can change it.
- **Cancel** asks *"Do you want to cancel…?"*. Answering **No** leaves the status unchanged.
- **Confirmed records are locked.** Participant, course and training date cannot
  change, and the record cannot be renumbered. Enforced in three layers:

  | Layer | Where | Catches |
  |---|---|---|
  | Page | Card fields `Editable = DetailsEditable` | User sees read-only fields |
  | Field validation | Table `OnValidate` → `TestFieldChangeAllowed` | Typing, `Validate()` in code |
  | Save check | `OnBeforeModifyEvent` subscriber → `CheckProtectedFieldsUnchanged` | Any code, even `Modify(false)` |

All messages are `Label`s in the codeunit and say what the user must correct.

## 5. Installation

**Prerequisites:** BC 29.1 server instance with developer services enabled
(`DeveloperServicesEnabled = true`, port 7049), VS Code, AL Language extension.

**From VS Code (development):**

1. Open this folder (the one containing `app.json`) in VS Code.
2. Check that `.vscode/launch.json` matches your server: `server`, `serverInstance`, `port`, `authentication`.
3. `Ctrl+Shift+P` → **AL: Download Symbols**.
4. **Ctrl+F5** to publish. The browser opens on *Training Registrations*.

**From the compiled package (Business Central Administration Shell):**

```powershell
Publish-NAVApp -ServerInstance BC290 -Path ".\Default Publisher_TrainingRegistration_1.0.0.0.app" -SkipVerification
Sync-NAVApp    -ServerInstance BC290 -Name TrainingRegistration -Version 1.0.0.0
Install-NAVApp -ServerInstance BC290 -Name TrainingRegistration -Version 1.0.0.0
```

Installing adds 10 sample registrations (TR0001–TR0010) to each company.
Republishing the same version does **not** re-run this. To reload the samples,
uninstall and reinstall the extension.

## 6. Setting up the training user

1. **Users** → **New**: enter the user (for Windows authentication, the domain account).
2. **User Permission Sets**: add **TRAINING REG USER** and a base set such as **D365 BASIC**. Do **not** add SUPER.
3. Sign in as that user and run the test scenarios.

What the permission set grants:

| Object | Permission |
|---|---|
| Training Registration data | Read, Insert, Modify, Delete |
| Table, both pages, report, both codeunits | Execute |

## 7. Using the module

1. **Find it:** `Alt+Q`, type *Training Registrations* (also: *training*, *course registration*, *participants*).
2. **Create:** **New**, enter a unique Registration No. and the details. It saves automatically when you close the card.
3. **Confirm:** open a record → **Confirm Registration**. Fix any fields named in the message if it is rejected.
4. **Cancel:** **Cancel Registration** → answer **Yes** to proceed or **No** to keep it.
5. **Print:** **Print Registration List** (list) or **Print Registration** (card). Set filters
   for Training Date, Course Name and Status → **Preview** or **Print**.
   The list's current filters carry over to the report.

## 8. Debugging

`launch.json` has two configurations (pick one in the **Run and Debug** dropdown):

| Configuration | Pauses on errors | SQL info | Use for |
|---|---|---|---|
| **Business Central Local Server** | No | Off | Everyday testing (normal speed) |
| **Business Central Local Server (debug demo)** | Yes | On | Demonstrating the debugger |

**Breakpoint demo:** choose *debug demo* → open `src/TrainingRegistrationMgt.Codeunit.al`
→ press **F9** on the first line of `ConfirmRegistration` → **F5** → in the browser run
*Confirm Registration*. VS Code stops on the line; use **F10** (step over), **F11**
(step into) and hover over variables. Press **F5** to continue, because the browser waits while paused.

> **Tip:** if an action seems slow or frozen, check whether VS Code is paused on a breakpoint
> or error. For normal testing use **Ctrl+F5** (no debugger).

## 9. Testing

The test scenarios and a results table to fill in are in [TEST-RESULTS.md](TEST-RESULTS.md).

## 10. Troubleshooting

| Symptom | Cause / fix |
|---|---|
| VS Code shows errors the build doesn't, e.g. *"does not contain a definition for…"* | Stale editor tabs. Close tabs for old/deleted files (**Don't Save**), then **Developer: Reload Window** |
| *"Training date … is in the past"* for a future date | The date is before today. (Older builds compared with the work date; republish.) |
| Report: *"The definition of the report is invalid"* | Invalid RDLC layout. Republish the current build; the layout was rewritten |
| Sample records missing | Install codeunit only runs on install. Uninstall and reinstall the extension |
| Training user gets a permission error | Assign both **TRAINING REG USER** and a base set (e.g. **D365 BASIC**) |
