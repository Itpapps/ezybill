# 03 - Payments & Payment Gateway Integration

> **Document scope:** All payment collection screens, payment history, invoice history, LCO wallet management, payment gateway (Billdesk/Payswiff) integration, and PG transaction reporting.
> **Source files analysed:** 20 Java activity/fragment files + 11 model classes + REST API v2 document.
> **Protocol note:** The legacy Android app uses SOAP (ksoap2) for customer payment operations and REST (Volley) for PG/wallet operations. In Flutter, **all calls must use the V2 REST endpoints** listed in this document.

---

## Table of Contents

1. [Screen S01 – Make Payment (Customer)](#screen-s01--make-payment-customer)
2. [Screen S02 – Payment History](#screen-s02--payment-history)
3. [Screen S03 – Invoice History](#screen-s03--invoice-history)
4. [Screen S04 – LCO Payment (MSO-to-LCO)](#screen-s04--lco-payment-mso-to-lco)
5. [Screen S05 – LCO Wallet Top-up](#screen-s05--lco-wallet-top-up)
6. [Screen S06 – LCO Wallet History](#screen-s06--lco-wallet-history)
7. [Screen S07 – PG Transaction Report](#screen-s07--pg-transaction-report)
8. [Screen S08 – Billdesk Payment Activity](#screen-s08--billdesk-payment-activity)
9. [Screen S09 – Payment WebView (Paytm/UPI Gateway)](#screen-s09--payment-webview-paytmupi-gateway)
10. [Screen S10 – Payment Response](#screen-s10--payment-response)
11. [Screen S11 – Payment Transaction (Payswiff POS)](#screen-s11--payment-transaction-payswiff-pos)
12. [Screen S12 – Display Payment Details (Receipt)](#screen-s12--display-payment-details-receipt)
13. [Screen S13 – Transaction Details (Card Approved)](#screen-s13--transaction-details-card-approved)
14. [Screen S14 – Transaction Details Declined](#screen-s14--transaction-details-declined)
15. [Screen S15 – Payswiff Account Activation](#screen-s15--payswiff-account-activation)
16. [Screen S16 – Payswiff Payment Transaction Fragment](#screen-s16--payswiff-payment-transaction-fragment)
17. [Screen S17 – Payswiff Transaction Details Fragment](#screen-s17--payswiff-transaction-details-fragment)
18. [Screen S18 – Billdesk SampleCallBack Handler](#screen-s18--billdesk-samplecallback-handler)
19. [Backend Config Flags Reference](#backend-config-flags-reference)
20. [Payment Mode Field Matrix](#payment-mode-field-matrix)
21. [Complete V2 REST API Reference – Payments Domain](#complete-v2-rest-api-reference--payments-domain)

---

## Screen S01 – Make Payment (Customer)

### 1. Screen Identity

| Property | Value |
|----------|-------|
| **Class** | `CustomerMgmtActivity_MakePayment_Fragment` (Fragment) |
| **Layout** | `makepayment_new` |
| **Title** | "Make Payment" |
| **Entry point** | Navigated from customer search/management; receives `custId` (int) and `reseller_id` (int) via Bundle. `reqOrigin` string also passed to identify calling screen. |
| **Purpose** | Collect payment from a customer for their outstanding bill. Supports Cash, Bank/Cheque, Card (Payswiff POS), Voucher, and UPI Payment modes. |

### 2. UI Elements

#### Header Info (read-only, populated from `getPendingAmountRest`)

| Widget | ID | Data source |
|--------|----|-------------|
| Customer Name | `makepayact_tv_custname` | `customerName` from getPendingAmount response |
| Pending Amount | `makepayact_tv_pendamunt` | `pendingAmount` from response |
| MSO Share | `makepayact_tv_msoshare` | `msoShare` from response |
| LCO Share | `makepayact_tv_lcoshare` | `lcoShare` from response |

#### Payment Form

| Widget | ID | Type | Visibility rule |
|--------|----|------|-----------------|
| Payment Mode Spinner | `makepaymet_spin_paymentmode` | Spinner | Always visible; populated from `getPaymentModesRest` |
| Amount | `makepayact_et_amount` | EditText (decimal, 2dp) | Always visible; pre-filled with pending amount |
| Receipt Number | `makepayact_et_receiptNumber` | EditText | Visible only when `AUTO_RECEIPT_NUMBER == 1` (manual entry) and mode is Cash or UPI |
| Receipt Book Selector | `ll_reciept_selchange` | LinearLayout (tap to open grid dialog) | Visible only when `AUTO_RECEIPT_NUMBER == 0` (receipt ranges enabled) |
| Cheque/DD Number | `makepayact_et_cheqddno` | EditText | Bank mode only |
| Bank Name | `makepayact_et_bank` | EditText | Bank mode only |
| Branch | `makepayact_et_branch` | EditText | Bank mode only |
| Cheque Date | `makepayact_btn_ChangeDate` | Button (DatePickerDialog) | Bank mode only |
| Voucher Code | `makepayact_et_vouchercode` | EditText | Voucher mode only; amount is set to 0 |
| Card Type | `cardtype_layout` | CheckBoxes (debit_chk / credit_chk) | Card mode only; mutually exclusive |
| Remarks | `makepayact_et_remarks` | EditText | All modes; suffix ". Paid From Android App" appended automatically |
| QR Code Image | `igv_qrcode` | ImageView | UPI Payment mode only |

#### Action Buttons

| Button | ID | Function |
|--------|----|----------|
| Pay (Cash/Cheque/Voucher/UPI) | `makepayact_btn_pay_cash` | Triggers MakePayment async task; label changes per mode |
| Pay by Card (POS) | `makepayact_btn_pay_card` | Launches Payswiff PaymentTransactionActivity |
| Clear | `makepayact_btn_clear` | Resets form fields |
| Change Cheque Date | `makepayact_btn_ChangeDate` | Opens DatePickerDialog |

### 3. Actions & Workflows

#### 3.1 On Fragment Load

```
1. Read custId, reseller_id, reqOrigin from Bundle.
2. Read AUTO_RECEIPT_NUMBER from LoginActivity.AUTO_RECEIPT_NUMBER.
3. Execute GetPaymentModesAsyncTask  →  populates payment mode spinner.
4. Execute GetPendingAmount          →  fills customer name, pending amount, billing ID.
5. If AUTO_RECEIPT_NUMBER == 0:
     - Hide receipt EditText row.
     - Call getrecieptnumber() (REST POST to /getReceiptRanges).
     - Show receipt book selector layout with searchable grid dialog.
```

#### 3.2 Payment Mode Selection (spinner listener)

When the user selects a mode the form rows are shown/hidden:

| Mode name | Visible rows |
|-----------|-------------|
| **Cash** | Amount, Receipt Number (if AUTO_RECEIPT_NUMBER==1), Remarks |
| **Bank** | Amount, Cheque No, Bank, Branch, Cheque Date, Remarks |
| **Card** | Amount, Card Type (debit/credit checkboxes), Remarks; shows `btn_pay_card` |
| **Voucher** | Voucher Code, Remarks; amount set to 0 internally |
| **UPI Payment** | Amount, Receipt Number, QR Code image, Remarks |

#### 3.3 Pay Button – Cash/Bank/Voucher/UPI

```
Pre-validation:
  - Network connectivity check.
  - Amount must not be "0.0".
  - For Bank mode: cheque no, bank, branch, cheque date must all be non-empty.
  - For Voucher mode: voucher code must be non-empty.
  - For manual receipt number (AUTO_RECEIPT_NUMBER==0): receipt must be selected (not "Select"/empty).

Amount vs. pending amount check (when userLcoDeposit == 0):
  - If entered < pending: show "Invalid Amount" alert, block payment.
  - If entered > pending: show confirmation dialog "Excess amount – OK to continue?"; on OK → execute MakePayment.
  - If entered == pending: execute MakePayment directly.

When userLcoDeposit == 1:
  - Amount field is disabled; system uses the pre-filled pending amount.
  - No amount comparison dialog shown; proceeds directly to MakePayment.
```

#### 3.4 MakePayment Async Task

```
onPreExecute:
  - Read and format all form fields.
  - Default remarks: "Paid From Android App" (appended to any user-typed text).
  - For cheque date: if "Select" still shown, use "0000-00-00".

doInBackground:
  - Build makePaymentsInfo object with fields matching selected mode.
  - SOAP call: METHOD = from PropertyReader("mpay").
  - 90-second timeout.

onPostExecute (statusCode parsing from SOAP string response):
  - statusCode==0 AND statusMessage=="Payment successful.":
      Extract: customerName, mobile, email, city, state, pin, billNumber,
               receiptNumber, paidAmount, billAmount, outstanding, customNumber,
               lco_business_name, lco_city, lco_state, lco_pincode,
               last_paid_amt, last_paid_date, collection_employee, mode, format,
               pendingAmount (final).
      Clear form fields.
      Navigate to Displayfrag with all receipt data in Bundle.
  - statusCode==0 AND statusMessage != "Payment successful." (e.g. digital activation):
      Show toast; re-execute GetPendingAmount.
  - statusCode==1: Show "Payment Failed!" dialog; pop back stack.
  - statusCode>=2: Show "Payment Failed!" + "Contact Support" toast; pop back stack.
  - response==null: Show "Server busy or unreachable" dialog.
```

#### 3.5 Pay by Card Button (Payswiff POS)

```
- Validate amount > 0.
- Validate card type selected (debit or credit checkbox).
- Navigate to PaymentTransactionActivity / PaymenttransacFragment (Payswiff SDK).
  Extras passed: amount, custID, billingId, pendingamount, mobile, remarks, cardtype.
```

### 4. API Calls

#### 4.1 Get Payment Modes

| Property | Value |
|----------|-------|
| **V2 Endpoint** | `POST /LcoRestServices/getPaymentModesRest` |
| **Android (legacy)** | SOAP method name from `PropertyReader.getProperty("pmodes")` |
| **Auth** | authToken in payload |
| **Request params** | None (uses authenticated session) |
| **Response** | `paymentModesList` array; each item has `paymentModeId` (int) and `PaymentModeName` (String) |

#### 4.2 Get Pending Amount

| Property | Value |
|----------|-------|
| **V2 Endpoint** | `POST /LcoRestServices/getPendingAmountRest` |
| **Android (legacy)** | SOAP method name from `PropertyReader.getProperty("pendamt")` |
| **Request params** | `altCustomerId` (int), `authToken` (String), `serial_no` (String, optional) |
| **Response fields** | `statusCode`, `statusMessage`, `customerName`, `pendingAmount`, `msoShare`, `lcoShare`, `mobileNumber`, `billingId` |

#### 4.3 Get Receipt Ranges

| Property | Value |
|----------|-------|
| **V2 Endpoint** | `POST /LcoRestServices/getReceiptRanges` |
| **Android (legacy)** | REST POST, URL from `PropertyReader.getProperty("rranges")` |
| **Request params** | `authtoken`, `dealer_id` |
| **Response** | `status_code`, `status_msg`, `ReceiptRanges` (JSON array of receipt number strings) |
| **Usage** | Only called when `AUTO_RECEIPT_NUMBER == 0`; shows a searchable grid dialog for receipt number selection |

#### 4.4 Make Payment

| Property | Value |
|----------|-------|
| **V2 Endpoint** | `POST /LcoRestServices/makePaymentsRest` |
| **Android (legacy)** | SOAP method name from `PropertyReader.getProperty("mpay")` |
| **Timeout** | 90 seconds |

**Request parameters (makePaymentsInfo / makePaymentsRest):**

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `altCustomerId` | int | Yes | Customer ID |
| `authToken` | String | Yes | Session token |
| `amount` | float | Yes | Payment amount (0 for Voucher mode) |
| `billingId` | int | Yes | Billing record ID from getPendingAmount |
| `modeType` | String | Yes | `"cash"`, `"bank"`, `"voucher"` |
| `remarks` | String | Yes | Free text; suffix ". Paid From Android App" always appended |
| `imei` | String | Yes | Device IMEI from `LoginActivity.imeiNo` |
| `receipt_number` | String | Conditional | Required when `AUTO_RECEIPT_NUMBER == 0` |
| `chequeNo` | String | Bank only | Cheque or DD number |
| `bank` | String | Bank only | Bank name |
| `branch` | String | Bank only | Branch name |
| `chequeDate` | String | Bank only | Format `yyyy-MM-dd`; `"0000-00-00"` if not selected |
| `voucherCode` | String | Voucher only | Voucher code entered by user |
| `rrnNo` | String | Card only | RRN from Payswiff POS |
| `cardholderName` | String | Card only | Cardholder name from POS terminal |

**Response fields (makePaymentsRest):**

| Field | Type | Description |
|-------|------|-------------|
| `status_code` | int | 0=success, 1=failure, 2+=server error |
| `status_msg` / `statusMessage` | String | "Payment successful." on success |
| `receipt_number` | String | Server-generated receipt number |
| `payment_records` | Object | Full receipt data |
| `customerName` | String | Customer name |
| `mobile` | long | Mobile number |
| `email` | String | Email |
| `city`, `state`, `pin` | String/int | Customer address |
| `billNumber` | String | Bill number |
| `receiptNumber` | String | Receipt number |
| `amount` | double | Amount paid |
| `billAmount` | double | Monthly bill amount |
| `customNumber` | String | Custom identifier |
| `lco_business_name` | String | LCO name for receipt header |
| `lco_city`, `lco_state`, `lco_pincode` | String | LCO address |
| `last_paid_amt` | double | Previous payment amount |
| `last_paid_date` | String | Previous payment date |
| `collection_employee` | String | Employee name |
| `mode` | String | Payment mode used |
| `format` | String | Bill format |
| `pendingAmount` | double | Remaining outstanding after payment |
| `digi_activation_from` | String | Digital activation trigger |
| `customerBoxList` | Array | Box-level activation details |

### 5. Validation Rules

| Rule | Detail |
|------|--------|
| Amount not zero | Amount field must not be "0.0" |
| Amount vs. pending (userLcoDeposit==0) | Amount less than pending: blocked. Amount greater: confirmation dialog. |
| Amount fixed (userLcoDeposit==1) | Amount field is disabled; only pending amount can be paid |
| Receipt number (AUTO_RECEIPT_NUMBER==0) | Must be selected from range, not empty or "Select" |
| Cheque mode fields | chequeNo, bank, branch, chequeDate all required |
| Cheque date | Must not be before today (validated in DatePickerDialog listener) |
| Voucher code | Must be non-empty |
| Card type | Debit or Credit checkbox must be selected before card payment |
| Network | Connectivity check on load and on each button press |

### 6. Backend Config Values

| Config flag | Source | Effect |
|-------------|--------|--------|
| `AUTO_RECEIPT_NUMBER` | `LoginActivity.AUTO_RECEIPT_NUMBER` (from validateLogin) | `0` = manual receipt from range; `1` = auto-generated by server |
| `userLcoDeposit` | `LoginActivity.userLcoDeposit` | `1` = amount fixed; `0` = amount editable |
| `blockpayment` | From validateLogin response | If set, payment screen entry should be blocked (check in calling screen) |
| `enable_box_wise_payment` | From validateLogin response | Enables per-STB payment workflow |

---

## Screen S02 – Payment History

### 1. Screen Identity

| Property | Value |
|----------|-------|
| **Class** | `PaymentHistory` (Fragment) |
| **Layout** | `fragment_payment_history` |
| **Title** | "Payment History" |
| **Entry** | Receives `custId` (int) and `custname` (String) via Bundle |
| **Purpose** | Display a chronological list of all payments made by a customer, with print and share (PDF) actions per entry. |

### 2. UI Elements

| Widget | ID | Description |
|--------|----|-------------|
| Total Count Label | `payment_total_counts` | "Total Count: N" |
| Payment List | `lv_payments` | ListView using `PaymentAdapter`; each row has print and share icons |

### 3. Actions & Workflows

- On load: executes `getpaymenthistory` async task.
- Print icon: shows confirmation dialog, then either prints via N910 thermal printer (Newland SDK) or sends to `Bluetooth_Fragment` (offline_report=9) for Bluetooth printer.
- Share icon: generates text receipt and calls `PDFTools.showPDFUrl()` to create and share a PDF.

**Print receipt fields:**
Customer Name, Payment Date, Payment ID, Payment Mode, Amount, Receipt No., Remarks.

### 4. API Calls

#### Get Payment History

| Property | Value |
|----------|-------|
| **V2 Endpoint** | `POST /LcoRestServices/PaymentServiceRest` |
| **Android (legacy)** | SOAP method name from `PropertyReader.getProperty("phist")` |

**Request (Invoicedatas model):**

| Field | Type | Value |
|-------|------|-------|
| `authToken` | String | Session token |
| `customer_id` | int | Customer ID (`customerId`) |
| `dealer_id` | int | `LoginActivity.dealerId` |

**Response – `payment_details` array; each entry (Paymenthistorymodel):**

| Field | Type | Description |
|-------|------|-------------|
| `paid_on` | String | Payment date/time |
| `paid_amount` | double | Amount paid |
| `receipt_no` | String | Receipt number |
| `payment_mode` | String | Cash/Bank/Card/etc. |
| `payment_id` | int | Unique payment record ID |
| `remarks` | String | Payment remarks |

### 5. Response Handling

- `statusCode == 0`: Populate `paymenthistorymodelArrayList` from `payment_details` elements; bind to adapter.
- `statusCode == 1`: Toast with statusMessage.
- `statusCode == 2`: Toast "Contact Support".
- `response == null`: Dialog "Server busy or unreachable".

---

## Screen S03 – Invoice History

### 1. Screen Identity

| Property | Value |
|----------|-------|
| **Class** | `InvoiceHistory` (Fragment) |
| **Layout** | `fragment_invoice_history` |
| **Entry** | Receives `custId` (int) and `custname` (String) via Bundle |
| **Purpose** | Display list of generated invoices/bills for a customer, with STB serial and VC number display. |

### 2. UI Elements

| Widget | ID | Description |
|--------|----|-------------|
| Total Count | `invoice_total_counts` | Count label |
| Serial Number | `invoice_serial_num` | STB serial (from bundle or response) |
| VC Number | `invoice_vc_num` | VC/MAC number |
| Invoice List | `lv_invoice` | ListView using `InvoiceAdapter` |

### 3. API Calls

#### Get Invoice History

| Property | Value |
|----------|-------|
| **V2 Endpoint** | `POST /LcoRestServices/InvoiceServiceRest` |
| **Android (legacy)** | SOAP method from `PropertyReader.getProperty("invhist")` |

**Request (Invoicedatas model):**

| Field | Type | Value |
|-------|------|-------|
| `authToken` | String | Session token |
| `customer_id` | int | Customer ID |
| `dealer_id` | int | `LoginActivity.dealerId` |

**Response – `invoice_details` array; each entry (Invoiceresult model):**

| Field | Type | Description |
|-------|------|-------------|
| `billing_id` | int | Invoice number |
| `bill_date` | String | Invoice generated date |
| `due_date` | String | Payment due date |
| `total_amount` | double | Total bill amount |
| `quantity` | int | Number of STBs |
| `base_price` | double | Base subscription price |
| `serial_number` | String | STB serial number |
| `mac_vc_number` | String | VC/MAC address |
| `pname` | String | Package name |
| `setup_price` | double | Setup/activation charge |
| `tax_amount` | double | GST/tax |
| `pending_amount` | double | Amount still outstanding |
| `discount_amount` | double | Discount applied |
| `is_adhoc` | int | 0=regular, 1=adhoc bill |

**Print receipt fields:** Customer Name, Invoice Number, Invoice Date, Due Date, Base Price, Setup Price, Tax Amount, Pending Amount, Discount Amount, Total Amount, Adhoc Bills (Yes/No).

---

## Screen S04 – LCO Payment (MSO-to-LCO)

### 1. Screen Identity

| Property | Value |
|----------|-------|
| **Class** | `LCO_Payment_Fragment` (Fragment) |
| **Layout** | `lco_payment_fragment` |
| **Purpose** | MSO/distributor employee records a cash or cheque payment made by/to an LCO. Supports adjustment entries (debit/credit). |

### 2. UI Elements

**Phase 1 – LCO Search:**

| Widget | ID | Description |
|--------|----|-------------|
| LCO Code | `lcopayments_lcocode` | EditText – LCO dealer code |
| Search Button | `lcopayments_searchBtn` | Triggers `LcoCode_Search` async task |

**Phase 2 – Payment Form (visible after search):**

| Widget | ID | Description |
|--------|----|-------------|
| Advance Display | `lcopayments_advancepayments_tv` | Shows current advance balance |
| Due Display | `lcopayments_due_tv` | Shows current due; pre-fills amount field |
| Amount | `lcopayments_amount` | EditText – payment amount |
| Payment Mode | `lcopayments_paymentmode_sp` | Spinner: CASH (mode=1), BANK (mode=2) |
| Receipt Number | `lcopayments_receiptnumber` | EditText |
| Remarks | `lcopayments_remarks` | EditText (required) |
| Is Adjustment | `lcopayments_adjustment_chkbox` | CheckBox; shows Credit/Debit spinner when checked |
| Credit/Debit | `lcopayments_credit_debit_sp` | Spinner: CREDIT (0), DEBIT (1) |
| Is Accepted | `lcopayments_isaccepted_chk` | CheckBox; only relevant for Bank mode |
| Cheque No | `lcopayments_chequeno` | EditText – Bank mode |
| Bank Name | `lcopayments_bankname` | EditText – Bank mode |
| Branch | `lcopayments_branch` | EditText – Bank mode |
| Cheque Date | `lcopayments_chequedate` | Button (DatePickerDialog) – Bank mode |
| Save Button | `lcopayments_savepayments` | Executes `Lcopaymentfunc` async task |

### 3. Actions & Workflows

```
1. User enters LCO code → Search → LcoCode_Search SOAP call.
   Response populates: employee_id, dealer_id, billing_id, advance, due, bill_amount, tds_deduction.
2. User fills payment form.
3. Validation:
   - Amount must be non-empty.
   - Remarks must be non-empty.
   - Bank mode: chequenum, bank, branch, cheqDate all required.
4. Executes Lcopaymentfunc SOAP call.
5. On success: alertforSuccess dialog.
6. On failure: alertforFaliure dialog.
```

### 4. API Calls

#### 4.1 LCO Code Search

| Property | Value |
|----------|-------|
| **Legacy SOAP** | `getlcoadvanceamountdue` (hardcoded constant) |
| **V2 REST equivalent** | Check REST API doc for LCO advance amount endpoint |

**Request (LCOcode_Search_Model):**

| Field | Value |
|-------|-------|
| `authToken` | Session token |
| `lco_code` | LCO dealer code entered |

**Response fields:** `employee_id`, `dealer_id`, `billing_id`, `advance`, `due`, `bill_amount`, `tds_deduction`

#### 4.2 LCO Payment

| Property | Value |
|----------|-------|
| **Legacy SOAP** | `lcopaymentfunc` (hardcoded constant) |

**Request (LcoPayment_Model) – 14 fields:**

| Field | Type | Description |
|-------|------|-------------|
| `authToken` | String | Session token |
| `lco_employee_id` | String | Employee ID from LCO search |
| `lco_billing_id` | String | Billing ID from LCO search |
| `amount` | String | Payment amount |
| `mode` | String | "1"=Cash, "2"=Bank |
| `receipt_number` | String | Manual receipt number |
| `adjust_flag` | String | "1" if adjustment, "0" otherwise |
| `dabit_credit` | String | "0"=Credit, "1"=Debit (when adjust_flag="1") |
| `accept` | String | "1" if accepted (Bank mode, checkbox ticked) |
| `chequeddnumber` | String | Cheque number (Bank mode) |
| `chequeDate` | String | Cheque date yyyy-MM-dd (Bank mode) |
| `bank` | String | Bank name (Bank mode) |
| `branch` | String | Branch (Bank mode) |
| `remarks` | String | Free text remarks (required) |

---

## Screen S05 – LCO Wallet Top-up

### 1. Screen Identity

| Property | Value |
|----------|-------|
| **Class** | `LcoTopupFragment` (Fragment) |
| **Layout** | `fragment_lco_topup` |
| **Purpose** | Allow LCO to top up their wallet via an online payment gateway (Paytm/UPI via WebView). |

### 2. UI Elements

| Widget | ID | Description |
|--------|----|-------------|
| LCO Name | `tv_lco_name` | Displays `LoginActivity.user` |
| Current Wallet Balance | `tv_wallet_amount` | Displays `Dashboard_Fragment.lco_deposit_amount` with currency sign |
| Amount | `lcopayments_amount` | EditText – amount to top up |
| Pay Now Button | `btn_paynow` | Navigates to `Payment_Webview_Frag` |

### 3. Actions & Workflows

```
1. User enters amount > 0.
2. On Pay Now: navigate to Payment_Webview_Frag with bundle key "gzs" = amount string.
3. Payment_Webview_Frag posts to the payment gateway WebView URL.
4. On completion: redirect URL detected → navigate to PaymentResponseActivity.
```

**Static field:** `LcoTopupFragment.tokennumber` (public static String) – used by BilldeskPaymentActivity to construct the PG message token.

---

## Screen S06 – LCO Wallet History

### 1. Screen Identity

| Property | Value |
|----------|-------|
| **Class** | `LcoWalletHistory` (Fragment) |
| **Layout** | `fragment_lwo_wallet_history` |
| **Purpose** | Display ledger of LCO wallet credits and debits for a selected date range. |

### 2. UI Elements

| Widget | ID | Description |
|--------|----|-------------|
| Total Count | `payment_total_counts` | Count label |
| Wallet Entries List | `lv_payments` | ListView using `LcowalletAdapter` |

### 3. Actions & Workflows

- Receives data as a `Parcelable ArrayList<Lcowalletmodel>` via Bundle key `"lcowalletres"`, and date strings `"fromDate"` and `"toDate"`.
- Data is fetched by the calling screen (Dashboard/Reports) before navigation.
- No API call in this fragment itself; it is a display-only screen.

### 4. Data Model – Lcowalletmodel Fields

| Field | Description |
|-------|-------------|
| `Deposit_Date` | Transaction date |
| `business_name` | LCO business name |
| `payment_mode` | Mode of transaction |
| `cheque_ddnumber` | Cheque/DD number if applicable |
| `bank` | Bank name |
| `branch` | Branch |
| `instrument_date` | Cheque instrument date |
| `credit_amount` | Credit entry amount |
| `debit_amount` | Debit entry amount |
| `transaction_no` | Transaction reference |
| `receipt_no` | Receipt number |
| `Remarks` | Remarks |
| `Deposited_By` | Employee who recorded |
| `deposite_amount` | Total deposit amount |

### 5. API Call (by calling screen)

| Property | Value |
|----------|-------|
| **V2 Endpoint** | `POST /LcoRestServices/getlcowalletRest` |
| **Request params** | `start_date`, `end_date`, `dealer_id` |
| **Response** | `status_code`, `status_msg`, `paymentresult` (JSON array of wallet entries) |

---

## Screen S07 – PG Transaction Report

### 1. Screen Identity

| Property | Value |
|----------|-------|
| **Class** | `PG_Transaction_Frag` (Fragment) |
| **Layout** | `fragment_pg_transaction` |
| **Purpose** | View PG (payment gateway) transaction logs with status filtering. |

### 2. UI Elements

| Widget | ID | Description |
|--------|----|-------------|
| Total Count | `pgtrans_total_counts` | "Total Count: N" |
| Status Filter | `pg_spinner` | Spinner: All / Success / Fail |
| Transaction List | `lv_pgtransactions` | ListView using `PgTransactionReportAdapter` |

### 3. Actions & Workflows

```
1. On spinner selection (including initial "All"):
   - Call getpgtransactionreport(item) via Volley POST.
   - status filter mapping: "All" → payment_status="-1", "Success" → "1", "Fail" → "2".
2. Parse JSON array; populate PgTransactionReportModel list.
3. Bind adapter.
4. On list item click: (adapter handles navigation to detail screen).
```

### 4. API Calls

#### PG Transaction Logs

| Property | Value |
|----------|-------|
| **V2 Endpoint** | `POST /LcoRestServices/pgTransactionLogs` |
| **Android URL** | `Urll + PropertyReader.getProperty("pgtl")` |

**Request parameters (POST body):**

| Field | Type | Value |
|-------|------|-------|
| `authtoken` | String | Session token |
| `dealer_id` | String | `LoginActivity.dealerId` |
| `payment_status` | String | "-1"=All, "1"=Success, "2"=Failed |

**Response:**

```json
{
  "status_code": 0,
  "status_msg": "Success",
  "paymentresult": [
    {
      "paymentid": 123,
      "paydate": "2024-01-15",
      "amount": "500.00",
      "transactionno": "TXN123456",
      "mode": "UPI",
      "transaction_id": "PG_TXN_ID",
      "status": "success",
      "responsemsg": "Transaction successful",
      "transaction_type": "SALE",
      "displayname": "Customer Display Name",
      "createddate": "2024-01-15 10:30:00",
      "tries": "1",
      "distributor_code": "DIST001",
      "subdistributor_code": "SUB001",
      "name": "Customer Name",
      "code": "CUST001",
      "lco_code": "LCO001",
      "business_name": "Business Name",
      "mobile_no": "9876543210",
      "email": "user@example.com"
    }
  ]
}
```

### 5. Data Model – PgTransactionReportModel Fields

| Field | Description |
|-------|-------------|
| `paymentid` | Internal payment record ID |
| `paydate` | Payment date |
| `amount` | Transaction amount |
| `transactionno` | PG transaction reference number |
| `mode` | Payment mode (UPI, Card, etc.) |
| `transaction_id` | PG-assigned transaction ID (may be "NA") |
| `status` | "success", "fail", etc. (null → "NA") |
| `responsemsg` | Gateway response message |
| `transaction_type` | SALE, REFUND, etc. |
| `displayname` | Customer display name |
| `createddate` | Record creation timestamp |
| `tries` | Number of attempts |
| `distributor_code` | Distributor identifier |
| `subdistributor_code` | Sub-distributor identifier |
| `name` | LCO name |
| `code` | LCO code |
| `lco_code` | LCO unique code |
| `business_name` | LCO business name |
| `mobile_no` | LCO mobile number |
| `email` | LCO email |

---

## Screen S08 – Billdesk Payment Activity

### 1. Screen Identity

| Property | Value |
|----------|-------|
| **Class** | `BilldeskPaymentActivity` (AppCompatActivity) |
| **Layout** | `activity_billdesk_payment` |
| **Purpose** | Initiate a Billdesk PG payment using the Billdesk Android SDK for LCO wallet top-up. |

### 2. UI Elements

| Widget | ID | Description |
|--------|----|-------------|
| Customer/LCO Name | `billdesk_tv_custname` | `LoginActivity.login_username` |
| Amount | `billdesk_tv_pendamunt` | Float amount from intent extra |
| Pay Now Button | `btnPayNow` | Triggers Billdesk SDK intent |

### 3. Billdesk PG Integration Flow

```
1. Activity receives: amount (float) from Intent extra "amount".
2. Constructs strPGMsg (pipe-delimited Billdesk message string):
   Format: "MERCHANTID|ORDERID|NA|AMOUNT|NA|NA|NA|INR|NA|R|SECURITYID|NA|NA|F|NA|...|RETURNURL|CHECKSUM"
   - MERCHANTID: "AIRMTST" (currently hardcoded UAT value)
   - ORDERID: Constructed from ARP prefix + timestamp (currently static demo value)
   - AMOUNT: floor(amount) as string
   - RETURNURL: "https://uat.billdesk.com/pgidsk/pgmerc/pg_dump.jsp" (UAT)
3. Optional: strTokenMsg for enhanced security token flow.
4. On Pay Now:
   - Creates SampleCallBack (implements LibraryPaymentStatusProtocol, Parcelable).
   - Builds Intent for PaymentOptions.class (Billdesk SDK activity).
   - Extras: "msg"=strPGMsg, "token"=strTokenMsg (if token longer than msg),
             "user-email"="test@bd.com", "user-mobile"=LoginActivity.lcoMobileNo,
             "callback"=SampleCallBack instance.
   - startActivity(sdkIntent).
```

**Production migration note:** The hardcoded UAT merchant ID, order ID, and return URL must be replaced with server-generated values from a backend API call before PG invocation.

### 4. Static Fields

| Field | Type | Description |
|-------|------|-------------|
| `BilldeskPaymentActivity.amount` | float | Payment amount (static, set on entry) |
| `BilldeskPaymentActivity.amt` | String | Floor integer amount as string |
| `BilldeskPaymentActivity.altcustid` | int | Customer ID (static) |
| `BilldeskPaymentActivity.billingid` | String | Billing ID (static) |

---

## Screen S09 – Payment WebView (Paytm/UPI Gateway)

### 1. Screen Identity

| Property | Value |
|----------|-------|
| **Class** | `Payment_Webview_Frag` (Fragment) |
| **Layout** | `fragment_payment_webview` |
| **Purpose** | Load the server-hosted payment gateway page in an embedded WebView for LCO wallet top-up via Paytm or UPI. |

### 2. WebView Configuration

```java
mWebViewDemo.getSettings().setJavaScriptEnabled(true);
mWebViewDemo.addJavascriptInterface(new PaytmJavaScriptInterface(), "checkoutUpiIntent");
mWebViewDemo.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
```

### 3. POST Parameters

The WebView is loaded via `mWebViewDemo.postUrl(url, postData.getBytes())`:

| Parameter | Value | Description |
|-----------|-------|-------------|
| `auth_key` | `"abcd1234abcd"` | Hardcoded auth key |
| `employee_id` | `LoginActivity.employeeId` | Logged-in employee |
| `dealer_id` | `LoginActivity.dealerId` | LCO dealer ID |
| `customer_id` | `"0"` | Always 0 for wallet top-up |
| `amount` | `gzs` | Amount from bundle key "gzs" |
| `from_mobile_app` | `"0"` | Mobile app flag |

**URL source:** `Urll + PropertyReader.getProperty("payweb")` where `Urll` = base URL with `/wsController` stripped.

### 4. URL Interception & Callback

```
shouldOverrideUrlLoading:
  - If url starts with "upi://pay": parse as UPI intent, launch chooser dialog.
  - Else: call movetofrst(url).

movetofrst(url):
  - If url == Urll + "/paymentgateway/mobile_paymentsend":
      Start PaymentResponseActivity.
      Finish current activity.

onPageFinished:
  - Dismiss progress dialog.
```

### 5. Back Navigation

Back key is blocked in this fragment. A Toast "Cannot go back!" is shown. This prevents accidental navigation away mid-transaction.

---

## Screen S10 – Payment Response

### 1. Screen Identity

| Property | Value |
|----------|-------|
| **Class** | `PaymentResponseActivity` (AppCompatActivity) |
| **Layout** | `activity_payment_response` |
| **Purpose** | Display the outcome of a PG (Paytm/UPI) payment transaction after WebView redirect completes. |

### 2. UI Elements

| Widget | ID | Description |
|--------|----|-------------|
| Status Icon | `igv_sf` | Success or fail drawable image |
| Status Text | `tv_status` | "Success" or "Fail" |
| Reference/Message | `tv_refid` | Transaction details or failure reason |
| Customer Name | `tv_names` | `first_name + last_name` |
| Transaction ID | `tv_transacid` | PG transaction reference number |
| Paid Amount | `tv_paidamount` | Amount with currency symbol |
| Back Button | `btn_backtodash` | Navigate to dashboard (success) or back to payment (fail) |

### 3. API Call

#### Customer Transaction Response

| Property | Value |
|----------|-------|
| **V2 Endpoint** | `POST /LcoRestServices/customer_transaction_reponseRest` |
| **Android URL** | `Urll + PropertyReader.getProperty("ctransac")` |
| **HTTP Method** | POST (JsonObjectRequest) |

**Request parameters:**

| Field | Type | Value |
|-------|------|-------|
| `employee_id` | String | `LoginActivity.employeeId` |
| `dealer_id` | String | `LoginActivity.dealerId` |
| `customer_id` | String | `"0"` (wallet top-up) |
| `auth_key` | String | `"abcd1234abcd"` |

**Response:**

| Field | Type | Description |
|-------|------|-------------|
| `status_code` | int | 0=found, 1=not found, >1=error |
| `status_msg` | String | Status message |
| `response_details` | String (JSON) | Nested JSON with transaction details |

**Nested `response_details` fields:**

| Field | Description |
|-------|-------------|
| `transactionno` | PG transaction reference |
| `responsemsg` | Gateway response message |
| `amount` | Amount processed |
| `status` | "TXN_SUCCESS", "success", "Txn Success" = successful; others = failed |
| `first_name` | Customer first name |
| `last_name` | Customer last name |

### 4. Response Handling

| Status value | Action |
|-------------|--------|
| "TXN_SUCCESS" / "success" / "Txn Success" | Show success icon, show reference/amount, Back button goes to Dashboard |
| Any other status | Show fail icon, show failure reason, Back button relabeled "Back to Payment" (goes to LcoTopup) |
| `status_code == 1` | "No Details Found" dialog; navigate to LcoTopup screen |
| `status_code > 1` | "Connectivity Error" dialog |

### 5. Back Press

Back press is blocked (`onBackPressed` shows Toast). User must use the on-screen button.

---

## Screen S11 – Payment Transaction (Payswiff POS)

### 1. Screen Identity

| Property | Value |
|----------|-------|
| **Classes** | `PaymentTransactionActivity` (Activity), `PaymenttransacFragment` (Fragment) |
| **Purpose** | Initiate a card payment via the Payswiff hardware POS terminal using Bluetooth connection. |
| **SDK** | `com.pnsol.sdk` (Payswiff SDK) – `PaymentInitialization`, `PaymentTransactionConstants`, `TransactionVO` |

### 2. Transaction Flow

```
1. Entry: receives amount, custID, billingId, PAYMENT_TYPE (SALE), referanceno, mobile from Bundle.
2. If merchantRefNo is null/empty: set to System.currentTimeMillis() string.
3. initiateConnection():
   - Creates PaymentInitialization(context).
   - Calls initialization.initiateTransaction(handler, DeviceType.N910, ...).
4. Handler receives message codes:
   - 1008 / 1010: SOCKET NOT CONNECTED / NO CARD IN SLOT → navigate to ConnectionDevice activity.
   - 1009: SOCKET CONNECTED.
   - 1001 / 1003 (CHIP/SWIPE APPROVED): navigate to TransactionDetails activity.
   - 1002 / 1004 (CHIP/SWIPE DECLINED): navigate to TransactionDetailsDeclined activity.
   - 1005: TRANSACTION NOT STARTED.
   - Additional codes handled per PaymentTransactionConstants.
5. Extras forwarded to next screen:
   custName, custID, pendingamount, amount, origin, billingId, remarks, mobile, cardtype, TransactionVO object.
```

### 3. Payswiff Fragment vs. Activity

- `PaymenttransacFragment`: Same flow as Activity but as a Fragment within `MainActivity`; Newland N910 device context.
- `PaymentTransaction_frag_payswiff`: Newer fragment variant; uses same Payswiff SDK; adds GPS location tracking; handles `ICCTransactionResponse`.

---

## Screen S12 – Display Payment Details (Receipt)

### 1. Screen Identity

| Property | Value |
|----------|-------|
| **Class** | `DisplayPaymentDetails_Fragment2` (AppCompatActivity) |
| **Layout** | `paymentdetails2` |
| **Title** | "Payment Details" |
| **Purpose** | Show payment receipt after successful cash/cheque payment. Supports thermal print (N910) and Bluetooth print. |

### 2. UI Elements

| Widget | Field displayed |
|--------|----------------|
| `paydetails_tv_custname` | Customer Name |
| `paydetails_tv_custid` | Customer ID |
| `paydetails_tv_mobileno` | Mobile Number |
| `paydetails_tv_custadd` | Customer Address (city, state, pin) |
| `paydetails_tv_receiptno` | Receipt Number |
| `paydetails_tv_dueamt` | Due Amount (with currency symbol) |
| `paydetails_tv_paidamt` | Paid Amount (formatted to 2dp) |

### 3. Data Received (via Intent extras)

| Extra key | Type | Source |
|-----------|------|--------|
| `custName` | String | From makePayments response |
| `custID` | String | altCustId |
| `mobileNo` | long | mobile field |
| `custAddress` | String | city + ", " + state + ", " + pin |
| `recieptNo` | String | receiptNumber |
| `billAmt` | double | billAmount |
| `dueAmt` | double | pendingAmount |
| `paidAmt` | double | paidAmount |
| `outAmt` | double | outstanding |
| `CustomNo` | String | customNumber |
| `lcoName` | String | lco_business_name |
| `lcoAddress` | String | lco_city + ", " + lco_state + ", " + lco_pincode |
| `lastpaidAmt` | double | last_paid_amt |
| `lastpaidDate` | String | last_paid_date |
| `collEmp` | String | collection_employee |
| `mode` | String | payment mode |
| `format` | String | bill format |
| `finalpending` | String | remaining pending after payment |
| `AmountName`, `CardHodlerName`, `RRN`, `TransactionId` | String | Card-specific fields (Payswiff) |
| `paymodes` | Boolean | true = card payment |

---

## Screen S13 – Transaction Details (Card Approved)

### 1. Screen Identity

| Property | Value |
|----------|-------|
| **Class** | `TransactionDetails` (AppCompatActivity) |
| **Purpose** | After Payswiff card approval, display transaction result and call `makePayments` SOAP to record the payment server-side. |

### 2. API Call

| Property | Value |
|----------|-------|
| **Legacy SOAP** | `makePayments` (hardcoded constant `PAY_SOAP_ACTION = NAMESPACE + "/makePayments"`) |
| **V2 Equivalent** | `POST /LcoRestServices/makePaymentsRest` |

**Additional card-specific fields passed to makePaymentsInfo:**

| Field | Source |
|-------|--------|
| `modeType` | `"card"` |
| `rrnNo` | From `TransactionVO.getHostResponse().getRrn()` |
| `cardholderName` | From `TransactionVO.getCardHolderName()` |

Key Payswiff TransactionVO fields extracted:
- `authcode`, `bankmerchantid`, `bankterminalid`, `batchno`, `cardholdername`, `cardnumber`, `date`, `invoiceno`, `rrn`, `transactiontype`, `cardexpiry`

---

## Screen S14 – Transaction Details Declined

### 1. Screen Identity

| Property | Value |
|----------|-------|
| **Class** | `TransactionDetailsDeclined` (AppCompatActivity) |
| **Purpose** | Display declined card transaction message; no makePayments call made. Option to retry. |

---

## Screen S15 – Payswiff Account Activation

### 1. Screen Identity

| Property | Value |
|----------|-------|
| **Class** | `AccountActivation_fgrag_payswiff` (Fragment) |
| **Layout** | `fragment_account_activation_fgrag_payswiff` |
| **Purpose** | Activate the Payswiff merchant account on the device using merchant key + partner API key. Required before first card transaction on N910 device. |

### 2. UI Elements

| Widget | ID | Description |
|--------|----|-------------|
| Merchant Key | `merchantKey` | EditText – 12-character key |
| Partner Key | `partnerkey` | EditText – hardcoded default `"2016665A802D"` |
| Activate Button | `activate_btn` | Calls `AccountValidator.accountActivation(handler, mkey, pkey)` |

### 3. SDK Call

```java
AccountValidator validator = new AccountValidator(getContext());
validator.accountActivation(handler, merchantKey, partnerKey);
```

Handler receives activation success/failure. On success, navigates to payment fragment.

---

## Screen S16 – Payswiff Payment Transaction Fragment

| Property | Value |
|----------|-------|
| **Class** | `PaymentTransaction_frag_payswiff` (Fragment) |
| **Purpose** | Newer Payswiff transaction fragment; handles ICCTransactionResponse, includes GPS tracking, used on N910 device. |
| **Difference from S11** | Uses `ICCTransactionResponse` instead of `TransactionVO`; passes `deviceSerial`, `deviceName`, `deviceMACAddress` params. |

---

## Screen S17 – Payswiff Transaction Details Fragment

| Property | Value |
|----------|-------|
| **Class** | `TransactionDetails_Frag_payswiff` (Fragment) |
| **Purpose** | Fragment version of TransactionDetails for Payswiff; after card approval calls `makePayments` SOAP (or V2 equivalent) and displays receipt. |
| **Extra fields** | `boxnumber`, `vcNumber`, `crf` (CRF number), `address` passed for receipt printing. |

Uses `POSReceipt` and `TransactionStatusResponse` from Payswiff SDK for enhanced receipt data.

---

## Screen S18 – Billdesk SampleCallBack Handler

### 1. Screen Identity

| Property | Value |
|----------|-------|
| **Class** | `SampleCallBack` (implements `LibraryPaymentStatusProtocol`, `Parcelable`) |
| **Purpose** | Callback handler registered with Billdesk SDK. Receives payment outcome from `PaymentOptions` activity. |

### 2. Callback Methods

| Method | Behavior |
|--------|----------|
| `paymentStatus(String status, Activity context)` | Shows Toast with PG response; starts `StatusActivity` with `status` extra; finishes calling activity. |
| `tryAgain()` | Logged only; no navigation. |
| `onError(Exception e)` | Logged only. |
| `cancelTransaction()` | Logged only. |

**Note:** `StatusActivity` (not in the analysed file list) receives the raw Billdesk status string and must handle final reconciliation.

---

## Backend Config Flags Reference

These flags are returned in the `validateLogin` response and govern payment screen behaviour:

| Flag | Type | Location | Effect on Payment Screens |
|------|------|----------|---------------------------|
| `AUTO_RECEIPT_NUMBER` | int | `LoginActivity.AUTO_RECEIPT_NUMBER` | `0` = manual receipt from range (show range picker, call getReceiptRanges); `1` = server auto-generates receipt (hide picker) |
| `blockpayment` | String | `LoginActivity` / session | Non-empty = payment is blocked for this LCO; calling screen should prevent navigation to Make Payment |
| `enable_box_wise_payment` | String | Login response | Enables box-level (per-STB) payment instead of customer-level; affects makePaymentsRest payload |
| `useLcoDeposit` / `userLcoDeposit` | int | `LoginActivity.userLcoDeposit` | `1` = amount field locked to pending amount; no excess-amount dialog |
| `use_lco_deposits` | String | Login response | Dashboard and collection flags for deposit-based billing |
| `allow_top_up` | String | Login response | Show/hide LCO wallet top-up menu item |
| `lco_billtype` | String | Login response | Bill calculation type for LCO |
| `customer_billtype` | String | Login response | Bill type for customer billing |

---

## Payment Mode Field Matrix

Summary of which form fields are shown per payment mode:

| Field | Cash | Bank | Card | Voucher | UPI Payment |
|-------|------|------|------|---------|-------------|
| Amount | Yes | Yes | Yes | No | Yes |
| Receipt Number | Yes (if AUTO_RECEIPT_NUMBER==1) | No | No | No | Yes |
| Receipt Range Picker | Yes (if AUTO_RECEIPT_NUMBER==0) | No | No | No | No |
| Cheque/DD Number | No | Yes | No | No | No |
| Bank Name | No | Yes | No | No | No |
| Branch | No | Yes | No | No | No |
| Cheque Date | No | Yes | No | No | No |
| Voucher Code | No | No | No | Yes | No |
| Card Type (Debit/Credit) | No | No | Yes | No | No |
| QR Code Image | No | No | No | No | Yes |
| Remarks | Yes | Yes | Yes | Yes | Yes |
| Pay (Cash) Button | Yes | Yes | No | Yes | Yes |
| Pay by Card Button | No | No | Yes | No | No |

---

## Complete V2 REST API Reference – Payments Domain

All endpoints use base URL: `POST {BASE_URL}/LcoRestServices/{endpoint}`

### Payment Endpoints Summary

| # | Endpoint | Method | Purpose |
|---|----------|--------|---------|
| 4.1 | `getPendingAmountRest` | POST | Fetch pending amount for a customer |
| 4.2 | `makePaymentsRest` | POST | Record a payment |
| 4.3 | `getPaymentModesRest` | POST | Fetch available payment modes |
| 4.4 | `getReceiptRanges` | POST | Fetch receipt number ranges for manual entry |
| 4.5 | `getbilldetailsRest` | POST | Box-level bill details (box-wise payment) |
| 4.6 | `pgTransactionLogs` | POST | PG transaction history with status filter |
| 4.7 | `PaymentServiceRest` | POST | Customer payment history |
| 4.8 | `customer_transaction_reponseRest` | POST | Latest PG transaction outcome |

---

### 4.1 getPendingAmountRest

**Endpoint:** `POST /LcoRestServices/getPendingAmountRest`

| Request Field | Type | Required | Description |
|---------------|------|----------|-------------|
| `altCustomerId` | int | Yes | Customer alternate ID |
| `serial_no` | String | No | STB serial (for box-wise payment) |

| Response Field | Type | Description |
|----------------|------|-------------|
| `status_code` | int | 0=success |
| `status_msg` | String | Message |
| `customerName` | String | Customer full name |
| `pendingAmount` | double | Total outstanding |
| `msoShare` | double | MSO portion of pending |
| `lcoShare` | double | LCO portion of pending |
| `mobileNumber` | long | Customer mobile |
| `billingId` | int | Current billing record ID |
| `paymentModesList` | Array | Available payment modes |

---

### 4.2 makePaymentsRest

**Endpoint:** `POST /LcoRestServices/makePaymentsRest`

| Request Field | Type | Required | Notes |
|---------------|------|----------|-------|
| `altCustomerId` | int | Yes | Customer ID |
| `authToken` | String | Yes | Session JWT |
| `amount` | double | Yes | Payment amount (0 for voucher) |
| `billingId` | int | Yes | From getPendingAmountRest |
| `modeType` | String | Yes | "cash", "bank", "card", "voucher" |
| `remarks` | String | Yes | Free text; always append ". Paid From Android App" |
| `imei` | String | Yes | Device IMEI |
| `receipt_number` | String | Conditional | Required when AUTO_RECEIPT_NUMBER==0 |
| `altReceiptNumber` | String | No | Alternate receipt number |
| `chequeNo` | String | Bank | Cheque or DD number |
| `bank` | String | Bank | Bank name |
| `branch` | String | Bank | Branch name |
| `chequeDate` | String | Bank | yyyy-MM-dd; "0000-00-00" if not selected |
| `voucherCode` | String | Voucher | Voucher code |
| `rrnNo` | String | Card | POS RRN |
| `cardholderName` | String | Card | Cardholder name from POS |

| Response Field | Type | Description |
|----------------|------|-------------|
| `status_code` | int | 0=success |
| `status_msg` / `statusMessage` | String | "Payment successful." on success |
| `receipt_number` | String | Server-generated receipt number |
| `payment_records` | Object | Full receipt data object |
| `customerBoxList` | Array | Per-box activation info |
| `digi_activation_from` | String | Digital activation trigger (if applicable) |
| `digi_key` | String | Digital activation key |
| `use_lco_deposit` | String | LCO deposit flag |
| `voucherCode` | String | Validated voucher code (voucher mode) |
| `error_msg` | String | Specific error detail on failure |

---

### 4.3 getPaymentModesRest

**Endpoint:** `POST /LcoRestServices/getPaymentModesRest`

| Request Field | Type | Required |
|---------------|------|----------|
| (none beyond auth) | — | — |

| Response Field | Type | Description |
|----------------|------|-------------|
| `paymentModesList` | Array | Each item: `{ paymentModeId: int, PaymentModeName: String }` |
| `status_msg` | String | Status message |

**Known mode names:** Cash, Bank, Card, Voucher, UPI Payment, Online, Online Transfer

---

### 4.4 getReceiptRanges

**Endpoint:** `POST /LcoRestServices/getReceiptRanges`

| Request Field | Type |
|---------------|------|
| `authtoken` | String |
| `dealer_id` | int |

| Response Field | Type | Description |
|----------------|------|-------------|
| `status_code` | int | 0=success |
| `status_msg` | String | Message |
| `ReceiptRanges` | Array | Array of receipt number strings |

---

### 4.5 getbilldetailsRest (Box-wise Payment)

**Endpoint:** `POST /LcoRestServices/getbilldetailsRest`

| Request Field | Type | Description |
|---------------|------|-------------|
| `serial_number` | String | STB serial |
| `package_id` | int | Package ID |
| `bill_type` | String | Bill type |
| `customer_id` | int | Customer ID |
| `employee_id` | int | Employee ID |

| Response Field | Type | Description |
|----------------|------|-------------|
| `arr_box_details` | Array | Per-box billing details |
| `arr_act_package_details` | Array | Package details |
| `tax_amount` | double | Tax applicable |
| `dealer_id` | int | Dealer ID |
| `array_dealer_setting` | Object | Dealer configuration |
| `ENABLE_PRORATA_DISCOUNT` | String | Pro-rata discount flag |

---

### 4.6 pgTransactionLogs

**Endpoint:** `POST /LcoRestServices/pgTransactionLogs`

| Request Field | Type | Description |
|---------------|------|-------------|
| `authtoken` | String | Session token |
| `dealer_id` | String | Dealer ID |
| `payment_status` | String | "-1"=All, "1"=Success, "2"=Failed |
| `start_date` | String | Filter start (optional) |
| `end_date` | String | Filter end (optional) |

Response: `paymentresult` array (see PgTransactionReportModel fields in Screen S07).

---

### 4.7 PaymentServiceRest (Payment History)

**Endpoint:** `POST /LcoRestServices/PaymentServiceRest`

| Request Field | Type | Description |
|---------------|------|-------------|
| `dealer_id` | int | Dealer ID |
| `customer_id` | int | Customer ID |

Response: `payment_details` array (see Paymenthistorymodel fields in Screen S02).

---

### 4.8 customer_transaction_reponseRest

**Endpoint:** `POST /LcoRestServices/customer_transaction_reponseRest`

| Request Field | Type | Description |
|---------------|------|-------------|
| `employee_id` | int | Employee ID |
| `dealer_id` | int | Dealer ID |
| `auth_key` | String | `"abcd1234abcd"` (static key) |

Response: `response_details` nested JSON (see Screen S10 for field list).

---

### 4.x InvoiceServiceRest (Invoice History)

**Endpoint:** `POST /LcoRestServices/InvoiceServiceRest`

| Request Field | Type | Description |
|---------------|------|-------------|
| `dealer_id` | int | Dealer ID |
| `customer_id` | int | Customer ID |

Response: `invoice_details` array (see Invoiceresult model fields in Screen S03).

---

### 4.x getlcowalletRest (LCO Wallet History)

**Endpoint:** `POST /LcoRestServices/getlcowalletRest`

| Request Field | Type | Description |
|---------------|------|-------------|
| `start_date` | String | Filter from date |
| `end_date` | String | Filter to date |
| `dealer_id` | int | Dealer ID |

Response: `paymentresult` array (see Lcowalletmodel fields in Screen S06).

---

## Flutter Migration Notes

### Critical Implementation Points

1. **Receipt Number Logic:** Check `AUTO_RECEIPT_NUMBER` from login response. If `0`: fetch ranges from `getReceiptRanges`, show a searchable picker dialog. If `1`: no receipt field needed on form; server auto-assigns.

2. **Amount Validation:** When `userLcoDeposit == 0` (from login `useLcoDeposit` field): enforce that entered amount >= pending amount. If greater: show confirmation dialog. If `userLcoDeposit == 1`: disable amount field; use pending amount as-is.

3. **Payment Mode Spinner:** Always fetch from `getPaymentModesRest`. Do not hardcode mode names. Mode name matching is case-insensitive (equalsIgnoreCase used throughout Android code).

4. **Cheque Date Validation:** Date selected must be >= today. Use server format `yyyy-MM-dd`. If no date selected, send `"0000-00-00"`.

5. **Remarks Field:** Always append `". Paid From Android App"` (or Flutter equivalent) to user-typed remarks.

6. **blockpayment Flag:** From login response. If non-empty, disable or hide the Make Payment option in the customer management menu.

7. **Billdesk PG:** Currently UAT/test credentials are hardcoded in Android. Production credentials and order ID generation should be moved to a backend API call. The Billdesk SDK (`PaymentOptions.class`) will need to be replaced with a Flutter equivalent (WebView or Billdesk Flutter SDK).

8. **Payswiff SDK:** The `com.pnsol.sdk` library is Android-only (Payswiff hardware POS). This functionality will either need a Flutter plugin for the Payswiff SDK or a different POS integration approach.

9. **LCO Wallet WebView (Paytm/UPI):** The payment gateway URL (`PropertyReader.getProperty("payweb")`) serves an HTML page. In Flutter, replace with `webview_flutter` package. Monitor URL changes to detect the completion redirect (`/paymentgateway/mobile_paymentsend`).

10. **Static Fields Pattern:** Multiple screens use `public static` fields (`BilldeskPaymentActivity.amount`, `CustomerMgmtActivity_MakePayment_Fragment.billingId`, etc.) for cross-screen data sharing. In Flutter, use Provider/Riverpod state management or pass data through named routes.

11. **SOAP to REST Migration:** All payment operations currently use ksoap2 SOAP. The V2 REST endpoints are exact replacements. Key SOAP method names are read from `PropertyReader` (a properties file). The mapping is:
    - `"pendamt"` → `getPendingAmountRest`
    - `"mpay"` → `makePaymentsRest`
    - `"pmodes"` → `getPaymentModesRest`
    - `"phist"` → `PaymentServiceRest`
    - `"invhist"` → `InvoiceServiceRest`
    - `"rranges"` → `getReceiptRanges`
    - `"pgtl"` → `pgTransactionLogs`
    - `"ctransac"` → `customer_transaction_reponseRest`
    - `"payweb"` → server-hosted payment gateway page URL

12. **UPI Intent Handling:** The WebView intercepts `upi://pay` URLs and launches the Android UPI chooser. In Flutter, use `url_launcher` or `upi_india` package for UPI deep-link handling.
