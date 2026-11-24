# Test results: Training Registration

Tester: ____________ Date: ____________ BC version: 29.1 Server instance: BC290

Fill in **Actual result** and **Pass/Fail** while running each scenario in the web client.

| # | Test | Steps | Expected result | Actual result | Pass/Fail |
|---|---|---|---|---|---|
| 1 | Create a valid registration | New → No. `TR0100`, fill all fields, Training Date in the future → close card | Saved with Status **Open** and Registration Date = work date | | |
| 2 | Enter an existing registration number | New → No. `TR0001` | Error: *Registration No. TR0001 already exists. Enter a different registration number.* | | |
| 3 | Confirm with missing mandatory fields | New `TR0101` with only Organisation filled → Confirm Registration | Blocked: *…Fill in the following fields first: Participant Name, Mobile Number, Course Name, Training Date.* | | |
| 4 | Confirm with a past training date | Complete record, Training Date = yesterday → Confirm | Blocked: *…training date … is in the past…* | | |
| 5 | Confirm a complete, valid registration | Open `TR0100` → Confirm Registration | Status changes to **Confirmed**; confirmation message shown | | |
| 6 | Change protected details after confirmation | Open `TR0100` | Participant Name, Course Name and Training Date are read-only; any change through code is rejected with an error | | |
| 7 | Cancel and decline the prompt | Open `TR0002` → Cancel Registration → **No** | Status remains unchanged | | |
| 8 | Cancel and accept the prompt | Open `TR0002` → Cancel Registration → **Yes** | Status changes to **Cancelled** | | |
| 9 | Invalid email | Email = `john@site` | Error explaining the expected format | | |
| 10 | Filter and preview the report | Print Registration List → Status = Open, Course Name = `Power BI` → Preview | Only matching records appear; *Number of Records Included* equals the rows shown | | |
| 11 | Use the module with the training user | Sign in as user with TRAINING REG USER + D365 BASIC only | Create, edit, confirm, cancel and print all work without SUPER | | |
| 12 | Close and reopen Business Central | Sign out, close browser, sign in again | Previously saved registrations are still listed | | |

## Defects found and corrected

| # | Defect | Fix | Retest result |
|---|---|---|---|
| | | | |
