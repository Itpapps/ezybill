# EzyBill API Request/Response Samples & Type Mapping

> Extracted from `api_test.html` and `api_responses.json`.
> Every field's server-side type is documented precisely.

**Base URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices`

**Auth:** All endpoints (except validateLogin) require `Authorization: Bearer <token>` header.

**Encryption:** All payloads are triple-hex-encoded. Request sends `payload=<encrypted>&hash=<hex>`. Response returns `{hash: "<hex-encoded-json>"}`.

**Content-Type:** `application/x-www-form-urlencoded`

---

## Table of Contents

1. [Authentication](#1-authentication)
2. [Dashboard](#2-dashboard)
3. [Customer](#3-customer)
4. [Payments](#4-payments)
5. [Complaints](#5-complaints)
6. [STB / Box Operations](#6-stb--box-operations)
7. [Packages / Services](#7-packages--services)
8. [Reports](#8-reports)
9. [Employees](#9-employees)
10. [Master Data](#10-master-data)
11. [MASTER MISMATCH SUMMARY](#11-master-mismatch-summary)

---

## 1. Authentication

### 1.1 validateLogin

**Endpoint:** `POST /validateLogin`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| UserName | String | Yes | Login username |
| PassWord | String | Yes | Login password |
| imei | String | No | Device IMEI |
| mobile_no | String | No | Mobile number |

**Request Payload Example:**
```json
{
  "UserName": "58948",
  "PassWord": "1234",
  "imei": "",
  "mobile_no": ""
}
```

**Response Sample:**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "token": "eyJ0eXAiOiJKV1Q...",
  "employeeId": "1054",
  "first_name": "MD.ABDUL WAJEED",
  "last_name": "",
  "address1": "13-5-610/3/3/1,...",
  "address2": null,
  "address3": null,
  "copy_rights": " ",
  "short_name": " ",
  "pin_code": "500028",
  "phone": null,
  "email": "mohdwajeedgulshan75@gmail.com",
  "country": "IN",
  "state": "101",
  "district": "20",
  "city": "2",
  "username": "58948",
  "dob": null,
  "adate": null,
  "employeeName": "MD.ABDUL WAJEED",
  "dealerId": "1",
  "userType": "RESELLER",
  "useCRF": "1",
  "useCAF": "MANUAL",
  "useLastName": "1",
  "useDiscount": "1",
  "useDataFromMasterTable": "1",
  "useMandatoryForHotel": "1",
  "useAccountNumber": "1",
  "employeeParentId": null,
  "employeeParentType": null,
  "useLcoDeposit": "1",
  "deposit_amount": "7467.76",
  "defaultCountry": "IN",
  "country_name": "INDIA",
  "defaultState": "101",
  "defaultDistrict": "20",
  "defaultCity": "-1",
  "recurringServiceEdit": "0",
  "showLcoComplaint": "0",
  "lcoCode": "58948",
  "lcoLocation": "GULSHAN STAR NETWORK",
  "lcoMobileNo": "919963575490",
  "freezecustomerparamsinapp": "0",
  "blockpayment": 0,
  "business_name": "GULSHAN STAR NETWORK",
  "is_unpaidlco": "0",
  "appMenuFormat": "DEFAULT",
  "invoicepaymentsearchlimit": "600",
  "lco_billtype": "0",
  "use_lco_deposits": "1",
  "userNotifications": [],
  "notifyCount": 0,
  "note_duration": 0,
  "customer_billtype": "0",
  "AUTO_RECEIPT_NUMBER": "1",
  "CURRENCY_CODE": "ts. ",
  "allow_top_up": 1,
  "show_caf_mobile_validation": 0,
  "patch_information": "1.4.10",
  "stb_pairing": 1,
  "stb_unpairing": 1,
  "show_mia_agreement_upload": "1",
  "accept_terms_condtions": "0",
  "agreement_details_count": 0,
  "access_distributor_wise": "0",
  "is_direct_lco": 0,
  "show_serial_vc": 0,
  "user_image": "",
  "show_service_extension": "1",
  "config_values_array": {
    "min_mobile_length": "10",
    "max_mobile_length": "10",
    "pincode_length": "6",
    "country_code": "91"
  },
  "edit_quantity": "1",
  "enable_box_wise_payment": "0",
  "baid_label": ""
}
```

**Type Mapping: LoginResponse**

| Server Field | Server Type | Server Example | Model Field | Model Type | Status |
|---|---|---|---|---|---|
| status_code | int literal | `0` | statusCode | int | MATCH |
| status_msg | String | `"Success"` | statusMsg | String | MATCH |
| token | String | `"eyJ..."` | token | String | MATCH |
| employeeId | **String** | `"1054"` | employeeId | **int** | **MISMATCH** - server sends String, model expects int |
| dealerId | **String** | `"1"` | dealerId | **int** | **MISMATCH** - server sends String, model expects int |
| first_name | String | `"MD.ABDUL WAJEED"` | firstName | String | MATCH |
| last_name | String | `""` | lastName | String | MATCH |
| email | String | `"mohdwaj..."` | email | String | MATCH |
| phone | **null** | `null` | phone | String (default '') | **MISMATCH** - server sends null, model default handles it |
| lcoCode | String | `"58948"` | lcoCode | String | MATCH |
| business_name | String | `"GULSHAN..."` | businessName | String | MATCH |
| employeeParentType | **null** | `null` | employeeParentType | String (default '') | **MISMATCH** - null vs default '' |
| employeeParentId | **null** | `null` | employeeParentId | String (default '') | **MISMATCH** - null vs default '' |
| username | String | `"58948"` | username | String? | MATCH |
| user_image | String | `""` | logoImg | String? | MATCH |
| address1 | String | `"13-5-..."` | address1 | String | MATCH |
| address2 | **null** | `null` | address2 | String (default '') | **MISMATCH** - null vs default '' |
| address3 | **null** | `null` | address3 | String (default '') | **MISMATCH** - null vs default '' |
| dob | **null** | `null` | dob | String (default '') | **MISMATCH** - null vs default '' |
| adate | **null** | `null` | adate | String (default '') | **MISMATCH** - null vs default '' |
| useCRF | **String** | `"1"` | useCRF | **int** | **MISMATCH** - String-encoded int |
| useLastName | **String** | `"1"` | useLastName | **int** | **MISMATCH** - String-encoded int |
| useDiscount | **String** | `"1"` | useDiscount | **int** | **MISMATCH** - String-encoded int |
| useDataFromMasterTable | **String** | `"1"` | useDataFromMasterTable | **int** | **MISMATCH** - String-encoded int |
| useMandatoryForHotel | **String** | `"1"` | useMandatoryForHotel | **int** | **MISMATCH** - String-encoded int |
| useAccountNumber | **String** | `"1"` | useAccountNumber | **int** | **MISMATCH** - String-encoded int |
| freezecustomerparamsinapp | **String** | `"0"` | freezecustomerparamsinapp | **int** | **MISMATCH** - String-encoded int |
| blockpayment | int literal | `0` | blockpayment | int | MATCH |
| deposit_amount | **String** | `"7467.76"` | depositAmount | **double** | **MISMATCH** - String-encoded double |
| lco_billtype | **String** | `"0"` | lcoBilltype | **int** | **MISMATCH** - String-encoded int |
| use_lco_deposits | **String** | `"1"` | useLcoDeposit | **int** | **MISMATCH** - String-encoded int |
| customer_billtype | **String** | `"0"` | customerBilltype | **int** | **MISMATCH** - String-encoded int |
| AUTO_RECEIPT_NUMBER | **String** | `"1"` | autoReceiptNumber | **int** | **MISMATCH** - String-encoded int |
| CURRENCY_CODE | String | `"ts. "` | currencyCode | String | MATCH |
| allow_top_up | int literal | `1` | allowTopUp | int | MATCH |
| show_caf_mobile_validation | int literal | `0` | showCafMobileValidation | int | MATCH |
| stb_pairing | int literal | `1` | stbPairing | int | MATCH |
| stb_unpairing | int literal | `1` | stbUnpairing | int | MATCH |
| show_mia_agreement_upload | **String** | `"1"` | showMiaAgreementUpload | **int** | **MISMATCH** - String-encoded int |
| accept_terms_condtions | **String** | `"0"` | acceptTermsConditions | **int** | **MISMATCH** - String-encoded int |
| agreement_details_count | int literal | `0` | agreementDetailsCount | int | MATCH |
| access_distributor_wise | **String** | `"0"` | accessDistributorWise | **int** | **MISMATCH** - String-encoded int |
| is_direct_lco | int literal | `0` | isDirectLco | int | MATCH |
| is_unpaidlco | **String** | `"0"` | isUnpaidlco | **int** | **MISMATCH** - String-encoded int |
| invoicepaymentsearchlimit | **String** | `"600"` | invoicePaymentSearchLimit | **int** | **MISMATCH** - String-encoded int |
| lcoMobileNo | **String** | `"919963575490"` | lcoMobileNo | **int** | **MISMATCH** - String-encoded number, too large for int! |
| recurringServiceEdit | **String** | `"0"` | recurringServiceEdit | **int** | **MISMATCH** - String-encoded int |
| showLcoComplaint | **String** | `"0"` | showLcoComplaint | **int** | **MISMATCH** - String-encoded int |
| show_serial_vc | int literal | `0` | showSerialVc | int | MATCH |
| show_service_extension | **String** | `"1"` | showServiceExtension | **int** | **MISMATCH** - String-encoded int |
| edit_quantity | **String** | `"1"` | editQuantity | **int** | **MISMATCH** - String-encoded int |
| enable_box_wise_payment | **String** | `"0"` | enableBoxWisePayment | **int** | **MISMATCH** - String-encoded int |
| defaultState | **String** | `"101"` | defaultState | **int?** | **MISMATCH** - String-encoded int |
| defaultDistrict | **String** | `"20"` | defaultDistrict | **int?** | **MISMATCH** - String-encoded int |
| defaultCity | **String** | `"-1"` | defaultCity | **int?** | **MISMATCH** - String-encoded int |
| userNotifications | **empty array** | `[]` | userNotifications | **int** (default 0) | **MISMATCH** - server sends [], model expects int |
| notifyCount | int literal | `0` | notifyCount | int | MATCH |
| note_duration | int literal | `0` | noteDuration | int | MATCH |
| config_values_array | **Object** | `{...}` | *(not mapped)* | *(missing)* | **MISSING** - not in model |
| useLcoDeposit | **String** | `"1"` | *(not mapped by JsonKey 'useLcoDeposit')* | | Note: model maps `use_lco_deposits` |

> **CRITICAL:** The `_sanitizeLoginJson()` function in the model handles most String-to-int conversions. However, `lcoMobileNo` is a phone number string ("919963575490") mapped to `int` -- this will overflow on 32-bit or be wrong. It should be `String`.

### 1.2 getAccessControl

**Endpoint:** `POST /getaccesscontrollRest`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

**Response Sample:**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "int_bulk_payment": 0,
  "invoice_page_access": 0,
  "payment_hist_page_access": 0,
  "access_for_complaints": 1,
  "int_stb_activation": "1",
  "int_stb_deactivation": "1",
  "int_stb_reactivation": "1",
  "int_payment_transaction_report_access": 1
}
```

**Type Mapping: AccessControlResponse**

| Server Field | Server Type | Server Example | Model Field | Model Type | Status |
|---|---|---|---|---|---|
| status_code | int literal | `0` | statusCode | int | MATCH |
| status_msg | String | `"Success"` | statusMsg | String | MATCH |
| int_bulk_payment | int literal | `0` | intBulkPayment | int | MATCH |
| invoice_page_access | int literal | `0` | invoicePageAccess | int | MATCH |
| payment_hist_page_access | int literal | `0` | paymentHistPageAccess | int | MATCH |
| access_for_complaints | int literal | `1` | accessForComplaints | int | MATCH |
| int_stb_activation | **String** | `"1"` | intStbActivation | **int** | **MISMATCH** - String-encoded int (sanitizer handles) |
| int_stb_deactivation | **String** | `"1"` | intStbDeactivation | **int** | **MISMATCH** - String-encoded int (sanitizer handles) |
| int_stb_reactivation | **String** | `"1"` | intStbReactivation | **int** | **MISMATCH** - String-encoded int (sanitizer handles) |
| int_payment_transaction_report_access | int literal | `1` | *(not mapped)* | | **MISSING** from model |
| pgtransaction | *(not in response)* | | pgtransaction | int | **EXTRA** in model only |

> Note: `_sanitizeAclJson()` converts all String values to int. This handles the STB activation mismatches.

---

## 2. Dashboard

### 2.1 dashBoardDetails

**Endpoint:** `POST /dashBoardDetailsRest`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

**Response Sample:**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "totalStbs": 790,
  "totalAssignedStbs": 0,
  "totalUnAssignedStbs": 216,
  "totalComplaints": 0,
  "totalClosedComplaints": 0,
  "totalActiveCustomers": 538,
  "totalDeactiveCustomers": 0,
  "totalCurrentMonthBill": 0,
  "totalDueAmount": 0,
  "totalPaidCustomers": 0,
  "totalUnPaidCustomers": 0,
  "gettotalPaidCustomers": -1,
  "gettotalUnPaidCustomers": -1,
  "outStandingAmount": "139655.05",
  "msoShare": 28242.499999999993,
  "totalActiveAssignedStbs": 538,
  "totalCurrentMonthMsoShare": 26095.1,
  "currentMonthOutstanding": "46.34",
  "currentMonthLCOBill": 0,
  "lcocurrentmonthdueamount": null
}
```

**Type Mapping: DashboardResponse**

| Server Field | Server Type | Server Example | Model Field | Model Type | Status |
|---|---|---|---|---|---|
| status_code | int literal | `0` | statusCode | int | MATCH |
| totalStbs | int literal | `790` | totalStbs | int | MATCH |
| totalAssignedStbs | int literal | `0` | totalAssignedStbs | int | MATCH |
| totalUnAssignedStbs | int literal | `216` | totalUnAssignedStbs | int | MATCH |
| totalComplaints | int literal | `0` | totalComplaints | int | MATCH |
| totalClosedComplaints | int literal | `0` | totalClosedComplaints | int | MATCH |
| totalActiveCustomers | int literal | `538` | totalActiveCustomers | int | MATCH |
| totalDeactiveCustomers | int literal | `0` | totalDeactiveCustomers | int | MATCH |
| totalCurrentMonthBill | int literal | `0` | totalCurrentMonthBill | double | MATCH (int auto-casts to double) |
| totalDueAmount | int literal | `0` | totalDueAmount | double | MATCH |
| totalPaidCustomers | int literal | `0` | totalPaidCustomers | int | MATCH |
| totalUnPaidCustomers | int literal | `0` | totalUnPaidCustomers | int | MATCH |
| gettotalPaidCustomers | int literal | `-1` | gettotalPaidCustomers | int | MATCH |
| gettotalUnPaidCustomers | int literal | `-1` | gettotalUnPaidCustomers | int | MATCH |
| outStandingAmount | **String** | `"139655.05"` | outStandingAmount | **double** | **MISMATCH** - String-encoded double (sanitizer handles) |
| msoShare | float literal | `28242.499999999993` | msoShare | double | MATCH |
| totalCurrentMonthMsoShare | float literal | `26095.1` | totalCurrentMonthMsoShare | double | MATCH |
| currentMonthOutstanding | **String** | `"46.34"` | currentMonthOutstanding | **double** | **MISMATCH** - String-encoded double (sanitizer handles) |
| currentMonthLCOBill | int literal | `0` | currentMonthLCOBill | double | MATCH |
| lcocurrentmonthdueamount | **null** | `null` | lcuCurrentMonthDueAmount | double (default 0.0) | **MISMATCH** - null vs double (sanitizer handles) |
| totalActiveAssignedStbs | int literal | `538` | *(not mapped)* | | **MISSING** from model |

> Note: `_sanitize()` in DashboardResponse handles String-to-double and null-to-default conversions.

### 2.2 lcoDepositAmount

**Endpoint:** `POST /lco_deposit_amountRest`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

**Response Sample:**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "deposit_amount": "7467.76"
}
```

**Type Mapping: WalletResponse (reused)**

| Server Field | Server Type | Server Example | Model Field | Model Type | Status |
|---|---|---|---|---|---|
| status_code | int literal | `0` | statusCode | int | MATCH |
| deposit_amount | **String** | `"7467.76"` | lcoDepositAmount | **double** | **MISMATCH** - String-encoded double (sanitizer handles) |
| status_msg | String | `"Success"` | *(not mapped)* | | **MISSING** from WalletResponse |

### 2.3 getLcoWallet

**Endpoint:** `POST /getlcowalletRest`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

**Response Sample (error):**
```json
{
  "status_code": 1,
  "status_msg": "Start Date is  required."
}
```

> Note: This endpoint apparently requires date parameters but the HTML test tool sends none. The `WalletHistoryEntry` model maps the `paymentresult` array items.

### 2.4 getDashboardList

**Endpoint:** `POST /getdashboardlist`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

> No response sample available. This endpoint likely returns dashboard list data.

### 2.5 expiryServicesCount

**Endpoint:** `POST /getExpiryServicesDateWiseCount`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

**Response Sample:**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "getExpiryServicesList": [
    {
      "date": "2026-03-25",
      "stb_count": "3"
    },
    {
      "date": "2026-03-26",
      "stb_count": "5"
    }
  ]
}
```

**Type Mapping: ExpiryServicesResponse / ExpiryDateCount**

| Server Field | Server Type | Server Example | Model Field | Model Type | Status |
|---|---|---|---|---|---|
| status_code | int literal | `0` | statusCode | int | MATCH |
| status_msg | String | `"Success"` | statusMsg | String | MATCH |
| getExpiryServicesList | Array | `[...]` | expiryServicesList | List<ExpiryDateCount> | MATCH |
| date | String | `"2026-03-25"` | date | String | MATCH |
| stb_count | **String** | `"3"` | stbCount | **int** | **MISMATCH** - String-encoded int (sanitizer handles) |

---

## 3. Customer

### 3.1 customerDetailsCount

**Endpoint:** `POST /getCustomerDetailsCountRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerNumber | String | No | Customer number filter |
| customerName | String | No | Name filter |
| mobileNumber | String | No | Mobile filter |
| boxNumber | String | No | STB/VC filter |
| lcoCustomerId | String | No | LCO Customer ID filter |

**Request Payload Example:**
```json
{
  "customerNumber": "",
  "customerName": "",
  "mobileNumber": "",
  "boxNumber": "",
  "lcoCustomerId": ""
}
```

**Response Sample:**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "customerCount": "512"
}
```

**Type Mapping: WalletResponse (reused for count)**

| Server Field | Server Type | Server Example | Model Field | Model Type | Status |
|---|---|---|---|---|---|
| customerCount | **String** | `"512"` | customerCount | **int** | **MISMATCH** - String-encoded int (sanitizer handles) |

### 3.2 customerDetails

**Endpoint:** `POST /getCustomerDetailsRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerNumber | String | No | Customer number filter |
| customerName | String | No | Name filter |
| mobileNumber | String | No | Mobile filter |
| boxNumber | String | No | STB/VC filter |
| lcoCustomerId | String | No | LCO Customer ID filter |
| cafNumber | String | No | CAF number filter |
| startValue | int | No | Pagination start (default 0) |
| endValue | int | No | Pagination end (default 20) |

**Request Payload Example:**
```json
{
  "customerNumber": "",
  "customerName": "",
  "mobileNumber": "",
  "boxNumber": "",
  "lcoCustomerId": "",
  "cafNumber": "",
  "startValue": 0,
  "endValue": 20
}
```

**Response Sample:**
```json
{
  "statusCode": 0,
  "statusMessage": "Success",
  "customerDetailsList": [
    {
      "customer_id": "1413",
      "reseller_id": "1054",
      "online_customer": "0",
      "customerName": "shiva  ",
      "caf_no": "13528363",
      "mobile_no": "918341679239",
      "status": "1",
      "billing_address": "HNO.13-2-2663, PURANI PULL,HYDERABAD,Telangana,INDIA",
      "installation_address": "HNO.13-2-2663, PURANI PULL,HYDERABAD,Hyderabad,Telangana,INDIA",
      "pin_code": "2339",
      "crf_number": "",
      "stb_count": "1",
      "account_number": "13528363",
      "pending_amount": "0.00",
      "latitude": "0.0",
      "longitude": "0.0",
      "bill_type": "1",
      "baid": null,
      "is_direct_lco": "0"
    }
  ],
  "total_amount": 0,
  "mso_share": 0,
  "tot_mso_share": "0.00",
  "lco_share": 0,
  "baid_label": ""
}
```

**Type Mapping: CustomerSearchResponse**

| Server Field | Server Type | Server Example | Model Field | Model Type | Status |
|---|---|---|---|---|---|
| statusCode | int literal | `0` | statusCode | int | MATCH |
| statusMessage | String | `"Success"` | statusMsg (JsonKey: 'statusMessage') | String? | MATCH |
| customerDetailsList | Array | `[...]` | existCustomerDetails (JsonKey: 'customerDetailsList') | List<CustomerModel> | MATCH |
| total_amount | int literal | `0` | totalAmount | double | MATCH |
| mso_share | int literal | `0` | msoShare | double | MATCH |
| tot_mso_share | **String** | `"0.00"` | *(not mapped)* | | **MISSING** - tot_mso_share not in model |
| lco_share | int literal | `0` | lcoShare | double | MATCH |
| baid_label | String | `""` | baidLabel | String? | MATCH |

**Type Mapping: CustomerModel (list items)**

| Server Field | Server Type | Server Example | Model Field | Model Type | Status |
|---|---|---|---|---|---|
| customer_id | **String** | `"1413"` | customerId | String | MATCH |
| reseller_id | **String** | `"1054"` | resellerId | String? | MATCH |
| online_customer | **String** | `"0"` | onlineCustomer | **int** | **MISMATCH** - String-encoded int (sanitizer handles) |
| customerName | String | `"shiva  "` | customerName | String | MATCH |
| caf_no | String | `"13528363"` | cafNumber | String? | MATCH |
| mobile_no | String | `"918341679239"` | mobileNumber | String? | MATCH |
| status | **String** | `"1"` | status | String | MATCH (both String) |
| billing_address | String | `"HNO..."` | billingAddress | String? | MATCH |
| installation_address | String | `"HNO..."` | installationAddress | String? | MATCH |
| pin_code | String | `"2339"` | pinCode | String? | MATCH |
| crf_number | String | `""` | crfNumber | String? | MATCH |
| stb_count | **String** | `"1"` | stbCount | **int** | **MISMATCH** - String-encoded int (sanitizer handles) |
| account_number | String | `"13528363"` | accountNumber | String? | MATCH |
| pending_amount | **String** | `"0.00"` | pendingAmount | **double** | **MISMATCH** - String-encoded double (sanitizer handles) |
| latitude | **String** | `"0.0"` | latitude | **double** | **MISMATCH** - String-encoded double (sanitizer handles) |
| longitude | **String** | `"0.0"` | longitude | **double** | **MISMATCH** - String-encoded double (sanitizer handles) |
| bill_type | String | `"1"` | billType | String? | MATCH |
| baid | **null** | `null` | baid | String? | MATCH |
| is_direct_lco | **String** | `"0"` | isDirectLco | **int** | **MISMATCH** - String-encoded int (sanitizer handles) |

### 3.3 existingCustomer

**Endpoint:** `POST /existingCustomerRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| mobileNumber | String | Yes | Mobile number to check |

**Request Payload Example:**
```json
{
  "mobileNumber": "9876543210"
}
```

**Response Sample:**
```json
{
  "status_code": 1,
  "status_msg": "Customer Details Not found",
  "existCustomerDetails": []
}
```

### 3.4 saveCustomer

**Endpoint:** `POST /saveCustomerRest`

**Request Parameters:** JSON body via textarea (SaveCustomerRequest fields)

**Request Payload Example:**
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "mobileNumber": "9876543210",
  "email": "john@example.com",
  "billingAddress1": "123 Main St",
  "installationAddress1": "123 Main St",
  "pinCode": "500028",
  "countryCode": "IN",
  "stateId": "101",
  "districtId": "20"
}
```

### 3.5 editCustomer

**Endpoint:** `POST /editCustomerRest`

**Request Parameters:** JSON body via textarea (EditCustomerRequest fields)

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "firstName": "John Updated",
  "mobileNumber": "9876543210",
  "changeAddress": false,
  "changeInstallAddress": false,
  "uploadDocs": false
}
```

### 3.6 updateCustomerLocation

**Endpoint:** `POST /updateCustomerLocation`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerId | String | Yes | Customer ID |
| latitude | float | Yes | GPS latitude (sent as parseFloat) |
| longitude | float | Yes | GPS longitude (sent as parseFloat) |

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "latitude": 17.385044,
  "longitude": 78.486671
}
```

---

## 4. Payments

### 4.1 getPendingAmount

**Endpoint:** `POST /getPendingAmountRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| altCustomerId | String | Yes | Alt customer ID |
| serial_no | String | No | Serial number |

**Request Payload Example:**
```json
{
  "altCustomerId": "13528363"
}
```

> No response sample in api_responses.json. Expected fields: pendingAmount, customerName, msoShare, lcoShare, billingId.

### 4.2 getPaymentModes

**Endpoint:** `POST /getPaymentModesRest`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

**Response Sample:**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "paymentModesList": [
    {
      "paymentModeId": "1",
      "PaymentModeName": "Cash"
    },
    {
      "paymentModeId": "2",
      "PaymentModeName": "Bank"
    },
    {
      "paymentModeId": "6",
      "PaymentModeName": "Card"
    },
    {
      "paymentModeId": "10",
      "PaymentModeName": "Voucher"
    }
  ]
}
```

**Type Mapping: PaymentMode**

| Server Field | Server Type | Server Example | Model Field (JsonKey) | Model Type | Status |
|---|---|---|---|---|---|
| paymentModeId | String | `"1"` | paymentModeId | String | MATCH |
| PaymentModeName | String (capital P) | `"Cash"` | paymentModeName (lowercase p) | String | **MISMATCH** - JsonKey `'paymentModeName'` vs server `'PaymentModeName'` (capital P) |

> **CRITICAL:** Server sends `PaymentModeName` (capital P), model expects `paymentModeName` (lowercase p). This will cause the field to be null/missing at runtime, crashing on `required`.

### 4.3 makePayment

**Endpoint:** `POST /makePaymentsRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| altCustomerId | String | Yes | Alt customer ID |
| amount | String | Yes | Payment amount (sent as string from gv()) |
| modeType | String | Yes | e.g. CASH, CHEQUE, ONLINE |
| receipt_number | String | No | Receipt number |
| altReceiptNumber | String | No | Alt receipt number |
| billingId | String | No | Billing ID |
| remarks | String | No | Remarks |
| chequeNo | String | No | Cheque number |
| bank | String | No | Bank name |
| branch | String | No | Branch name |
| chequeDate | String | No | YYYY-MM-DD |
| rrnNo | String | No | RRN number |

**Request Payload Example:**
```json
{
  "altCustomerId": "13528363",
  "amount": "500",
  "modeType": "CASH",
  "receipt_number": "REC001",
  "remarks": "Monthly payment"
}
```

> Note: HTML sends `receipt_number` but model MakePaymentRequest uses `receiptNumber`. The server endpoint name is `/makePaymentsRest`.

### 4.4 getReceiptRanges

**Endpoint:** `POST /getReceiptRanges`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

**Response Sample:**
```json
{
  "status_code": 1,
  "status_msg": "No Receipt range found.",
  "ReceiptRanges": []
}
```

> Note: List key is `ReceiptRanges` (capital R). No ReceiptRange items in sample.

### 4.5 getBillDetails

**Endpoint:** `POST /getbilldetailsRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| serial_number | String | Yes | Serial number |
| package_id | String | Yes | Package ID |
| customer_id | String | Yes | Customer ID |
| bill_type | int | No | Bill type (sent as parseInt) |
| employee_id | int | No | Employee ID (sent as parseInt) |

**Request Payload Example:**
```json
{
  "serial_number": "ABC123",
  "package_id": "456",
  "customer_id": "1413"
}
```

### 4.6 paymentHistory

**Endpoint:** `POST /PaymentServiceRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerId | String | Yes | Customer ID |
| fromDate | String | No | YYYY-MM-DD |
| toDate | String | No | YYYY-MM-DD |

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "fromDate": "2026-01-01",
  "toDate": "2026-03-27"
}
```

---

## 5. Complaints

### 5.1 getComplaintList

**Endpoint:** `POST /getComplaintList`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| serviceemployeeid | int | No | Employee ID (sent as parseInt, default 0) |
| login_users_type | String | No | Default "RESELLER" |

**Request Payload Example:**
```json
{
  "serviceemployeeid": 0,
  "login_users_type": "RESELLER"
}
```

**Response Sample:**
```json
{
  "status_code": 1,
  "status_msg": "No records found.",
  "lcoComplaintlist": []
}
```

### 5.2 totalComplaintsList

**Endpoint:** `POST /gettotalcomplaintslist`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| serviceemployeeid | int | No | Employee ID (default 0) |
| login_users_type | String | No | Default "RESELLER" |

**Request Payload Example:**
```json
{
  "serviceemployeeid": 0,
  "login_users_type": "RESELLER"
}
```

### 5.3 customerComplaints

**Endpoint:** `POST /getCustomerComplaintListRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerId | String | Yes | Customer ID |

**Request Payload Example:**
```json
{
  "customerId": "1413"
}
```

### 5.4 complaintCategories

**Endpoint:** `POST /complaintCategoriesRest`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

**Response Sample:**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "complaintCategories": [
    {
      "categoryId": "6",
      "categoryName": "adszxvv",
      "parent_category_id": "0"
    },
    {
      "categoryId": "1",
      "categoryName": "TEST",
      "parent_category_id": "0"
    }
  ]
}
```

**Type Mapping: ComplaintCategory**

| Server Field | Server Type | Server Example | Model Field | Model Type | Status |
|---|---|---|---|---|---|
| categoryId | **String** | `"6"` | categoryId | **int** | **MISMATCH** - String-encoded int, NO sanitizer! Will crash |
| categoryName | String | `"adszxvv"` | categoryName | String | MATCH |
| parent_category_id | **String** | `"0"` | *(not mapped)* | | **MISSING** from model |

> **CRITICAL:** `ComplaintCategory.fromJson` has no sanitizer. Server sends `categoryId` as String `"6"`, model expects `required int`. This WILL throw a type cast error.

### 5.5 complaintSubCategories

**Endpoint:** `POST /getComplaintsubCategory`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| categoryId | String | Yes | Category ID |

**Request Payload Example:**
```json
{
  "categoryId": "1"
}
```

> **CRITICAL:** `ComplaintSubcategory` model expects `required int subCategoryId` and `required int categoryId`. If server sends these as Strings (likely based on pattern), there is no sanitizer and it will crash.

### 5.6 complaintTypes

**Endpoint:** `POST /complaintTypesRest`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

**Response Sample:**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "complaintStatuses": [
    { "value": "ASSIGNED" },
    { "value": "INPROCESS" },
    { "value": "ONHOLD" },
    { "value": "RESOLVED" },
    { "value": "CLOSED" },
    { "value": "REOPEN" }
  ],
  "ticket_closer_categories": []
}
```

> Note: This returns simple `{value: String}` objects. No dedicated model -- likely parsed as raw map.

### 5.7 createComplaint

**Endpoint:** `POST /createComplaintRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerId | String | Yes | Customer ID |
| category | int | Yes | Category ID (sent as parseInt) |
| complaint | String | Yes | Complaint description |
| error | String | No | Error details |
| assignedTo | int | No | Employee ID (sent as optFieldInt) |

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "category": 1,
  "complaint": "Signal issue"
}
```

> Note: HTML sends `category` and `complaint` as field names. The CreateComplaintRequest model uses `categoryId` and `description`. These are the names sent TO the server -- the server may accept different field names.

### 5.8 closeComplaint

**Endpoint:** `POST /closeComplaintRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| complaintId | String | Yes | Complaint ID |
| remarks | String | No | Closing remarks |

**Request Payload Example:**
```json
{
  "complaintId": "123",
  "remarks": "Issue resolved"
}
```

---

## 6. STB / Box Operations

### 6.1 customerBoxDetails

**Endpoint:** `POST /getCustomerBoxDetailsRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerId | String | Yes | Customer ID |

**Request Payload Example:**
```json
{
  "customerId": "1413"
}
```

### 6.2 particularBoxDetails

**Endpoint:** `POST /getCustomerParticularBoxDetailsRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerId | String | Yes | Customer ID |
| serialNumber | String | Yes | Serial number |

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "serialNumber": "ABC123"
}
```

### 6.3 deactivateBox

**Endpoint:** `POST /deactivateBoxRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerId | String | Yes | Customer ID |
| serialNumber | String | Yes | Serial number |
| reasonId | String | Yes | Deactivation reason ID |
| remarks | String | No | Remarks |

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "serialNumber": "ABC123",
  "reasonId": "17"
}
```

### 6.4 reactivateBox

**Endpoint:** `POST /reactivateBoxRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerId | String | Yes | Customer ID |
| serialNumber | String | Yes | Serial number |

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "serialNumber": "ABC123"
}
```

### 6.5 deactivationReasons

**Endpoint:** `POST /getDeactiveReasonsRest`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

**Response Sample:**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "reasonList": [
    {
      "reasonId": "6",
      "reasonName": "Deactivation Package Change",
      "display_name": "Deactivation Package Change",
      "act_deact_reason_id": "0",
      "global_reason": "0"
    },
    {
      "reasonId": "17",
      "reasonName": "Unpaid Customer",
      "display_name": "Unpaid Customer",
      "act_deact_reason_id": "2",
      "global_reason": "1"
    }
  ]
}
```

**Type Mapping: DeactivationReason**

| Server Field | Server Type | Server Example | Model Field (JsonKey) | Model Type | Status |
|---|---|---|---|---|---|
| reasonId | **String** | `"6"` | reasonId | **int** | **MISMATCH** - String-encoded int, NO sanitizer! Will crash |
| reasonName | String | `"Deactivation..."` | reasonName | String | MATCH |
| display_name | String | `"Deactivation..."` | *(not mapped)* | | **MISSING** from model |
| act_deact_reason_id | String | `"0"` | *(not mapped)* | | **MISSING** from model |
| global_reason | **String** | `"0"` | globalReason (JsonKey: 'globalReason') | **int?** | **MISMATCH** - JsonKey doesn't match server key `global_reason`, AND String vs int |
| *(not in response)* | | | disableForDpo | int? | **EXTRA** in model only |

> **CRITICAL:** `DeactivationReason.fromJson` has no sanitizer. `reasonId` as String `"6"` into `required int` WILL crash. Also `globalReason` JsonKey doesn't match server's `global_reason`.

### 6.6 temporaryActivation

**Endpoint:** `POST /temporaryActivationRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerId | String | Yes | Customer ID |
| serialNumber | String | Yes | Serial number |
| days | int | Yes | Number of days (sent as parseInt) |

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "serialNumber": "ABC123",
  "days": 7
}
```

### 6.7 stbPair

**Endpoint:** `POST /stbPairRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerId | String | Yes | Customer ID |
| stbNumber | String | Yes | STB number |
| vcNumber | String | Yes | VC number |

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "stbNumber": "STB001",
  "vcNumber": "VC001"
}
```

### 6.8 stbUnpair

**Endpoint:** `POST /stbUnpairRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerId | String | Yes | Customer ID |
| serialNumber | String | Yes | Serial number |

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "serialNumber": "ABC123"
}
```

### 6.9 stbReplacement

**Endpoint:** `POST /stb_replacement`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerId | String | Yes | Customer ID |
| oldSerialNumber | String | Yes | Old serial number |
| newSerialNumber | String | Yes | New serial number |

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "oldSerialNumber": "OLD001",
  "newSerialNumber": "NEW001"
}
```

---

## 7. Packages / Services

### 7.1 customerPackages

**Endpoint:** `POST /getCustomerPackages_splitRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerId | String | Yes | Customer ID |
| serialNumber | String | Yes | Serial number |

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "serialNumber": "ABC123"
}
```

### 7.2 unassignedPackages

**Endpoint:** `POST /getUnassignedPackages_splitRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerId | String | Yes | Customer ID |
| serialNumber | String | Yes | Serial number |

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "serialNumber": "ABC123"
}
```

### 7.3 activateService

**Endpoint:** `POST /activateServiceRest`

**Request Parameters:** JSON body via textarea

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "serialNumber": "ABC123",
  "packageId": "456"
}
```

### 7.4 deactivateService

**Endpoint:** `POST /deactivateServiceRest`

**Request Parameters:** JSON body via textarea

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "serialNumber": "ABC123",
  "packageId": "456"
}
```

### 7.5 extendService

**Endpoint:** `POST /extendCustomerServices`

**Request Parameters:** JSON body via textarea

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "serialNumber": "ABC123",
  "packageId": "456",
  "months": 1
}
```

### 7.6 casPackages

**Endpoint:** `POST /getCasPackagesRest`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

### 7.7 channelList

**Endpoint:** `POST /channel_listRest`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

---

## 8. Reports

### 8.1 dailyReport

**Endpoint:** `POST /DailyreportRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| fromDate | String | No | YYYY-MM-DD |
| toDate | String | No | YYYY-MM-DD |

**Request Payload Example:**
```json
{
  "fromDate": "2026-03-27",
  "toDate": "2026-03-27"
}
```

**Response Sample (error - no date):**
```json
{
  "status_code": 1,
  "status_msg": "Date is  required."
}
```

### 8.2 empCollection

**Endpoint:** `POST /empCollectionRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| fromDate | String | No | YYYY-MM-DD |
| toDate | String | No | YYYY-MM-DD |

**Request Payload Example:**
```json
{
  "fromDate": "2026-03-01",
  "toDate": "2026-03-27"
}
```

**Response Sample:**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "collectionList": [
    {
      "employee_id": null,
      "name": null,
      "Amt": null
    }
  ]
}
```

**Type Mapping: EmpCollectionSummary**

| Server Field | Server Type | Server Example | Model Field (JsonKey) | Model Type | Status |
|---|---|---|---|---|---|
| employee_id | **null** | `null` | employeeId (JsonKey: 'employeeId') | **String (required)** | **MISMATCH** - JsonKey `'employeeId'` vs server `'employee_id'`, AND null vs required String |
| name | **null** | `null` | name | **String (required)** | **MISMATCH** - null vs required String. Will crash |
| Amt | **null** | `null` | amt (JsonKey: 'amt') | **double (required)** | **MISMATCH** - JsonKey `'amt'` vs server `'Amt'` (capital A), AND null vs required double |

> **CRITICAL:** Three mismatches in EmpCollectionSummary:
> 1. `employee_id` vs `employeeId` (snake_case vs camelCase)
> 2. `Amt` vs `amt` (capital A)
> 3. All fields can be null but model uses `required`

### 8.3 empCustomerCollection

**Endpoint:** `POST /empCustomerCollectionDetailsRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| employeeId | String | Yes | Employee ID |
| fromDate | String | No | YYYY-MM-DD |
| toDate | String | No | YYYY-MM-DD |

**Request Payload Example:**
```json
{
  "employeeId": "1054",
  "fromDate": "2026-03-01",
  "toDate": "2026-03-27"
}
```

### 8.4 invoiceHistory

**Endpoint:** `POST /InvoiceServiceRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerId | String | Yes | Customer ID |
| fromDate | String | No | YYYY-MM-DD |
| toDate | String | No | YYYY-MM-DD |

**Request Payload Example:**
```json
{
  "customerId": "1413",
  "fromDate": "2026-01-01",
  "toDate": "2026-03-27"
}
```

---

## 9. Employees

### 9.1 lcoEmployeeList

**Endpoint:** `POST /getLcoEmployeeList`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

**Response Sample:**
```json
{
  "status_code": 1,
  "status_msg": "Please Enter LCO Id",
  "lcoEmployeelist": []
}
```

### 9.2 serviceEmployeeList

**Endpoint:** `POST /getServiceEmployeeList`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

**Response Sample:**
```json
{
  "status_code": 1,
  "status_msg": "No Services Employees.",
  "getServiceEmployeeList": []
}
```

---

## 10. Master Data

### 10.1 getCountries

**Endpoint:** `POST /getCountriesRest`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

**Response Sample (truncated):**
```json
{
  "status_code": 0,
  "status_msg": "1054",
  "countriesList": [
    { "iso": "AD", "name": "ANDORRA" },
    { "iso": "IN", "name": "INDIA" }
  ]
}
```

**Type Mapping: Country**

| Server Field | Server Type | Server Example | Model Field | Model Type | Status |
|---|---|---|---|---|---|
| iso | String | `"AD"` | iso | String | MATCH |
| name | String | `"ANDORRA"` | name | String | MATCH |
| *(not in response)* | | | numcode | int? | OK (nullable) |

### 10.2 getStates

**Endpoint:** `POST /getStatesRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| countryId | String | Yes | Country ID |

**Request Payload Example:**
```json
{
  "countryId": "IN"
}
```

**Response Sample:**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "statesList": [
    {
      "id": "66",
      "name": "Andhra Pradesh",
      "country_code": "IN"
    }
  ]
}
```

**Type Mapping: StateModel**

| Server Field | Server Type | Server Example | Model Field (JsonKey) | Model Type | Status |
|---|---|---|---|---|---|
| id | **String** | `"66"` | id | **int** | **MISMATCH** - String-encoded int, NO sanitizer! Will crash |
| name | String | `"Andhra Pradesh"` | name | String | MATCH |
| country_code | String | `"IN"` | countryCode (JsonKey: 'countryCode') | String | **MISMATCH** - JsonKey `'countryCode'` vs server `'country_code'` |

> **CRITICAL:** `StateModel.fromJson` has no sanitizer. `id` as String `"66"` into `required int` WILL throw. Also `countryCode` JsonKey doesn't match server's `country_code`.

### 10.3 getDistricts

**Endpoint:** `POST /getdistrictsRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| stateId | String | Yes | State ID |

**Request Payload Example:**
```json
{
  "stateId": "101"
}
```

**Response Sample:**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "districtList": [
    {
      "district_id": "15",
      "district_name": "Adilabad",
      "state_id": "101"
    }
  ]
}
```

**Type Mapping: District**

| Server Field | Server Type | Server Example | Model Field (JsonKey) | Model Type | Status |
|---|---|---|---|---|---|
| district_id | **String** | `"15"` | id (JsonKey: 'id') | **int** | **MISMATCH** - JsonKey `'id'` vs server `'district_id'`, AND String vs int |
| district_name | String | `"Adilabad"` | name (JsonKey: 'name') | String | **MISMATCH** - JsonKey `'name'` vs server `'district_name'` |
| state_id | **String** | `"101"` | stateId (JsonKey: 'stateId') | **int** | **MISMATCH** - JsonKey `'stateId'` vs server `'state_id'`, AND String vs int |

> **CRITICAL:** Every single field in District has a JsonKey mismatch with the server response. The model will receive all nulls and crash on `required`.

### 10.4 getCities

**Endpoint:** `POST /getCitiesRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| districtId | String | Yes | District ID |

**Request Payload Example:**
```json
{
  "districtId": "20"
}
```

**Response Sample (error):**
```json
{
  "status_code": 1,
  "status_msg": "Box Number is  required."
}
```

> Note: This error suggests the endpoint may need different parameters than expected.

### 10.5 getMandals

**Endpoint:** `POST /getmandalsRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| districtId | String | Yes | District ID |

**Request Payload Example:**
```json
{
  "districtId": "20"
}
```

**Response Sample:**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "mandalList": [
    {
      "district_id": "20",
      "mandal_id": "1",
      "mandal_name": "Ameerpet"
    }
  ]
}
```

**Type Mapping: Mandal**

| Server Field | Server Type | Server Example | Model Field (JsonKey) | Model Type | Status |
|---|---|---|---|---|---|
| district_id | **String** | `"20"` | districtId (JsonKey: 'districtId') | **int** | **MISMATCH** - JsonKey `'districtId'` vs server `'district_id'`, AND String vs int |
| mandal_id | **String** | `"1"` | mandalId (JsonKey: 'mandalId') | **int** | **MISMATCH** - JsonKey `'mandalId'` vs server `'mandal_id'`, AND String vs int |
| mandal_name | String | `"Ameerpet"` | mandalName (JsonKey: 'mandalName') | String | **MISMATCH** - JsonKey `'mandalName'` vs server `'mandal_name'` |

> **CRITICAL:** Every field in Mandal has a JsonKey mismatch. Same pattern as District.

### 10.6 getLocations

**Endpoint:** `POST /getLocationsOfDistrictRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| districtId | String | Yes | District ID |

**Request Payload Example:**
```json
{
  "districtId": "20"
}
```

### 10.7 getGroups

**Endpoint:** `POST /getGroupsRest`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

**Response Sample (error):**
```json
{
  "status_code": 0,
  "status_msg": "Undefined property: stdClass::$serialNumber"
}
```

> Note: Even with status_code 0, this is a server-side error. No groups list returned.

### 10.8 getCustomerTypes

**Endpoint:** `POST /getCustomerTypesRest`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

**Response Sample:**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "customerTypeList": [
    {
      "customer_type_id": "4",
      "customer_type": "Commercial",
      "description": "Commercial",
      "status": "1",
      "is_commercial_multi_box": "0",
      "enable_display": "0"
    },
    {
      "customer_type_id": "2",
      "customer_type": "Residence",
      "description": "Residence",
      "status": "1",
      "is_commercial_multi_box": "0",
      "enable_display": "1"
    }
  ]
}
```

**Type Mapping: CustomerType**

| Server Field | Server Type | Server Example | Model Field (JsonKey) | Model Type | Status |
|---|---|---|---|---|---|
| customer_type_id | **String** | `"4"` | customerTypeId (JsonKey: 'customerTypeId') | **int** | **MISMATCH** - JsonKey `'customerTypeId'` vs server `'customer_type_id'`, AND String vs int |
| customer_type | String | `"Commercial"` | customerType (JsonKey: 'customerType') | String | **MISMATCH** - JsonKey `'customerType'` vs server `'customer_type'` |
| is_commercial_multi_box | **String** | `"0"` | isCommercialMultiBox (JsonKey: 'isCommercialMultiBox') | **int?** | **MISMATCH** - JsonKey `'isCommercialMultiBox'` vs server `'is_commercial_multi_box'`, AND String vs int |
| description | String | `"Commercial"` | *(not mapped)* | | **MISSING** from model |
| status | String | `"1"` | *(not mapped)* | | **MISSING** from model |
| enable_display | String | `"0"` | *(not mapped)* | | **MISSING** from model |

> **CRITICAL:** All mapped fields have JsonKey mismatches with server keys.

### 10.9 customerTypeTypes

**Endpoint:** `POST /getcustomerTypeTypesRest`

**Request Parameters:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerTypeId | String | Yes | Customer Type ID |

**Request Payload Example:**
```json
{
  "customerTypeId": "1"
}
```

### 10.10 getIdTypes

**Endpoint:** `POST /getIdsRest`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

**Response Sample:**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "idList": [
    {
      "id_type_id": "1",
      "type": "PAN"
    },
    {
      "id_type_id": "5",
      "type": "AADHAR CARD"
    }
  ]
}
```

**Type Mapping: IdType**

| Server Field | Server Type | Server Example | Model Field (JsonKey) | Model Type | Status |
|---|---|---|---|---|---|
| id_type_id | **String** | `"1"` | id (JsonKey: 'id') | **int** | **MISMATCH** - JsonKey `'id'` vs server `'id_type_id'`, AND String vs int |
| type | String | `"PAN"` | name (JsonKey: 'name') | String | **MISMATCH** - JsonKey `'name'` vs server `'type'` |

> **CRITICAL:** Both fields have JsonKey mismatches.

### 10.11 formValidations

**Endpoint:** `POST /dynamicformvalidationsRest`

**Request Parameters:** None (JWT token only)

**Request Payload:** `{}`

> No response sample available.

---

## 11. MASTER MISMATCH SUMMARY

### CRASH-LEVEL Mismatches (No sanitizer, will throw at runtime)

These models have NO `_sanitize()` function and will crash when the server sends String-encoded numbers:

| Model | File | Field | Server Sends | Model Expects | Fix Needed |
|-------|------|-------|-------------|---------------|------------|
| **ComplaintCategory** | complaint_category.dart | categoryId | String `"6"` | `required int` | Add sanitizer or change to String |
| **ComplaintSubcategory** | complaint_subcategory.dart | subCategoryId, categoryId | String (likely) | `required int` | Add sanitizer or change to String |
| **DeactivationReason** | deactivation_reason.dart | reasonId | String `"6"` | `required int` | Add sanitizer or change to String |
| **StateModel** | state_model.dart | id | String `"66"` | `required int` | Add sanitizer AND fix JsonKey |
| **District** | district.dart | id (district_id), stateId (state_id) | String `"15"` | `required int` | Fix JsonKey AND add sanitizer |
| **Mandal** | mandal.dart | districtId (district_id), mandalId (mandal_id) | String `"1"` | `required int` | Fix JsonKey AND add sanitizer |
| **CustomerType** | customer_type.dart | customerTypeId (customer_type_id) | String `"4"` | `required int` | Fix JsonKey AND add sanitizer |
| **IdType** | id_type.dart | id (id_type_id) | String `"1"` | `required int` | Fix JsonKey AND add sanitizer |
| **PaymentMode** | payment_mode.dart | PaymentModeName | String `"Cash"` | `required String` | Fix JsonKey case: `PaymentModeName` not `paymentModeName` |
| **EmpCollectionSummary** | emp_collection_summary.dart | employee_id, Amt | null / String | `required String`, `required double` | Fix JsonKey names AND handle nulls |

### JsonKey Name Mismatches (server key != model JsonKey)

| Model | Model JsonKey | Actual Server Key | Fix |
|-------|-------------|-------------------|-----|
| **PaymentMode** | `paymentModeName` | `PaymentModeName` | Change to `'PaymentModeName'` |
| **StateModel** | `countryCode` | `country_code` | Change to `'country_code'` |
| **District** | `id` | `district_id` | Change to `'district_id'` |
| **District** | `name` | `district_name` | Change to `'district_name'` |
| **District** | `stateId` | `state_id` | Change to `'state_id'` |
| **Mandal** | `districtId` | `district_id` | Change to `'district_id'` |
| **Mandal** | `mandalId` | `mandal_id` | Change to `'mandal_id'` |
| **Mandal** | `mandalName` | `mandal_name` | Change to `'mandal_name'` |
| **CustomerType** | `customerTypeId` | `customer_type_id` | Change to `'customer_type_id'` |
| **CustomerType** | `customerType` | `customer_type` | Change to `'customer_type'` |
| **CustomerType** | `isCommercialMultiBox` | `is_commercial_multi_box` | Change to `'is_commercial_multi_box'` |
| **IdType** | `id` | `id_type_id` | Change to `'id_type_id'` |
| **IdType** | `name` | `type` | Change to `'type'` |
| **DeactivationReason** | `globalReason` | `global_reason` | Change to `'global_reason'` |
| **EmpCollectionSummary** | `employeeId` | `employee_id` | Change to `'employee_id'` |
| **EmpCollectionSummary** | `amt` | `Amt` | Change to `'Amt'` |

### String-to-Number Mismatches (handled by existing sanitizers)

These models HAVE `_sanitize()` functions that convert String to int/double:

| Model | Fields Handled | Status |
|-------|---------------|--------|
| LoginResponse | 25+ int/double fields | HANDLED by `_sanitizeLoginJson` |
| AccessControlResponse | All int fields | HANDLED by `_sanitizeAclJson` |
| DashboardResponse | outStandingAmount, currentMonthOutstanding, etc. | HANDLED by `_sanitize` |
| WalletResponse | deposit_amount, customerCount | HANDLED by `_sanitize` |
| ExpiryDateCount | stb_count | HANDLED by `_sanitizeCount` |
| CustomerModel | online_customer, stb_count, pending_amount, lat/lng, is_direct_lco | HANDLED by `_sanitize` |
| CustomerSearchResponse | statusCode, customerCount, shares | HANDLED by `_sanitize` |
| PendingAmount | statusCode, pendingAmount, shares | HANDLED by `_sanitize` |
| PackageModel | is_base_package, base_price, taxes, etc. | HANDLED by `_sanitize` |

### LoginResponse Special Issues

| Field | Issue | Severity |
|-------|-------|----------|
| `lcoMobileNo` | Server sends String `"919963575490"` - mapped to `int`. This is a phone number (12 digits), exceeds 32-bit int range. Should be `String`. | HIGH |
| `userNotifications` | Server sends `[]` (empty array), model expects `int` (default 0). Sanitizer must handle List type. | HIGH |
| `config_values_array` | Server sends `{min_mobile_length, max_mobile_length, ...}` object. Not mapped in model at all. | MEDIUM |
| `useLcoDeposit` | Model has `@JsonKey(name: 'use_lco_deposits')` but server also sends `useLcoDeposit: "1"`. These are different keys. | LOW |

### Server Type Patterns Summary

The EzyBill API has inconsistent typing across endpoints:

| Pattern | Examples | Frequency |
|---------|----------|-----------|
| **String-encoded integers** | `"1"`, `"0"`, `"512"`, `"1054"` | VERY COMMON - most ID fields and boolean flags |
| **String-encoded doubles** | `"7467.76"`, `"0.00"`, `"139655.05"` | COMMON - all monetary amounts |
| **Integer literals** | `0`, `1`, `790`, `538` | COMMON - counts and some flags |
| **Float literals** | `28242.499999999993`, `26095.1` | RARE - only some calculated amounts |
| **null for missing** | `null` | COMMON - optional fields |
| **Empty string for missing** | `""` | COMMON - string fields |
| **Empty array for missing** | `[]` | UNCOMMON - userNotifications, empty lists |
| **Mixed types same field** | `blockpayment: 0` (int) vs `is_direct_lco: 0` (int) vs `is_direct_lco: "0"` (String in customer) | VERY COMMON - same field different types per endpoint |

> **Root Cause:** The PHP backend does not enforce consistent JSON types. Database values are often returned as-is (strings from MySQL), while calculated values may be int/float. Every Flutter model that receives numeric data MUST have a sanitizer that handles String, int, double, and null inputs.
