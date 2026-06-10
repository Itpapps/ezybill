# Customer Creation Flow Analysis

This file mirrors `CUSTOMERCREATION_FLOW_ANALYSIS.md` and is kept for discoverability
using the hyphenated name referenced in team chat.

---

## Latest update — 2026-04-29 Session 3 (Comprehensive address fixes)

### CRITICAL: Two customer creation paths exist

1. **`new_customer_screen.dart`** — Full wizard (STB verify → form → package → confirm → save)
   - Uses `masterDataProvider` selections directly in payload
2. **`edit_customer_screen.dart`** with `customerId='new'` — Used when navigating from
   STB lookup to create a new customer
   - Uses LOCAL state vars (`_billingCountry`, `_billingState`, `_billingCity` etc.)
   - These are SEPARATE from `masterDataProvider` selected values
   - Address fields gated behind `_changeAddress` toggle (defaults to `false`!)

### Issue 1: City invalid on save — "Please select City/Invalid City"

**Runtime error:**
```
{status_code: 1, status_msg: Please select City/Invalid City.}
```

**Root causes found (multiple layers):**

1. **`_changeAddress = false` by default** in `edit_customer_screen.dart`
   - For new customers (`customerId='new'`), address section was HIDDEN
   - User could never enter Country/State/District/City
   - City was either missing or picked from stale `widget.customer` data
   - **Fix**: Force `_changeAddress = true` and `_changeInstallAddress = true` for new customers

2. **Session defaults not synced to edit screen local state**
   - `masterDataProvider.initialise()` auto-selects default Country/State/District/City
   - But edit screen uses LOCAL vars (`_billingCountry` etc.) — these stayed `null`
   - **Fix**: After `_loadMasterData()`, sync from `masterDataProvider` state

3. **`getCitiesRest` fallback missing `boxNumber`**
   - `getCitiesRest` requires `boxNumber` per server contract (doc section 50)
   - `loadCitiesForMandal` fallback called `getCitiesRest` WITHOUT `boxNumber`
   - Server returned `{status_code: 1, status_msg: Box Number is required.}`
   - City list became empty; user couldn't select any city
   - **Fix**: Pass `boxNumber` parameter to `loadCitiesForMandal` and its fallback

4. **City canonicalization silently failed**
   - `getCitiesRest` returns error map (not exception) — `_fetch` doesn't throw
   - `_parseModelList` found no list → canonicalization skipped → bad city stayed
   - **Fix**: Wrapped in try/catch, falls back to `_billingCity` UI selection

5. **City list emptied after mandal selection**
   - If both `getLocationsOfDistrictRest` AND `getCitiesRest` failed, city list → empty
   - **Fix**: Preserve `previousCities` as fallback in `loadCitiesForMandal`

6. **`getLocationsOfDistrictRest` server bug**
   - Returns `{status_code: 0, status_msg: Undefined variable: statusCode}` with NO data
   - This is a persistent server-side bug on this deployment

### Issue 2: Oppo/OnePlus touch event consuming dropdown taps

**Error log:**
```
D/OplusViewDragTouchViewHelper: dispatchTouchView action = 1
D/ViewRootImplExtImpl: the up motion event handled by client, just return
```

- `DropdownButtonFormField` popup overlay is consumed by OS gesture system
- **Fix**: Replaced ALL dropdowns with `_WizardDialogSelector` (new_customer_screen) and
  `_buildDialogSelector` (edit_customer_screen) — full `AlertDialog` instead of popup
- **Applies to**: Billing address (Country, State, District, Mandal, City) AND
  Installation address (Country, State, District, Mandal, City)

### Issue 3: Mandal/City field order

- Expected: Country > State > District > **Mandal** > **City**
- Was: City before Mandal in some sections
- **Fix**: Reordered in both screens

### Issue 4: Installation mandal does NOT filter city list (Session 4 fix)

- **User report**: "if i choose to add installation address manually and choose mandal
  there the city not reflecting according to that"
- **Root cause**: Installation mandal `onChanged` only did `setState(() => _installMandal = m)`
  — it never called any API to filter the city list by mandal
- **Fix**: Added `_loadInstallCitiesForMandal(Mandal)` method that calls
  `getLocationsOfDistrictRest`, filters by `mandal_id`, and updates `_installCities`
- Installation mandal `onSelected` now clears `_installCity` and calls the new method

### Issue 5: City ID table mismatch (Session 5 — KEY FIX)

- **Root cause**: `getLocationsOfDistrictRest` and `getCitiesRest` may use
  **DIFFERENT ID tables** on the server. The UI populates city dropdowns from
  `getLocationsOfDistrictRest` (e.g., ADAMBAKKAM = location_id 212), but
  `saveCustomerRest` validates against `getCitiesRest` IDs (where ADAMBAKKAM
  might have a different ID). Sending 212 fails because the save validation
  table doesn't contain that ID.
- **Fix**: ALWAYS resolve city via `getCitiesRest` before saving:
  1. Fetch cities from `getCitiesRest(stateId, districtId, boxNumber)`
  2. Match by ID first (fast path if tables agree)
  3. Match by exact NAME (case-insensitive) — bridges different ID tables
  4. Match by partial name (handles typos like PLLAVARAMM vs PALLAVARAM)
  5. Last resort: use first city from `getCitiesRest` (server WILL accept it)
  6. Full city list from `getCitiesRest` is logged for diagnostics
- Applied to BOTH `edit_customer_screen.dart` AND `new_customer_screen.dart`

### Issue 6: "Same as billing" sends invalid city (Session 4+5 fix)

- Linked to Issue 5 — city ID from UI came from wrong table
- With the `getCitiesRest` resolution, the name-matched ID is always valid

### Issue 7: Mandal ID mismatch — TRUE ROOT CAUSE of "Invalid City" (Session 6 — CRITICAL FIX)

- **Root cause**: `loadMandals` in `master_data_provider.dart` has 3 fallback levels:
  1. `getMandalsRest` — returns real mandal_ids from the mandals table
  2. `getLocationsOfDistrictRest` — derives mandals from location data
  3. `getCitiesRest` — creates fake mandals using **city location_id as mandal_id**
  When fallback 2 or 3 triggers, the `Mandal.mandalId` is actually a city location_id
  (e.g., Hyderabad location_id=293 becomes mandalId=293). The payload then sends
  `mandal=293` and `city=293` — same value! The server's `new_customer_validation`
  workflow checks mandal against the real mandals table, finds 293 doesn't exist there,
  and reports **"Please select City/Invalid City."** (misleading error about city when
  the actual problem is the mandal).
- **Evidence**: Payload showed `mandal=293, city=293` — identical values is impossible
  for correctly sourced data since mandal_ids and location_ids are from different tables.
- **Fix**: Before saving, call `getMandalsRest` directly to get real mandals:
  1. Match by ID (fast path if mandal came from real getMandalsRest data)
  2. Match by exact name (bridges fake-to-real mapping)
  3. Match by partial name
  4. Use first real mandal if no name match
  5. If `getMandalsRest` returns empty → send `mandal=0`
- Applied to BOTH `edit_customer_screen.dart` AND `new_customer_screen.dart`

### Issue 8: Installation mandal dialog does not open (Session 6 fix)

- **Root cause**: `_loadInstallCitiesAndMandals` only called `getMandalsRest` with NO
  fallback. When `getMandalsRest` returns empty (many deployments), `_installMandals`
  stays empty. `_buildDialogSelector` shows "No data available" for empty lists.
- **Fix**: Added fallback to `getLocationsOfDistrictRest` — derives mandals from
  location data, deduplicating by mandal_id. Mirrors the fallback in
  `master_data_provider.loadMandals`.

### Issue 9: installationAddress always required (Session 6 fix)

- **Root cause**: `installationAddress` was only included in the payload when
  `_changeInstallAddress` was true. Server requires this field unconditionally.
- **Fix**: Always provide `installationAddress` and `installation_address` in payload.
  Falls back to billing address text when no explicit installation address is entered.

### Issue 10: UI restructured to match old app (Session 7 — MAJOR SIMPLIFICATION)

- **User request**: "make it simple like old one" — provided screenshots of old app
- **Old app layout**: Single flat form with:
  Address 1* → Address 2 → "Same as above" checkbox → Installation Add 1* →
  Installation Add 2 → Country* → State* → District* → Mandal (optional) → City* → PIN
- **Key difference**: ONE shared set of Country/State/District/Mandal/City — no separate
  billing vs installation geo selectors
- **Changes**:
  1. Removed "Billing Address" / "Installation Address" section headers and toggles
  2. Removed duplicate installation geo selectors (Country/State/District/Mandal/City)
  3. Single shared geo set from masterDataProvider applies to both addresses
  4. "Same as above" checkbox copies Address 1/2 → Installation Add 1/2 (text only)
  5. Installation Add 1/2 shown as readOnly when "Same as above" is checked
  6. Mandal is optional — if not selected, City shows ALL cities for the district
  7. Removed all `_install*` geo state variables and cascading loaders
  8. Submit always sends geo fields (no `_changeAddress` guard)
  9. `installationAddress` = Install Add 1 text (or Address 1 if "same as above")
- This eliminates the entire class of installation geo selector bugs

### Issue 11: Removed city/mandal resolution — send raw UI values (Session 7 fix)

- **Root cause**: The getCitiesRest/getMandalsRest resolution logic added in Session 6 was
  over-engineering the payload. The city data loaded by `masterDataProvider.loadCities`
  already comes from `getCitiesRest`, so the IDs are already valid. Re-resolving could
  actually CHANGE the city to a different one (e.g., partial name match picking wrong city).
- **Fix**: Removed ALL getCitiesRest/getMandalsRest resolution code from BOTH
  `edit_customer_screen.dart` and `new_customer_screen.dart`.
  Send raw UI values directly — exactly like the old app does.
- **Mandal**: When not selected, send mandal='' (empty string) instead of '0'.
  The server's `saveCustomerRest` reads `$mandal=isset($this->payload->mandal)?trim(...):'';`
  Empty string is the default, matching what happens when mandal is not provided at all.
  '0' may be treated as an invalid mandal_id by the `new_customer_validation` workflow.
- **Logging**: Uses `print()` (not `debugPrint()`) for critical payload dump — cannot be
  filtered or throttled. Look for `========== SAVE_CUSTOMER PAYLOAD ==========`.

### Issue 12: Wrong cities loading + Invalid City error (Session 7 — FINAL FIX)

- **Two bugs**, one causing the other:

**Bug A — Wrong city API used when no mandal selected** (reverted by Session 7 final fix)
  - A previous attempt changed `selectDistrict` to call `loadCitiesForMandal(mandalId='0')`.
  - `getLocationsOfDistrictRest` returns ALL locations in the DB for the district, NOT filtered
    by LCO/dealer. User selected a valid-looking city (e.g. "KARUR") that the server's
    `new_customer_validation` workflow rejected as invalid for that LCO.
  - **Correct API mapping**:
    - No mandal → `getCitiesRest` (LCO-mapped cities) → `loadCities(stateId, districtId)`
    - Mandal selected → `getLocationsOfDistrictRest` filtered by mandal → `loadCitiesForMandal`
  - **Fix** `master_data_provider.dart`: `selectDistrict` calls `loadCities(stateId, districtId)`.
  - **Fix** `edit_customer_screen.dart`: `_ensureBillingCitiesLoaded` calls `loadCities` when
    mandal is null, `loadCitiesForMandal` only when mandal is set.

**Bug B — Missing payload keys cause "Mandatory fields missing"**
  - `city`, `state`, `district`, `mandal`, `pin` were wrapped in `if (value != null)` guards.
    When null, the key was OMITTED from the JSON. Backend `validateInputDataType_updated`
    requires ALL keys to exist even as empty strings.
  - **Fix** both `edit_customer_screen.dart` and `new_customer_screen.dart`:
    all geo/address keys now unconditionally set using `?? ''` for null values.

### Diagnostic logging added

After hot restart, check these log prefixes:
- `========== SAVE_CUSTOMER PAYLOAD ==========` — **NEW** critical payload dump (uses print())
- `========== NEW_CUSTOMER PAYLOAD ==========` — same for new_customer_screen
- `▼▼▼ SAVE_CUSTOMER FULL PAYLOAD ▼▼▼` — full payload in customer_remote_datasource
- `[MASTER_DATA] getCitiesRest key=... count=...` — raw city response on load

### Server API contract notes

From `12_server_api_contracts.md`:
- `saveCustomerRest` input: "Similar to editCustomerRest" + boxNumber, packageId, etc.
- `editCustomerRest` input includes: `country, state, district, city, mandal, pin, address, installationAddress`
- `getCitiesRest` requires: `stateId` (int), `boxNumber` (string) — BOTH required
- Response: `{citiesList: [{location_id, location_name, state_id}]}`
- `getLocationsOfDistrictRest` returns: `{districtLocationsList: [{location_id, location_name, district_id, mandal_id}]}`
- `getMandalsRest` returns: `{mandalList: [{mandal_id, mandal_name, district_id}]}`
- **CRITICAL**: `location_id` (from cities/locations) ≠ `mandal_id` (from mandals table)
- **CRITICAL**: `loadMandals` fallback may conflate these two ID spaces

### Files modified

- `lib/application/providers/master_data_provider.dart` — loadCitiesForMandal fixes, city logging, debugPrint import
- `lib/presentation/screens/customers/edit_customer_screen.dart`:
  - `_changeAddress = true` for new customers
  - Sync billing defaults from masterDataProvider
  - ALL dropdowns → dialog selectors (billing + installation)
  - Installation mandal → city filtering via `_loadInstallCitiesForMandal`
  - City resolution: ALWAYS resolve via getCitiesRest by name-matching
  - **Mandal resolution: ALWAYS resolve via getMandalsRest before save (Session 6)**
  - **Installation mandal fallback to getLocationsOfDistrictRest (Session 6)**
  - **installationAddress always included in payload (Session 6)**
  - Send all field name variants (city+cityId, state+stateId, etc.)
- `lib/presentation/screens/customers/new_customer_screen.dart`:
  - _WizardDialogSelector, boxNumber pass
  - City resolution: same getCitiesRest name-matching strategy
  - **Mandal resolution: same getMandalsRest resolution strategy (Session 6)**
- `lib/presentation/screens/customers/new_customer_confirm_screen.dart` — Mandal before City, billType, instPinCode
- `lib/data/datasources/remote/customer_remote_datasource.dart` — full payload dump logging

### Next steps after Session 6 fixes

1. **Hot restart the app** (not just hot reload) to pick up all changes
2. Create new customer — fill all mandatory fields
3. Check logs for `[EDIT→SAVE] getMandalsRest returned N mandals`:
   - If N > 0 → mandal was properly resolved, should work
   - If N = 0 → mandal sent as 0, check if server accepts it
4. Check `[EDIT→SAVE] RESOLVED mandal=X` — confirm X ≠ city ID
5. Check `▼▼▼ SAVE_CUSTOMER FULL PAYLOAD ▼▼▼` — verify mandal ≠ city
6. If error changes from "Invalid City" to something else, report new error
7. If server requires mandal > 0 but getMandalsRest is empty, escalate to backend
