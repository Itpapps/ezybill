# Android EzyBill Business Logic: Payment & Package Management (SOAP API)

> **Source files analyzed:**
> - `CustomerMgmtActivity_MakePayment_Fragment.java` (2302 lines)
> - `FragActive_plan.java` (2691 lines)
> - `Frag_deact_pack.java` (2071 lines)
> - `Package_Operations_Fragment.java` (238 lines)
> - `RenewFragment.java` (495 lines)
> - `PaymentHistory.java` (532 lines)
> - `InvoiceHistory.java` (580 lines)
> - `DisplayPaymentDetails_Fragment2.java` (251 lines)
> - `LCO_Payment_Fragment.java` (723 lines)
>
> **IMPORTANT NOTE:** The Android app uses **SOAP (kSOAP2)** for most operations and **Volley REST (V2)** for a few newer features. The Flutter app targets **V2 REST APIs only**. This document captures the business logic regardless of transport so Flutter can replicate it via REST endpoints.

---

## 1. Make Payment (CustomerMgmtActivity_MakePayment_Fragment)

### 1.1 Initialization & Pre-Payment Data Loading

On fragment load, two parallel calls fire:
1. **GetPaymentModesAsyncTask** (SOAP) -- loads all available payment modes
2. **GetPendingAmount** (SOAP) -- loads pending amount for the customer

**Input params received from parent:**
- `altCustId` (int) -- customer ID
- `reseller_id` (int) -- reseller/employee ID
- `requestOrigin` (string) -- where user came from
- `userLcoDeposit` = `LoginActivity.userLcoDeposit` (0 or 1)
- `AUTO_RECEIPT_NUMBER` = `LoginActivity.AUTO_RECEIPT_NUMBER` (0 or 1)

### 1.2 Payment Mode Logic

**API:** `GetPaymentMode` (SOAP) / Flutter equivalent: `getPaymentModesRest`

**Response parsing:** Iterates `paymentModesList` items, extracting:
- `paymentModeId` (int)
- `PaymentModeName` (string)

All modes are loaded into the spinner (no filtering in current active code; commented-out code suggests Voucher/Online/Online Transfer were previously filtered).

### 1.3 Field Visibility Matrix Per Mode

| Field/Element | Cash | Bank (Cheque) | Card | Voucher | UPI Payment |
|---|---|---|---|---|---|
| Amount row | VISIBLE | VISIBLE | VISIBLE | **GONE** | VISIBLE |
| Receipt number row | VISIBLE | GONE | GONE | GONE | VISIBLE |
| Cheque/DD No | GONE | VISIBLE | GONE | GONE | GONE |
| Bank name | GONE | VISIBLE | GONE | GONE | GONE |
| Branch | GONE | VISIBLE | GONE | GONE | GONE |
| Cheque date | GONE | VISIBLE | GONE | GONE | GONE |
| Voucher code | GONE | GONE | GONE | VISIBLE | GONE |
| Card type (debit/credit) | GONE | GONE | VISIBLE | GONE | GONE |
| QR code image | GONE | GONE | GONE | GONE | VISIBLE |
| Pay Cash button | VISIBLE ("Pay by Cash") | VISIBLE ("Pay by Cheque") | GONE | VISIBLE ("Pay by Voucher") | VISIBLE ("Pay") |
| Pay Card button | GONE | GONE | VISIBLE | GONE | GONE |

**Flutter must replicate:** Show/hide fields dynamically when payment mode spinner changes.

### 1.4 Receipt Number Logic

**Config flag:** `AUTO_RECEIPT_NUMBER` from `LoginActivity`

| Value | Behavior |
|---|---|
| `0` | Manual receipt selection required. Calls `getrecieptnumber()` REST endpoint on load. Receipt row is initially GONE, but `ll_reciept` (receipt book selector) becomes VISIBLE after receipts load. User must pick from a grid/list. |
| `1` (non-zero) | Receipt number row is visible but auto-generated server-side. No receipt book picker shown. Receipt text field exists but user can type freely. |

**Receipt Range Picker (when AUTO_RECEIPT_NUMBER == 0):**
- **REST endpoint:** `{baseUrl}/customerRestservices/getReceiptRanges` (derived from property `rranges`)
- **Params:** `authToken`, `employee_id` (= reseller_id)
- **Response:** `{ status_code: 0, status_msg: "...", ReceiptRanges: ["R001-R100", "R101-R200", ...] }`
- Displays receipt ranges in a searchable grid dialog
- User selects a receipt range, which populates `receipt_num_et`
- **Validation:** If receipt is "Select" or empty, shows toast: "Select valid Receipt Number."

### 1.5 Amount Validation & userLcoDeposit

**Config flag:** `userLcoDeposit` (from `LoginActivity.userLcoDeposit`)

| Value | Behavior |
|---|---|
| `1` | Amount field is **disabled** (not editable). Amount is locked to `pendingAmount` from server. |
| `0` | Amount field is **editable**. User can enter any amount. Additional validation applies (see below). |

**Amount validation rules (when userLcoDeposit == 0):**

1. **Amount == "0.0"**: Dialog: "Amount should not be empty." / "Empty Fields!" -- **BLOCKS payment**
2. **Amount < pendingAmount**: Dialog: "Entered amount {amount}, is less than the actual pending amount - {pendingAmount}, please enter actual pending amount or excess amount to continue" / Title: "Invalid Amount" -- **BLOCKS payment** (OK dismisses, no payment made)
3. **Amount >= pendingAmount** (including exact match): Dialog: "Entered amount {amount}, is more than the actual pending amount - {pendingAmount}" / Title: "If you wish to pay excess amount click on OK else cancel the transaction by clicking on cancel" -- **OK proceeds with payment**, Cancel aborts
4. **When userLcoDeposit == 1**: No amount validation -- proceeds directly to `MakePayment`

**CRITICAL BUSINESS RULE:** When `userLcoDeposit == 0`, the app blocks amounts LESS than pending. Amounts >= pending are allowed with a confirmation dialog. This means partial payments are NOT allowed when this flag is 0.

### 1.6 Bank/Cheque Mode Validation

When mode is "Bank":
- All four fields must be non-empty: `cheqDDNo`, `bank`, `branch`, `chequeDate`
- If any is empty: Dialog "Fields should not be empty." / "Empty Fields!" -- **BLOCKS payment**
- Cheque date must NOT be before today (validated in date picker callback)

### 1.7 Voucher Mode Validation

- Voucher code field must not be null or empty
- If empty: Toast "Please enter a voucher code."
- When mode is Voucher, amount is set to `0` in the API call (server handles amount from voucher)

### 1.8 Card Mode Validation

- Amount must not be "0.0"
- Must select either Debit or Credit checkbox (mutually exclusive)
- If neither selected: Toast "Please select card type"
- Debit = cardtype 1, Credit = cardtype 2

### 1.9 Remarks Auto-Suffix

**Business rule:** Remarks always get a suffix appended:
- If user enters nothing: `remarks = "Paid From Android App"`
- If user enters text: `remarks = "{userText}. Paid From Android App"`

**Flutter must replicate this suffix logic.**

### 1.10 MakePayment API Call

**SOAP method:** `makePaymentsInfo` / Flutter equivalent: `makePaymentsRest`

**Parameters by mode:**

| Parameter | Cash | Bank | Voucher |
|---|---|---|---|
| `altCustomerId` | custId | custId | custId |
| `authToken` | token | token | token |
| `amount` | float from field | float from field | **0** (hard-coded) |
| `billingId` | from getPendingAmount response | same | same |
| `remarks` | with suffix | with suffix | with suffix |
| `imei` | LoginActivity.imeiNo | LoginActivity.imeiNo | LoginActivity.imeiNo |
| `modeType` | "cash" | "bank" | "voucher" |
| `receipt_number` | only when AUTO_RECEIPT_NUMBER==0 | -- | -- |
| `chequeNo` | -- | from field | -- |
| `bank` | -- | from field | -- |
| `branch` | -- | from field | -- |
| `chequeDate` | -- | date or "0000-00-00" | -- |
| `voucherCode` | -- | -- | from field |

### 1.11 Post-Payment Response Handling

**Status codes:**
- `statusCode == 0`: Success
  - Check if `statusMessage == "Payment successful."`:
    - **YES**: Extract full receipt details, navigate to `Displayfrag` with all receipt data
    - **NO**: Show toast with statusMessage, then re-call `GetPendingAmount` (refreshes the screen)
- `statusCode == 1`: Dialog "Payment Failed!" with statusMessage, then `popBackStack()`
- `statusCode >= 2`: Dialog "Payment Failed!" with statusMessage, then `popBackStack()`
- `response == null`: Dialog "Server is busy or Un reachable!"

**Receipt data extracted on success (for display/print):**
- `customerName`, `mobile`, `email`, `city`, `state`, `pin`
- `billNumber`, `receiptNumber`, `amount` (paidAmount), `billAmount`
- `customNumber`, `lco_business_name`, `lco_city`, `lco_state`, `lco_pincode`
- `last_paid_amt`, `last_paid_date`, `collection_employee`
- `mode`, `format`, `pendingAmount` (final)
- For Bank mode additionally: `cheque`, `bankname`, `str_branch`

**Outstanding calculation:** `outstanding = pendingAmount - paidAmount`

**Navigation:** After successful payment, navigates to `Displayfrag` (receipt display fragment) with all the extracted data as bundle extras.

### 1.12 GetPendingAmount Response

**SOAP method:** `getPendingAmountInfo`

**Params:** `altCustomerId`, `authToken`

**Response fields extracted:**
- `statusCode`, `statusMessage`
- `customerName` -- displayed in header
- `pendingAmount` -- pre-fills amount field and display
- `msoShare` -- displayed (hidden if parse fails)
- `lcoShare` -- displayed (hidden if parse fails)
- `mobileNumber`
- `billingId` -- stored for payment call

### 1.13 BLE Print Receipt (DisplayPaymentDetails_Fragment2)

**Receipt format (N910 thermal printer):**
```
--------------------------------
     PAYMENT RECEIPT
--------------------------------
{formatted current date/time}
--------------------------------
CUSTOMER NAME  :{custName}
CUSTOMER ID    :{custId}
MOBILE NO      :{mobileNo}
ADDRESS        :{address}
RECEIPT NO     :{receiptNo}
PAID.AMT       :{paidAmount}
DUE.AMT        :{dueAmt}
--------------------------------
```

If card payment (`payments == true`), additionally:
```
     TRANSACTION DETAILS
--------------------------------
CARD NAME      :{CardHolderName}
RRN            :{RRN}
AMOUNT         :{Amount}
TRANSACTION ID :{TransactionId}
--------------------------------
```

---

## 2. Package Operations Router (Package_Operations_Fragment)

This is a navigation hub, not a data screen. Business rules:

### 2.1 Visibility Flags

| Button | Condition | Action |
|---|---|---|
| Activate Package | `LoginActivity.int_stb_activation == 1` | VISIBLE, else INVISIBLE |
| Deactivate Package | `LoginActivity.int_stb_deactivation == 1` | VISIBLE, else INVISIBLE |
| Renew Package | `isexpired == 1 AND patch_information in ("1.4.13.2", "1.4.13.3", "1.4.13.4")` | VISIBLE, else INVISIBLE |

**CRITICAL:** The renewal button visibility has an operator precedence bug in Android:
```java
if (isexpired==1 && LoginActivity.patch_information.equals("1.4.13.2") || ...)
```
Due to `&&` binding tighter than `||`, the second and third patch checks bypass the `isexpired==1` requirement. Flutter should use proper parentheses: `isexpired == 1 && (patch in [list])`.

### 2.2 Data Passed to Sub-Fragments

All sub-fragments receive: `custId`, `boxNo`, `custDevId`, `custStockId`, `resellerid`

---

## 3. Package Activation (FragActive_plan)

### 3.1 Package Loading

**SOAP method:** `getUnassignedPackages_split` (property key: `unassigned`)

**Params:** `authToken`, `customerId`, `boxNumber`

**Response:** Packages split into 4 named arrays in the SOAP response:
- `packageList_base` -- Base packages
- `packageList_addon` -- Add-on packages
- `packageList_ala` -- A la carte packages
- `packageList_broadcaster` -- Broadcaster packages
- `deactivate_customerservices` -- Currently active services (shown in a separate popup)

**Fields parsed per package:**
- `product_id` (int) -- stored as `packageId`
- `pname` (string) -- stored as `packageName`
- `pricing_structure_type` (int) -- 1=OneTime, 2=Recurring
- `base_price` (double)
- `sd_channels_count` (int)
- `hd_channels_count` (int)
- `monthly_or_yearly` (string)
- `validity` (string) -- e.g., "Year(s)", "Month(s)", or day-based
- `validity_days` (int) -- numeric value

### 3.2 Tab Display

Four tabs: Base | Add-On | A la Carte | Broadcaster

Each tab has its own ListView with multi-select checkboxes (via `Packageadapter`). Search bar filters the currently visible tab's list.

### 3.3 Package Selection

When user clicks "Save" button, `AllinOneSave()` is called:
1. Iterates all 4 package lists, finds selected items (`isSelected()`)
2. For each selected package, computes start/end dates using validity
3. Collects all selected package IDs into comma-separated string (`totalstrs`)
4. Shows confirmation dialog with package list, amounts, and total

### 3.4 Validity/Date Computation

**CRITICAL BUSINESS RULE** -- Validity string length determines date unit:

| `validity.length()` | Date Unit | Example |
|---|---|---|
| 7 (e.g., "Year(s)") | `Calendar.YEAR` | Add N years to today |
| 8 (e.g., "Month(s)") | `Calendar.MONTH` | Add N months to today |
| Other | `Calendar.DATE` | Add N days to today |

**End date:** After adding the period, subtract 1 day. So a 1-month package starting Jan 1 ends Jan 31.

**Start date:** Always today (`dd-MM-yyyy` format)

### 3.5 Bill Details (Get Bill) -- REST V2

**REST endpoint:** `{baseUrl}/customerRestservices/getbilldetails` (property key: `getbill`)

**Method:** POST

**Params:**
- `authtoken` -- LoginActivity.authToken
- `dealer_id` -- LoginActivity.dealerId
- `employee_id` -- resellerid
- `customer_id` -- customerId
- `package_id` -- comma-separated product IDs (totalstrs)
- `serial_number` -- boxNumber

**Response (status_code == 0):**
```json
{
  "status_code": 0,
  "status_msg": "...",
  "basePrice": {
    "lco_share": 100.0,
    "mso_share": 50.0,
    "total_amount": 200.0,
    "ncf_display_name": "NCF",
    "encf_display_name": "ENCF",
    "ncf_total_amount": 23.60,
    "encf_total_amount": 0.0
  }
}
```

**Display rules:**
- NCF row hidden if `ncf_total_amount <= 0`
- ENCF row hidden if `encf_total_amount <= 0`
- After Get Bill succeeds: "Get Bill" button hides, "Activate" button appears
- lco_share, mso_share, NCF, ENCF values displayed with rupee sign

### 3.6 Two-Step Confirmation Flow

1. User selects packages and clicks "Save"
2. Summary dialog shows: package list, start/end dates, total amount, "Get Bill" button, "Cancel" button
3. User clicks "Get Bill" -- calls `getbilldetails` REST API
4. After bill loads: "Get Bill" hides, "Activate" appears with lco_share, mso_share, NCF, ENCF
5. User clicks "Activate" -- confirmation dialog "Are you sure you want to Activate packages?"
6. Yes -- calls `ActivatingPackage`

### 3.7 Activate Service API

**SOAP method:** `activateService` (property key: `acser`)

**Params:**
- `authToken` -- LoginActivity.authToken
- `customerDeviceId` -- from bundle
- `customerId` -- from bundle
- `productId` -- **comma-separated product IDs** (totalstrs)
- `quantity` -- **hard-coded 1**
- `dateType` -- **hard-coded 0**
- `pricingStructureType` -- **hard-coded 1**
- `validityDays` -- **hard-coded 1**
- `stockId` -- from bundle
- `fromMobileApp` -- **hard-coded 1**
- `login_employee_id` -- LoginActivity.employeeId
- `reseller_id` -- from bundle
- `dealer_id` -- LoginActivity.dealerId

**Response handling:**
- `statusCode == 0`:
  - If `actt == 1` (box activation): Dialog "Box Activated Successfully", navigate to MainActivity
  - Else: Dialog with statusMessage (HTML tags stripped), navigate to MainActivity
- `statusCode == 1`: Dialog "Activation Failed!" with message, `popBackStack()`
- `statusCode == 2`: Toast "Contact Support"
- `statusCode > 2`: Dialog "Activation Failed!"

**HTML stripping:** Response messages may contain `<b>`, `<br>`, `</br>`, `</b>` tags -- all are removed for display.

### 3.8 Pricing Structure Type

| Value | Meaning | Activation Cycle Options |
|---|---|---|
| 1 | One-time product | Year, Month, Day |
| 2 | Recurring product | Year only |

(Note: This is loaded but the activation cycle spinner is not actively used in the current code -- `reloadActivationSpinner()` exists but activation always sends hardcoded values.)

---

## 4. Package Deactivation (Frag_deact_pack)

### 4.1 Initialization

On load, two parallel calls:
1. **GetUnAssaignedPackages** (SOAP, property key: `custpacksp`) -- loads customer's active packages
2. **ReasonValues** (SOAP, property key: `deres`) -- loads deactivation reasons

### 4.2 Active Package Loading

**SOAP method:** Customer packages split (same structure as activation but uses `customer_service_id`)

**Response arrays:**
- `packageList_base`, `packageList_addon`, `packageList_ala`, `packageList_broadcaster`

**Fields parsed per package:**
- `customer_name`
- `service_start_date`, `service_end_date`
- `product_id`, `product_name`
- `customer_service_id` -- **THIS is used for deactivation, NOT product_id**
- `base_price`, `sd_channels_count`, `hd_channels_count`
- `monthly_or_yearly`, `validity`
- `pricing_structure_type`, `validity_days`

### 4.3 Package Selection for Deactivation

Same 4-tab UI as activation. User selects packages with checkboxes.

**CRITICAL:** Deactivation uses `getServiceId()` (= `customer_service_id`) NOT `getPackageId()` (= `product_id`). The comma-separated string `totalstrs` contains **service IDs**.

### 4.4 Deactivation Reason Loading & Filtering

**SOAP method:** `getDeactiveReasons` (property key: `deres`)

**Params:** `authToken`

**Response:** List of `reasonList` items with:
- `reasonId` (int)
- `reasonName` (string)
- `global_reason` (int) -- 0 or 1

**Filtering rules -- reasons EXCLUDED from the spinner:**

| Condition | Excluded? | Reason |
|---|---|---|
| `reasonId == 17` | YES | System-reserved reason |
| `reasonId == 21` | YES | System-reserved reason |
| `global_reason == 1` | YES | Global reasons not shown to LCO users |

**Flutter must replicate:** Filter out reasons with id 17, 21, or global_reason == 1 before displaying in dropdown.

### 4.5 Deactivation Validation

Before calling deactivation API:
1. Packages must be selected (at least one)
2. Remarks field must NOT be empty -- Dialog: "Remarks should not be empty." / "Empty fields!"
3. Internet connection check

### 4.6 Deactivation API Call

**SOAP method:** `deactivateService` (property key: `deactser`)

**Params:**
- `authToken` -- LoginActivity.authToken
- `customerId` -- from bundle
- `serviceId` -- **comma-separated customer_service_ids** (NOT product_ids)
- `fromMobileApp` -- **hard-coded 1**
- `reasonId` -- selected from spinner
- `remarks` -- user text + **".Deactivation From Android App"** suffix
- `stock_id` -- from bundle
- `dealer_id` -- LoginActivity.dealerId
- `reseller_id` -- from bundle
- `login_employee_id` -- LoginActivity.employeeId

**Remarks suffix rule:** `remarks = et_remarks.getText() + ".Deactivation From Android App"`

**Response handling:**
- `statusCode == 0`: Dialog "Product deactivated successfully" / "Deactivation Successful", then `popBackStack()`
- `statusCode == 1`: Dialog "{statusMessage} Package deactivation failed" / "Deactivation Failed!"
- `statusCode >= 2`: Dialog "{statusMessage}. Package deactivation failed. Please Check and enter valid details"

### 4.7 Deactivation Summary Dialog

Before calling API, a confirmation dialog shows:
- Selected packages list (name, amount, start date, end date, pricing structure type)
- Total amount
- Two-step: "Deactivate" button and "Cancel" button
- "Deactivate" shows confirmation: "Are you sure you want to deactivate packages?" with Yes/No

---

## 5. Package Renewal (RenewFragment)

### 5.1 Loading Renewable Services -- REST V2

**REST endpoint:** `{baseUrl}/customerRestservices/getRenewServicesList`

**Method:** POST

**Params:**
- `authtoken` -- LoginActivity.authToken
- `dealer_id` -- LoginActivity.dealerId
- `customer_id` -- customerId

**Response (status_code == 0):**
```json
{
  "status_code": 0,
  "status_msg": "...",
  "getRenewServices": [
    {
      "customer_service_id": "123",
      "product_id": "456",
      "base_price": "100.00",
      "pname": "Basic Pack"
    }
  ]
}
```

### 5.2 Renewal Selection

- Multi-select list with checkboxes
- User selects packages, clicks "Save"
- Summary dialog shows selected packages with names and prices
- Total amount calculated
- Confirmation: "Are you sure you want to Renew packages?"

### 5.3 Renewal API Call -- REST V2

**REST endpoint:** `{baseUrl}/customerRestservices/renewServicesList`

**Method:** POST

**Params:**
- `authtoken` -- LoginActivity.authToken
- `dealer_id` -- LoginActivity.dealerId
- `customer_id` -- customerId
- `customer_service_id` -- **comma-separated** customer_service_ids of selected packages
- `product_ids` -- **comma-separated** product_ids of selected packages

**Response:**
- `status_code == 0`: Success dialog with status_msg, then `popBackStack()`
- `status_code == 1`: Failure dialog with status_msg, then `popBackStack()`

### 5.4 Renewal Visibility Rule

Renewal button only visible in Package_Operations_Fragment when:
- `isexpired == 1` AND `patch_information` is one of: "1.4.13.2", "1.4.13.3", "1.4.13.4"

---

## 6. LCO Payment (LCO_Payment_Fragment)

### 6.1 Two-Phase Flow

**Phase 1: LCO Code Search**
**Phase 2: Payment Form**

### 6.2 LCO Code Search API (SOAP)

**SOAP method:** `getlcoadvanceamountdue`

**Params:**
- `authToken` -- LoginActivity.authToken
- `lco_code` -- user-entered LCO code

**Validation:** LCO code cannot be empty

**Response fields (statusCode == 0):**
- `employee_id` (int)
- `dealer_id` (string)
- `billing_id` (string)
- `advance` (string) -- displayed as "Advance Payment"
- `due` (string) -- displayed as "Due", also pre-fills amount field
- `bill_amount` (string)
- `tds_deduction` (string)

After successful search: search layout hides, result/payment layout shows.

### 6.3 Payment Mode (LCO)

Two modes only: **CASH** and **BANK**

| Field | CASH | BANK |
|---|---|---|
| Bank details (cheque, bank, branch, date) | GONE | VISIBLE |
| Payment mode code | `paymode = 1` | `paymode = 2` |

### 6.4 Adjustment / Debit-Credit Logic

- `isAdjustment` checkbox: when checked, shows Credit/Debit spinner
  - CREDIT = `int_credit_debit = 0`
  - DEBIT = `int_credit_debit = 1`
- `adjust_flag`: "1" if adjustment checked, "0" otherwise
- `isAccepted` checkbox: only relevant for Bank mode, sets `accept = "1"`

### 6.5 LCO Payment Validation

1. Amount cannot be empty or zero
2. Remarks cannot be empty
3. For Bank mode: cheque number, bank name, branch, and cheque date all required

### 6.6 LCO Payment API (SOAP)

**SOAP method:** `lcopaymentfunc`

**Params:**
- `authToken`
- `lco_employee_id` -- from search response
- `lco_billing_id` -- from search response
- `receipt_number` -- user entered
- `amount` -- user entered
- `mode` -- "1" (cash) or "2" (bank)
- `adjust_flag` -- "0" or "1"
- `dabit_credit` -- "0" (credit) or "1" (debit), only when adjust_flag == "1"
- `accept` -- "1" if bank mode and accepted checkbox checked
- `chequeddnumber` -- cheque number (bank mode)
- `chequeDate` -- cheque date string (bank mode)
- `bank` -- bank name (bank mode)
- `branch` -- branch name (bank mode)
- `remarks` -- user entered

### 6.7 Cheque Date Validation (same as Make Payment)

Cheque date must not be before current date. Validated in DatePicker callback.

---

## 7. Payment History (PaymentHistory)

### 7.1 Loading Payment History (SOAP)

**SOAP method:** Property key `phist`

**Params:** `authToken`, `customer_id`, `dealer_id` (via `Invoicedatas` complex type)

**Response:** List of `payment_details` items with:
- `paid_on` (string -- date)
- `paid_amount` (double)
- `receipt_no` (string)
- `payment_mode` (string)
- `payment_id` (int)
- `remarks` (string)

### 7.2 Display

- ListView showing all payments
- Header: "Total Payments - {count}"
- Each item has Print and Share buttons

### 7.3 Print Format (Payment History)

```
--------------------------------
     PAYMENT  HISTORY
--------------------------------
{current date/time}
--------------------------------
CUSTOMER NAME   :{custname}
PAYMENT DATE    :{paid_on}
PAYMENT ID      :{payment_id}
PAYMENT MODE    :{payment_mode}
AMOUNT          :{paid_amount}
RECEIPT NO.     :{receipt_no}
REMARKS         :{remarks}
--------------------------------
```

### 7.4 Share (PDF)

Same content as print but generated as PDF via `PDFTools.showPDFUrl()`.

### 7.5 BLE Print (Payment History)

For N910 device: direct thermal print. For other devices: navigate to `Bluetooth_Fragment` with `offline_report = 9` and all payment data fields.

---

## 8. Invoice History (InvoiceHistory)

### 8.1 Loading Invoice History (SOAP)

**SOAP method:** Property key `invhist`

**Params:** `authToken`, `customer_id`, `dealer_id` (via `Invoicedatas` complex type)

**Response:** List of `invoice_details` items with:
- `pname` (string)
- `billing_id` (int)
- `bill_date` (string)
- `due_date` (string)
- `total_amount` (double)
- `quantity` (int)
- `is_adhoc` (int -- 0=No, 1=Yes)
- `base_price` (double)
- `setup_price` (double)
- `tax_amount` (double)
- `pending_amount` (double)
- `discount_amount` (double)
- `serial_number` (string) -- displayed in header
- `mac_vc_number` (string) -- displayed in header

### 8.2 Display

- Header: "Total Invoices - {count}", serial number, VC number
- ListView with Print and Share per item

### 8.3 Print Format (Invoice History)

```
--------------------------------
     INVOICE HISTORY
--------------------------------
{current date/time}
--------------------------------
CUSTOMER NAME   :{custname}
INVOICE NUMBER  :{billing_id}
INVOICE DATE    :{bill_date}
DUE DATE        :{due_date}
BASE PRICE      :{base_price}
SETUP PRICE     :{setup_price}
TAX AMOUNT      :{tax_amount}
PENDING AMOUNT  :{pending_amount}
DISCOUNT AMOUNT :{discount_amount}
TOTAL AMOUNT    :{total_amount}
ADHOC BILLS     :{Yes/No}
--------------------------------
```

### 8.4 BLE Print

For N910: direct thermal. For others: `Bluetooth_Fragment` with `offline_report = 8` and all invoice fields.

---

## Summary of Config Flags Flutter Must Replicate

| Flag | Source | Affects |
|---|---|---|
| `AUTO_RECEIPT_NUMBER` | LoginActivity (from login response) | Receipt entry mode: manual picker (0) vs auto (1) |
| `userLcoDeposit` | LoginActivity (from login response) | Amount field editable (0) vs locked (1) |
| `int_stb_activation` | LoginActivity (from login response) | Activate button visibility |
| `int_stb_deactivation` | LoginActivity (from login response) | Deactivate button visibility |
| `isexpired` | From customer profile/search | Renewal button visibility |
| `patch_information` | LoginActivity (from login response) | Renewal button visibility (version check) |
| `dealerId` | LoginActivity (from login response) | Sent in most API calls |
| `employeeId` | LoginActivity (from login response) | Sent as login_employee_id |
| `imeiNo` | LoginActivity (device IMEI) | Sent in payment calls |

## Summary of Remarks Suffixes

| Screen | Suffix |
|---|---|
| Make Payment | `. Paid From Android App` or `Paid From Android App` (if empty) |
| Package Deactivation | `.Deactivation From Android App` |

## Summary of REST V2 Endpoints (New APIs)

| Endpoint | Screen | Purpose |
|---|---|---|
| `/customerRestservices/getReceiptRanges` | Make Payment | Load receipt number ranges |
| `/customerRestservices/getbilldetails` | Package Activation | Get bill breakdown before activation |
| `/customerRestservices/getRenewServicesList` | Renewal | Load expired/renewable services |
| `/customerRestservices/renewServicesList` | Renewal | Execute renewal |

## Key Differences: Deactivation vs Activation IDs

| Operation | ID Field Sent | Source |
|---|---|---|
| **Activation** | `productId` (comma-separated product_ids) | `packageArrayList.get(i).getPackageId()` = `product_id` |
| **Deactivation** | `serviceId` (comma-separated customer_service_ids) | `packageArrayList.get(i).getServiceId()` = `customer_service_id` |
| **Renewal** | Both `customer_service_id` AND `product_ids` (separate params) | From getRenewServicesList response |

This is a critical distinction. Flutter must use the correct ID type for each operation.
