# 03 - Payments & PG Integration: Flutter Changes Required

> **Generated:** 2026-03-26
> **Spec:** `screen_docs/03_payments_pg_integration.md` (20 screens documented)
> **Flutter files reviewed:** `payment_remote_datasource.dart`, `payment_provider.dart`, `make_payment_screen.dart`, `api_constants.dart`, plus full `lib/` grep for payment-related files.

---

## Summary

The Flutter app currently implements **one screen** (`MakePaymentScreen`) with partial coverage of **Screen S01** from the spec. Of the 18 spec screens and 2 reference sections, **15 screens are entirely missing** and the one implemented screen has significant gaps. The API endpoint constants are defined but most are not wired to any UI.

---

## 1. API Endpoints Audit

| # | Endpoint | Constant Defined? | Datasource Method? | Called from UI? | Gap |
|---|----------|:-:|:-:|:-:|-----|
| 4.1 | `getPendingAmountRest` | YES | YES | YES | None |
| 4.2 | `makePaymentsRest` | YES | YES | YES | Missing `imei` param (required by spec) |
| 4.3 | `getPaymentModesRest` | YES | YES | YES | None |
| 4.4 | `getReceiptRanges` | YES | YES | NO | Method exists but never called from any screen |
| 4.5 | `getbilldetailsRest` | YES | YES | NO | Method exists but never called from any screen |
| 4.6 | `pgTransactionLogs` | YES (constant) | NO | NO | No datasource method, no screen |
| 4.7 | `PaymentServiceRest` | YES | YES | NO | Method exists but no Payment History screen |
| 4.8 | `customer_transaction_reponseRest` | YES (constant) | NO | NO | No datasource method, no screen |
| -- | `InvoiceServiceRest` | YES (constant) | NO | NO | No datasource method, no screen |
| -- | `getlcowalletRest` | YES (constant in dashboard section) | NO (in payment ds) | NO | No LCO wallet history screen |

**Priority: HIGH** -- 5 of 8 payment-domain endpoints have no datasource method or UI wiring.

---

## 2. Screen S01 -- Make Payment (Gaps in Existing Implementation)

### 2.1 Payment Mode Field Visibility Matrix -- NOT IMPLEMENTED
**Priority: HIGH**

The spec defines 5 payment modes (Cash, Bank, Card, Voucher, UPI Payment) each with different visible form fields. The Flutter screen shows a **static form** regardless of selected mode:
- **Missing:** Cheque No, Bank Name, Branch, Cheque Date fields (Bank mode)
- **Missing:** Voucher Code field (Voucher mode); amount should be set to 0
- **Missing:** Card Type checkboxes -- debit/credit (Card mode)
- **Missing:** QR Code image display (UPI Payment mode)
- **Missing:** Dynamic show/hide of fields based on `_selectedPaymentMode`

The datasource `makePayment()` accepts `chequeNo`, `bank`, `branch`, `chequeDate`, `voucherCode`, `rrnNo`, `cardholderName` params but the **provider's `makePayment()` method does not pass them through** -- it only forwards `customerId`, `amount`, `modeType`, `receiptNumber`, `remarks`, `billingId`.

### 2.2 Receipt Number -- AUTO_RECEIPT_NUMBER Logic Missing
**Priority: HIGH**

- Spec requires reading `AUTO_RECEIPT_NUMBER` from login config
- When `AUTO_RECEIPT_NUMBER == 0`: hide manual receipt field, call `getReceiptRanges`, show searchable grid picker
- When `AUTO_RECEIPT_NUMBER == 1`: show manual receipt entry for Cash/UPI modes only
- Flutter: Receipt field is always visible as a plain text field labeled "optional" regardless of config or mode

### 2.3 Amount Validation Against Pending Amount -- Missing
**Priority: HIGH**

Spec requires:
- Amount < pending: block with "Invalid Amount" alert (when `userLcoDeposit == 0`)
- Amount > pending: show confirmation "Excess amount" dialog
- Amount == pending: proceed directly
- When `userLcoDeposit == 1`: amount field disabled, locked to pending amount

Flutter: Only checks amount is non-empty. No comparison against pending amount. No `userLcoDeposit` handling.

### 2.4 Missing `imei` Parameter in makePaymentsRest
**Priority: MEDIUM**

Spec requires `imei` (device IMEI) in the makePayment request payload. Not sent by Flutter.

### 2.5 Remarks Auto-Suffix Missing
**Priority: LOW**

Spec: Always append ". Paid From Android App" (or Flutter equivalent) to remarks. Not implemented.

### 2.6 Post-Payment Receipt Navigation Missing
**Priority: HIGH**

On successful payment, spec navigates to `DisplayPaymentDetails` (Screen S12) with full receipt data bundle. Flutter only shows a SnackBar and pops the screen. No receipt screen exists.

### 2.7 Pay by Card (Payswiff POS) Button Missing
**Priority: MEDIUM**

Card mode should show a separate "Pay by Card" button that launches the POS flow. No Payswiff integration exists.

### 2.8 Status Code Handling Incomplete
**Priority: MEDIUM**

Spec defines distinct handling for `status_code` 0 (with sub-cases), 1, and 2+. Flutter only checks `status_code == 0` and throws for anything else.

### 2.9 `blockpayment` Config Flag Not Checked
**Priority: MEDIUM**

Spec: If `blockpayment` is set in login response, entry to Make Payment should be prevented. Not implemented.

---

## 3. Missing Screens

### 3.1 Screen S02 -- Payment History
**Priority: HIGH**

- **Status:** Completely missing. No screen file exists.
- **API:** `getPaymentHistory()` method exists in datasource but is unused.
- **Required:** Screen with ListView showing `paid_on`, `paid_amount`, `receipt_no`, `payment_mode`, `payment_id`, `remarks` columns. Total count label. Print and Share (PDF) actions per row.
- **Note:** Datasource sends `customerId` but spec requires `dealer_id` and `customer_id`. Datasource also sends `fromDate`/`toDate` which are not in the spec's PaymentServiceRest request (may be extra).

### 3.2 Screen S03 -- Invoice History
**Priority: HIGH**

- **Status:** Completely missing. No screen file exists.
- **API:** `InvoiceServiceRest` constant defined but no datasource method.
- **Required:** New datasource method, provider, and screen. Fields: `billing_id`, `bill_date`, `due_date`, `total_amount`, `quantity`, `base_price`, `serial_number`, `mac_vc_number`, `pname`, `setup_price`, `tax_amount`, `pending_amount`, `discount_amount`, `is_adhoc`.

### 3.3 Screen S04 -- LCO Payment (MSO-to-LCO)
**Priority: MEDIUM**

- **Status:** Completely missing.
- **Required:** Two-phase screen: LCO code search, then payment form with adjustment (credit/debit), Cash/Bank modes. Separate SOAP/REST endpoints needed (LCO advance amount search + LCO payment). V2 REST equivalents need to be identified.

### 3.4 Screen S05 -- LCO Wallet Top-up
**Priority: MEDIUM**

- **Status:** Completely missing.
- **Required:** Amount entry screen, navigates to Payment WebView (S09). Displays LCO name and current wallet balance.

### 3.5 Screen S06 -- LCO Wallet History
**Priority: MEDIUM**

- **Status:** Completely missing. `getlcowalletRest` constant exists in api_constants.
- **Required:** Display-only screen receiving wallet ledger data. Fields: `Deposit_Date`, `payment_mode`, `credit_amount`, `debit_amount`, `transaction_no`, `receipt_no`, `Remarks`, etc.

### 3.6 Screen S07 -- PG Transaction Report
**Priority: MEDIUM**

- **Status:** Completely missing. `pgTransactionLogs` constant defined but no datasource method.
- **Required:** New datasource method + screen with status filter spinner (All/Success/Fail). ListView with `PgTransactionReportModel` fields.

### 3.7 Screen S08 -- Billdesk Payment Activity
**Priority: LOW** (PG integration -- typically Phase 2)

- **Status:** Completely missing.
- **Required:** Billdesk SDK integration or equivalent WebView-based PG flow. Constructs pipe-delimited message, launches payment SDK. Production merchant ID/keys needed from backend.

### 3.8 Screen S09 -- Payment WebView (Paytm/UPI Gateway)
**Priority: MEDIUM**

- **Status:** Completely missing.
- **Required:** WebView loading server-hosted PG page with POST params (`auth_key`, `employee_id`, `dealer_id`, `customer_id`, `amount`, `from_mobile_app`). URL interception for UPI intents and redirect detection. Back button blocked during transaction.

### 3.9 Screen S10 -- Payment Response
**Priority: MEDIUM**

- **Status:** Completely missing. `customer_transaction_reponseRest` constant defined but no datasource method.
- **Required:** New datasource method + screen showing success/fail icon, transaction ID, amount, customer name. Status parsing: "TXN_SUCCESS"/"success"/"Txn Success" = success, others = fail.

### 3.10 Screen S11 -- Payment Transaction (Payswiff POS)
**Priority: LOW** (hardware POS -- device-specific)

- **Status:** Completely missing.
- **Note:** Requires Payswiff SDK (`com.pnsol.sdk`). May not have a Flutter equivalent. Consider native platform channel if needed.

### 3.11 Screen S12 -- Display Payment Details (Receipt)
**Priority: HIGH**

- **Status:** Completely missing.
- **Required:** Post-payment receipt screen showing Customer Name, ID, Mobile, Address, Receipt No, Due Amount, Paid Amount. Supports print (BLE thermal) and share (PDF).

### 3.12 Screen S13 -- Transaction Details (Card Approved)
**Priority: LOW** (Payswiff-dependent)

- **Status:** Completely missing.
- **Required only if** Payswiff POS integration is in scope.

### 3.13 Screen S14 -- Transaction Details Declined
**Priority: LOW** (Payswiff-dependent)

- **Status:** Completely missing.

### 3.14 Screen S15 -- Payswiff Account Activation
**Priority: LOW** (Payswiff-dependent)

- **Status:** Completely missing.

### 3.15 Screen S16 -- Payswiff Payment Transaction Fragment
**Priority: LOW** (Payswiff-dependent)

- **Status:** Completely missing.

### 3.16 Screen S17 -- Payswiff Transaction Details Fragment
**Priority: LOW** (Payswiff-dependent)

- **Status:** Completely missing.

### 3.17 Screen S18 -- Billdesk SampleCallBack Handler
**Priority: LOW** (Billdesk SDK-specific)

- **Status:** Completely missing.

---

## 4. Backend Config Flags Not Implemented

| Flag | Priority | Current Status |
|------|----------|----------------|
| `AUTO_RECEIPT_NUMBER` | HIGH | Not read from login response; receipt logic missing |
| `blockpayment` | MEDIUM | Not checked before navigating to Make Payment |
| `enable_box_wise_payment` | MEDIUM | Not implemented; box-wise payment flow absent |
| `userLcoDeposit` | HIGH | Not used; amount field always editable |
| `allow_top_up` | MEDIUM | Not used; LCO wallet top-up screen missing entirely |
| `use_lco_deposits` | LOW | Not used |
| `lco_billtype` / `customer_billtype` | LOW | Not used |

---

## 5. Payment Provider Gaps

### 5.1 makePayment() Does Not Forward Mode-Specific Fields
**Priority: HIGH**

The `PaymentNotifier.makePayment()` method only accepts `customerId`, `amount`, `modeType`, `receiptNumber`, `remarks`, `billingId`. It does not forward:
- `chequeNo`, `bank`, `branch`, `chequeDate` (Bank mode)
- `voucherCode` (Voucher mode)
- `rrnNo`, `cardholderName` (Card mode)
- `altReceiptNumber`
- `imei`

These are accepted by the datasource but never passed from the provider.

### 5.2 No Receipt Ranges State or Method
**Priority: HIGH**

`PaymentState` has no field for receipt ranges. No provider method calls `getReceiptRanges()`.

### 5.3 No Payment History State or Screen Integration
**Priority: HIGH**

No provider method or state for payment history, invoice history, PG transactions, or wallet history.

### 5.4 No Bill Details State for Box-wise Payment
**Priority: MEDIUM**

`getBillDetails()` exists in datasource but no provider integration.

---

## 6. BLE Print Integration
**Priority: MEDIUM**

Spec references thermal printing (N910 Newland SDK) and Bluetooth printing (`Bluetooth_Fragment`) for:
- Payment receipts (S02, S12)
- Invoice receipts (S03)
- Transaction receipts (S13, S17)

No print functionality exists in the Flutter app. A BLE print service/plugin will be needed.

---

## 7. Prioritized Implementation Order

### Phase 1 -- HIGH Priority (Core Payment Flow)
1. **Fix S01 Make Payment:** Add payment mode field matrix (show/hide per mode), wire all mode-specific params through provider, implement `AUTO_RECEIPT_NUMBER` and receipt range picker, add amount-vs-pending validation, add `userLcoDeposit` handling, add `imei` param.
2. **Add S12 Display Payment Details (Receipt):** Post-payment receipt screen with all data fields from makePayments response.
3. **Add S02 Payment History:** Screen + provider wiring for `PaymentServiceRest`. Print/share actions.
4. **Add S03 Invoice History:** New datasource method for `InvoiceServiceRest` + screen.
5. **Backend config flags:** Read and store `AUTO_RECEIPT_NUMBER`, `blockpayment`, `userLcoDeposit`, `enable_box_wise_payment` from login response.

### Phase 2 -- MEDIUM Priority (LCO Wallet & PG)
6. **Add S05 LCO Wallet Top-up** + **S09 Payment WebView** + **S10 Payment Response:** End-to-end wallet top-up via WebView PG.
7. **Add S06 LCO Wallet History:** Display-only screen with wallet ledger.
8. **Add S07 PG Transaction Report:** New datasource method for `pgTransactionLogs` + screen with status filter.
9. **Add S04 LCO Payment (MSO-to-LCO):** Two-phase form with adjustment support.
10. **BLE Print plugin** for receipts.

### Phase 3 -- LOW Priority (Hardware POS & SDK)
11. **S08 Billdesk Payment Activity** (SDK or WebView equivalent).
12. **S11, S13, S14, S15, S16, S17 Payswiff POS** screens (requires native platform channel for Payswiff SDK).
13. **S18 Billdesk Callback Handler.**

---

## 8. File Locations Referenced

| File | Path |
|------|------|
| Spec | `D:\ITP2026\android\Flutter_ezybill\screen_docs\03_payments_pg_integration.md` |
| API Constants | `D:\ITP2026\android\Flutter_ezybill\lib\core\constants\api_constants.dart` |
| Payment Datasource | `D:\ITP2026\android\Flutter_ezybill\lib\data\datasources\remote\payment_remote_datasource.dart` |
| Payment Provider | `D:\ITP2026\android\Flutter_ezybill\lib\application\providers\payment_provider.dart` |
| Make Payment Screen | `D:\ITP2026\android\Flutter_ezybill\lib\presentation\screens\payments\make_payment_screen.dart` |
| App Router | `D:\ITP2026\android\Flutter_ezybill\lib\presentation\router\app_router.dart` |
