# EzyBill Flutter Migration — Screen Documentation: Customer Management

> **Source analyzed:** Android Java source files in `activities_fragments/` and `complexclasses/`
> **API reference:** `REST_API_V2_SERVICE_DOCUMENT.md` (V2 REST only — all SOAP references are for Android legacy only)
> **Date:** 2026-03-26

---

## Table of Contents

1. [Screen Flow Overview](#1-screen-flow-overview)
2. [SC-01 — Customer Search Screen](#2-sc-01--customer-search-screen)
3. [SC-02 — Customer Search Results List](#3-sc-02--customer-search-results-list)
4. [SC-03 — Customer Operations Hub](#4-sc-03--customer-operations-hub)
5. [SC-04 — New Customer Creation Form](#5-sc-04--new-customer-creation-form)
6. [SC-05 — New Customer Package Selection](#6-sc-05--new-customer-package-selection)
7. [SC-06 — New Customer Confirmation Screen](#7-sc-06--new-customer-confirmation-screen)
8. [SC-07 — Edit Customer Info](#8-sc-07--edit-customer-info)
9. [SC-08 — Customer STB / Box Selection](#9-sc-08--customer-stb--box-selection)
10. [SC-09 — Payment Receipt Display (Displayfrag)](#10-sc-09--payment-receipt-display-displayfrag)
11. [SC-10 — Account Activation (POS Payment Terminal)](#11-sc-10--account-activation-pos-payment-terminal)
12. [SC-11 — Dashboard STB Count Fragments](#12-sc-11--dashboard-stb-count-fragments)
13. [Backend Config Flags Reference](#13-backend-config-flags-reference)
14. [Form Validations Model — `dynamicformvalidationsRest`](#14-form-validations-model--dynamicformvalidationsrest)
15. [Address Cascading Dropdown Logic](#15-address-cascading-dropdown-logic)
16. [Master Data API Calls Summary](#16-master-data-api-calls-summary)

---

## 1. Screen Flow Overview

```
Main Menu
├── Search Customer (origin = "customerMgmt")
│   └── Customer Search Results List
│       └── Customer Operations Hub (tap a customer row)
│           ├── [Button] Make Payment      → CustomerMgmtActivity_MakePayment_Fragment
│           ├── [Button] Box Operations    → Customer STB Select Fragment
│           │   └── Activate / Deactivate / Reactivate STB
│           ├── [Button] Package Operations → Customer STB Select Fragment
│           │   └── Activate / Deactivate / Extend Package
│           ├── [Button] Edit Customer     → Edit_Customer_Info
│           ├── [Button] Invoice History   → InvoiceHistory
│           ├── [Button] Payment History   → PaymentHistory
│           ├── [Button] Complaint History → ComapliantHistory
│           └── [Button] Complaint Ops     → Complaint_Operations_Fragment
│
├── Scan STB → validate STB → New Customer Creation Form (origin = "stb_Map_custID")
│   └── New Customer Package Selection (NewCust_AddPackage_Activity)
│       └── New Customer Confirmation Screen
│           └── [Confirm] → saveCustomerRest → success
│
├── Payments (origin = "payments")
│   └── Customer Search Results List → Make Payment
│
├── Package Management (origin = "packageMgmt")
│   └── Customer Search Results List → Customer STB Select
│
└── Dashboard → STB Count Tiles
    ├── AssignedSTB_CountsFrag    (stbType=1)
    ├── UnAssignedStb_Frag        (stbType=2)
    ├── TotalStbs_Frag            (stbType=3)
    ├── DashBoard_Active_Stb_Frag (stbType=4)
    └── DeactiveStb_Frag          (stbType=5)
```

---

## 2. SC-01 — Customer Search Screen

**Class:** `SearchCustomer_Fragment.java`
**Layout:** `search_customer`
**Title:** "Search Customer"
**Purpose:** Entry point for finding customers. Accepts one or more search criteria and fetches the total count from the server. If count is valid (< 10,000), navigates to the results list.

### 2.1 UI Elements

| Element Type | Resource ID | Label | Input Type | Notes |
|---|---|---|---|---|
| TextView | `tv_head` | "Search Customer" | — | Screen title |
| TextView | `tvcustcrf` | "CRF No" / "CAF No" | — | Label changes based on `useCRF` (not used on this screen directly; visible as hint label) |
| EditText | `searchcust_et_custid` | Customer ID | Number | Search by customer number |
| EditText | `searchcust_et_custname` | Customer Name | Text | Min 3 chars if used |
| EditText | `searchcust_et_mobile` | Mobile No | Phone | Search by mobile number |
| EditText | `searchcust_et_boxno` | Box / STB No | Text | Search by STB serial |
| EditText | `searchcust_lco_no` | LCO Customer ID | Text | Search by LCO-assigned customer ID |
| Button | `searchcust_btn_search` | "Search" | — | Triggers search |
| LinearLayout | `searchcustlayout` | — | — | Touch to dismiss keyboard |

### 2.2 Input Parameters Passed to This Screen

| Bundle Key | Type | Source | Notes |
|---|---|---|---|
| `origin` | String | Calling screen | Controls where result-tap navigates. Values: `"customerMgmt"`, `"payments"`, `"complaintMgmt"`, `"packageMgmt"`, `"stb_Map_custID"` |
| `stbNo` | String | STB scan flow | Only when `origin == "stb_Map_custID"`. Passes scanned STB serial to next screen. |

### 2.3 Validation Rules

| Rule | Condition | Error Message |
|---|---|---|
| At least one field | All five fields empty | "Please enter data in atleast one field." |
| Name minimum length | Name entered but length < 3 | "Please enter 3 letters to search with name." |
| Network check | No active network | "Please turn on Wifi or Data Network in your phone." |
| Count limit | `customerCount >= 10000` | "Your Search results in large count of customers..." |

### 2.4 API Call — Get Customer Count

**Endpoint:** `POST /LcoRestServices/getCustomerDetailsCountRest`

**Request Payload:**

| Field | Type | Mandatory | Description |
|---|---|---|---|
| `authToken` | String | Yes | JWT from login |
| `customerNumber` | String | No | Customer ID search term |
| `customerName` | String | No | Customer name search term |
| `mobileNumber` | String | No | Mobile number search term |
| `boxNumber` | String | No | STB serial search term |
| `lcoCustomerId` | String | No | LCO customer ID search term |
| `use_lco_deposits` | String | No | From login config |

**Response Fields:**

| Field | Type | Notes |
|---|---|---|
| `status_code` | int | 0 = success, 1+ = failure |
| `status_msg` | String | Message to show on failure |
| `customerCount` | int | Total matching customers |
| `existCustomerDetails` | Object | May contain pre-fetched data |

### 2.5 Response Handling

- `statusCode == 0` and `customerCount < 10,000`: Navigate to `CustomerSearchList_Fragment` passing all search parameters + count + origin.
- `statusCode == 0` and `customerCount >= 10,000`: Show "Large Count" dialog, block navigation.
- `statusCode == 1` or `statusCode >= 2`: Show "Customers not found!" dialog.
- `response == null`: Show "Server connectivity error!" dialog.

### 2.6 Navigation Output (Bundle to Next Screen)

| Key | Value |
|---|---|
| `count` | String(int) — total results |
| `custNo` | ET customer ID value |
| `custName` | ET customer name value |
| `mobileNo` | ET mobile value |
| `boxNo` | ET box number value |
| `lcoCustomerId` | ET lco no value |
| `reqOrigin` | Passed-through `request_origin` |
| `boxno_stbcheck` | Passed-through STB number (when origin = stb_Map_custID) |

---

## 3. SC-02 — Customer Search Results List

**Class:** `CustomerSearchList_Fragment.java`
**Layout:** `customersearch_list_fragment`
**Title:** "Customer List"
**Purpose:** Paginated list of customers matching search criteria. 100 items per page. On row tap, navigates based on `request_origin`.

### 3.1 UI Elements

| Element | ID | Description |
|---|---|---|
| ListView (ListFragment) | (built-in) | Scrollable customer list |
| TextView | `title` | Page/list header |
| Button | `reports_btn_first` | Jump to page 1 |
| Button | `reports_btn_prev` | Previous page |
| Button | `reports_btn_next` | Next page |
| Button | `reports_btn_last` | Jump to last page |
| LinearLayout | `btnLay` | Pagination button row |

### 3.2 List Row Data (from `customerDetailsList` model)

Each row in the list displays and carries:

| Field | Type | Description |
|---|---|---|
| `customerId` | int | Internal customer ID |
| `customerName` | String | Full customer name |
| `cafNumber` | String | CAF/CRF number |
| `mobileNumber` | String | Mobile number |
| `status` | int | 0 = Deactive, 1 = Active |
| `billingAddress` | String | Billing address |
| `installationAddress` | String | Installation address |
| `pinCode` | int | PIN code |
| `crfNumber` | String | CRF number |
| `pending_amount` | double | Outstanding amount |
| `online_customer` | int | 1 = online customer flag |
| `checkaddserviceaccess` | int | Whether add-service is allowed |
| `ADDON_AFTER_BASEPACK` | int | Addon after base pack flag |
| `reseller_id` | int | Reseller ID |
| `bill_type` | int | Bill type |
| `is_direct_lco` | int | Direct LCO flag |
| `accountnumber` | int | Account number |
| `latitude` | String | GPS latitude |
| `longitude` | String | GPS longitude |

### 3.3 Pagination Logic

- `NUM_ITEMS_PAGE = 100`
- `pageCount = ceil(TOTAL_LIST_ITEMS / 100)`
- Pagination uses `startValue` and `endValue` in the API call.
- `startValue = increment * 100`, `endValue = startValue + 100`
- Prev/First buttons disabled on page 0.
- Next/Last buttons disabled on final page.

### 3.4 API Call — Fetch Customer List Page

**Endpoint:** `POST /LcoRestServices/getCustomerDetailsRest`

**Request Payload:**

| Field | Type | Mandatory | Description |
|---|---|---|---|
| `authToken` | String | Yes | JWT from login |
| `customerNumber` | String | No | From search |
| `customerName` | String | No | From search |
| `mobileNumber` | String | No | From search |
| `boxNumber` | String | No | From search |
| `lcoCustomerId` | String | No | From search |
| `cafNumber` | String | No | From search (usually empty) |
| `startValue` | int | Yes | Pagination start (0-based, ×100) |
| `endValue` | int | Yes | Pagination end (startValue+100) |

**Response Fields:**

| Field | Type | Description |
|---|---|---|
| `status_code` | int | 0 = success |
| `status_msg` | String | Error message if any |
| `lco_share` | String | LCO share value |
| `existCustomerDetails` | Array | Array of customer records |

### 3.5 Row-Tap Navigation Logic

When the user taps a list row, the destination depends on `request_origin`:

| `request_origin` value | Destination Screen | Key Data Sent |
|---|---|---|
| `"customerMgmt"` | `CustomerOperations_Fragment` | custId, custName, cafNo, mobileNO, status, billAdd, instAdd, pinCode, pending_amount, online, reseller_id, lati, longi, account_number, bill_type, addservice |
| `"payments"` | `CustomerMgmtActivity_MakePayment_Fragment` | custId, custName, reqOrigin, reseller_id |
| `"complaintMgmt"` | `Complaint_Operations_Fragment` | custId, custName, reqOrigin, reseller_id |
| `"packageMgmt"` | `Customer_STB_Select_Fragment` | custId, custName, reqOrigin, operationType="packageOperation", pending_amount, resellerid, bill_type |
| `"stb_Map_custID"` | Special STB-to-customer mapping flow | custId, boxno_stbcheck |

**Special case for `packageMgmt`:** If `online_customer == 1` AND `checkaddserviceaccess != 1`, blocks navigation with dialog "Package operations not available for online customer."

---

## 4. SC-03 — Customer Operations Hub

**Class:** `CustomerOperations_Fragment.java`
**Layout:** `customeroperations_new`
**Title:** "Customer Operations"
**Purpose:** Central hub displaying a specific customer's summary and buttons to perform all available operations. This is the main customer profile card.

### 4.1 UI Elements — Display Fields

| TextView ID | Label | Content |
|---|---|---|
| `custoper_tv_custname` | Name | `custName` (split at 18 chars if longer) |
| `custoper_tv_custid` | Account No | `account_number` (or "NA" if null) |
| `custoper_tv_cafno` | CRF/CAF No | `cafNo` (label from `useCRF` flag) |
| `custoper_tv_status` | Status | "ACTIVE" or "DEACTIVE" (from `int_status`) |
| `custoper_tv_billadd` | Bill Address | `billAddress` (marquee scroll enabled) |
| `custoper_tv_pin` | PIN | `pinCode` |
| `custoper_btn_mobileno` | Mobile | `mobileNO` (or "NA") |
| `custoper_tv_dueamt1` | Due Amount | `₹{pending_amount}` |
| `custoper_tv_dueamtbtn` | Due (button) | Visible only when `pending_amount > 0` |
| `tv_custprof` | Profile label | Customer profile heading |

### 4.2 CAF/CRF Label Logic

```
if (LoginActivity.useCRF == 0) → label = "CRF No"
else                            → label = "CAF No"
```

### 4.3 Operation Buttons — Visibility and Navigation

| Button / Layout ID | Label | Visibility Condition | Destination |
|---|---|---|---|
| `custoper_btn_payment` | Make Payment | `int_bulk_payment==1` AND `hidemakepayment==0` | `CustomerMgmtActivity_MakePayment_Fragment` |
| `custoper_tv_dueamtbtn` | Due Amount button | Same as payment AND `pending_amount > 0` | `CustomerMgmtActivity_MakePayment_Fragment` |
| `custoper_btn_boxoperations` | Box Operations | `int_stb_activation==1` OR `int_stb_deactivation==1` OR `int_stb_reactivation==1` | `Customer_STB_Select_Fragment` (operationType="boxOperation") |
| `custoper_btn_invoicehistory` | Invoice History | `invoice_page_access == 1` | `InvoiceHistory` |
| `custoper_btn_editcustomer_paymenthistory` | Payment History | `payment_hist_page_access == 1` | `PaymentHistory` |
| `custoper_btn_editcustomer_compalinthistory` | Complaint History | `access_for_complaints == 1` | `ComapliantHistory` |
| `custoper_btn_complaintoperations` | Complaint Ops | `access_for_complaints == 1` | `Complaint_Operations_Fragment` |
| `tv_locate` | View on Map | `patch_information` in {"1.4.13.2","1.4.13.3","1.4.13.4"} | Google Maps Intent (if coords exist) or MapsFragmentlocupdate |
| `custoper_update` | Update Location | Same as `tv_locate` | `MapsFragmentlocupdate` or direct `updatelocation()` |

> Note: Edit Customer button (navigates to `Edit_Customer_Info`) is present on this screen but not shown in the visible code segment — it receives all customer data via bundle.

### 4.4 Bundle Received by This Screen

| Key | Type | Description |
|---|---|---|
| `custName` | String | Customer full name |
| `custId` | int | Internal customer ID |
| `cafNo` | String | CAF/CRF number |
| `mobileNO` | String | Mobile number |
| `status` | int | 0=Deactive, 1=Active |
| `billAdd` | String | Billing address |
| `instAdd` | String | Installation address |
| `account_number` | String | Account number |
| `pinCode` | int | PIN code |
| `pending_amount` | double | Outstanding amount |
| `online` | int | Online customer flag |
| `addservice` | int | Add service access |
| `reseller_id` | int | Reseller ID |
| `lati` | String | Stored GPS latitude |
| `longi` | String | Stored GPS longitude |
| `bill_type` | int | Bill type |

### 4.5 API Call — Update Customer Location

**Endpoint:** `POST /LcoRestServices/updateCustomerLocation`
(Also available as a Volley REST call via `updateCustomerLocation_url`)

**Request Payload:**

| Field | Type | Mandatory | Description |
|---|---|---|---|
| `authToken` | String | Yes | JWT |
| `latitude` | double | Yes | Current GPS latitude |
| `longitude` | double | Yes | Current GPS longitude |
| `customer_id` | int | Yes | Customer ID |

**Response:** `status_code`, `status_msg`

### 4.6 Location Handling

- On `tv_locate` tap:
  - If stored coords are `0.0/0.0` → prompt to update location → navigate to `MapsFragmentlocupdate`.
  - If coords are valid → launch Google Maps intent to `maps.google.com/maps?daddr={lat},{lng}`.
  - If device is N910 POS machine → shows dialog for direct update (no Maps app available).

---

## 5. SC-04 — New Customer Creation Form

**Class:** `NewCustCreation_Fragment.java`
**Layout:** `newcustcreation_fragment`
**Title:** "New Customer"
**Purpose:** Collects all data for creating a new customer. This screen is reached after scanning/validating an STB. The STB serial is pre-filled and locked. On "Save", sends data to `saveCustomerRest`.

### 5.1 Complete UI Element List

#### Spinners (Dropdowns)

| Spinner ID | Label | Data Source API | Notes |
|---|---|---|---|
| `newcust_spin_cust_type` | Customer Type * | `getCustomerTypesRest` | Primary customer type selector |
| `newcust_spin_cust_type_multi` | Customer Sub-type | `getcustomerTypeTypesRest` | Shown when `useMandatoryForHotel==1` AND custType has sub-types |
| `newcust_spin_group` | Group * | `getGroupsRest` | Mandatory — saved as `groupItemValue` |
| `newcust_spin_country` | Country * | `getCountriesRest` | Triggers state reload on selection |
| `newcust_spin_state` | State * | `getStatesRest` | Triggers district reload |
| `newcust_spin_dist` | District * | `getdistrictsRest` | Triggers city+mandal reload |
| `newcust_spin_city` | City * | `getCitiesRest` | Filtered by stateId |
| `newcust_spin_mandal` | Mandal | `getmandalsRest` | Conditionally mandatory via `is_mandal_id_mandatory` |
| `newcust_spin_idtype` | Id Type | `getIdsRest` | Conditionally mandatory via `is_id_type_mandatory` |
| `newcust_spin_billtype` | Bill Type | Static: Year/Month/Day (per pricing type) | Determines billing cycle |
| `spin_gender` (local var) | Gender | Static: Male/Female | Conditionally mandatory via `is_gender_mandatory` |

#### EditTexts

| EditText ID | Label | Mandatory? | Input Type | Notes |
|---|---|---|---|---|
| `newcust_caf` | CAF Number | Conditional | Text | Required when `useCRF==1` AND `useCAF=="MANUAL"` |
| `newlco_custid` | LCO Customer ID | Conditional | Text | Required when `useCAF=="MANUAL"` OR `is_baid_mandatory=="1"` |
| `newcust_bname` | Business Name | No | Text | For commercial/hotel customers |
| `newcust_fname` | First Name / Customer Name * | Yes (always) | Text | Label shows "Customer Name" when `useLastName==0`, "First Name" when `useLastName==1` |
| `newcust_lastname` | Last Name | Conditional | Text | Visible and required when `useLastName==1` AND `is_lastname_mandatory=="1"` |
| `newcust_fathername` | Father's Name | No | Text | — |
| `newcust_idnumber` | ID Number | Conditional | Text | Required when `is_id_number_mandatory=="1"` |
| `newcust_accountnumber` | Account Number * | Conditional | Text | Required when `useAccountNumber==0`; hidden when `useAccountNumber>0` |
| `newcust_addl1` | Address Line 1 * | Yes (always) | Text | |
| `newcust_addl2` | Address Line 2 | No | Text | |
| `newcust_instaddl1` | Installation Address 1 * | Yes (always) | Text | |
| `newcust_instaddl2` | Installation Address 2 | No | Text | |
| `newcust_pincode` | Pincode * | Yes (always) | Number | Min 6 digits |
| `newcust_phone` | Phone | No | Phone | Landline |
| `newcust_mobile` | Mobile (+91) * | Conditional | Phone | Pre-filled from STB scan; required when `is_mobile_no_mandatory=="1"`, min 10 digits |
| `newcust_email` | Email | Conditional | Email | Required when `is_email_mandatory=="1"`; validated with regex `[a-zA-Z0-9._-]+@[a-z]+\.+[a-z]+` |
| `newcust_boxno` | STB Number * | Yes (locked) | Text | Pre-filled from scan; not editable |
| `newcust_discount` | Discount | Conditional | Number | Visible based on `useDiscount` flag |
| `newcust_remarks` | Remarks | No | Text | — |
| `newcust_tv_latie` | Latitude | Auto | Decimal | GPS auto-fill |
| `newcust_tv_long` | Longitude | Auto | Decimal | GPS auto-fill |

#### Buttons

| Button ID | Label | Action |
|---|---|---|
| `newcust_btn_dob` | DOB (Date Picker) | Opens DatePickerDialog for date of birth |
| `newcust_btn_doa` | DOA (Date Picker) | Opens DatePickerDialog for date of activation/anniversary |
| `newcust_btn_packages` | "Select Package" | Launches `NewCust_AddPackage_Activity` for intent result |
| `newcust_btn_clear` | Clear | Clears all EditText fields |
| `newcust_btn_save` | Save | Validates all fields, then starts `NewCustomer_Confirm_Activity` |

#### Image Captures

| ImageView ID | Label | Camera Request Code |
|---|---|---|
| `newcust_image_idphoto` | ID Photo | `CAMERA_REQUEST_IDPHOTO = 1887` |
| `newcust_image_photo` | Customer Photo | `CAMERA_REQUEST_PHOTO = 1888` |
| `newcust_image_signature` | Signature | `REQUEST_SIGNATURE = 1889` |

#### Checkbox

| CheckBox ID | Label | Behavior |
|---|---|---|
| `newcust_cb_same` | "Same as Billing Address" | When checked, auto-fills installation address fields from billing address |

### 5.2 Config Flags that Affect Form Fields

| Flag | Source | Effect |
|---|---|---|
| `useCRF` (int) | `LoginActivity.useCRF` | 0 = hide all CAF fields; 1 = show CAF section |
| `useCAF` (String) | `LoginActivity.useCAF` | "AUTO" = CAF auto-generated, hide input; "MANUAL" = CAF required |
| `useLastName` (int) | `LoginActivity.useLastName` | 1 = show Last Name field; 0 = hide it, label = "Customer Name" |
| `useDiscount` (int) | `LoginActivity.useDiscount` | 0 = hide; 1 = show for DEALER/ADMIN/EMPLOYEE only; 2 = show always |
| `useAccountNumber` (int) | `LoginActivity.useAccountNumber` | 0 = show Account Number field (user-editable); >0 = hide/auto-generate |
| `useMandatoryForHotel` (int) | `LoginActivity.useMandatoryForHotel` | 1 = show Customer Sub-type spinner |
| `freezecustomerparamsinapp` (int) | `LoginActivity.freezecustomerparamsinapp` | Intended to lock fields (implementation varies) |
| `is_email_mandatory` (String) | `dynamicformvalidationsRest` | "1" = email field required + label shows red asterisk |
| `is_lastname_mandatory` (String) | `dynamicformvalidationsRest` | "1" = last name required + label shows red asterisk |
| `is_id_type_mandatory` (String) | `dynamicformvalidationsRest` | "1" = ID Type spinner required |
| `is_id_number_mandatory` (String) | `dynamicformvalidationsRest` | "1" = ID Number field required |
| `is_gender_mandatory` (String) | `dynamicformvalidationsRest` | "1" = gender selection required |
| `is_mobile_no_mandatory` (String) | `dynamicformvalidationsRest` | "1" = mobile number required (min 10 digits) |
| `is_baid_mandatory` (String) | `dynamicformvalidationsRest` | "1" = LCO Customer ID required |
| `is_mandal_id_mandatory` (String) | `dynamicformvalidationsRest` | "1" = Mandal selection required |

### 5.3 Field Visibility Matrix

| Field | Shown when | Hidden when |
|---|---|---|
| `tableRowCafcno` (old CAF row) | Never (always hidden) | Always |
| `tableRowCafcno1` (new CAF row) | `useCRF==1 AND useCAF!="AUTO"` | `useCRF==0` or `useCAF=="AUTO"` |
| `tableRowAccno` | `useAccountNumber == 0` | `useAccountNumber > 0` |
| `tableRowDiscount` | `useDiscount==2` or (`useDiscount==1` and DEALER/ADMIN/EMP) | `useDiscount==0` |
| `tableRowLastname` | `useLastName == 1` | `useLastName == 0` |
| `tableRowLcoCustId` | Always visible | — |
| `tableRowidPhoto` | Always visible | — |
| `tableRowSpinnerCustTupes` | `useMandatoryForHotel==1` AND type has sub-types | Otherwise |
| `tableRoweditCustypes` | `useMandatoryForHotel==1` AND no sub-types | Otherwise |

### 5.4 Validation Rules (Sequential — first failure shown)

| Order | Condition | Error |
|---|---|---|
| 1 | `custType == "Select"` | "Please select a Customer Type!" |
| 2 | `useMandatoryForHotel==1 AND mandatory_check==1 AND custTypeTypes=="Select"` | "Please select a Customer Type!" |
| 3 | `useMandatoryForHotel==1 AND mandatory_check==0 AND edit_custType_multi is empty` | "Please Enter Customer Type!" |
| 4 | `useCRF==1 AND useCAF=="MANUAL" AND cafNo.isEmpty` | "'CAF Number' should not be empty." |
| 5 | `useCAF=="MANUAL" AND lcoCustomerId.isEmpty` | "'LCO Customer Id' should not be empty." |
| 6 | `is_baid_mandatory=="1" AND lcoCustomerId.isEmpty` | "'LCO Customer Id' should not be empty." |
| 7 | `firstName.isEmpty` | "'First Name' should not be empty." |
| 8 | `is_lastname_mandatory=="1" AND lastName.isEmpty` | "'Last Name' should not be empty." |
| 9 | `useAccountNumber==0 AND accountNo.isEmpty` | "'Account Number' should not be empty." |
| 10 | `useAccountNumber==0 AND accountNo !~ /^(?=.*\d)(?=.*[a-z]).{3,30}$/` | "Account Number should contain at least 1 numeric and 1 Alphabet and minimum length of 3." |
| 11 | `addLine1.isEmpty OR instAddLine1.isEmpty` | "Address should not be empty." |
| 12 | `is_mobile_no_mandatory=="1" AND mobile.length < 10` | "Mobile number should not be less than 10 digits." |
| 13 | `pinCode.length < 6` | "Pincode number should not be less than 6 digits." |
| 14 | `email.notEmpty AND is_email_mandatory=="1" AND email !~ emailPattern` | "Email Id pattern is Invalid." |
| 15 | `packageButton text == "Select Package"` | "Package should not be empty." |
| 16 | `group == "Select"` | "Please select a Group." |
| 17 | `is_id_type_mandatory=="1" AND idType=="Select"` | "Please select ID Type." |
| 18 | `is_id_number_mandatory=="1" AND idNumber.isEmpty` | "Please enter an ID Number." |
| 19 | `is_gender_mandatory=="1" AND gender=="Select"` | (gender validation) |
| 20 | Country/State/City == "Select" | Address dropdown validation |

### 5.5 "Save" Button Action Flow

1. Run all validation rules above sequentially.
2. On first failure, show alert and stop.
3. On all pass: Collect all field values + GPS coordinates.
4. Launch `NewCustomer_Confirm_Activity` via `startActivityForResult(intent, DETAILS_CONFORM_REQUEST = 1886)`.
5. Pass ALL collected data as intent extras (see SC-06 for fields).
6. On result `RESULT_OK` from confirmation: Call `saveCustomerRest` API.

### 5.6 Bundle Received by This Screen (from STB scan flow)

| Key | Type | Description |
|---|---|---|
| `stbNo` | String | STB serial from scan |
| `resellerid` | int | Reseller ID |
| `mobile` | String | Mobile from STB lookup (pre-fills mobile field) |
| `formvalidations` | ArrayList\<FormValidations_Model\> | Dynamic validation rules from server |

### 5.7 API Calls Made on Screen Load (Sequential)

1. `getCustomerTypesRest` — populate customer type spinner
2. `getCountriesRest` — populate country spinner, auto-select default
3. `getIdsRest` — populate ID type spinner
4. `getGroupsRest` — populate group spinner

On country selection: trigger `getStatesRest`
On state selection: trigger `getdistrictsRest`
On district selection: trigger `getCitiesRest` + `getmandalsRest`
When customer type changes: trigger `getcustomerTypeTypesRest` if `useMandatoryForHotel==1`

### 5.8 Complete saveCustomerRest Payload Fields

**Endpoint:** `POST /LcoRestServices/saveCustomerRest`

| Field | Type | Mandatory | Source |
|---|---|---|---|
| `authToken` | String | Yes | `LoginActivity.authToken` |
| `customerTypeId` | int | Yes | From customer type spinner |
| `cafNumber` | String | Conditional | From `et_cafNo` |
| `lcoCustomerId` | String | Conditional | From `et_lco_cutid` |
| `businessName` | String | No | From `et_businessName` |
| `firstName` | String | Yes | From `et_firstName` |
| `lastName` | String | Conditional | From `et_lastName` |
| `idType` | int | Conditional | From `spin_idType` |
| `idNumber` | String | Conditional | From `et_idNumber` |
| `fatherName` | String | No | From `et_fatherName` |
| `gender` | int | Conditional | 1=Male, 2=Female |
| `group` | int | Yes | From `spin_groupValue` |
| `discount` | int | Conditional | From `et_discount` |
| `country` | String | Yes | Country ISO code |
| `state` | int | Yes | State ID |
| `district` | int | Yes | District ID |
| `city` | int | Yes | City ID |
| `mandal` | String | Conditional | Mandal ID |
| `phone` | String | No | From `et_phone` |
| `mobile` | String | Conditional | From `et_mobile` |
| `old_mobile` | String | No | Previous mobile (for updates) |
| `email` | String | Conditional | From `et_email` |
| `pin` | int | Yes | From `et_pinCode` |
| `address` | String | Yes | `addLine1 + ", " + addLine2` |
| `installationAddress` | String | Yes | `instAddLine1 + ", " + instAddLine2` |
| `remarks` | String | No | From `et_remarks` |
| `idProofImg` | String | No | Base64-encoded ID photo |
| `customerImg` | String | No | Base64-encoded customer photo |
| `signatureImg` | String | No | Base64-encoded signature |
| `boxNumber` | String | Yes | Pre-filled STB serial |
| `packageId` | int | Yes | From package selection |
| `dateType` | int | Yes | 1=Year, 2=Month, 3=Day |
| `quantity` | int | Yes | From package selection |
| `validityDays` | int | Conditional | If dateType=Day |
| `pricingStructureType` | int | Yes | From package selection |
| `dateofbirth` | String | No | From DOB picker (dd/MM/yyyy) |
| `dateofanniversary` | String | No | From DOA picker |
| `latitude` | String | No | GPS |
| `longitude` | String | No | GPS |
| `ipAddress` | String | No | Device IP |
| `billType` | int | Yes | From bill type spinner |
| `accountNumber` | String | Conditional | From `et_account_no` |
| `customerTypeTypesId` | String | Conditional | From sub-type spinner |
| `is_stb` | int | Yes | 1 = has STB |
| `state_str` | String | No | State name string |
| `city_str` | String | No | City name string |
| `district_str` | String | No | District name string |
| `customerId` | int | No | 0 for new customers |
| `baid` | String | Conditional | Same as lcoCustomerId |
| `installation_charges` | String | No | Installation fee amount |
| `customersla_id` | int | No | SLA ID |

**Response Fields:**

| Field | Type | Description |
|---|---|---|
| `status_code` | int | 0 = success |
| `status_msg` | String | Message |
| `customer_id` | int | Newly created customer ID |
| `online_customer` | int | Online customer flag |
| `stb_count` | int | Number of STBs |
| `email` | String | Stored email |
| `pin_code` | String | PIN code |
| `int_operation_id` | int | Operation ID |
| `form_validations` | Array | Dynamic validation rules (also returned here, same as `dynamicformvalidationsRest`) |
| `NCF_ENCF` | String | NCF/ENCF config |
| `dealer_id` | int | Dealer ID |
| `array_dealer_setting` | Object | Dealer settings object |

---

## 6. SC-05 — New Customer Package Selection

**Class:** `NewCust_AddPackage_Activity.java`
**Layout:** `newcust_packageactiv_fragment`
**Title:** "Select a package"
**Purpose:** Shows a searchable list of available CAS packages for the STB. User selects one and configures quantity/validity. Returns result to `NewCustCreation_Fragment`.

### 6.1 UI Elements

| Element | ID | Label | Type |
|---|---|---|---|
| TextView | `addnewpack_tv_title` | "Select a package" | Display |
| EditText | `ed_search_grid` | (search box) | Text — filters list |
| ListView | `gridView` | Package list | Selectable list |
| EditText | `newcust_packactivation_et_quant` | Quantity * | Number |
| Spinner | `newcust_packactivation_spin_cycle` | Activation Cycle | Options depend on pricing type |
| EditText | `newcust_packactivation_et_validdays` | Validity Days | Number — enabled only when cycle="Day" |
| Button | `newcust_packactivation_btn_add` | "Add" | Submits selection |

### 6.2 Activation Cycle Options

| `pricingStructureType` | Options |
|---|---|
| 1 (One-time) | Year, Month, Day |
| Other (Recurring) | Year only |

When "Day" is selected: `ll_validitydays` becomes visible and `et_validDays` is enabled.

### 6.3 Validation Rules

| Rule | Condition | Error |
|---|---|---|
| Quantity required | `quantity.isEmpty` | "Quantity should not be empty." |
| Validity days required | `cycle=="Day" AND validityDays.isEmpty` | "Validity days should not be empty." |

### 6.4 API Call — Get CAS Packages

**Endpoint:** `POST /LcoRestServices/getCasPackagesRest`

**Request Payload:**

| Field | Type | Mandatory | Description |
|---|---|---|---|
| `authToken` | String | Yes | JWT |
| `boxNumber` | String | Yes | STB serial from intent |

**Response Fields:**

| Field | Type | Description |
|---|---|---|
| `status_code` | int | 0 = success |
| `status_msg` | String | Error if any |
| `caspackageList` | Array | List of available packages |

Each `caspackageList` item contains: `productId`, `productName`, `pricingStructureType`.

### 6.5 Return Data (Intent Result to NewCustCreation_Fragment)

| Extra Key | Type | Description |
|---|---|---|
| `selProductId` | int | Selected package ID |
| `selProductName` | String | Package display name |
| `selQuantity` | int | Quantity entered |
| `selActiveCycle` | String | "Year", "Month", or "Day" |
| `selValidDays` | int | Validity days (1 if not Day cycle) |
| `selPricingType` | int | Pricing structure type |

---

## 7. SC-06 — New Customer Confirmation Screen

**Class:** `NewCustomer_Confirm_Activity.java`
**Layout:** `newcustomer_confirm`
**Title:** "Confirm New Customer"
**Purpose:** Read-only review screen. Displays all collected customer data for user confirmation before saving. Returns `RESULT_OK` to `NewCustCreation_Fragment` to trigger the API save call.

### 7.1 Display Fields (All TextView — read only)

| TextView ID | Label | Data Key |
|---|---|---|
| `newcustdetails_tv_custtype` | Customer Type | `custType` |
| `newcustdetails_tv_cafno` | CAF No | `cafNo` |
| `newcustdetails_tv_lcocustid` | LCO Cust ID | `LcoCustid` |
| `newcustdetails_tv_bname` | Business Name | `bName` |
| `newcustdetails_tv_fname` | Customer Name | `fName` |
| `newcustdetails_tv_gender` | Gender | `gender` |
| `newcustdetails_tv_billtype` | Bill Type | `billtype` |
| `newcustdetails_tv_fathname` | Father Name | `fatName` |
| `newcustdetails_tv_add` | Bill Address | `address` |
| `newcustdetails_tv_instadd` | Inst. Address | `instaddress` |
| `newcustdetails_tv_city` | City | `city` |
| `newcustdetails_tv_dist` | District | `dist` |
| `newcustdetails_tv_pin` | Pincode | `pincode` |
| `newcustdetails_tv_country` | Country | `country` |
| `newcustdetails_tv_state` | State | `state` |
| `newcustdetails_tv_phone` | Phone | `phone` |
| `newcustdetails_tv_mobile` | Mobile | `mobile` |
| `newcustdetails_tv_email` | Email | `email` |
| `newcustdetails_tv_dob` | Date of Birth | `dob` |
| `newcustdetails_tv_doa` | Date of Activation | `doa` |
| `newcustdetails_tv_group` | Group | `group` |
| `newcustdetails_tv_boxno` | Box No | `boxNo` |
| `newcustdetails_tv_package` | Package | `package` |
| `newcustdetails_tv_disc` | Discount | `disc` |
| `newcustdetails_tv_remarks` | Remarks | `remarks` |
| `newcustdetails_tv_idtype` | ID Type | `idType` |
| `newcustdetails_tv_idno` | ID Number | `idNo` |
| `newcustdetails_tv_longitude` | Longitude | `longi` |
| `newcustdetails_tv_latitude` | Latitude | `lati` |
| `newcustdetails_tv_mandal` | Mandal | `mandal` |

### 7.2 Buttons

| Button | Label | Action |
|---|---|---|
| Confirm | "Confirm" | `setResult(RESULT_OK)` + `finish()` |
| Edit / Back | "Edit" or Back press | `finish()` with no result → stays in NewCustCreation |

---

## 8. SC-07 — Edit Customer Info

**Class:** `Edit_Customer_Info.java`
**Layout:** `edit_cust_profile`
**Title:** "Edit Customer"
**Purpose:** Full edit form for an existing customer. Most fields are editable. Account number editability is controlled by `useAccountNumber`. On "Update", calls `editCustomerRest`.

### 8.1 Complete UI Element List

#### EditText Fields

| Field ID | Label | Editable? | Notes |
|---|---|---|---|
| `edit_firstname` | First Name * | Yes | Always required |
| `edit_lastname` | Last Name | Conditional | Required if `is_lastname_mandatory=="1"` |
| `edit_fatname` | Father's Name | Yes | Optional |
| `edit_buisnessname` | Business Name | Yes | Optional |
| `edit_bill_addrs` | Billing Address | Yes (via checkbox) | Editable only when `address_chkbox` is checked |
| `edit_installationaddr` | Installation Address | Yes (via checkbox) | Editable only when `install_addrs_chkbox` is checked |
| `edit_pin` | PIN Code | Yes | |
| `edit_phone` | Phone | Yes | Optional |
| `edit_mobile` | Mobile * | Conditional | Required if `is_mobile_no_mandatory=="1"`; min 10 digits; strips country code prefix (+91 → 10 digits) |
| `edit_email` | Email | Conditional | Required if `is_email_mandatory=="1"`; validates regex |
| `edit_acct_number` | Account Number | Conditional | Editable if `useAccountNumber==0`; locked if `useAccountNumber>0` |
| `edit_caf_number` | CAF Number | Yes | Min length 2 |
| `edit_username` | Username | Yes | Portal login username |
| `edit_password` | Password | Yes | Portal login password (cleared on load) |
| `edit_signup_date` | Signup Date | Yes | Date string |
| `edit_discount` | Discount | Yes | |
| `edit_latitude` | Latitude | Auto | GPS |
| `edit_longitude` | Longitude | Auto | GPS |
| `edit_lconum` | LCO Customer ID | Conditional | Required if `is_baid_mandatory=="1"`; min length 2 |
| `edit_idnumber` | ID Number | Yes | |
| `edit_dob` | Date of Birth | Yes | Date string |
| `edit_anniversary` | Anniversary Date | Yes | Date string |

#### Spinners

| Spinner ID | Label | Data Source |
|---|---|---|
| `edit_idtype` | ID Type | `getIdsRest` |
| `edit_custtype` | Customer Type | `getCustomerTypesRest` |
| `edit_country` | Country | `getCountriesRest` |
| `edit_state` | State | `getStatesRest` |
| `edit_district` | District | `getdistrictsRest` |
| `edit_city` | City | `getCitiesRest` |
| `edit_mandal` | Mandal | `getmandalsRest` |
| `edit_gender` | Gender | Static: Male/Female |
| `edit_acct_status` | Account Status | Static spinner |
| `edit_is_verified` | Is Verified | Static spinner |
| `edit_group` | Group | `getGroupsRest` |

#### Checkboxes

| Checkbox ID | Label | Effect |
|---|---|---|
| `edit_change_addr_chk` | "Change Billing Address?" | Reveals `address_layout` (full address form) |
| `edit_change_install_addr_chk` | "Change Installation Address?" | Reveals `install_address_layout` |
| `edit_upload_photo_chk` | "Upload Documents?" | Reveals `edit_upload_docs_ll` |

#### ImageViews (tappable)

| ImageView ID | Action |
|---|---|
| `edit_personal_idphoto` | Tap to open camera/gallery for ID photo |
| `edit_personal_photo` | Tap to open camera/gallery for customer photo |
| `edit_personal_signature` | Tap to open `CaptureSignature` activity |

#### Buttons

| Button | Label | Action |
|---|---|---|
| `edit_update_btn` | "Update" | Validates and calls `editCustomerRest` |
| `edit_integrate_aadhar` | "Link Aadhaar" | Aadhaar integration button |

### 8.2 Pre-Population from `EditCustomer_ResponseModel`

On screen load, the following are pre-populated from the response object passed via bundle (`"editdata"` parcelable):

| Field | Response Field |
|---|---|
| `et_firstname` | `getFirst_name()` |
| `et_lastname` | `getLast_name()` |
| `et_fathersname` | `getFathers_name()` |
| `et_billing_addr` | `getAddress1() + ", " + getAddress2()` |
| `et_pin` | `getPin_code()` |
| `et_businessname` | `getBusiness_name()` |
| `et_phone` | `getPhone_no()` |
| `et_mobile` | `getMobile_no()` (strips +91 prefix if length==12) |
| `et_emailid` | `getEmail()` |
| `et_caf_num` | `getCaf_no()` |
| `et_username` | `getUser_name()` |
| `et_password` | "" (always cleared) |
| `et_installation_addrs` | `getInstallation_address()` |
| `et_signup_date` | `getSignup_date()` |
| `et_loc_cust_id` (BAID) | `getBaid()` |
| `et_dob` | `getDate_of_birth()` |
| `et_anniversary_date` | `getAnniversary_date()` |
| `et_acct_number` | `getAccount_number()` |
| `sp_gender` | `getGender()` → 1=Male, 2=Female |

### 8.3 Account Number Field Lock Logic

```
if (LoginActivity.useAccountNumber == 0) {
    et_acct_number.setFocusable(true)   // user can edit
    et_acct_number.setEnabled(true)
} else {
    et_acct_number.setFocusable(false)  // auto-generated, locked
    et_acct_number.setEnabled(false)
}
```

### 8.4 Validation Rules (on "Update" tap)

| Rule | Condition | Error |
|---|---|---|
| First name | `firstName.isEmpty` | "First name should not be empty" |
| Last name | `is_lastname_mandatory=="1" AND lastName.isEmpty` | "'Last Name' should not be empty." |
| LCO Customer ID | `is_baid_mandatory=="1" AND lcoCustomerId.length < 2` | "Lco customer id should not be empty" |
| Mobile | `is_mobile_no_mandatory=="1" AND mobile.length < 10` | "Mobile number should not be empty/enter valid mobile number" |
| Account Number | `accountNo.length < 2` | "Account number should not be empty/enter valid account number" |
| CAF Number | `cafNo.length < 2` | "Caf number should not be empty/enter valid caf number" |
| Email | `email.notEmpty AND is_email_mandatory=="1" AND email !~ emailPattern` | "Email Id should not be empty/Enter valid Email Id" |

GPS location must be enabled (shows toast but does NOT block save if unavailable).

### 8.5 API Calls Made on Screen Load

Same cascade as New Customer Creation:
1. `dynamicformvalidationsRest` — get field mandatory rules
2. `getCountriesRest` — populate countries
3. `getGroupsRest` — populate groups
4. `getIdsRest` — populate ID types
5. `getCustomerTypesRest` — populate customer types
Then cascading on selection: states → districts → cities/mandals

### 8.6 API Call — Edit Customer

**Endpoint:** `POST /LcoRestServices/editCustomerRest`

**Request Payload:**

| Field | Type | Mandatory | Description |
|---|---|---|---|
| `authToken` | String | Yes | JWT |
| `customerId` | int | Yes | Customer ID from bundle |
| `firstName` | String | Yes | Updated first name |
| `lastName` | String | Conditional | Updated last name |
| `reseller_id` | int | No | Reseller ID |
| `customerTypeId` | int | No | Updated customer type |
| `gender` | String | Conditional | "1" or "2" |
| `group` | int | No | Updated group |
| `customer_sla_id` | int | No | SLA ID |
| `country` | int | No | Country ID |
| `state` | int | No | State ID |
| `district` | int | No | District ID |
| `city` | int | No | City ID |
| `mandal` | String | Conditional | Mandal ID |
| `email` | String | Conditional | Email |
| `mobile` | String | Conditional | Mobile |
| `phone` | String | No | Phone |
| `pin` | String | No | PIN code |
| `address1` | String | No | Billing address |
| `installationAddress` | String | No | Installation address |
| `cafNumber` | String | No | CAF number |
| `accountNumber` | String | Conditional | Account number |
| `baid` | String | Conditional | LCO customer ID |
| `idType` | int | No | ID type |
| `idNumber` | String | No | ID number |
| `idProofImg` | String | No | Base64 ID photo |
| `customerImg` | String | No | Base64 customer photo |
| `signatureImg` | String | No | Base64 signature |
| `latitude` | String | No | GPS latitude |
| `longitude` | String | No | GPS longitude |
| `dateofbirth` | String | No | DOB |
| `dateofanniversary` | String | No | Anniversary date |
| `discount` | int | No | Discount |

**Response Fields:** `status_code`, `status_msg`

---

## 9. SC-08 — Customer STB / Box Selection

**Class:** `Customer_STB_Select_Fragment.java`
**Layout:** `stb_select_fragment`
**Title:** "Select a Box"
**Purpose:** If a customer has multiple STBs, this screen shows all assigned boxes in a spinner. User selects one and taps "Done" to proceed with the operation.

### 9.1 UI Elements

| Element | ID | Label | Description |
|---|---|---|---|
| Spinner | `selectstb_spin_group` | Select Box | Lists all STBs for the customer |
| Button | `selectstb_btn_done` | "Done" | Fetches selected box details and navigates |

### 9.2 Bundle Received

| Key | Type | Description |
|---|---|---|
| `custId` | int | Customer ID |
| `operationType` | String | "boxOperation" or "packageOperation" |
| `reqOrigin` | String | Origin screen name |
| `pending_amount` | double | Outstanding amount |
| `resellerid` | int | Reseller ID |
| `bill_type` | int | Bill type |

### 9.3 API Call 1 — Get All Customer Boxes

**Endpoint:** `POST /LcoRestServices/getCustomerBoxDetailsRest`

**Request Payload:**

| Field | Type | Mandatory | Description |
|---|---|---|---|
| `authToken` | String | Yes | JWT |
| `customerId` | int | Yes | Customer ID |

**Response Fields:**

| Field | Type | Description |
|---|---|---|
| `status_code` | int | 0 = success |
| `status_msg` | String | Error if any |
| `customerBoxList` | Array | List of box objects |
| `is_expired_service` | int | Flag if service is expired |

Each box in `customerBoxList` contains: serialNumber, vcNumber, boxNumber, macAddress, stockId, deviceId, backendSetupId, stockStatus.

**Auto-navigation:** If only 1 box found, the fragment auto-proceeds without user selection.

### 9.4 API Call 2 — Get Particular Box Details

**Endpoint:** `POST /LcoRestServices/getCustomerParticularBoxDetailsRest`

Triggered when user taps "Done".

**Request Payload:**

| Field | Type | Mandatory | Description |
|---|---|---|---|
| `authToken` | String | Yes | JWT |
| `customerId` | int | Yes | Customer ID |
| `stockId` | int | Yes | Selected STB stock ID |
| `userType` | String | Yes | From login |

**Response Fields:**

| Field | Type | Description |
|---|---|---|
| `status_code` | int | 0 = success |
| `status_msg` | String | |
| `stb_replacement_form_validations` | Object | STB-specific validation rules |
| `reasonList` | Array | Deactivation reason options |

The response data is combined with previously fetched box details and passed as a bundle to the operation screen (STB activation/deactivation/package screens).

---

## 10. SC-09 — Payment Receipt Display (Displayfrag)

**Class:** `Displayfrag.java`
**Layout:** `fragment_displayfrag`
**Title:** "Payment Details"
**Purpose:** Post-payment confirmation and receipt display. Supports print (via POS printer for N910 device) and share (SMS/WhatsApp via share intent).

### 10.1 UI Elements

| TextView ID | Label | Content |
|---|---|---|
| `paydetails_tv_custname` | Customer Name | From bundle `custName` |
| `paydetails_tv_custid` | Customer ID | From bundle `custID` |
| `paydetails_tv_mobileno` | Mobile No | From bundle `mobileNo` |
| `paydetails_tv_custadd` | Address | From bundle `custAddress` |
| `paydetails_tv_receiptno` | Receipt No | From bundle `recieptNo` |
| `paydetails_tv_dueamt` | Due Amount | `₹{dueAmt}` |
| `paydetails_tv_paidamt` | Paid Amount | `"Paid ₹{paidAmt}"` |
| `tv_transacresp` | Transaction Message | Full receipt message with amount + receipt no |
| `paydetails_tv_chequeno` | Cheque No | Visible only when `mode == "Bank"` |
| `paydetails_tv_bankname` | Bank Name | Visible only when `mode == "Bank"` |
| `paydetails_tv_branch` | Branch | Visible only when `mode == "Bank"` |

### 10.2 Buttons

| Button | Label | Action |
|---|---|---|
| `paydetails_btn` | "Done" | Confirmation dialog → navigate to MainActivity (home) |
| `printdetails_btn` | Print | Sends to POS printer (N910 hardware integration) |
| `sharepayment` | Share | Share receipt as text via Android share sheet (hidden on N910) |

### 10.3 Bundle Received

| Key | Type | Description |
|---|---|---|
| `custName` | String | Customer name |
| `custID` | int | Customer ID |
| `mobileNo` | long | Mobile number |
| `custAddress` | String | Customer address |
| `recieptNo` | String | Receipt number |
| `billAmt` | double | Bill amount |
| `dueAmt` | double | Due amount |
| `paidAmt` | double | Amount paid in this transaction |
| `outAmt` | double | Outstanding after payment |
| `CustomNo` | String | Custom number |
| `lcoName` | String | LCO name |
| `lastpaidAmt` | double | Last payment amount |
| `lastpaidDate` | String | Last payment date |
| `collEmp` | String | Collection employee |
| `mode` | String | Payment mode ("Cash", "Bank", etc.) |
| `format` | String | Receipt format |
| `finalpending` | String | Final pending after this payment |
| `cheque` | String | Cheque number (if mode="Bank") |
| `bankname` | String | Bank name (if mode="Bank") |
| `str_branch` | String | Branch name (if mode="Bank") |

---

## 11. SC-10 — Account Activation (POS Payment Terminal)

**Class:** `AccountActivation.java`
**Layout:** `activation`
**Purpose:** Used specifically for activating a merchant account on the POS payment terminal hardware. Not a general customer management screen — this is for hardware-specific payment terminal setup.

### 11.1 UI Elements

| Element | ID | Label | Description |
|---|---|---|---|
| EditText | `activation_edit` | Merchant Key | 12-character activation key |
| Button | `activation_btn` | "Activate" | Triggers account activation |

### 11.2 Validation

- Key must be exactly 12 characters.
- Uses `AccountValidator.accountActivation()` SDK call from PNSOl payment SDK.

### 11.3 Navigation

- On success: navigates to `ConnectionDevice` activity.
- On back press: returns to `CustomerMgmtActivity_MakePayment_Fragment`.

> **Flutter Note:** This screen is POS hardware-specific (`pnsol.sdk`). For the Flutter app targeting mobile devices, this entire flow can be replaced by standard Android payment integrations or omitted entirely if POS terminal hardware is not targeted.

---

## 12. SC-11 — Dashboard STB Count Fragments

These four fragments share identical structure. They all use the same Retrofit `Api.getassignedtsb()` call with a different `stbType` integer parameter.

### 12.1 Fragments and Their stbType Values

| Class | stbType | Displays |
|---|---|---|
| `AssignedSTB_CountsFrag` | 1 | All assigned STBs |
| `UnAssignedStb_Frag` | 2 | Unassigned STBs in stock |
| `TotalStbs_Frag` | 3 | All STBs total |
| `DashBoard_Active_Stb_Frag` | 4 | Active STBs |
| `DeactiveStb_Frag` | 5 | Deactivated STBs |

### 12.2 UI Elements (identical across all)

| Element | ID | Description |
|---|---|---|
| ListView | `listview1` | STB list rows, 15 per page |
| TextView | `tv_ttlcount` | Shows total count label |
| LinearLayout | `linear_scroll` | Horizontal scroll of page buttons (auto-generated) |

### 12.3 Pagination

- `rowSize = 15` items per page.
- Page buttons dynamically generated. Each button shows page number.

### 12.4 API Call (All Four Fragments)

**Endpoint (Retrofit):** `GET /api/getassignedtsb` (or equivalent REST endpoint)

**Parameters:**

| Field | Type | Description |
|---|---|---|
| `authToken` | String | JWT token (header) |
| `dealerId` | int | `LoginActivity.dealerId` |
| `stbType` | int | 1=assigned, 2=unassigned, 3=total, 4=active, 5=deactive |

**Response (via `Assignedstbresp`):**

| Field | Type | Description |
|---|---|---|
| `status_code` | int | 0 = success |
| `status_msg` | String | Error if any |
| `getOpenComplaintsModels` | List\<AssignedStbModel\> | STB records |

Each `AssignedStbModel` contains STB details displayed in the list (serial number, VC number, status, customer name etc.).

### 12.5 Response Handling

- `status==0`: Populate list, show count in `tv_ttlcount`.
- `status==1`: Show toast with error message + AlertDialog.
- Network error (`onFailure`): Toast with error message.

---

## 13. Backend Config Flags Reference

All these flags are received from the `validateLogin` API response and stored in `LoginActivity` static fields.

| Flag | Type | Values | Effect on Customer Screens |
|---|---|---|---|
| `useCRF` | int | 0 or 1 | 0 = label "CRF No"; 1 = label "CAF No". Controls CAF field visibility in new customer form. |
| `useCAF` | String | "AUTO", "MANUAL" | "AUTO" = hide CAF input, server generates; "MANUAL" = show and require CAF input |
| `useLastName` | int | 0 or 1 | 1 = show Last Name field; 0 = hide and use single name field |
| `useDiscount` | int | 0, 1, 2 | 0=hide discount; 1=show for DEALER/ADMIN/EMPLOYEE; 2=always show |
| `useAccountNumber` | int | 0 or 1+ | 0=user enters account no; >0=auto-generated, field hidden/locked |
| `useMandatoryForHotel` | int | 0 or 1 | 1=show customer sub-type spinner |
| `useDataFromMasterTable` | int | 0 or 1 | Data source for dropdowns |
| `freezecustomerparamsinapp` | int | 0 or 1 | Intended to lock customer fields (partial implementation) |
| `hidemakepayment` | int | 0 or 1 | 0=show payment button; 1=hide it |
| `int_bulk_payment` | int | 0 or 1 | 1=show payment button (from `getaccesscontrollRest`) |
| `int_stb_activation` | int | 0 or 1 | 1=box operations button visible |
| `int_stb_deactivation` | int | 0 or 1 | 1=box operations button visible |
| `int_stb_reactivation` | int | 0 or 1 | 1=box operations button visible |
| `invoice_page_access` | int | 0 or 1 | 1=Invoice History button visible |
| `payment_hist_page_access` | int | 0 or 1 | 1=Payment History button visible |
| `access_for_complaints` | int | 0 or 1 | 1=Complaint buttons visible |
| `patch_information` | String | version string | "1.4.13.2/3/4" = show Location and Update Location buttons |
| `defaultcountry` | String | ISO code | Pre-select country in address dropdowns |
| `defaultstate` | int | State ID | Pre-select state |
| `defaultdistrict` | int | District ID | Pre-select district |
| `defaultcity` | int | City ID | Pre-select city |

---

## 14. Form Validations Model — `dynamicformvalidationsRest`

This endpoint returns per-field mandatory rules from the server, allowing operators to configure which fields are required without an app update.

**Endpoint:** `POST /LcoRestServices/dynamicformvalidationsRest`

**Request Payload:**

| Field | Type | Description |
|---|---|---|
| `authToken` | String | JWT |
| `table_name` | String | Database table name — "customer_details" for customer forms |
| `dealerId` | int | Dealer ID |

**Response:** Array of `FormValidations_Model` objects.

### 14.1 FormValidations_Model Fields

| Field | Type | Description |
|---|---|---|
| `column_name` | String | Database column name |
| `is_mandatory` | String | "1" = mandatory, "0" = optional |

### 14.2 Known column_name Values and Their Effect

| `column_name` | Mapped Flag | UI Effect |
|---|---|---|
| `last_name` | `is_lastname_mandatory` | Adds red `*` to Last Name label; validates on save |
| `email` | `is_email_mandatory` | Adds red `*` to Email label; validates format and emptiness |
| `id_type` | `is_id_type_mandatory` | Adds red `*` to Id Type label; validates selection |
| `id_number` | `is_id_number_mandatory` | Adds red `*` to Id Number label; validates emptiness |
| `gender` | `is_gender_mandatory` | Adds red `*` to Gender label; validates selection |
| `mobile_no` | `is_mobile_no_mandatory` | Adds red `*` to Mobile label; validates min 10 digits |
| `baid` | `is_baid_mandatory` | Adds red `*` to LCO Customer ID label; validates emptiness |
| `mandal_id` | `is_mandal_id_mandatory` | Adds red `*` to Mandal label; validates selection |

> **Flutter Implementation:** Call `dynamicformvalidationsRest` on entry to both New Customer and Edit Customer screens. Store results in a map keyed by `column_name`. Before rendering labels, check map for mandatory status and append the red asterisk indicator to the label. Run corresponding validation on form submit.

---

## 15. Address Cascading Dropdown Logic

Both New Customer and Edit Customer forms implement a 5-level cascading address hierarchy:

```
Country → State → District → City
                           ↘ Mandal (from District)
```

### 15.1 Cascade Trigger Points

| Selection | Triggers |
|---|---|
| Country selected | Load States (using country ISO code) |
| State selected | Load Districts (using stateId) |
| District selected | Load Cities (using stateId) AND Load Mandals (using districtId) |
| Mandal selected | Optionally load Cities-by-Mandal |

### 15.2 API Calls for Address Cascade

| Step | Endpoint | Request | Response |
|---|---|---|---|
| Load Countries | `POST /LcoRestServices/getCountriesRest` | (none) | `countriesList[]` → `{iso, name}` |
| Load States | `POST /LcoRestServices/getStatesRest` | `countryCode` (ISO) | `statesList[]` → `{stateId, stateName}` |
| Load Districts | `POST /LcoRestServices/getdistrictsRest` | `stateId` | `districtList[]` → `{districtId, districtName}` |
| Load Cities | `POST /LcoRestServices/getCitiesRest` | `stateId`, `boxNumber` | `citiesList[]` → `{cityId, cityName}` |
| Load Mandals | `POST /LcoRestServices/getmandalsRest` | `districtId` | `mandalList[]` → `{mandalId, mandalName}` |
| Load Cities by Mandal | `POST /LcoRestServices/getLocationsOfDistrictRest` | `districtId` | `districtLocationsList[]` |

### 15.3 Default Values

Defaults are set from login response:
- `defaultcountry` (String ISO code) — pre-select in country spinner
- `defaultstate` (int ID) — pre-select in state spinner after countries load
- `defaultdistrict` (int ID) — pre-select in district spinner after states load
- `defaultcity` (int ID) — pre-select in city spinner after districts load

On Edit screen: pre-selected values come from `EditCustomer_ResponseModel` (the existing customer data).

---

## 16. Master Data API Calls Summary

All master data endpoints are V2 REST POST calls. Use JWT in header.

| Endpoint | Purpose | Key Request Param | Key Response Field |
|---|---|---|---|
| `getCountriesRest` | Country list for dropdowns | (none) | `countriesList` |
| `getStatesRest` | States for a country | `countryCode` (ISO) | `statesList` |
| `getdistrictsRest` | Districts for a state | `stateId` | `districtList` |
| `getCitiesRest` | Cities for a state | `stateId`, `boxNumber` | `citiesList` |
| `getmandalsRest` | Mandals for a district | `districtId` | `mandalList` |
| `getLocationsOfDistrictRest` | Alternate city list (by mandal) | `districtId` | `districtLocationsList` |
| `getGroupsRest` | Customer groups | `serialNumber` | `groupsList` |
| `getCustomerTypesRest` | Customer types | (none) | `customerTypeList` |
| `getcustomerTypeTypesRest` | Customer sub-types | `resellerId`, `customerTypeId` | `customerTypeTypesInfoList` |
| `getIdsRest` | ID proof types | (none) | `idList` |
| `dynamicformvalidationsRest` | Mandatory field rules | `table_name`, `dealerId` | Array of `{column_name, is_mandatory}` |
| `getCasPackagesRest` | Available packages for STB | `boxNumber` | `caspackageList` |

---

*End of Customer Management Documentation*
