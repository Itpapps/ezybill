# STB Box Operations - Flutter Changes Required

> **Generated:** 2026-03-26
> **Spec:** `screen_docs/05_stb_box_operations.md`
> **Compared files:** `stb_remote_datasource.dart`, `stb_provider.dart`, `stb_operations_screen.dart`, `api_constants.dart`

---

## 1. API Endpoint Coverage

| # | Endpoint | API Constant | Datasource Method | Status |
|---|----------|-------------|-------------------|--------|
| 1 | `getCustomerBoxDetailsRest` | Defined | `getCustomerBoxDetails()` | IMPLEMENTED |
| 2 | `getCustomerParticularBoxDetailsRest` | Defined | `getParticularBoxDetails()` | IMPLEMENTED |
| 3 | `deactivateBoxRest` | Defined | `deactivateBox()` | PARTIAL (see gaps below) |
| 4 | `reactivateBoxRest` | Defined | `reactivateBox()` | PARTIAL (see gaps below) |
| 5 | `getDeactiveReasonsRest` | Defined | `getDeactivationReasons()` | PARTIAL (see gaps below) |
| 6 | `temporaryActivationRest` | Defined | `temporaryActivation()` | NOT WIRED TO UI |
| 7 | `validateBoxInfoRest` | Defined | `validateBoxInfo()` | NOT WIRED TO UI |
| 8 | `stbPairRest` | Defined | `stbPair()` | NOT WIRED TO UI |
| 9 | `stbUnpairRest` | Defined | `stbUnpair()` | PARTIAL (see gaps below) |
| 10 | `stb_replacement` | Defined | `stbReplacement()` | NOT WIRED TO UI |

**Summary:** All 10 endpoints are defined in `api_constants.dart` and have datasource methods. However, only 4 operations (get boxes, deactivate, reactivate, unpair) are wired through to the UI screen. Six operations have backend plumbing but no UI or provider integration.

---

## 2. STB List Display Gaps

**Priority: MEDIUM**

### 2.1 Missing columns / fields in the card display

The spec (Section 4.2 - `AssignedSTBAdapter`) defines an expandable row with these fields:

| Spec Field | Flutter `_StbCard` | Status |
|-----------|-------------------|--------|
| Serial Number | `box['stb_no']` | Shown |
| VC Number | `box['vc_no']` | Shown |
| Active Status | `box['status']` | Shown |
| CAS Type | `box['cas_type']` | Shown |
| Activated Date | -- | **MISSING** |
| Assigned Date | -- | **MISSING** |
| Is Assigned | -- | **MISSING** |
| Installation Address | -- | **MISSING** |
| Packages (associated) | -- | **MISSING** |

### 2.2 No expandable row mechanism

The spec (Section 18.3, point 11) requires expandable rows (Android uses a toggle arrow to show/hide additional fields). Flutter uses a flat card with no expand/collapse. Should use `ExpansionTile` or equivalent.

### 2.3 `show_serial_vc` config flag not checked

The spec (Section 2) states `show_serial_vc` controls display of serial/VC columns. Flutter ignores this flag entirely - serial and VC are always shown.

---

## 3. Deactivation Flow Gaps

### 3.1 Missing `from_mobileapp=1` parameter - HIGH

The spec (Section 6.4, Section 18.2 point 9) requires `from_mobileapp: 1` to be hardcoded in the deactivation request. The Flutter datasource `deactivateBox()` sends only `customer_id`, `stb_no`, `reason_id`, and `remarks`. The following required fields are absent:

- `from_mobileapp` (hardcoded `1`) - **HIGH**
- `serialNumber` (spec uses this field name, Flutter uses `stb_no`) - verify field name mapping
- `vcNumber` - **MEDIUM**
- `boxNumber` - **MEDIUM**
- `macAddress` - **MEDIUM**
- `stockId` - **MEDIUM**
- `deviceId` - **MEDIUM**
- `backEndSetupId` - **MEDIUM**
- `dealer_id` - **MEDIUM**
- `reseller_id` - **MEDIUM**

### 3.2 Reason ID 17 not excluded - HIGH

The spec (Section 6.3, Section 18.2 point 4) states: "The app excludes reason with `reasonId == 17` from the spinner." The Flutter deactivation dialog renders `reasons` directly from state without filtering. No exclusion of reason ID 17 exists anywhere.

### 3.3 Missing `showforlco` and `stockId` in reasons request - MEDIUM

The spec (Section 6.3) states the REST endpoint accepts `showforlco` and `stockId` parameters. The Flutter `getDeactivationReasons()` sends no parameters at all.

### 3.4 Missing `global_reason` / `disable_for_dpo` filtering - MEDIUM

The spec (Section 6.3) states reasons should be filtered by `global_reason` and `disable_for_dpo` flags based on user type. No such filtering exists in Flutter.

### 3.5 Missing default remarks suffix - MEDIUM

The spec (Section 6.1, step 7) requires: if remarks are empty, use `"Box Deactivation from Android app"`; if non-empty, append `". Box Deactivation from Android app"`. Flutter sends user remarks as-is, with no suffix appended.

### 3.6 Deactivation response status code handling - HIGH

The spec (Section 6.5) states deactivation response uses `status_code=0` for success. The provider `deactivateBox()` does not check `status_code` at all - it simply assumes any non-exception response is success and shows a hardcoded "STB deactivated successfully" message instead of using the server's `status_msg`.

### 3.7 Missing `is_temp_deactivated` state tracking - MEDIUM

The spec (Section 6.5, 18.2 point 3) states that `is_temp_deactivated` from the deactivation response drives whether the activate button shows "Activate STB" or "Temporary Activate STB". `StbState` has no field for this. The screen has no concept of temporary deactivation.

---

## 4. Reactivation Flow Gaps

### 4.1 Missing `reinitialize=1` parameter - HIGH

The spec (Section 7.2, 18.2 point 8) requires `reinitialize: 1` hardcoded in the reactivation request. Flutter `reactivateBox()` sends only `customer_id` and `stb_no`. Missing fields:

- `reinitialize` (hardcoded `1`) - **HIGH**
- `serialNumber` - **MEDIUM**
- `boxNumber` - **MEDIUM**
- `macAddress` - **MEDIUM**
- `stockId` - **MEDIUM**
- `deviceId` - **MEDIUM**
- `backEndSetupId` - **MEDIUM**

### 4.2 Confirmation dialog present (correct) - OK

The spec (Section 7.1) requires a confirmation alert before reactivation. Flutter implements this via `_confirmAction()`. This is correct.

### 4.3 Response status code not checked - HIGH

Same issue as deactivation: the provider returns `true` on any non-exception response without checking `status_code`. The server's `status_msg` is not used.

---

## 5. Temporary Activation Gaps

### 5.1 No UI for temporary activation - HIGH

The spec (Section 9) describes a "Temporary Activate STB" button that appears when `is_temp_deactivated == 1`. Flutter has no UI for this operation at all. The datasource method `temporaryActivation()` exists but:

- No provider method calls it
- No button or trigger in the UI
- No `is_temp_deactivated` state tracking

### 5.2 Should fire immediately (no confirmation) - LOW

The spec (Section 9, 18.2 point 12) explicitly states: "No confirmation dialog for temporary activation - triggers immediately on button tap." When implementing, do NOT add a confirmation dialog.

### 5.3 Wrong parameters in datasource - MEDIUM

The datasource `temporaryActivation()` sends `customer_id`, `stb_no`, `days`. The spec (Section 9.1, note under 14.5) says the REST endpoint requires only `customerId` and `stockId`. The `days` parameter is not in the spec, and `stb_no` should likely be `stockId`.

---

## 6. STB Pair/Unpair Gaps

### 6.1 No Pair/Unpair screen - HIGH

The spec (Section 11) describes a dedicated `StbPairUnpair` fragment with Pair and Unpair tabs, accessed from the main menu. Flutter has:

- A datasource `stbPair()` method and provider `pairStb()` method, but NO pair UI/screen
- An `onUnpair` button on the STB card for unpair, but this is per-customer-STB, not the standalone serial+VC input screen the spec requires
- No tab-based Pair/Unpair layout

### 6.2 No serial + VC input fields for pairing - HIGH

The spec (Section 11.3) requires EditText fields for serial number and VC number input. Flutter has no input fields for pairing - it just calls `stbPair()` from the provider which is never invoked from UI.

### 6.3 No barcode scanner integration - MEDIUM

The spec (Sections 15, 18.2 point 7) requires barcode scanner support via camera (Google Vision in Android, recommended `mobile_scanner` for Flutter). No scanner implementation exists.

### 6.4 No tab visibility control from config flags - HIGH

The spec (Section 11.2) states Pair/Unpair tabs should be shown/hidden based on `stb_pairing` and `stb_unpairing` login flags. No such check exists.

### 6.5 Pair uses wrong field names - MEDIUM

The datasource `stbPair()` sends `customer_id`, `stb_no`, `vc_no`. The spec (Section 12.1) states the pair endpoint requires `serialNumber` and `vcNumber`. Also, the spec's Pair endpoint does NOT require `customer_id` - it is a standalone operation.

### 6.6 Unpair uses wrong field names and extra parameters - MEDIUM

The datasource `stbUnpair()` sends `customer_id` and `stb_no`. The spec (Section 13.1) states the unpair endpoint requires only `serialNumber`. No `customer_id` should be sent.

### 6.7 No navigation to home after pair/unpair success - LOW

The spec (Sections 12.2, 13.2, 18.2 point 10) states that after successful pair/unpair, the app navigates to the home screen (`MainActivity` with `frgToLoad=0`). Flutter does not implement this navigation.

---

## 7. STB Replacement Gaps

### 7.1 No replacement UI or flow - HIGH

The spec (Section 10) describes a full STB replacement flow with old/new STB details, replacement type, amount, receipt number, pair_condition, etc. Flutter has:

- A datasource `stbReplacement()` method but it only sends `customer_id`, `old_stb_no`, `new_stb_no`, `new_vc_no`
- No provider method for replacement
- No UI screen or dialog for replacement

### 7.2 Missing replacement request parameters - HIGH

The spec (Section 10.1) requires these fields that the datasource does not send:

- `serial_number` (old STB) - field name mismatch (`old_stb_no` vs `serial_number`)
- `account_nmber` (sic, customer account number)
- `replacement_type_id`
- `amount`
- `receipt_number`
- `remarks`
- `replace_serial_number` / `replace_vc_number` - field name mismatch
- `is_permanent_surrender`
- `pair_condition`

### 7.3 No call to `getCustomerParticularBoxDetailsRest` before replacement - MEDIUM

The spec (Section 10) states that before replacement, the app must call `getCustomerParticularBoxDetailsRest` to get form validations and reason list. While the datasource method exists and has a provider method `loadBoxDetails()`, there is no replacement flow that chains these calls.

---

## 8. Config Flag Gaps

### 8.1 No access control flag checks for button visibility - HIGH

The spec (Section 2, Section 3.4, 18.2 point 6) requires these flags to control button visibility:

| Flag | Effect | Flutter Status |
|------|--------|---------------|
| `int_stb_activation` | Shows Activate STB button | **NOT CHECKED** |
| `int_stb_deactivation` | Shows Deactivate STB button | **NOT CHECKED** |
| `int_stb_reactivation` | Shows Reactivate STB button | **NOT CHECKED** |
| `stb_pairing` | Shows Pair tab | **NOT CHECKED** |
| `stb_unpairing` | Shows Unpair tab | **NOT CHECKED** |
| `show_serial_vc` | Controls serial/VC column display | **NOT CHECKED** |

Flutter currently shows Deactivate (for active STBs), Reactivate (for inactive STBs), and Unpair buttons unconditionally. There is no reference to any config flags from the login response or access control response.

### 8.2 No "Box Operations" button visibility check - MEDIUM

The spec (Section 2) states the "Box Operations" button should only be visible when at least one of `int_stb_activation`, `int_stb_deactivation`, or `int_stb_reactivation` equals 1. This check is not implemented.

---

## 9. Status Code Handling Gaps

### 9.1 REST `status_code=1` for success not implemented - HIGH

The spec (Section 17, 18.2 point 1) explicitly states: "Flutter must use the REST convention: `status_code = 1` means success." The Flutter provider methods (`deactivateBox`, `reactivateBox`, `pairStb`, `unpairStb`) do not check `status_code` at all. They treat any non-exception HTTP response as success. This means:

- A response with `status_code=0` (failure) will be treated as success
- The server's `status_msg` is never shown to the user
- No differentiation between `status_code=1` (failure/success depending on endpoint), `status_code>=2` (contact support), or null (server error)

### 9.2 No "Contact Support" messaging - MEDIUM

The spec defines `status_code >= 2` as "Contact Support" for pair/unpair operations and general errors for others. Flutter has no such handling.

---

## 10. Missing Operations Summary

| Operation | Datasource | Provider | UI Screen | Overall |
|-----------|-----------|---------|-----------|---------|
| Get Customer Box List | Yes | Yes | Yes | PARTIAL - missing fields |
| Get Particular Box Details | Yes | Yes | No | NOT WIRED |
| Deactivate STB | Partial | Partial | Yes (dialog) | PARTIAL - many param/logic gaps |
| Reactivate STB | Partial | Partial | Yes (button) | PARTIAL - missing params |
| Get Deactivation Reasons | Partial | Yes | Yes (dropdown) | PARTIAL - no filtering |
| Temporary Activation | Yes (wrong params) | No | No | NOT IMPLEMENTED |
| Validate Box Info | Yes | No | No | NOT IMPLEMENTED |
| STB Pair | Yes (wrong params) | Yes | No | NOT IMPLEMENTED (no screen) |
| STB Unpair | Yes (wrong params) | Yes | Partial (per-STB only) | PARTIAL - wrong flow |
| STB Replacement | Partial (missing params) | No | No | NOT IMPLEMENTED |
| Barcode Scanner | N/A | N/A | No | NOT IMPLEMENTED |
| STB Check / Enter STB Details | N/A | N/A | No | NOT IMPLEMENTED |

---

## 11. Prioritized Action Items

### HIGH Priority

1. **Add `from_mobileapp: 1` to deactivation request** and all other missing required parameters (Section 3.1)
2. **Add `reinitialize: 1` to reactivation request** and all other missing required parameters (Section 4.1)
3. **Filter out `reasonId == 17`** from deactivation reasons dropdown (Section 3.2)
4. **Implement `status_code` checking** in all provider response handlers - `status_code=1` is success for REST API (Section 9.1)
5. **Build Temporary Activation UI** - button on STB card when `is_temp_deactivated==1`, fires immediately without confirmation (Section 5.1)
6. **Build STB Pair/Unpair screen** - standalone screen with tabs, serial+VC inputs, accessed from menu (Section 6.1)
7. **Build STB Replacement UI** - form with old/new STB fields, replacement type, amount, pair_condition (Section 7.1)
8. **Implement config flag checks** for all button/tab visibility using login and access control flags (Section 8.1)

### MEDIUM Priority

9. **Add missing STB list columns** - activated date, assigned date, is_assigned, installation address (Section 2.1)
10. **Implement expandable rows** in STB list using `ExpansionTile` (Section 2.2)
11. **Append deactivation remarks suffix** `". Box Deactivation from Android app"` (Section 3.5)
12. **Send `showforlco` and `stockId`** in deactivation reasons request (Section 3.3)
13. **Apply `global_reason` / `disable_for_dpo` filtering** on deactivation reasons (Section 3.4)
14. **Track `is_temp_deactivated` in StbState** for UI state management (Section 3.7)
15. **Fix field names** in pair (`serialNumber`/`vcNumber` not `stb_no`/`vc_no`) and unpair (`serialNumber` only) datasource methods (Sections 6.5, 6.6)
16. **Fix replacement datasource** to include all required fields per spec (Section 7.2)
17. **Add barcode scanner** using `mobile_scanner` package (Section 6.3)
18. **Build Validate Box Info (STB Check) screen** for new customer flow (Section 10)
19. **Add "Contact Support" error messaging** for `status_code >= 2` (Section 9.2)

### LOW Priority

20. **Implement `show_serial_vc` flag** to conditionally show serial/VC columns (Section 2.3)
21. **Navigate to home after pair/unpair success** (Section 6.7)
22. **Fix temporary activation parameters** - use `customerId`/`stockId` instead of `customer_id`/`stb_no`/`days` (Section 5.3)
23. **Add "Box Operations" button visibility check** on parent screen (Section 8.2)
