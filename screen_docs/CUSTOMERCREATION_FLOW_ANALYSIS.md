# Customer Creation Flow Analysis

## Current Issue Snapshot

- Observed runtime logs:
  - `[SAVE_CUSTOMER] Failed response keys: [status_code, status_msg]`
  - `[SAVE_CUSTOMER] Failed response: {status_code: 1, status_msg: Mandatory fields are missing.}`
  - UI error surfaced from save/update path as `ApiException ... (statusCode: 1)`.
- Meaning: backend accepted request routing/auth enough to respond, but save payload failed mandatory-field checks.

## Root Cause Pattern

The backend uses legacy key names in multiple places (`country/state/district/city/mandal`, `group`, `installationAddress` / `installation_address`) while Flutter had mixed/new key variants in some paths.  
This can trigger generic server response: `Mandatory fields are missing.` even when UI fields appear filled.

## What Was Updated

### 1) Save/Edit error visibility hardening

File: `lib/data/datasources/remote/customer_remote_datasource.dart`

- Added explicit bearer header for customer save/edit:
  - `Authorization: Bearer <authtoken>`
- Added empty-token guard:
  - throws `Session missing. Please login again.`
- Added robust status parsing:
  - supports both `status_code` and `statusCode`
- Added debug failure logs showing response keys + payload map for save/edit failures.

### 2) New customer payload compatibility hardening

File: `lib/presentation/screens/customers/new_customer_screen.dart`

- Sent both legacy and alias keys for critical location/group/install fields:
  - `country` + `countryCode`
  - `state` + `stateId`
  - `district` + `districtId`
  - `city` + `cityId`
  - `mandal` + `mandalId`
  - `group` + `groupId`
  - `installationAddress` + `installation_address`
- Purpose: prevent backend mandatory-check failures due key-name mismatch across server branches/procedures.

### 3) Edit customer payload alignment (done earlier in this debugging cycle)

File: `lib/presentation/screens/customers/edit_customer_screen.dart`

- Normalized to server-expected keys for update flow:
  - `mobile`, `group`, `country/state/district/city/mandal`, `address`, `pin`,
    `installationAddress`/`installation_address`, `change_addrs`.
- Restored `Group` as mandatory in UI validation.

### 4) Edit screen "new customer" save path hardening

File: `lib/presentation/screens/customers/edit_customer_screen.dart`

- `Edit Customer` has a branch where `customerId == "new"` and it calls `saveCustomerRest`.
- That branch now sends compatibility aliases for mandatory location/group fields:
  - `mobile` + `mobileNumber`
  - `group` + `groupId`
  - `country` + `countryCode`
  - `state` + `stateId`
  - `district` + `districtId`
  - `city` + `cityId`
  - `mandal` + `mandalId`
  - `resellerId` + `reseller_id`
- Added fail-fast client validation for mandatory request keys in this branch:
  - `customerTypeId`, `firstName`, `mobile`, `group`, `country`, `state`,
    `district`, `city`, `address`, `pin`, `installationAddress`, `boxNumber`
- Reason: backend was returning generic `status_code:1, Mandatory fields are missing`
  without indicating which field was absent.

## Mandal/City Dependency Note (Requested Behavior)

- Expected behavior confirmed:
  - Mandal list from API by district/dealer context.
  - If mandal not selected -> full city list.
  - If mandal selected -> city list filtered by selected mandal.
- This dependency was wired in edit flow with mandal-first behavior.

## Next Debug Step If Status 1 Persists

If save still returns `{status_code: 1, status_msg: "Mandatory fields are missing."}`:

1. Capture `[SAVE_CUST_REQ] ALL keys` and `[SAVE_CUSTOMER] Failed response` logs.
2. Compare keys against server-side save procedure expectations for that dealer deployment.
3. Add any deployment-specific mandatory fields (if server procedure enforces extras like `resellerId`, etc.).
4. If error still persists, capture `[EDIT→SAVE] saveCustomerRest payload keys` log and compare with server-side required keys in `saveCustomerRest_post`.

