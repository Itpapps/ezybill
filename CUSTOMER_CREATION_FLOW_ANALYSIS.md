# EzyBill Flutter — Customer Creation Flow: Analysis, Fixes & Status

> 
> **Conversation ID:** `0a2d2edb-a8d4-41f5-9d8a-58932181aab8`
> **Last Updated:** 2026-05-04 (Session 4)
> **Status:** ✅ All fixes implemented + UI enhancements — ready for testing

---

## 1. Problem Statement (User Report)

> *"I go to Fresh STB (where VC number is paired), fill all mandatory fields in Edit Customer, click Update → 'Dealer or Employee does not exist (statusCode:1)'. Should show a Review page → click Confirm → create customer in DB."*

### Expected Flow
```
Home → Fresh Tab → Tap STB card
  → NewCustomerScreen (auto-skips STB step, shows form)
  → Fill mandatory fields
  → Select package
  → NewCustomerConfirmScreen (Review: Cancel / Create Customer)
  → Confirm → saveCustomerRest → Customer created in DB ✅
```

### Actual Flow (Before Fixes)
```
Home → Fresh Tab → Tap STB card → NewCustomerScreen
  → Fill fields → Click Create Customer
  → saveCustomerRest → statusCode:1 ERROR ❌
    Reason: vcNumber + dealer_id missing from payload
```

---

## 2. Root Cause Analysis — All Three Causes

### Root Cause #1 — MISSING `vcNumber` in `saveCustomerRest` payload  ← PRIMARY BUG

**File:** `lib/presentation/screens/customers/new_customer_screen.dart`
**Method:** `_saveCustomer()` ~line 674

The VC number is captured in `_vcController.text` (pre-filled from route params or typed by
user), but was **never added to the `customerData` map** before sending to the server.

`saveCustomerRest` on the server links the STB box to the new customer via both `boxNumber`
(serial) and `vcNumber`. Without `vcNumber`, the server cannot validate the STB→dealer chain
and returns "Dealer or Employee does not exist" (statusCode:1).

**Fix applied:**
```dart
if (_vcController.text.trim().isNotEmpty)
  'vcNumber': _vcController.text.trim(),
```

---

### Root Cause #2 — MISSING `dealer_id` / `employee_id` in payload

**File:** `lib/presentation/screens/customers/new_customer_screen.dart`
**Method:** `_saveCustomer()` ~line 677

The server's `saveCustomerRest_post()` extracts `dealerId` and `employeeId` from the JWT
token via `WsModel->isValidPassToken()`. However, some server deployments ALSO validate
these from the request body. When both checks exist, not sending them in the body causes
"Dealer or Employee does not exist".

**Fix applied:**
```dart
if ((session?.dealerId ?? 0) > 0)
  'dealer_id': session!.dealerId.toString(),
if ((session?.employeeId ?? 0) > 0)
  'employee_id': session!.employeeId.toString(),
```

---

### Root Cause #3 — MISSING `reseller_id` in BOTH `saveCustomerRest` and `editCustomerRest` ← CONFIRMED BUG

**File:** `lib/presentation/screens/customers/new_customer_screen.dart` (saveCustomer)
**File:** `lib/presentation/screens/customers/edit_customer_screen.dart` (editCustomer)

The `editCustomerRest` API doc (section 3.5) explicitly lists `reseller_id` as a required
payload field. It was **never being sent** from `EditCustomerScreen._submit()`.

Without `reseller_id`, the server cannot verify the dealer→customer ownership chain:
- Server looks up the customer's assigned reseller
- Compares it to the JWT's dealerId
- If the resellerId in the payload is missing/0 → "Dealer or Employee does not exist"

For `saveCustomerRest`, `reseller_id` comes from `validateBoxInfoRest` response (`resellerId`
field), which identifies which reseller owns the STB being registered.

**Fix applied to `edit_customer_screen.dart`:**
```dart
final resellerId =
    widget.customer['reseller_id']?.toString().isNotEmpty == true
        ? widget.customer['reseller_id'].toString()
        : widget.customer['resellerId']?.toString().isNotEmpty == true
            ? widget.customer['resellerId'].toString()
            : session.dealerId.toString(); // fallback
data['reseller_id'] = resellerId;
```

**Fix applied to `new_customer_screen.dart`:**
```dart
// Stored in _stbResellerId during _verifyStb() from validateBoxInfoRest response
'reseller_id': (_stbResellerId.isNotEmpty
    ? _stbResellerId
    : (session?.dealerId ?? 0).toString()),
```

---

Various entry points navigated Fresh STBs to `EditCustomerScreen` (calls `editCustomerRest`)
instead of `NewCustomerScreen` (calls `saveCustomerRest`). `editCustomerRest` requires an
existing `customerId` — Fresh STBs have none, causing the same server error.

**Entry points fixed:**

| Entry Point | Before | After |
|---|---|---|
| `quick_action_sheet.dart` `onNewCustomer` | TODO stub — navigated nowhere | Pushes to `/customer/new` with serial+VC |
| `customer_profile_screen.dart` Edit button | Always went to EditCustomerScreen | Fresh status → redirects to NewCustomerScreen |
| `quick_action_provider.dart` STB/VC search | "No customer found" for unregistered fresh boxes | `validateBoxInfoRest` fallback → FRESH card with New Customer button |

---

## 3. Status Code Convention (CRITICAL)

**Two different conventions exist — never confuse them:**

| Field name | Value | Meaning |
|---|---|---|
| `statusCode` (camelCase) | `0` | ✅ SUCCESS for `saveCustomerRest`, `editCustomerRest` |
| `statusCode` (camelCase) | `1` | ❌ ERROR: Dealer/Employee not found |
| `status_code` (snake_case) | `1` | ✅ SUCCESS for most other endpoints |
| `status_code` (snake_case) | `0` | ❌ ERROR for most other endpoints |

**`CustomerRemoteDatasource.saveCustomer()` (line 125-138):**
```dart
final status = data['status_code'] ?? data['statusCode'];
if (status == 0 || status == '0') return data;  // 0 = success ✅ CORRECT
throw ApiException(...);                          // non-0 = error ✅ CORRECT
```
This check is **correct as-is — do not change it.**

---

## 4. All Files Modified

### 4.1 `lib/presentation/screens/customers/new_customer_screen.dart`

Changes made:
1. Added `import 'package:flutter/foundation.dart'` for `kDebugMode`
2. Added `'mobileNumber'` alias alongside `'mobile'` (server key compatibility)
3. **Added `'vcNumber'` to `customerData`** ← PRIMARY FIX
4. **Added `'dealer_id'` and `'employee_id'`** from session ← SECONDARY FIX
5. Structured `[NEW_CUSTOMER]` debug logging block before API call

**Full payload now sent to `saveCustomerRest`:**
```
authtoken, customerTypeId, customerTypeTypesId?,
cafNumber?, lcoCustomerId, firstName, lastName?,
mobile, mobileNumber, email?, fatherName?, gender?, dateofbirth?,
idType?, idNumber?, businessName?,
accountNumber?, address, address2?, pin,
installationAddress?, instAddress2?, instPinCode?,
country, state, district?, city, mandal?,
group, billType, remarks?, discount?,
latitude?, longitude?,
boxNumber, vcNumber,            ← ADDED: was missing, causing statusCode:1
reseller_id,                    ← ADDED: from validateBoxInfoRest.resellerId
dealer_id, employee_id,         ← ADDED: belt-and-suspenders auth
[packageId, pricingStructureType, dateType, quantity, validityDays?]  ← only if VC exists
```

### 4.2 `lib/presentation/screens/quick_action/quick_action_sheet.dart`

`onNewCustomer` callback was a TODO stub (navigated nowhere). Fixed:
```dart
onNewCustomer: () {
  final s = ref.read(quickActionProvider);
  Navigator.of(context).pop();
  context.push(RouteNames.newCustomer, extra: {
    'serialNumber': s.serialNumber ?? '',
    'vcNumber': s.vcNumber ?? '',
  });
},
```

### 4.3 `lib/presentation/screens/customers/customer_profile_screen.dart`

Edit button now guards Fresh customers:
```dart
// Label changes to 'Add Customer' for fresh STBs
label: _statusString == 'Fresh' ? 'Add Customer' : 'Edit',

// Inside onTap:
if (_statusString == 'Fresh') {
  context.push(RouteNames.newCustomer, extra: {
    'serialNumber': serial,
    'vcNumber': vc,
  });
  return;
}
// else → existing EditCustomerScreen flow
```

⚠️ `_statusString` defaults to `'Active'` for unrecognized status values. If the server
returns an integer (e.g. `status: 4`) for fresh customers, this guard may not fire. See
Section 7.1.

### 4.4 `lib/application/providers/quick_action_provider.dart`

Two changes:
1. `hasResult` now `true` when `stbStatus == 'FRESH'` (even without `customerId`):
```dart
bool get hasResult =>
    (customerId != null && customerId!.isNotEmpty) ||
    stbStatus == 'FRESH';
```

2. `validateBoxInfoRest` fallback when STB/VC search returns no customer:
```dart
if (state.searchField == QuickSearchField.stbNo ||
    state.searchField == QuickSearchField.vcNo) {
  try {
    final boxResult = await _stbDs.validateBoxInfo(
      authtoken: _token,
      boxNumber: trimmed,
    );
    final boxCode = (boxResult['statusCode'] ?? boxResult['status_code'])?.toString();
    if (boxCode == '0') {
      // Box is valid and unassigned — show as FRESH
      state = QuickActionState(
        searchField: state.searchField,
        serialNumber: trimmed,
        vcNumber: trimmed,
        stbStatus: 'FRESH',
      );
      return;
    }
  } catch (_) { /* fall through to generic error */ }
}
```

### 4.5 `lib/presentation/screens/customers/edit_customer_screen.dart`

Changes made:
1. **Added `reseller_id`** from `widget.customer` map (falls back to `session.dealerId`) ← PRIMARY FIX for editCustomerRest
2. Added `dealer_id` and `employee_id` from session
3. Added `[EDIT_CUSTOMER]` debug logging line before API call

**Key payload fields now sent to `editCustomerRest`:**
```
customerId (always), firstName, mobile, group, customerTypeId,
reseller_id,   ← ADDED: required by API doc 3.5 — was never being sent
dealer_id, employee_id  ← ADDED: belt-and-suspenders auth
```

--- (Already Correct)

| File | Reason |
|---|---|
| `new_customer_confirm_screen.dart` | Review page fully built with Cancel + Create Customer |
| `new_customer_package_screen.dart` | Package selection correct |
| `customer_remote_datasource.dart` | `saveCustomer` status check is correct (0=success) |
| `app_session.dart` | `dealerId`, `employeeId`, `token` correctly populated after login |
| `app_router.dart` | Route `/customer/new` correctly accepts `serialNumber`/`vcNumber`/`stbCode` |
| `stb_remote_datasource.dart` | `validateBoxInfo(authtoken, boxNumber)` works correctly |

---

## 6. Architecture — Navigation Map

### 6.1 All entry points into customer creation

| Screen | Trigger | Navigation | Status |
|---|---|---|---|
| `home_screen.dart` L901 | Tap Fresh tab card | `RouteNames.newCustomer` | ✅ Correct |
| `home_screen.dart` L926 | Tap "Activate" action on Fresh card | `RouteNames.newCustomer` | ✅ Correct |
| `quick_action_sheet.dart` L176 | "New Customer" button in Quick Action | `RouteNames.newCustomer` + serial/VC | ✅ Fixed |
| `customer_profile_screen.dart` L601 | Edit button on Fresh profile | Redirects to `newCustomer` | ✅ Fixed |
| `quick_action_provider.dart` L249 | STB/VC search → no customer | validateBoxInfoRest → FRESH card | ✅ Fixed |

### 6.2 `NewCustomerScreen` 4-Step Wizard

```
Step 0 — STB Entry
  prefilledSerial set → auto-skip (_applyRouteParams sets _stbVerified=true)
  Otherwise → user types serial → _verifyStb() → validateBoxInfoRest

Step 1 — Customer Form
  20-rule validation chain (_validate())
  Key rules: CustomerType, FirstName, Mobile≥10, PIN≥6, Address, Country, State, City, Group

Step 2 — Package Selection (NewCustomerPackageScreen)
  Only applicable when VC exists (_hasVc == true)
  If no VC → package step shows "No STB linked" info

Step 3 — Review & Confirm (NewCustomerConfirmScreen)
  Shows: STB serial, VC, customer type, personal info, contact, address, package
  Buttons: "Cancel" (back) / "Create Customer" (calls onConfirm callback)
  onConfirm → NewCustomerScreen._saveCustomer() → CustomerRemoteDatasource.saveCustomer()
  → POST /LcoRestServices/saveCustomerRest
  → statusCode:0 → success dialog → Navigator.pop()
  → statusCode:1+ → error snackbar (no crash)
```

### 6.3 `Route` definition (`app_router.dart` line ~467)

```dart
GoRoute(
  path: RouteNames.newCustomer,     // '/customer/new'
  name: RouteNames.newCustomerName, // 'new-customer'
  parentNavigatorKey: _rootNavigatorKey,  // Full-screen (no bottom nav)
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>?;
    return NewCustomerScreen(
      prefilledSerial:  extra?['serialNumber']?.toString(),
      prefilledVc:      extra?['vcNumber']?.toString(),
      prefilledStbCode: extra?['stbCode']?.toString(),
    );
  },
)
```

---

## 7. Known Limitations & Remaining Risks

### 7.1 `_statusString` guard may not catch all fresh customer status codes

`customer_profile_screen._statusString` defaults to `'Active'` for any unrecognized status.
If the server returns `status: 4` or another integer for fresh customers, the guard won't
redirect and the user will reach `EditCustomerScreen` → `editCustomerRest` → same error.

**To fix:** Find out what numeric status the server returns for fresh/unassigned customers,
then add that to the `_statusString` getter conditions.

### 7.2 Fresh customers with a partial DB record may be duplicated

Some fresh STBs in the dashboard list may have a `customerId` (partial record created by
another flow). Navigating these to `NewCustomerScreen` → `saveCustomerRest` would create a
DUPLICATE customer. The correct call for partial records would be `editCustomerRest`.

**Current behaviour:** `home_screen.dart` uses `tab == CustomerFilterTab.fresh` to navigate
ALL Fresh tab items to `NewCustomerScreen`, regardless of whether they have a `customerId`.
This is correct only if all Fresh tab items are truly unassigned.

### 7.3 Session token field-name risk

`AppSession.fromLoginResponse` reads `json['authToken']` (camelCase). If the login response
returns `token` (lowercase), `session.token` would be empty and all authenticated requests
would fail. Verify the actual login response field names match.

---

## 8. API Reference

### `saveCustomerRest`
```
POST /LcoRestServices/saveCustomerRest
Auth: authtoken in POST body + Authorization: Bearer <jwt> header
Success: { statusCode: 0, status_msg: "success", customer_id: "123" }
Error 1: { statusCode: 1, statusMessage: "Dealer or Employee does not exist" }
Error 2: { statusCode: 2, statusMessage: "STB already assigned" }
```

### `editCustomerRest`
```
POST /LcoRestServices/editCustomerRest
Requires: customerId of an EXISTING customer in the DB
⛔ NEVER call for a fresh/unassigned STB — will always fail
```

### `validateBoxInfoRest`
```
POST /LcoRestServices/validateBoxInfoRest
Payload: { authtoken, boxNumber }
Success: { status_code: 0, resellerId: "..." }
Error:   { status_code: 1 }
Used in: NewCustomerScreen._verifyStb() + quick_action_provider fallback
```

---

## 9. Debug Checklist (If Error Still Occurs)

Run in **debug mode** and search logcat for:
```
[NEW_CUSTOMER] DealerId  : <must be non-zero for any logged-in user>
[NEW_CUSTOMER] EmployeeId: <non-zero for EMPLOYEE users, 0 for DEALER users>
[NEW_CUSTOMER] UserType  : DEALER | ADMIN | EMPLOYEE
[NEW_CUSTOMER] boxNumber : <STB serial — must not be empty>
[NEW_CUSTOMER] Keys      : [...vcNumber..., ...dealer_id...]  ← confirm presence
[SAVE_CUSTOMER] Failed response: {...}   ← inspect full server response
[DECRYPT] Decrypted data: {...}          ← inspect decrypted server response
[ENC-v2] Encrypting N fields            ← confirm payload is being encrypted
```

**If `DealerId = 0`** → `session.dealerId` not being populated → check `AppSession.fromLoginResponse`
**If `boxNumber = ''`** → route params not being applied → check `_applyRouteParams()`
**If `vcNumber` missing from Keys** → `_vcController.text` is empty → ensure VC is pre-filled

---

## 10. Test Verification Steps

### Happy Path (Fresh STB with VC Pair → New Customer)
1. Login → Home → tap **Fresh** pill tab
2. Tap any STB card (shows `VC: xxx` and `Tap to assign`)
3. ✅ Verify: opens `NewCustomerScreen`, serial pre-filled, Step 0 auto-skipped
4. Fill: Customer Type, First Name, Mobile (≥10 digits), PIN (6 digits), Address, Country, State, City, Group
5. Tap **Next** → verify Step 2 Package screen opens
6. Select any package → tap **Next**
7. ✅ Verify: Step 3 (Review) shows ALL entered data: STB, VC, name, mobile, address, package
8. Tap **Create Customer** → verify loading indicator
9. ✅ Verify: success dialog appears with customer ID
10. Tap OK → verify navigate back → Fresh count decreases by 1

### Error Paths
- Empty mandatory field → tap Next → ✅ snackbar shows specific field error, no crash
- No internet → tap Create Customer → ✅ network error snackbar, no crash
- Expired session → tap Create Customer → ✅ "Session missing. Please login again." dialog

---

---

## 11. Session 3–4 Updates: reseller_id Fix & UI Enhancements

### 11.1 reseller_id Fix (CRITICAL)

**Root Cause:** Backend `checkCity` validation query joins `eb_location_lco_mapping` on
`lcm.employee_id = $reseller_id`. Previously, `reseller_id` was set to `dealer_id` (1) for
new customers, but the validation requires `employee_id` (98).

**Validation query:**
```sql
SELECT count(*) FROM eb_location_locations l
JOIN eb_location_lco_mapping lcm ON lcm.location_id = l.location_id
WHERE l.location_id = $city AND l.state_id = $state
AND l.dealer_id = $dealer_id AND lcm.employee_id = $reseller_id
```

**Fix in `edit_customer_screen.dart`:**
```dart
// For NEW customers: reseller_id = session.employeeId (e.g. 98)
// For EXISTING customers: keep original reseller_id from customer data
final resellerId = isNewCustomer
    ? session.employeeId.toString()
    : (widget.customer['reseller_id']?.toString() ??
       widget.customer['resellerId']?.toString() ??
       session.employeeId.toString());
data['reseller_id'] = resellerId;
```

**Key insight:** `getCitiesRest` returns correct `location_id` values (e.g. 293 for Hyderabad).
Previous assumption that it returned `location_lco_mapping_id` was WRONG.

### 11.2 Customer Profile Screen Redesign

**File:** `lib/presentation/screens/customers/customer_profile_screen.dart`

Replaced old grid layout with dynamic profile rows matching the old app design:
- Customer Name, Account No, Mobile Number (with call icon), CAF/CRF No
- Status, Pincode, Billing Address, Due Amount (with Pay button if > 0)

Replaced old `CircleActionBar` + `_ActionTile` list with a single card:
- **QUICK ACTIONS** header + **LOCATION** pin icon (opens Google Maps)
- 3-column grid: Update Location, Customer Payment, STB Operations,
  Package Operations, Complaint Operations, Edit Customer,
  Complaint History, Invoice History, Payment History

### 11.3 Edit Customer Screen Enhancements

**File:** `lib/presentation/screens/customers/edit_customer_screen.dart`

New fields added:
- **Phone** (landline) — text field
- **Date of Birth** — read-only (from server data)
- **Anniversary Date** — read-only (from server data)
- **Signup Date** — read-only (from server data)
- **Change Installation Address** checkbox (replaces "Same as above")
- **Upload Photo, ID Proof and Signature** — working image picker using `image_picker` package
  - Customer Photo (camera capture)
  - ID Proof (camera capture)
  - Signature (camera capture)
  - Images encoded as base64 and included in payload

**PIN Code** made mandatory with validation:
```dart
validator: (v) {
  if (v == null || v.trim().isEmpty) return 'PIN code is required';
  return validatePinCode(v);
},
```

### 11.4 Dependencies Added

- `image_picker: ^1.1.2` — for camera-based document uploads

---

*End of Document — Last updated: 2026-05-04 *
