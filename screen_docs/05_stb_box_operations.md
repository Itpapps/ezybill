# Screen 05: STB / Box Operations

> **Source files analysed:**
> - `activities_fragments/Box_Operations_Fragment.java`
> - `activities_fragments/CustomerOperations_Fragment.java` (STB entry point section)
> - `activities_fragments/StbPairUnpair.java`
> - `activities_fragments/STB_Check_Fragment_Old.java`
> - `activities_fragments/ScannerFrag.java`
> - `complexclasses/deactivateBox.java`, `reactivateBox.java`, `deactivateReasonInfo.java`, `reasonList.java`
> - `complexclasses/getCustomerBoxDetails.java`, `getCustomerParticularBoxDetails.java`, `customerBoxList.java`
> - `complexclasses/StbPairInfo.java`, `StbUnpairModel.java`, `activateService.java`
> - `adapter/AssignedSTBAdapter.java`, `UnAssigned_Stb_Adapter.java`, `DeactivateAdapter.java`
> - **REST API reference:** `REST_API_V2_SERVICE_DOCUMENT.md` — Section 6 (STB / Box Operations)

---

## 1. Architecture Overview

STB/Box operations in the Android app follow a multi-step navigation:

```
CustomerOperations_Fragment
  └─ "Box Operations" button
       └─ Customer_STB_Select_Fragment   (select which STB)
            └─ Box_Operations_Fragment   (per-STB operations panel)
                 ├─ Deactivate STB       (showDialog → DeactivateSTB async task)
                 ├─ Reactivate STB       (ReactivateSTB async task)
                 ├─ Activate / Temp Activate STB (FragActive_plan or TempActivatingPackage)
                 └─ STB Replacement      (getCustomerParticularBoxDetailsRest → stb_replacement)

StbPairUnpair (separate fragment, accessed via menu)
  ├─ Pair tab      (StbPairInfo1 async task)
  └─ Unpair tab    (StbUnpair1 async task)

STB_Check_Fragment_Old (standalone STB serial lookup / new-customer flow)
  └─ ScannerFrag   (barcode camera scanner → customer search)
```

---

## 2. Backend Configuration Values (from Login Response)

These flags, returned by `POST /LcoRestServices/validateLogin`, control which STB operations are visible in the app.

| Flag | Type | Effect |
|------|------|--------|
| `stb_pairing` | int (0/1) | Shows the **Pair** tab in `StbPairUnpair` when `== 1` |
| `stb_unpairing` | int (0/1) | Shows the **Unpair** tab in `StbPairUnpair` when `== 1` |
| `show_serial_vc` | int (0/1) | Controls display of serial/VC columns in STB list |
| `int_stb_activation` | int (0/1) | Shows Activate STB button (from `getaccesscontrollRest`) |
| `int_stb_deactivation` | int (0/1) | Shows Deactivate STB button (from `getaccesscontrollRest`) |
| `int_stb_reactivation` | int (0/1) | Shows Reactivate STB button (from `getaccesscontrollRest`) |

Access-control flags (`int_stb_activation`, `int_stb_deactivation`, `int_stb_reactivation`) are fetched after login via `POST /LcoRestServices/getaccesscontrollRest` and stored in `LoginActivity` static fields.

The "Box Operations" button in `CustomerOperations_Fragment` is visible only when at least one of `int_stb_activation`, `int_stb_deactivation`, or `int_stb_reactivation` equals 1:

```java
if (LoginActivity.int_stb_activation==1 || LoginActivity.int_stb_deactivation==1 || LoginActivity.int_stb_reactivation==1) {
    btn_boxOperation.setVisibility(View.VISIBLE);
}
```

---

## 3. Screen: Box Operations Fragment

### 3.1 Screen Identity

| Property | Value |
|----------|-------|
| **Title** | "Box Operations" (set on ActionBar) |
| **Fragment class** | `Box_Operations_Fragment` |
| **Layout** | `box_operations_new` |
| **Purpose** | Display a single STB's details and provide deactivation, reactivation, activation, and temporary activation controls |
| **Entry** | Navigated to from `Customer_STB_Select_Fragment` after the user selects a specific STB |

### 3.2 Arguments Received (Bundle from Previous Fragment)

All data is passed via a `Bundle`; no API call is made on entry to this screen.

| Bundle Key | Type | Description |
|------------|------|-------------|
| `custId` | String (parsed to int) | Customer ID |
| `custName` | String | Customer full name |
| `sNo` | String | STB serial number |
| `vcNo` | String | VC (smart card) number |
| `boxNo` | String | Box number |
| `macAdd` | String | MAC address |
| `stockId` | String (parsed to int) | Stock record ID |
| `devId` | String (parsed to int) | Device ID |
| `stockStatus` | String (parsed to int) | 1 = Active, 2 = Deactivated |
| `backSetupId` | String (parsed to int) | Backend setup ID |
| `reqOrigin` | String | Request origin identifier |
| `is_temp_deactivated` | int | 0 = normal deactivation, 1 = temporary deactivation |
| `resellerid` | int | Reseller ID (default 0) |

### 3.3 UI Elements

| Element | Type | ID | Description |
|---------|------|----|-------------|
| STB Serial No | TextView | `paf_tv_stbNo` | Displays `sNo` from bundle |
| VC Number | TextView | `paf_tv_vcno` | Displays `vcNo` from bundle |
| Customer Name | TextView | `paf_tv_custname` | Displays `custName` (wrapped at 18 chars) |
| Customer ID | TextView | `paf_tv_custid` | Displays `custId` |
| Status | TextView | `paf_tv_status` | "ACTIVE", "DE-ACTIVE", or "TEMPORARY DE-ACTIVE" |
| Activate STB | LinearLayout (button) | `paf_btn_activate` | Opens activation flow; label changes to "Temporary Activate STB" when `is_temp_deactivated == 1` |
| Activate label | TextView | `tv_activatestb` | Text label inside activate button |
| Deactivate STB | LinearLayout (button) | `paf_btn_deactive` | Opens deactivation dialog; hidden if `int_stb_deactivation != 1` |
| Deactivate label | TextView | `tv_deactivate` | Text label inside deactivate button |
| Reactivate STB | LinearLayout (button) | `paf_btn_reactivate` | Triggers reactivation; hidden if `int_stb_reactivation != 1` |
| Reactivate label | TextView | `tv_reactivate` | Text label inside reactivate button |
| Icon images | ImageView | `igv_activate`, `igv_deactivate`, `igv_reactivate` | Icons with enabled/disabled states |
| Arrow indicators | ImageView | `next1`, `next2`, `next3` | Arrow indicators with enabled/disabled states |
| App logo | ImageView | `app_logo` | |

### 3.4 Initial Button State Logic

| STB Status (`stat_stb`) | `is_temp_deactivated` | Activate | Deactivate | Reactivate | Status Text |
|-------------------------|----------------------|----------|------------|------------|-------------|
| 1 (Active) | any | **Disabled** (greyed) | Enabled | Enabled | "ACTIVE" |
| 2 (Deactivated) | 0 | Enabled ("Activate STB") | **Disabled** | **Disabled** | "DE-ACTIVE" |
| 2 (Deactivated) | 1 | Enabled ("Temporary Activate STB") | **Disabled** | **Disabled** | "TEMPORARY DE-ACTIVE" |

Button visibility is then further controlled by the access-control flags (hidden entirely if the flag is 0, regardless of STB status).

---

## 4. Operation: Get Customer Box List

This is called by `Customer_STB_Select_Fragment` before entering `Box_Operations_Fragment` to display the list of STBs belonging to a customer.

### 4.1 API Call

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getCustomerBoxDetailsRest` |
| **Purpose** | Fetch all STBs (assigned boxes) for a customer |

#### Request Parameters

| Field | Type | Source |
|-------|------|--------|
| `customerId` | int | Selected customer's ID |

#### Response Fields

| Field | Description |
|-------|-------------|
| `status_code` | 1 = success, 0 = error |
| `status_msg` | Human-readable status |
| `customerBoxList` | Array of box objects |
| `is_expired_service` | Whether any service is expired |

#### `customerBoxList` Object Fields (from `customerBoxList.java`)

| Field | Type | Description |
|-------|------|-------------|
| `customerId` | int | Customer ID |
| `customerName` | String | Customer name |
| `serialNumber` | String | STB serial number |
| `vcNumber` | String | VC/smart card number |
| `boxNumber` | String | Box number |
| `macAddress` | String | MAC address |
| `stockStatus` | int | 1 = Active, 2 = Deactivated |
| `stockId` | int | Stock record ID |
| `deviceId` | int | Device ID |
| `backEndSetupId` | int | Backend setup ID |

### 4.2 STB List Display (AssignedSTBAdapter)

The `AssignedSTBAdapter` (layout `row_assignedstbs`) renders each STB row with an expandable section.

| Column / Field | View ID | Data Source |
|---------------|---------|-------------|
| Customer name + serial (header) | `tv_Customername` | `customer_name + "(" + serial_number + ")"` |
| Serial Number | `tv_serial` | `getSerial_number()` |
| VC Number | `tv_vcnumber` | `getVc_number()` |
| Active Status | `tv_isactive` | `getIs_active()` |
| Activated Date | `tv_activateddate` | `getActivate_date()` |
| Is Assigned | `tv_isassigned` | `getIs_assigned()` |
| Assigned Date | `tv_assigneddate` | `getAssigned_date()` |
| CAS | `tv_cas` | `getCas()` |
| Installation Address | `tv_installationaddress` | `getInstallation_address()` |
| Expand/Collapse toggle | `tv_arrow` | Arrow icon toggling `ll_remaining` |

**Unassigned STB adapter** (`UnAssigned_Stb_Adapter`, layout `row_unasignedstbs`) shows the same fields but replaces the installation address column with a "Create Customer" link (`tv_createcustomer`) that navigates to `STB_Check_Fragment_Old` with the serial and VC pre-filled.

---

## 5. Operation: Get Particular Box Details (for STB Replacement)

### 5.1 API Call

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getCustomerParticularBoxDetailsRest` |
| **Purpose** | Fetch replacement form validations and reason list for a specific STB |

#### Request Parameters (from `getCustomerParticularBoxDetails.java`)

| Field | Type | Source |
|-------|------|--------|
| `customerId` | int | Customer ID |
| `stockId` | int | STB's stock ID |
| `userType` | String | From login session |

#### Response Fields

| Field | Description |
|-------|-------------|
| `status_code` | 1 = success |
| `status_msg` | Status message |
| `stb_replacement_form_validations` | Form field validation rules for replacement |
| `reasonList` | List of replacement reason objects |

---

## 6. Operation: Deactivate STB

### 6.1 Workflow

1. User taps the **Deactivate STB** button.
2. Network connectivity is checked; no-network alert is shown if offline.
3. A modal dialog (`activity_box_deactivation` layout) is displayed via `showDialog()`.
4. The `ReasonValues` async task is triggered to load deactivation reasons (spinner).
5. User selects a reason from the spinner and optionally enters remarks in a text field.
6. User taps **Deactivate** in the dialog.
7. If remarks field is empty, a default remark `"Box Deactivation from Android app"` is used; otherwise the user's text is appended with `". Box Deactivation from Android app"`.
8. `DeactivateSTB` async task executes.
9. The modal dialog is dismissed before the async task result is shown.

### 6.2 Deactivation Dialog UI Elements

| Element | Type | ID | Notes |
|---------|------|----|-------|
| Reason Spinner | Spinner | `boxdeactivation_spin_cycle` | Populated from `getDeactiveReasonsRest` |
| Remarks | EditText | `boxdeactivaion_et_remarks` | Optional; uses Segoe font |
| Deactivate button | Button | `boxdeactivation_btn_deact` | Executes `DeactivateSTB` |
| Close button | Button | `boxdeactivation_btn_close` | Dismisses dialog without action |

### 6.3 Get Deactivation Reasons

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getDeactiveReasonsRest` |
| **Purpose** | Load reason list into the deactivation dialog spinner |

#### Request Parameters (from `deactivateReasonInfo.java` + REST doc)

| Field | Type | Source | Notes |
|-------|------|--------|-------|
| `showforlco` | String | Hardcoded or config | Filter for LCO-visible reasons |
| `stockId` | int | Current STB's stockId | |

> **Note:** The Android SOAP model (`deactivateReasonInfo.java`) only sends `authToken`. The REST v2 endpoint accepts `showforlco` and `stockId`. Flutter must send both.

#### Response Fields

| Field | Description |
|-------|-------------|
| `reasonList` | Array of reason objects |
| `packageList_broadcaster` | Broadcaster package list (supplementary) |

#### `reasonList` Object Fields (from `reasonList.java`)

| Field | Type | Description |
|-------|------|-------------|
| `reasonId` | int | Unique reason ID |
| `reasonName` | String | Display name shown in spinner |
| `global_reason` | int | 1 = globally applicable reason |
| `disable_for_dpo` | int | 1 = hidden for DPO user type |

**Filtering logic:** The app excludes reason with `reasonId == 17` from the spinner. Reasons are shown based on `global_reason` and `disable_for_dpo` flags in more advanced configurations.

### 6.4 Deactivate STB API Call

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/deactivateBoxRest` |
| **Progress text** | "Deactivating STB, Please wait..." |

#### Request Parameters (from `deactivateBox.java`)

| Field | Type | Source | Notes |
|-------|------|--------|-------|
| `serialNumber` | String | `str_stbNo` (bundle) | STB serial number |
| `vcNumber` | String | `str_vcNo` (bundle) | VC/smart card number |
| `boxNumber` | String | `str_boxNumber` (bundle) | Box number |
| `macAddress` | String | `str_macAddress` (bundle) | MAC address |
| `stockId` | int | `int_stockId` (bundle) | Stock record ID |
| `deviceId` | int | `int_deviceId` (bundle) | Device ID |
| `backEndSetupId` | int | `int_backendSetupId` (bundle) | Backend setup ID |
| `reasonId` | int | `reasonId` (selected from spinner) | Deactivation reason ID |
| `remarks` | String | `str_remarks` (user input + suffix) | Remarks with "Box Deactivation from Android app" appended |
| `customer_id` | int | `int_custId` (bundle) | Customer ID |
| `dealer_id` | int | `LoginActivity.dealerId` | Dealer ID from session |
| `reseller_id` | int | `reselleerid` (bundle, default 0) | Reseller ID |
| `from_mobileapp` | int | Hardcoded `1` | Always 1 for mobile app |

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `status_code` | int | 0 = success, 1 = failure, >=2 = error |
| `status_msg` | String | Human-readable result message |
| `is_temp_deactivated` | int | 0 = permanent deactivation, 1 = temporary deactivation |

### 6.5 Deactivation Response Handling

| `status_code` | Dialog Title | Action |
|---------------|-------------|--------|
| `0` (success) | "Deactivated Successfully!" | Updates `tv_status` text; disables Deactivate and Reactivate buttons; enables Activate button; if `is_temp_deactivated == 1`, changes status to "TEMPORARY DE-ACTIVE" and activate button label to "Temporary Activate STB"; pops fragment back stack |
| `1` (failure) | "Deactivation Failed!" | Shows `statusMessage + ". Please contact our support team."` |
| `>= 2` (error) | "Activation Failed!" | Shows `statusMessage + ". Please contact our support team."` |
| `null` (server unreachable) | Toast | "Server is busy or Un reachable - Please Try after sometime" |

---

## 7. Operation: Reactivate STB

### 7.1 Workflow

1. User taps **Reactivate STB** button.
2. Network check performed.
3. Confirmation alert: title "Confirm Reactivation!", message "Are you sure to REACTIVATE this STB?", buttons OK / Cancel.
4. On OK: `ReactivateSTB` async task executes.

### 7.2 Reactivate STB API Call

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/reactivateBoxRest` |
| **Progress text** | "Reactivating STB, Please wait..." |

#### Request Parameters (from `reactivateBox.java`)

| Field | Type | Source | Notes |
|-------|------|--------|-------|
| `serialNumber` | String | `str_stbNo` (bundle) | STB serial number |
| `boxNumber` | String | `str_boxNumber` (bundle) | Box number |
| `macAddress` | String | `str_macAddress` (bundle) | MAC address |
| `stockId` | int | `int_stockId` (bundle) | Stock record ID |
| `deviceId` | int | `int_deviceId` (bundle) | Device ID |
| `backEndSetupId` | int | `int_backendSetupId` (bundle) | Backend setup ID |
| `reinitialize` | int | Hardcoded `1` | Always 1 (triggers CAS reinitialization) |

> **Note:** `vcNumber` is not sent for reactivation (unlike deactivation). `customer_id` and `dealer_id` are also not in the SOAP model but may be required by the REST endpoint — verify against server code.

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `status_code` | int | 0 = success, 1 = failure, >=2 = error |
| `status_msg` | String | Result message |

### 7.3 Reactivation Response Handling

| `status_code` | Dialog Title | Action |
|---------------|-------------|--------|
| `0` (success) | "Reactivated Successfully!" | Shows success dialog; no automatic UI state update (commented out in source) |
| `1` (failure) | "Reactivation Failed!" | Shows `statusMessage + ". Please contact our support team."` |
| `>= 2` (error) | "Reactivation Failed!" | Shows `statusMessage + ". Please contact our support team."` |

> **Flutter note:** After successful reactivation, refresh the STB status display (the Android code had this commented out). The STB status should be set to "ACTIVE" and buttons re-enabled appropriately.

---

## 8. Operation: Activate STB (Standard)

When `tv_activatestb.getText()` is NOT "Temporary Activate STB" (i.e., the STB is in a normal deactivated state):

1. Confirmation alert: "You will be redirected to Package Activation operation. Do you want to continue?"
2. On OK: Navigates to `FragActive_plan` fragment with a bundle containing `custId`, `boxNo`, `custDevId`, `custStockId`, `actt=1`.

This is the full package activation flow (covered separately in screen documentation for Package Activation).

---

## 9. Operation: Temporary Activate STB

When `tv_activatestb.getText().equals("Temporary Activate STB")` (i.e., `is_temp_deactivated == 1`):

The button directly triggers `TempActivatingPackage` async task — no confirmation dialog is shown.

### 9.1 Temporary Activation API Call

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/temporaryActivationRest` |
| **Progress text** | "Activating Package, Please wait..." |

#### Request Parameters (from `activateService.java` — `TempActivatingPackage` usage)

| Field | Type | Source | Notes |
|-------|------|--------|-------|
| `customerId` | int | `int_custId` (bundle) | Customer ID |
| `stockId` | int | `int_stockId` (bundle) | Stock record ID |
| `access_key` | String | Hardcoded `""` | Empty string |

> **Note:** The REST API doc for `temporaryActivationRest` only specifies `customerId` and `stockId`. The Android SOAP model (`activateService`) carries many more fields but most are not relevant for the temp activation call. Flutter should send only `customerId` and `stockId`.

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `status_code` | int | 0 = success, 1 = failure, >=2 = error |
| `status_msg` | String | Result message |
| `employee_id` | int | Employee who performed the action |
| `authToken` | String | Refreshed auth token (if applicable) |
| `is_customer_temp_reason_exist` | int/bool | Whether a temp deactivation reason exists |
| `operation_name` | String | Name of the operation performed |

### 9.2 Temporary Activation Response Handling

| `status_code` | Dialog Title | Action |
|---------------|-------------|--------|
| `0` (success) | "Activation Successful!" | Shows "STB activated successfully"; pops back stack to `box_operation` tag |
| `1` (failure) | "Activation aborted!" | Shows `statusMessage`; pops back stack |
| `>= 2` (error) | "Activation aborted!" | Shows `statusMessage`; pops back stack |
| `null` (server error) | "Server connectivity error!" | "Server is busy or unreachable. Please try again after sometime" |

---

## 10. Operation: STB Replacement

STB replacement is initiated from `Customer_STB_Select_Fragment` by selecting a box and choosing the replacement option, which calls `getCustomerParticularBoxDetailsRest` to get form validations, then submits via `stb_replacement`.

### 10.1 STB Replacement API Call

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/stb_replacement` |
| **Purpose** | Replace an existing STB with a new one |

#### Request Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `serial_number` | String | Yes | Old/current STB serial number |
| `account_nmber` | String | Yes | Customer account number |
| `replacement_type_id` | int | Yes | Replacement type (from reason/type list) |
| `amount` | double | Yes | Replacement charge amount |
| `receipt_number` | String | Yes | Receipt/transaction number |
| `remarks` | String | No | Additional remarks |
| `replace_serial_number` | String | Yes | New STB serial number |
| `replace_vc_number` | String | Yes | New VC/smart card number |
| `is_permanent_surrender` | boolean | Yes | True if the old STB is permanently surrendered |
| `pair_condition` | String | Yes | Condition of the pair (e.g., "new", "used") |

#### Response Fields

| Field | Description |
|-------|-------------|
| `status_code` | 1 = success, 0 = error |
| `status_msg` | Result message |
| `response_details` | Additional detail object |

---

## 11. Screen: STB Pair / Unpair Fragment

### 11.1 Screen Identity

| Property | Value |
|----------|-------|
| **Fragment class** | `StbPairUnpair` |
| **Layout** | `fragment_stb_pair_unpair` |
| **Purpose** | Pair a serial number with a VC (smart card) number, or unpair a serial number |
| **Entry** | Accessed from the main menu (not from customer context) |

### 11.2 Tab Visibility Control

The fragment shows either the Pair tab, the Unpair tab, or both, based on login flags:

| Condition | Result |
|-----------|--------|
| `LoginActivity.stb_pairing == 1` | Pair tab shown, Unpair tab hidden |
| `LoginActivity.stb_unpairing == 1` | Unpair tab shown, Pair tab hidden |
| Both `== 1` | Both tabs available; user can switch by tapping tab labels |
| Both `== 0` | Neither tab is visible; the fragment shows nothing operable |

When both are enabled and user taps a tab label (`tv_pair` or `tv_unpair`), the corresponding layout becomes visible and the active tab label turns blue (`btnblue`).

### 11.3 UI Elements

#### Pair Tab

| Element | Type | ID | Description |
|---------|------|----|-------------|
| Pair / Unpair tab labels | TextView | `tv_pair`, `tv_unpair` | Tab switcher |
| Serial Number field | EditText | `ed_pairserial` | STB serial number input |
| VC Number field | EditText | `ed_pairvc` | VC/smart card number input |
| Pair Type spinner | Spinner | `sp_pair_type` | (Present in layout; not populated in code — reserved) |
| Pair button | Button | `stb_btn_pair` | Submits pairing |

#### Unpair Tab

| Element | Type | ID | Description |
|---------|------|----|-------------|
| Serial Number field | EditText | `ed_unpairvcserial` | STB serial number to unpair |
| Unpair Type spinner | Spinner | `sp_unpair_type` | (Present in layout; not used in current code) |
| Serial/VC mode spinner | Spinner | `sp_unpair_serialvc` | (Present in layout; not used in current code) |
| Serial/VC label | TextView | `tv_serialvc` | Label for unpair field |
| Unpair button | Button | `stb_btn_unpair` | Submits unpairing |

### 11.4 Validation Rules

#### Pair Validation
- `ed_pairserial` must not be empty.
- `ed_pairvc` must not be empty.
- Both fields must have `length >= 1`.
- On validation failure: Toast "Please enter Serial/VC number".
- Network must be available; if not, alert "No internet connection!".

#### Unpair Validation
- `ed_unpairvcserial` must not be empty (`length >= 1`).
- On validation failure: Toast "Please enter Serial number".
- Network must be available.

### 11.5 Pair Confirmation Dialog

When validation passes, an alert is shown before submitting:

- **Title:** "Pairing"
- **Message:** `"Are You sure, You want to Pair Serial number - {serial} with VC Number - {vc} ? "`
- Buttons: **OK** (executes `StbPairInfo1`) / **Cancel**

### 11.6 Unpair Confirmation Dialog

- **Title:** "UnPairing"
- **Message:** `"Are You sure, You want to UnPair Serial number - {serial} ? "`
- Buttons: **OK** (executes `StbUnpair1`) / **Cancel**

---

## 12. Operation: STB Pair

### 12.1 API Call

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/stbPairRest` |
| **Progress text** | "Pairing, Please wait..." |

#### Request Parameters (from `StbPairInfo.java`)

| Field | Type | Source | Notes |
|-------|------|--------|-------|
| `serialNumber` | String | `ed_pairserial` (user input) | STB serial number |
| `vcNumber` | String | `ed_pairvc` (user input) | VC/smart card number |

> **Note:** The SOAP model also includes `authToken`. The REST endpoint authenticates via JWT header; `authToken` may still be included in the JSON payload for compatibility — include it.

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `status_code` | int | 0 = success, 1 = failure, >=2 = contact support |
| `status_msg` | String | Result message |

### 12.2 Pair Response Handling

The response string is parsed for `statusCode` and `statusMessage` fields.

| `statusCode` | Dialog Title | Action |
|--------------|-------------|--------|
| `0` (success) | "Success!!" | Clears both fields; shows `statusMessage`; on OK navigates to `MainActivity` with `frgToLoad=0` (home) |
| `1` (failure) | "Fail!!" | Clears both fields; shows `statusMessage`; stays on screen |
| `>= 2` (error) | "Contact Support!!" | Shows `statusMessage` |
| `null` (server error) | "Server connectivity error!" | "Please contact our support team." |

---

## 13. Operation: STB Unpair

### 13.1 API Call

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/stbUnpairRest` |
| **Progress text** | "Unpairing, Please wait..." |

#### Request Parameters (from `StbUnpairModel.java`)

| Field | Type | Source | Notes |
|-------|------|--------|-------|
| `serialNumber` | String | `ed_unpairvcserial` (user input) | STB serial number to unpair |

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `status_code` | int | 0 = success, 1 = failure, >=2 = contact support |
| `status_msg` | String | Result message |

### 13.2 Unpair Response Handling

| `statusCode` | Dialog Title | Action |
|--------------|-------------|--------|
| `0` (success) | "Success!!" | Clears field; shows `statusMessage`; on OK navigates to `MainActivity` with `frgToLoad=0` |
| `1` (failure) | "Fail!!" | Clears field; shows `statusMessage` |
| `>= 2` (error) | "Contact Support!!" | Clears field; shows `statusMessage` |
| `null` (server error) | "Server connectivity error!" | `statusCode` set to 3, `statusMessage` to "Error"; alert shown |

---

## 14. Screen: STB Check (Enter STB Details)

### 14.1 Screen Identity

| Property | Value |
|----------|-------|
| **Fragment class** | `STB_Check_Fragment_Old` |
| **Title** | "Enter STB Details" |
| **Layout** | `stb_check_fragment_old` |
| **Purpose** | Validate an STB serial/VC number for new customer creation; also used as the entry point when an unassigned STB is selected from the stock list |

### 14.2 UI Elements

| Element | Type | ID | Description |
|---------|------|----|-------------|
| STB Number field | EditText | `stbcheck_et_stbno` | Serial number or VC number input; Gothic font |
| Check button | Button | `stbcheck_btn_check` | Validates the STB via SOAP `checkBoxInfo` |
| Scan button | Button | `stbcheck_btn_scan` | Launches `doScan()` (ZXing barcode scanner via `IntentIntegrator`; currently calls empty stub) |

### 14.3 Pre-fill from Unassigned STB List

When launched from `UnAssigned_Stb_Adapter` with `from=1`:
- If `serial` is non-empty, `et_stbNo` is pre-filled with `serial`.
- Otherwise, `et_stbNo` is pre-filled with `vc`.

### 14.4 Validation

- If `et_stbNo` is empty: Toast "Please enter STB details."
- Network check performed before API call.

### 14.5 API Call (STB Check / Form Validate)

The `STB_Check_Fragment_Old` uses SOAP (`checkBoxInfo` class, property key `vbinfo`). The REST v2 equivalent is:

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/validateBoxInfoRest` |
| **Purpose** | Validate a scanned/entered STB serial number; return reseller info |

#### Request Parameters

| Field | Type | Source |
|-------|------|--------|
| `boxNumber` | String | User-entered STB serial or VC number |

#### Response Fields

| Field | Description |
|-------|-------------|
| `status_code` | 1 = valid, 0 = invalid |
| `status_msg` | Result message |
| `resellerId` | Reseller associated with this STB |

### 14.6 Form Validation (Dynamic Fields)

`STB_Check_Fragment_Old` also fetches dynamic form validations via `FormValidate` async task on load. This calls a SOAP endpoint for `table_name = "customer"` to determine which customer form fields are mandatory. This is handled as a prerequisite for the customer creation form that follows STB validation.

---

## 15. Screen: Barcode Scanner Fragment

### 15.1 Screen Identity

| Property | Value |
|----------|-------|
| **Fragment class** | `ScannerFrag` |
| **Layout** | `fragment_scanner` |
| **Purpose** | Camera-based barcode scanner that reads STB serial numbers and initiates customer search |
| **Entry** | Navigated to with a `origin` argument string |

### 15.2 UI Elements

| Element | Type | ID | Description |
|---------|------|----|-------------|
| Camera preview | SurfaceView | `surfaceView` | Live camera feed |
| Scanned value display | TextView | `txtBarcodeValue` | Shows "Scanned value is: {value}" |
| Action button | Button | `btnAction` | Triggers customer search with scanned value |

### 15.3 Scanner Behavior

- Uses **Google Mobile Vision** `BarcodeDetector` with `Barcode.ALL_FORMATS`.
- Camera: 1920×1080 preview with autofocus.
- On barcode detection: `txtBarcodeValue` is updated on the UI thread.
- Camera is released on `onPause()` and restarted on `onResume()`.
- Camera permission (`CAMERA`) is requested at runtime if not granted.

### 15.4 Action Button Behavior

When the Action button is tapped with a non-empty scanned value (`intentData.length() > 0`):

1. `GetCustomersListCount` async task executes with `boxNumber = intentData`.
2. Calls `POST /LcoRestServices/getCustomerDetailsCountRest` with `boxNumber = scannedValue` (all other search fields empty).
3. On success (`statusCode == 0`): Checks `customerCount`. If >= 10,000, shows warning. Otherwise navigates to `CustomerSearchList_Fragment` with the scanned box number.
4. On failure (`statusCode == 1`): Toast with message.
5. On error (`statusCode >= 2`): Alert dialog.

#### Customer Count Request Parameters

| Field | Type | Value |
|-------|------|-------|
| `customerNumber` | String | `""` (empty) |
| `customerName` | String | `""` (empty) |
| `mobileNumber` | String | `""` (empty) |
| `boxNumber` | String | Scanned barcode value |
| `lcoCustomerId` | String | `""` (empty) |

---

## 16. Validate Box Info (STB New Customer Flow)

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/validateBoxInfoRest` |
| **Purpose** | Validate an STB before creating a new customer assignment |
| **When called** | After entering/scanning STB number in `STB_Check_Fragment_Old` |

#### Request Parameters

| Field | Type | Description |
|-------|------|-------------|
| `boxNumber` | String | STB serial number or VC number entered by user |

#### Response Fields

| Field | Description |
|-------|-------------|
| `status_code` | 1 = valid STB found, 0 = not found/error |
| `status_msg` | Status message |
| `resellerId` | Reseller ID associated with this box |

---

## 17. Status Code Reference (All STB Operations)

The SOAP-based Android code uses a reversed convention compared to the REST API:

| Convention | Success | Failure |
|-----------|---------|---------|
| **Android SOAP response** | `statusCode = 0` | `statusCode = 1` |
| **REST API v2 response** | `status_code = 1` | `status_code = 0` |

**Flutter must use the REST convention:** `status_code = 1` means success.

---

## 18. Flutter Migration Notes

### 18.1 API Mapping Summary

| Operation | REST Endpoint | Method |
|-----------|--------------|--------|
| Get customer STB list | `getCustomerBoxDetailsRest` | POST |
| Get specific STB details (replacement) | `getCustomerParticularBoxDetailsRest` | POST |
| Get deactivation reasons | `getDeactiveReasonsRest` | POST |
| Deactivate STB | `deactivateBoxRest` | POST |
| Reactivate STB | `reactivateBoxRest` | POST |
| Temporary activate STB | `temporaryActivationRest` | POST |
| Pair STB + VC | `stbPairRest` | POST |
| Unpair STB | `stbUnpairRest` | POST |
| Replace STB | `stb_replacement` | POST |
| Validate box info | `validateBoxInfoRest` | POST |
| Customer search by box number | `getCustomerDetailsCountRest` | POST |

### 18.2 Key Implementation Points

1. **Status code inversion:** Android parses `statusCode=0` as success; REST v2 uses `status_code=1` as success. All response handling must use the REST convention.

2. **Deactivation remarks:** Always append `". Box Deactivation from Android app"` suffix to remarks. If remarks are empty, the default string is `"Box Deactivation from Android app"`.

3. **`is_temp_deactivated` flag:** This single field from the deactivation response (and the bundle) drives whether the activate button shows "Activate STB" or "Temporary Activate STB". Store it in STB state.

4. **Reason filtering:** Exclude `reasonId == 17` from the deactivation spinner. Apply `global_reason` and `disable_for_dpo` filtering based on user type.

5. **STB Pair/Unpair tab control:** Check `stb_pairing` and `stb_unpairing` from login response before showing tabs. If both are 0, do not show the feature at all.

6. **Access control for Box Operations:** Always check `int_stb_activation`, `int_stb_deactivation`, `int_stb_reactivation` (from `getaccesscontrollRest`) before rendering operation buttons. Hide buttons (not just disable) if the user lacks access.

7. **Barcode scanner:** Use a Flutter camera/barcode package (e.g., `mobile_scanner`) replacing the Google Vision `BarcodeDetector`. All barcode formats must be supported.

8. **Reactivation — `reinitialize` field:** Send `reinitialize: 1` in the reactivation request. This is always hardcoded to 1 in the Android source.

9. **`from_mobileapp` field:** Deactivation sends `from_mobileapp: 1`. Include this in the Flutter deactivation request.

10. **Navigation after pair/unpair success:** Android navigates to `MainActivity` home screen (`frgToLoad=0`). Flutter equivalent is navigating to the dashboard/home route.

11. **STB list expandable rows:** The Android adapter uses a toggle arrow to show/hide additional fields per row. Flutter should implement a similar expandable `ListTile` or `ExpansionTile`.

12. **No confirmation dialog for temporary activation:** Unlike standard activation (which shows a confirmation alert), temporary activation triggers immediately on button tap. Do not add an extra confirmation step.

### 18.3 Data Flow Diagram

```
Login Response
  ├─ stb_pairing → StbPairUnpair pair tab visibility
  ├─ stb_unpairing → StbPairUnpair unpair tab visibility
  └─ show_serial_vc → column visibility in STB list

getaccesscontrollRest Response
  ├─ int_stb_activation → Activate button visibility
  ├─ int_stb_deactivation → Deactivate button visibility
  └─ int_stb_reactivation → Reactivate button visibility

Customer_STB_Select_Fragment
  └─ getCustomerBoxDetailsRest(customerId)
       └─ customerBoxList[ ] → ListView
            └─ tap row → Box_Operations_Fragment(bundle)
                 ├─ stockStatus=1 → show Deactivate + Reactivate
                 └─ stockStatus=2, is_temp_deactivated=0 → show Activate
                 └─ stockStatus=2, is_temp_deactivated=1 → show "Temp Activate"

Deactivate flow:
  getDeactiveReasonsRest(stockId) → spinner
  → user selects reason + enters remarks
  → deactivateBoxRest(all fields) → response(is_temp_deactivated)
  → update UI status

Reactivate flow:
  → confirm dialog
  → reactivateBoxRest(reinitialize=1) → success/fail

Temp Activate flow:
  → temporaryActivationRest(customerId, stockId) → success/fail

Pair flow (StbPairUnpair):
  → validate serial + vc not empty
  → confirm dialog
  → stbPairRest(serialNumber, vcNumber) → success/fail → home

Unpair flow (StbPairUnpair):
  → validate serial not empty
  → confirm dialog
  → stbUnpairRest(serialNumber) → success/fail → home
```
