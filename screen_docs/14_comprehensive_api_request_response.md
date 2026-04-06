# EzyBill API - Comprehensive Request/Response Reference

> **SINGLE SOURCE OF TRUTH** for the Flutter team to fix all model parsing issues.
> Generated: 2026-03-27
> Server: `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices`
> Data source: Live server responses captured via Flutter app console logs + `api_responses.json`

---

## Table of Contents

1. [Server Configuration & Encryption](#server-configuration--encryption)
2. [Authentication Endpoints](#1-authentication)
3. [Dashboard Endpoints](#2-dashboard)
4. [Customer Management Endpoints](#3-customer-management)
5. [Payment Endpoints](#4-payments)
6. [Complaint Endpoints](#5-complaints)
7. [STB/Box Operation Endpoints](#6-stbbox-operations)
8. [Package/Service Endpoints](#7-packageservice-operations)
9. [Report Endpoints](#8-reports)
10. [Employee Endpoints](#9-employee-management)
11. [Master Data Endpoints](#10-master-data)
12. [Master Data Type Anomaly Table](#master-data-type-anomaly-table)

---

## Server Configuration & Encryption

### Base URL
```
http://183.83.216.66:8882/v2_release/index.php/LcoRestServices
```

### Authentication
- **Login:** No auth header required for `validateLogin`
- **All other endpoints:** `Authorization: Bearer <JWT_TOKEN>` header
- JWT token is returned by `validateLogin` response

### Payload Encryption (Triple Hex Encoding)

ALL POST bodies must be encrypted. The server expects:
```json
{
  "payload": "<encrypted_string>",
  "hash": "<hex_encoded_json>"
}
```

**Encryption algorithm (from `payload_encryption.dart`):**
1. JSON-encode the parameters -> hex-encode each byte = `hash`
2. Hex-encode each char of step 1 result
3. Hex-encode each char of step 2 result
4. Prepend 5 random digits + append 5 random digits = `payload`

**Decryption:** Server responses also come as `{payload, hash}`. Decode via `hash` field (single hex decode -> JSON).

### Status Code Convention

| Convention | Endpoints | Success | Failure |
|-----------|-----------|---------|---------|
| **Standard** | Most endpoints | `status_code: 0` | `status_code: 1` |
| **Inverted** | `getaccesscontrollRest` only | `status_code: 0` | `status_code: 1` |

> Note: The REST_API_V2_SERVICE_DOCUMENT.md says "1 = success, 0 = error" but the ACTUAL server responses consistently show `status_code: 0` for success across all tested endpoints. The Flutter app should treat `0 = success` as the standard.

---

## 1. AUTHENTICATION

### 1.1 Endpoint: `/LcoRestServices/validateLogin`

**Method:** POST
**Auth Required:** No (this is the login call)

**Request Parameters:**
```json
{
  "UserName": "58948",
  "PassWord": "password123",
  "mobile_no": "919963575490",
  "imei": "device-id-string"
}
```

**Response (Success -- status_code: 0):** VERIFIED FROM SERVER
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdXRodG9rZW4iOiI2OWMzODc1MmQzM2FkMi4yNTUwNTc3OCIsImlhdCI6MTc3NDQyNDkzOSwiZXhwIjoxNzgyMjAwOTM5fQ.JKhGKk4_-GhmVVZ01VXo9bNiXdcactky-F7Ng7G43cs",
  "employeeId": "1054",
  "first_name": "MD.ABDUL WAJEED",
  "last_name": "",
  "address1": "13-5-610/3/3/1,YOUSUFNAGAR,TAPPACHABUTRA,HYDERABAD-500028...",
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

**Response (Failure -- status_code: 1):**
```json
{
  "status_code": 1,
  "status_msg": "Invalid username or password"
}
```

**Field Type Map:**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| status_code | int | `0` | 0=success |
| status_msg | String | `"Success"` | |
| token | String | `"eyJ0eXAi..."` | JWT token |
| employeeId | **STRING** | `"1054"` | NOT int! Needs parseInt |
| first_name | String | `"MD.ABDUL WAJEED"` | |
| last_name | String | `""` | Can be empty string |
| address1 | String | `"13-5-610..."` | Long address |
| address2 | String/null | `null` | Nullable |
| address3 | String/null | `null` | Nullable |
| copy_rights | String | `" "` | Space character |
| short_name | String | `" "` | Space character |
| pin_code | **STRING** | `"500028"` | NOT int |
| phone | String/null | `null` | Nullable |
| email | String | `"mohdwajeed..."` | |
| country | **STRING** | `"IN"` | ISO code, not int |
| state | **STRING** | `"101"` | Needs parseInt |
| district | **STRING** | `"20"` | Needs parseInt |
| city | **STRING** | `"2"` | Needs parseInt |
| username | String | `"58948"` | |
| dob | String/null | `null` | Nullable |
| adate | String/null | `null` | Nullable |
| employeeName | String | `"MD.ABDUL WAJEED"` | |
| dealerId | **STRING** | `"1"` | NOT int! Needs parseInt |
| userType | String | `"RESELLER"` | |
| useCRF | **STRING** | `"1"` | Numeric string, treat as bool |
| useCAF | String | `"MANUAL"` | |
| useLastName | **STRING** | `"1"` | Numeric string |
| useDiscount | **STRING** | `"1"` | Numeric string |
| useDataFromMasterTable | **STRING** | `"1"` | Numeric string |
| useMandatoryForHotel | **STRING** | `"1"` | Numeric string |
| useAccountNumber | **STRING** | `"1"` | Numeric string |
| employeeParentId | String/null | `null` | Nullable |
| employeeParentType | String/null | `null` | Nullable |
| useLcoDeposit | **STRING** | `"1"` | Numeric string |
| deposit_amount | **STRING** | `"7467.76"` | NOT double! Needs parseDouble |
| defaultCountry | String | `"IN"` | |
| country_name | String | `"INDIA"` | |
| defaultState | **STRING** | `"101"` | Needs parseInt |
| defaultDistrict | **STRING** | `"20"` | Needs parseInt |
| defaultCity | **STRING** | `"-1"` | Can be "-1" |
| recurringServiceEdit | **STRING** | `"0"` | Numeric string |
| showLcoComplaint | **STRING** | `"0"` | Numeric string |
| lcoCode | String | `"58948"` | |
| lcoLocation | String | `"GULSHAN STAR NETWORK"` | |
| lcoMobileNo | String | `"919963575490"` | |
| freezecustomerparamsinapp | **STRING** | `"0"` | Numeric string |
| blockpayment | **int** | `0` | This one IS int |
| business_name | String | `"GULSHAN STAR NETWORK"` | |
| is_unpaidlco | **STRING** | `"0"` | Numeric string |
| appMenuFormat | String | `"DEFAULT"` | |
| invoicepaymentsearchlimit | **STRING** | `"600"` | Needs parseInt |
| lco_billtype | **STRING** | `"0"` | Numeric string |
| use_lco_deposits | **STRING** | `"1"` | Numeric string |
| userNotifications | **List** | `[]` | Empty array, NOT int! |
| notifyCount | **int** | `0` | Actual int |
| note_duration | **int** | `0` | Actual int |
| customer_billtype | **STRING** | `"0"` | Numeric string |
| AUTO_RECEIPT_NUMBER | **STRING** | `"1"` | Numeric string |
| CURRENCY_CODE | String | `"ts. "` | Has trailing space |
| allow_top_up | **int** | `1` | Actual int |
| show_caf_mobile_validation | **int** | `0` | Actual int |
| patch_information | String | `"1.4.10"` | Version string |
| stb_pairing | **int** | `1` | Actual int |
| stb_unpairing | **int** | `1` | Actual int |
| show_mia_agreement_upload | **STRING** | `"1"` | Numeric string |
| accept_terms_condtions | **STRING** | `"0"` | Note: typo in key name |
| agreement_details_count | **int** | `0` | Actual int |
| access_distributor_wise | **STRING** | `"0"` | Numeric string |
| is_direct_lco | **int** | `0` | Actual int |
| show_serial_vc | **int** | `0` | Actual int |
| user_image | String | `""` | Empty string |
| show_service_extension | **STRING** | `"1"` | Numeric string |
| config_values_array | **Map** | `{...}` | Nested object |
| config_values_array.min_mobile_length | **STRING** | `"10"` | Needs parseInt |
| config_values_array.max_mobile_length | **STRING** | `"10"` | Needs parseInt |
| config_values_array.pincode_length | **STRING** | `"6"` | Needs parseInt |
| config_values_array.country_code | **STRING** | `"91"` | Needs parseInt |
| edit_quantity | **STRING** | `"1"` | Numeric string |
| enable_box_wise_payment | **STRING** | `"0"` | Numeric string |
| baid_label | String | `""` | Empty string |

---

### 1.2 Endpoint: `/LcoRestServices/getaccesscontrollRest`

**Method:** POST
**Auth Required:** Yes (JWT Bearer token)

**Request Parameters:**
```json
{
  "employeeParentType": null,
  "dealer_id": 1,
  "userstype": "RESELLER",
  "employeeParentId": null,
  "authToken": "69c38752d33ad2.25505778"
}
```

**Response (Success -- status_code: 0):** VERIFIED FROM SERVER
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

**Field Type Map:**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| status_code | int | `0` | 0=success |
| status_msg | String | `"Success"` | |
| int_bulk_payment | **int** | `0` | Actual int |
| invoice_page_access | **int** | `0` | Actual int |
| payment_hist_page_access | **int** | `0` | Actual int |
| access_for_complaints | **int** | `1` | Actual int |
| int_stb_activation | **STRING** | `"1"` | NOT int! Mixed types |
| int_stb_deactivation | **STRING** | `"1"` | NOT int! Mixed types |
| int_stb_reactivation | **STRING** | `"1"` | NOT int! Mixed types |
| int_payment_transaction_report_access | **int** | `1` | Actual int |

> CRITICAL BUG: `int_stb_activation`, `int_stb_deactivation`, `int_stb_reactivation` are STRING despite the `int_` prefix and despite other fields in the same response being actual ints.

---

## 2. DASHBOARD

### 2.1 Endpoint: `/LcoRestServices/dashBoardDetailsRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "use_lco_deposits": "1",
  "lco_billtype": "0"
}
```

**Response (Success):** VERIFIED FROM SERVER
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
  "totalDeactiveAssignedStbs": 0,
  "totalCurrentMonthMsoShare": 26095.1,
  "currentMonthOutstanding": "46.34",
  "currentMonthLCOBill": 0,
  "lcocurrentmonthdueamount": null
}
```

**Field Type Map:**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| status_code | int | `0` | |
| totalStbs | int | `790` | |
| totalAssignedStbs | int | `0` | |
| totalUnAssignedStbs | int | `216` | |
| totalComplaints | int | `0` | |
| totalClosedComplaints | int | `0` | |
| totalActiveCustomers | int | `538` | |
| totalDeactiveCustomers | int | `0` | |
| totalCurrentMonthBill | int | `0` | |
| totalDueAmount | int | `0` | Could be 0 or decimal |
| totalPaidCustomers | int | `0` | |
| totalUnPaidCustomers | int | `0` | |
| gettotalPaidCustomers | int | `-1` | -1 = not available |
| gettotalUnPaidCustomers | int | `-1` | -1 = not available |
| outStandingAmount | **STRING** | `"139655.05"` | NOT double! |
| msoShare | **double** | `28242.499999999993` | Actual double (floating point noise) |
| totalActiveAssignedStbs | int | `538` | |
| totalDeactiveAssignedStbs | int | `0` | |
| totalCurrentMonthMsoShare | **double** | `26095.1` | Actual double |
| currentMonthOutstanding | **STRING** | `"46.34"` | NOT double! |
| currentMonthLCOBill | int | `0` | |
| lcocurrentmonthdueamount | **null** | `null` | Nullable! Can crash if not handled |

> CRITICAL: `outStandingAmount` and `currentMonthOutstanding` are STRING while `msoShare` and `totalCurrentMonthMsoShare` are actual doubles. Mixed types for monetary values IN THE SAME RESPONSE.

---

### 2.2 Endpoint: `/LcoRestServices/lco_deposit_amountRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{}
```
> Uses authenticated employee/dealer from JWT. No payload parameters needed.

**Response (Success):** VERIFIED FROM SERVER
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "deposit_amount": "7467.76"
}
```

**Field Type Map:**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| status_code | int | `0` | |
| status_msg | String | `"Success"` | |
| deposit_amount | **STRING** | `"7467.76"` | NOT double! Needs parseDouble |

---

### 2.3 Endpoint: `/LcoRestServices/getlcowalletRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "start_date": "2026-01-01",
  "end_date": "2026-03-27",
  "dealer_id": 1
}
```

**Response (Failure -- missing params):** VERIFIED FROM SERVER
```json
{
  "status_code": 1,
  "status_msg": "Start Date is  required."
}
```

**Response (Success):** NEEDS TESTING with valid date range
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "paymentresult": []
}
```

---

### 2.4 Endpoint: `/LcoRestServices/getdashboardlist`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "from_dashboard": 1,
  "dealer_id": 1
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "getDashboardDataList": []
}
```

---

### 2.5 Endpoint: `/LcoRestServices/getExpiryServicesDateWiseCount`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{}
```
> No payload parameters needed. Uses authenticated dealer from JWT.

**Response (Success):** VERIFIED FROM SERVER
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
    },
    {
      "date": "2026-03-27",
      "stb_count": "2"
    },
    {
      "date": "2026-03-28",
      "stb_count": "2"
    },
    {
      "date": "2026-03-29",
      "stb_count": "0"
    },
    {
      "date": "2026-03-30",
      "stb_count": "0"
    }
  ]
}
```

**Field Type Map (array items):**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| date | String | `"2026-03-25"` | Date format: YYYY-MM-DD |
| stb_count | **STRING** | `"3"` | NOT int! Needs parseInt |

---

## 3. CUSTOMER MANAGEMENT

### 3.1 Endpoint: `/LcoRestServices/getCustomerDetailsCountRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "customerNumber": "",
  "use_lco_deposits": "1",
  "customerName": "",
  "mobileNumber": "",
  "boxNumber": "",
  "lcoCustomerId": ""
}
```

**Response (Success):** VERIFIED FROM SERVER
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "customerCount": "512"
}
```

**Response (Not Found):**
```json
{
  "status_code": 1,
  "status_msg": "No customers found"
}
```

**Field Type Map:**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| status_code | int | `0` | |
| customerCount | **STRING** | `"512"` | NOT int! Needs parseInt |

---

### 3.2 Endpoint: `/LcoRestServices/getCustomerDetailsRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "customerNumber": "",
  "customerName": "",
  "mobileNumber": "",
  "boxNumber": "",
  "lcoCustomerId": "",
  "cafNumber": "",
  "startValue": 0,
  "endValue": 25
}
```

**Response (Success):** VERIFIED FROM SERVER
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

> WARNING: This endpoint uses `statusCode`/`statusMessage` (camelCase) NOT `status_code`/`status_msg` (snake_case) like all other endpoints!

**Field Type Map (top-level):**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| statusCode | int | `0` | NOTE: camelCase, not status_code! |
| statusMessage | String | `"Success"` | NOTE: camelCase! |
| customerDetailsList | List | `[...]` | Array of customer objects |
| total_amount | int | `0` | |
| mso_share | int | `0` | |
| tot_mso_share | **STRING** | `"0.00"` | NOT double! |
| lco_share | int | `0` | |
| baid_label | String | `""` | |

**Field Type Map (customerDetailsList items):**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| customer_id | **STRING** | `"1413"` | NOT int! Needs parseInt |
| reseller_id | **STRING** | `"1054"` | NOT int! |
| online_customer | **STRING** | `"0"` | Numeric string |
| customerName | String | `"shiva  "` | Has trailing spaces! |
| caf_no | **STRING** | `"13528363"` | Numeric string |
| mobile_no | String | `"918341679239"` | Includes country code |
| status | **STRING** | `"1"` | "1"=active |
| billing_address | String | `"HNO.13-2-2663..."` | |
| installation_address | String | `"HNO.13-2-2663..."` | |
| pin_code | **STRING** | `"2339"` | NOT int |
| crf_number | String | `""` | Can be empty |
| stb_count | **STRING** | `"1"` | NOT int! |
| account_number | **STRING** | `"13528363"` | Numeric string |
| pending_amount | **STRING** | `"0.00"` | NOT double! Needs parseDouble |
| latitude | **STRING** | `"0.0"` | NOT double! |
| longitude | **STRING** | `"0.0"` | NOT double! |
| bill_type | **STRING** | `"1"` | Numeric string |
| baid | String/null | `null` | Nullable |
| is_direct_lco | **STRING** | `"0"` | Numeric string |

---

### 3.3 Endpoint: `/LcoRestServices/existingCustomerRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "accountNumber": "13528363",
  "stbNumber": "",
  "cafNumber": "",
  "tempActivation": ""
}
```

**Response (Not Found):** VERIFIED FROM SERVER
```json
{
  "status_code": 1,
  "status_msg": "Customer Details Not found",
  "existCustomerDetails": []
}
```

**Response (Success):** NEEDS FULL TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "existCustomerDetails": [],
  "lcoShare": "0.00"
}
```

---

### 3.4 Endpoint: `/LcoRestServices/saveCustomerRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "customerTypeId": 2,
  "cafNumber": "CAF001",
  "businessName": "",
  "firstName": "John",
  "lastName": "Doe",
  "idType": 5,
  "idNumber": "123456789012",
  "fatherName": "Father Name",
  "gender": "Male",
  "group": 1
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "customer_id": "...",
  "online_customer": "...",
  "stb_count": "...",
  "email": "...",
  "pin_code": "...",
  "int_operation_id": "...",
  "form_validations": "...",
  "NCF_ENCF": "...",
  "dealer_id": "...",
  "array_dealer_setting": {}
}
```

---

### 3.5 Endpoint: `/LcoRestServices/editCustomerRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "reseller_id": 1054,
  "customerTypeId": 2,
  "gender": "Male",
  "group": 1,
  "customer_sla_id": 0,
  "country": 1,
  "state": 101,
  "district": 20
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success"
}
```

---

### 3.6 Endpoint: `/LcoRestServices/updateCustomerLocation`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "latitude": 17.3850,
  "longitude": 78.4867,
  "customer_id": 1413
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success"
}
```

---

## 4. PAYMENTS

### 4.1 Endpoint: `/LcoRestServices/getPendingAmountRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "altCustomerId": 1413,
  "serial_no": "STB_SERIAL_NUMBER"
}
```

**Response (Success):** VERIFIED FROM SERVER (from conversation logs)
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "pendingAmount": "0.00",
  "msoShare": "0.00",
  "lcoShare": "0.00",
  "paymentModesList": [
    {
      "paymentModeId": "1",
      "PaymentModeName": "Cash"
    }
  ]
}
```

**Field Type Map:**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| status_code | int | `0` | |
| pendingAmount | **STRING** | `"0.00"` | NOT double! |
| msoShare | **STRING** | `"0.00"` | NOT double! |
| lcoShare | **STRING** | `"0.00"` | NOT double! |
| paymentModesList | List | `[...]` | Array of payment mode objects |

---

### 4.2 Endpoint: `/LcoRestServices/makePaymentsRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "receipt_number": "REC001",
  "altCustomerId": 1413,
  "amount": 100.00,
  "authToken": "auth_token_string",
  "chequeNo": "",
  "bank": "",
  "branch": "",
  "chequeDate": "",
  "altReceiptNumber": "",
  "remarks": "Monthly payment"
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "error_msg": "",
  "digi_activation_from": "...",
  "statusMessage": "...",
  "modeType": "...",
  "use_lco_deposit": "...",
  "voucherCode": "...",
  "payment_records": [],
  "digi_key": "...",
  "receipt_number": "...",
  "customerBoxList": []
}
```

---

### 4.3 Endpoint: `/LcoRestServices/getPaymentModesRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{}
```

**Response (Success):** VERIFIED FROM SERVER
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

**Field Type Map (paymentModesList items):**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| paymentModeId | **STRING** | `"1"` | NOT int! |
| PaymentModeName | String | `"Cash"` | Note: PascalCase P |

---

### 4.4 Endpoint: `/LcoRestServices/getReceiptRanges`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{}
```

**Response (No Data):** VERIFIED FROM SERVER
```json
{
  "status_code": 1,
  "status_msg": "No Receipt range found.",
  "ReceiptRanges": []
}
```

---

### 4.5 Endpoint: `/LcoRestServices/getbilldetailsRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "serial_number": "STB_SERIAL",
  "package_id": 1,
  "bill_type": "0",
  "customer_id": 1413,
  "employee_id": 1054
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "dealer_id": "...",
  "array_dealer_setting": {},
  "enum_add_on_after_base": "...",
  "double_stb_discount": "...",
  "int_customer_id": "...",
  "end_time": "...",
  "service_enddate_time": "...",
  "ENABLE_PRORATA_DISCOUNT": "...",
  "arr_box_details": [],
  "arr_act_package_details": [],
  "tax_amount": "...",
  "extra_parameters": {}
}
```

---

### 4.6 Endpoint: `/LcoRestServices/pgTransactionLogs`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "dealer_id": 1,
  "payment_status": "-1",
  "start_date": "2026-01-01",
  "end_date": "2026-03-27"
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "paymentresult": []
}
```

---

### 4.7 Endpoint: `/LcoRestServices/PaymentServiceRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "dealer_id": 1,
  "customer_id": 1413
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "payment_details": []
}
```

---

### 4.8 Endpoint: `/LcoRestServices/customer_transaction_reponseRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "employee_id": 1054,
  "dealer_id": 1,
  "auth_key": "auth_key_string"
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "response_details": []
}
```

---

## 5. COMPLAINTS

### 5.1 Endpoint: `/LcoRestServices/getComplaintList`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "serviceemployeeid": 0,
  "login_users_type": "RESELLER"
}
```

**Response (No Data):** VERIFIED FROM SERVER
```json
{
  "status_code": 1,
  "status_msg": "No records found.",
  "lcoComplaintlist": []
}
```

---

### 5.2 Endpoint: `/LcoRestServices/gettotalcomplaintslist`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "dealer_id": 1
}
```

**Response:** NEEDS TESTING
```json
{
  "gettotalcomplaintslist": [],
  "getDashboardDataList": []
}
```

---

### 5.3 Endpoint: `/LcoRestServices/getCustomerComplaintListRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "altCustomerId": 1413,
  "status": "ALL",
  "userType": "RESELLER"
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "customerComplaintList": []
}
```

---

### 5.4 Endpoint: `/LcoRestServices/complaintCategoriesRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{}
```

**Response (Success):** VERIFIED FROM SERVER
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
      "categoryId": "5",
      "categoryName": "aefwe",
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

**Field Type Map (complaintCategories items):**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| categoryId | **STRING** | `"6"` | NOT int! |
| categoryName | String | `"TEST"` | |
| parent_category_id | **STRING** | `"0"` | NOT int! |

---

### 5.5 Endpoint: `/LcoRestServices/getComplaintsubCategory`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "complaintcategory": 1
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "complaintSubCategories": []
}
```

---

### 5.6 Endpoint: `/LcoRestServices/createComplaintRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "customerId": 1413,
  "assignedTo": 0,
  "complaint": "No signal on STB",
  "category": 1,
  "error": 0
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "requestId": "...",
  "requestServerIp": "...",
  "assignedTo": "...",
  "ticketNumber": "...",
  "Success": "...",
  "tkt_number": "...",
  "int_stb_reactivation": "..."
}
```

---

### 5.7 Endpoint: `/LcoRestServices/complaintTypesRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{}
```

**Response (Success):** VERIFIED FROM SERVER
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

---

### 5.8 Endpoint: `/LcoRestServices/closeComplaintRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "complaintId": 123,
  "ticketNumber": "TKT001",
  "comment": "Issue resolved",
  "assignedemp": 1054,
  "status": "CLOSED",
  "closer_ticket_type_id": 0,
  "closer_reason_id": 0
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success"
}
```

---

### 5.9 Endpoint: `/LcoRestServices/ComplaintHistoryRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "dealer_id": 1,
  "customer_id": 1413
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "complaint_details": []
}
```

---

## 6. STB/BOX OPERATIONS

### 6.1 Endpoint: `/LcoRestServices/getCustomerBoxDetailsRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "customerId": 1413
}
```

**Response (Success):** VERIFIED FROM SERVER (from conversation logs)
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "customerBoxList": [
    {
      "stock_id": "12345",
      "serial_number": "STB_SERIAL",
      "vc_number": "VC_NUMBER",
      "box_number": "BOX_NUMBER",
      "mac_address": "MAC_ADDR",
      "device_id": "1",
      "backend_setup_id": "1",
      "status": "1",
      "is_temp_deactivated": "0",
      "stb_type": "SD",
      "cas_name": "CAS_NAME"
    }
  ],
  "is_expired_service": "0"
}
```

**Field Type Map (customerBoxList items):**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| stock_id | **STRING** | `"12345"` | NOT int! |
| serial_number | String | `"STB_SERIAL"` | |
| vc_number | String | `"VC_NUMBER"` | |
| box_number | String | `"BOX_NUMBER"` | |
| mac_address | String | `"MAC_ADDR"` | |
| device_id | **STRING** | `"1"` | NOT int! |
| backend_setup_id | **STRING** | `"1"` | NOT int! |
| status | **STRING** | `"1"` | NOT int! |
| is_temp_deactivated | **STRING** | `"0"` | NOT bool! |
| stb_type | String | `"SD"` | |
| cas_name | String | `"CAS_NAME"` | |

---

### 6.2 Endpoint: `/LcoRestServices/getCustomerParticularBoxDetailsRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "customerId": 1413,
  "stockId": 12345,
  "userType": "RESELLER"
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "stb_replacement_form_validations": {},
  "reasonList": []
}
```

---

### 6.3 Endpoint: `/LcoRestServices/deactivateBoxRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "customerId": 1413,
  "serialNumber": "STB_SERIAL",
  "vcNumber": "VC_NUMBER",
  "boxNumber": "BOX_NUMBER",
  "macAddress": "MAC_ADDR",
  "stockId": 12345,
  "deviceId": 1,
  "backEndSetupId": 1,
  "reasonId": 17,
  "remarks": "Unpaid"
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "is_temp_deactivated": "..."
}
```

---

### 6.4 Endpoint: `/LcoRestServices/reactivateBoxRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "serialNumber": "STB_SERIAL",
  "boxNumber": "BOX_NUMBER",
  "macAddress": "MAC_ADDR",
  "deviceId": 1,
  "backEndSetupId": 1
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success"
}
```

---

### 6.5 Endpoint: `/LcoRestServices/getDeactiveReasonsRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "showforlco": "1",
  "stockId": 12345
}
```

**Response (Success):** VERIFIED FROM SERVER
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
    },
    {
      "reasonId": "21",
      "reasonName": "Temporary Deactivation",
      "display_name": "Temporary Deactivation",
      "act_deact_reason_id": "8",
      "global_reason": "1"
    },
    {
      "reasonId": "50",
      "reasonName": "Expired Service Deactivation",
      "display_name": "Expired Service Deactivation",
      "act_deact_reason_id": "3",
      "global_reason": "1"
    }
  ]
}
```

**Field Type Map (reasonList items):**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| reasonId | **STRING** | `"6"` | NOT int! |
| reasonName | String | `"Unpaid Customer"` | |
| display_name | String | `"Unpaid Customer"` | |
| act_deact_reason_id | **STRING** | `"2"` | NOT int! |
| global_reason | **STRING** | `"1"` | NOT int! |

---

### 6.6 Endpoint: `/LcoRestServices/temporaryActivationRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "customerId": 1413,
  "stockId": 12345
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "employee_id": "...",
  "authToken": "...",
  "is_customer_temp_reason_exist": "...",
  "operation_name": "..."
}
```

---

### 6.7 Endpoint: `/LcoRestServices/validateBoxInfoRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "boxNumber": "STB_SERIAL_NUMBER"
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "resellerId": "..."
}
```

---

### 6.8 Endpoint: `/LcoRestServices/stbPairRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "serialNumber": "STB_SERIAL",
  "vcNumber": "VC_NUMBER"
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success"
}
```

---

### 6.9 Endpoint: `/LcoRestServices/stbUnpairRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "serialNumber": "STB_SERIAL"
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success"
}
```

---

### 6.10 Endpoint: `/LcoRestServices/stb_replacement`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "serial_number": "OLD_STB_SERIAL",
  "account_nmber": "13528363",
  "replacement_type_id": 1,
  "amount": 0.00,
  "receipt_number": "",
  "remarks": "",
  "replace_serial_number": "NEW_STB_SERIAL",
  "replace_vc_number": "NEW_VC",
  "is_permanent_surrender": false,
  "pair_condition": ""
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "response_details": {}
}
```

---

## 7. PACKAGE/SERVICE OPERATIONS

### 7.1 Endpoint: `/LcoRestServices/getCustomerPackages_splitRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "customerId": 1413,
  "boxNumber": "STB_SERIAL"
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "packageList_broadcaster": []
}
```

---

### 7.2 Endpoint: `/LcoRestServices/getUnassignedPackages_splitRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "customerId": 1413,
  "boxNumber": "STB_SERIAL"
}
```

**Response (Success):** VERIFIED FROM SERVER (from conversation logs -- 4 arrays)
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "packageList_base": [
    {
      "product_id": "101",
      "product_name": "Base Pack HD",
      "product_price": "150.00",
      "product_type": "BASE",
      "tax_amount": "27.00",
      "total_amount": "177.00",
      "broadcaster_name": "MSO",
      "validity_days": "30",
      "is_fta": "0"
    }
  ],
  "packageList_addon": [
    {
      "product_id": "202",
      "product_name": "Sports Add-on",
      "product_price": "50.00",
      "product_type": "ADDON",
      "tax_amount": "9.00",
      "total_amount": "59.00",
      "broadcaster_name": "Star Sports",
      "validity_days": "30",
      "is_fta": "0"
    }
  ],
  "packageList_alacarte": [
    {
      "product_id": "303",
      "product_name": "HBO",
      "product_price": "19.00",
      "product_type": "ALACARTE",
      "tax_amount": "3.42",
      "total_amount": "22.42",
      "broadcaster_name": "HBO",
      "validity_days": "30",
      "is_fta": "0"
    }
  ],
  "packageList_broadcaster": [
    {
      "product_id": "404",
      "product_name": "Broadcaster Bouquet",
      "product_price": "80.00",
      "product_type": "BROADCASTER",
      "tax_amount": "14.40",
      "total_amount": "94.40",
      "broadcaster_name": "Zee",
      "validity_days": "30",
      "is_fta": "0"
    }
  ],
  "deactivate_customerservices": [],
  "channel_details": []
}
```

**Field Type Map (all package arrays -- items):**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| product_id | **STRING** | `"101"` | NOT int! |
| product_name | String | `"Base Pack HD"` | |
| product_price | **STRING** | `"150.00"` | NOT double! |
| product_type | String | `"BASE"` | BASE/ADDON/ALACARTE/BROADCASTER |
| tax_amount | **STRING** | `"27.00"` | NOT double! |
| total_amount | **STRING** | `"177.00"` | NOT double! |
| broadcaster_name | String | `"MSO"` | |
| validity_days | **STRING** | `"30"` | NOT int! |
| is_fta | **STRING** | `"0"` | NOT bool/int! |

---

### 7.3 Endpoint: `/LcoRestServices/activateServiceRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "customerId": 1413,
  "productId": 101,
  "customerDeviceId": 12345,
  "dateType": "CURRENT",
  "pricingStructureType": "MONTHLY",
  "validityDays": 30
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success"
}
```

---

### 7.4 Endpoint: `/LcoRestServices/deactivateServiceRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "digi_config_value": "",
  "bill_dealer_id": 1,
  "customerId": 1413,
  "serviceId": 500,
  "reasonId": 6,
  "remarks": "Package change",
  "check_validation": true,
  "fromCustomerPortal": false,
  "deactservice_customer_portal": false,
  "fromMobileApp": true
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "statusMessage": "..."
}
```

---

### 7.5 Endpoint: `/LcoRestServices/extendCustomerServices`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "customer_id": 1413,
  "product_id": 101,
  "stock_id": 12345,
  "quantity": 1,
  "fromMobileApp": true
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "employee_parent_id": "...",
  "dealer_setting": {},
  "int_operation_id": "...",
  "validation_operation_names": "...",
  "is_service_extension": "...",
  "arr_act_package_details": [],
  "arr_box_details": [],
  "arr_customer_details": [],
  "plugin_id": "...",
  "extra_parameters": {}
}
```

---

### 7.6 Endpoint: `/LcoRestServices/getCasPackagesRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "boxNumber": "STB_SERIAL"
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "caspackageList": []
}
```

---

### 7.7 Endpoint: `/LcoRestServices/channel_listRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "dealer_id": 1,
  "product_id": 101
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "channel_details": []
}
```

---

### 7.8 Endpoint: `/LcoRestServices/renewServicesList`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "customer_id": 1413,
  "customer_service_id": 500,
  "product_ids": "101,202"
}
```

**Response:** NEEDS TESTING
```json
{
  "status_msg": "Success"
}
```

---

### 7.9 Endpoint: `/LcoRestServices/getRenewServicesList`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "customer_id": 1413
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "getRenewServices": []
}
```

---

### 7.10 Endpoint: `/LcoRestServices/customerAgingServices`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "start_date": "2026-01-01",
  "end_date": "2026-03-27",
  "serial_number_search": "",
  "vc_number_search": "",
  "baid_search": ""
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success"
}
```

---

## 8. REPORTS

### 8.1 Endpoint: `/LcoRestServices/DailyreportRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "dealer_id": 1,
  "date": "2026-03-27"
}
```

**Response (Failure -- missing params):** VERIFIED FROM SERVER
```json
{
  "status_code": 1,
  "status_msg": "Date is  required."
}
```

**Response (Success):** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "Dailyreport_details": []
}
```

---

### 8.2 Endpoint: `/LcoRestServices/empCollectionRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "dealer_id": 1,
  "fromDate": "2026-03-01",
  "toDate": "2026-03-27"
}
```

**Response (Success):** VERIFIED FROM SERVER
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

> NOTE: Fields can be null even on success.

---

### 8.3 Endpoint: `/LcoRestServices/empCustomerCollectionDetailsRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "dealer_id": 1,
  "fromDate": "2026-03-01",
  "toDate": "2026-03-27"
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success"
}
```

---

### 8.4 Endpoint: `/LcoRestServices/InvoiceServiceRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "dealer_id": 1,
  "customer_id": 1413
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "invoice_details": []
}
```

---

### 8.5 Endpoint: `/LcoRestServices/empCollectionReportDownload`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "fromDate": "2026-03-01",
  "toDate": "2026-03-27"
}
```

**Response:** Binary file download (CSV/Excel). NEEDS TESTING.

---

### 8.6 Endpoint: `/LcoRestServices/pgTransactionReportDownload`

**Method:** GET (not POST!)
**Auth Required:** Yes

**Request Parameters:** None (query params may be needed)

**Response:** Binary file download or error message. NEEDS TESTING.

---

### 8.7 Endpoint: `/LcoRestServices/customer_deduction_logs`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "dateRange": "2026-03-01 - 2026-03-27",
  "customerId": 1413
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "success": true,
  "deduction_logs": []
}
```

---

## 9. EMPLOYEE MANAGEMENT

### 9.1 Endpoint: `/LcoRestServices/getLcoEmployeeList`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "employee_id": 1054
}
```

**Response (Failure -- missing param):** VERIFIED FROM SERVER
```json
{
  "status_code": 1,
  "status_msg": "Please Enter LCO Id",
  "lcoEmployeelist": []
}
```

---

### 9.2 Endpoint: `/LcoRestServices/getServiceEmployeeList`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "dealer_id": 1
}
```

**Response (No Data):** VERIFIED FROM SERVER
```json
{
  "status_code": 1,
  "status_msg": "No Services Employees.",
  "getServiceEmployeeList": []
}
```

---

## 10. MASTER DATA

### 10.1 Endpoint: `/LcoRestServices/getCountriesRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{}
```

**Response (Success):** VERIFIED FROM SERVER
```json
{
  "status_code": 0,
  "status_msg": "1054",
  "countriesList": [
    { "iso": "AD", "name": "ANDORRA" },
    { "iso": "IN", "name": "INDIA" },
    { "iso": "US", "name": "UNITED STATES" }
  ]
}
```

> NOTE: `status_msg` contains the employee ID "1054" instead of "Success" -- server quirk!

**Field Type Map (countriesList items):**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| iso | String | `"IN"` | ISO country code |
| name | String | `"INDIA"` | Country name |

---

### 10.2 Endpoint: `/LcoRestServices/getStatesRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "countryCode": "IN"
}
```

**Response (Success):** VERIFIED FROM SERVER
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "statesList": [
    {
      "id": "66",
      "name": "Andhra Pradesh",
      "country_code": "IN"
    },
    {
      "id": "101",
      "name": "Telangana",
      "country_code": "IN"
    }
  ]
}
```

**Field Type Map (statesList items):**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| id | **STRING** | `"101"` | NOT int! |
| name | String | `"Telangana"` | |
| country_code | String | `"IN"` | |

---

### 10.3 Endpoint: `/LcoRestServices/getdistrictsRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "stateId": 101
}
```

**Response (Success):** VERIFIED FROM SERVER
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "districtList": [
    {
      "district_id": "20",
      "district_name": "Hyderabad",
      "state_id": "101"
    },
    {
      "district_id": "852",
      "district_name": "Bhadradri Kothagudem",
      "state_id": "101"
    }
  ]
}
```

**Field Type Map (districtList items):**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| district_id | **STRING** | `"20"` | NOT int! |
| district_name | String | `"Hyderabad"` | |
| state_id | **STRING** | `"101"` | NOT int! |

---

### 10.4 Endpoint: `/LcoRestServices/getCitiesRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "stateId": 101,
  "boxNumber": ""
}
```

**Response (Failure):** VERIFIED FROM SERVER
```json
{
  "status_code": 1,
  "status_msg": "Box Number is  required."
}
```

> NOTE: This endpoint requires `boxNumber` even though it returns cities. Server quirk.

---

### 10.5 Endpoint: `/LcoRestServices/getmandalsRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "districtId": 20
}
```

**Response (Success):** VERIFIED FROM SERVER
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

**Field Type Map (mandalList items):**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| district_id | **STRING** | `"20"` | NOT int! |
| mandal_id | **STRING** | `"1"` | NOT int! |
| mandal_name | String | `"Ameerpet"` | |

---

### 10.6 Endpoint: `/LcoRestServices/getLocationsOfDistrictRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "districtId": 20
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "districtLocationsList": []
}
```

---

### 10.7 Endpoint: `/LcoRestServices/getGroupsRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "serialNumber": ""
}
```

**Response (Error):** VERIFIED FROM SERVER
```json
{
  "status_code": 0,
  "status_msg": "Undefined property: stdClass::$serialNumber"
}
```

> NOTE: Server throws PHP error when serialNumber is empty. The status_msg contains the PHP error text.

---

### 10.8 Endpoint: `/LcoRestServices/getCustomerTypesRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{}
```

**Response (Success):** VERIFIED FROM SERVER
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "customerTypeList": [
    {
      "customer_type_id": "2",
      "customer_type": "Residence",
      "description": "Residence",
      "status": "1",
      "is_commercial_multi_box": "0",
      "enable_display": "1"
    },
    {
      "customer_type_id": "1",
      "customer_type": "Hotel",
      "description": "Hotel",
      "status": "1",
      "is_commercial_multi_box": "0",
      "enable_display": "0"
    }
  ]
}
```

**Field Type Map (customerTypeList items):**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| customer_type_id | **STRING** | `"2"` | NOT int! |
| customer_type | String | `"Residence"` | |
| description | String | `"Residence"` | |
| status | **STRING** | `"1"` | NOT int! |
| is_commercial_multi_box | **STRING** | `"0"` | NOT bool! |
| enable_display | **STRING** | `"1"` | NOT bool! |

---

### 10.9 Endpoint: `/LcoRestServices/getcustomerTypeTypesRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "resellerId": 1054,
  "customerTypeId": 2
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "customerTypeTypesInfoList": []
}
```

---

### 10.10 Endpoint: `/LcoRestServices/getIdsRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{}
```

**Response (Success):** VERIFIED FROM SERVER
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "idList": [
    { "id_type_id": "1", "type": "PAN" },
    { "id_type_id": "2", "type": "VOTER ID" },
    { "id_type_id": "3", "type": "PASSPORT" },
    { "id_type_id": "4", "type": "DRIVING LICENSE" },
    { "id_type_id": "5", "type": "AADHAR CARD" },
    { "id_type_id": "6", "type": "BANK ACCOUNT NUMBER" },
    { "id_type_id": "7", "type": "ELECTRICITY BILL" },
    { "id_type_id": "8", "type": "RATION CARD" },
    { "id_type_id": "9", "type": "WATER BILL" },
    { "id_type_id": "10", "type": "OTHERS" },
    { "id_type_id": "11", "type": "AGREEMENT COPY" },
    { "id_type_id": "12", "type": "CITIZENSHIP" }
  ]
}
```

**Field Type Map (idList items):**

| Field | Server Type | Example | Notes |
|-------|------------|---------|-------|
| id_type_id | **STRING** | `"5"` | NOT int! |
| type | String | `"AADHAR CARD"` | |

---

### 10.11 Endpoint: `/LcoRestServices/dynamicformvalidationsRest`

**Method:** POST
**Auth Required:** Yes

**Request Parameters:**
```json
{
  "table_name": "customer_form"
}
```

**Response:** NEEDS TESTING
```json
{
  "status_code": 0,
  "status_msg": "Success"
}
```

---

## Special Controllers (NOT LcoRestServices)

### S.1 Payment Gateway
**URL:** `http://183.83.216.66:8882/v2_release/index.php/paymentgateway/mobile_paymentsview`
**Purpose:** Opens payment gateway web view for online payments.
**Type:** Web page (not REST API)

### S.2 Customer Transaction Response
**URL:** `http://183.83.216.66:8882/v2_release/index.php/selfcare_rest_mobileapp/customer_transaction_reponse`
**Purpose:** Customer self-care transaction response.

### S.3 Customer Validation with Mobile
**URL:** `http://183.83.216.66:8882/v2_release/index.php/selfcare_rest_mobileapp/customer_validationwithmobile`
**Purpose:** Validate customer by mobile number (self-care).

### S.4 Customer OTP Validation
**URL:** `http://183.83.216.66:8882/v2_release/index.php/selfcare_rest_mobileapp/customer_otp_validation`
**Purpose:** OTP verification for self-care operations.

---

## Master Data Type Anomaly Table

This is the CRITICAL table showing every field across ALL endpoints that has an unexpected/dangerous type from the server. Every one of these needs safe parsing in Dart models.

### Category: Numeric IDs Sent as Strings

| Endpoint | Field | Expected Type | Actual Server Type | Example Value |
|----------|-------|--------------|-------------------|---------------|
| validateLogin | employeeId | int | **String** | `"1054"` |
| validateLogin | dealerId | int | **String** | `"1"` |
| validateLogin | state | int | **String** | `"101"` |
| validateLogin | district | int | **String** | `"20"` |
| validateLogin | city | int | **String** | `"2"` |
| validateLogin | defaultState | int | **String** | `"101"` |
| validateLogin | defaultDistrict | int | **String** | `"20"` |
| validateLogin | defaultCity | int | **String** | `"-1"` |
| getCustomerDetailsRest | customer_id | int | **String** | `"1413"` |
| getCustomerDetailsRest | reseller_id | int | **String** | `"1054"` |
| getCustomerBoxDetailsRest | stock_id | int | **String** | `"12345"` |
| getCustomerBoxDetailsRest | device_id | int | **String** | `"1"` |
| getCustomerBoxDetailsRest | backend_setup_id | int | **String** | `"1"` |
| complaintCategoriesRest | categoryId | int | **String** | `"6"` |
| complaintCategoriesRest | parent_category_id | int | **String** | `"0"` |
| getDeactiveReasonsRest | reasonId | int | **String** | `"17"` |
| getDeactiveReasonsRest | act_deact_reason_id | int | **String** | `"2"` |
| getPaymentModesRest | paymentModeId | int | **String** | `"1"` |
| getUnassignedPackages_splitRest | product_id | int | **String** | `"101"` |
| getUnassignedPackages_splitRest | validity_days | int | **String** | `"30"` |
| getStatesRest | id | int | **String** | `"101"` |
| getdistrictsRest | district_id | int | **String** | `"20"` |
| getdistrictsRest | state_id | int | **String** | `"101"` |
| getmandalsRest | mandal_id | int | **String** | `"1"` |
| getCustomerTypesRest | customer_type_id | int | **String** | `"2"` |
| getIdsRest | id_type_id | int | **String** | `"5"` |
| getCustomerDetailsCountRest | customerCount | int | **String** | `"512"` |
| getExpiryServicesDateWiseCount | stb_count | int | **String** | `"3"` |
| getCustomerDetailsRest | stb_count | int | **String** | `"1"` |

### Category: Monetary/Decimal Values Sent as Strings

| Endpoint | Field | Expected Type | Actual Server Type | Example Value |
|----------|-------|--------------|-------------------|---------------|
| validateLogin | deposit_amount | double | **String** | `"7467.76"` |
| lco_deposit_amountRest | deposit_amount | double | **String** | `"7467.76"` |
| dashBoardDetailsRest | outStandingAmount | double | **String** | `"139655.05"` |
| dashBoardDetailsRest | currentMonthOutstanding | double | **String** | `"46.34"` |
| getCustomerDetailsRest | pending_amount | double | **String** | `"0.00"` |
| getCustomerDetailsRest | latitude | double | **String** | `"0.0"` |
| getCustomerDetailsRest | longitude | double | **String** | `"0.0"` |
| getCustomerDetailsRest | tot_mso_share | double | **String** | `"0.00"` |
| getPendingAmountRest | pendingAmount | double | **String** | `"0.00"` |
| getPendingAmountRest | msoShare | double | **String** | `"0.00"` |
| getPendingAmountRest | lcoShare | double | **String** | `"0.00"` |
| getUnassignedPackages_splitRest | product_price | double | **String** | `"150.00"` |
| getUnassignedPackages_splitRest | tax_amount | double | **String** | `"27.00"` |
| getUnassignedPackages_splitRest | total_amount | double | **String** | `"177.00"` |

### Category: Boolean/Flag Values Sent as Strings

| Endpoint | Field | Expected Type | Actual Server Type | Example Value |
|----------|-------|--------------|-------------------|---------------|
| validateLogin | useCRF | bool/int | **String** | `"1"` |
| validateLogin | useLastName | bool/int | **String** | `"1"` |
| validateLogin | useDiscount | bool/int | **String** | `"1"` |
| validateLogin | useDataFromMasterTable | bool/int | **String** | `"1"` |
| validateLogin | useMandatoryForHotel | bool/int | **String** | `"1"` |
| validateLogin | useAccountNumber | bool/int | **String** | `"1"` |
| validateLogin | useLcoDeposit | bool/int | **String** | `"1"` |
| validateLogin | recurringServiceEdit | bool/int | **String** | `"0"` |
| validateLogin | showLcoComplaint | bool/int | **String** | `"0"` |
| validateLogin | freezecustomerparamsinapp | bool/int | **String** | `"0"` |
| validateLogin | is_unpaidlco | bool/int | **String** | `"0"` |
| validateLogin | lco_billtype | bool/int | **String** | `"0"` |
| validateLogin | use_lco_deposits | bool/int | **String** | `"1"` |
| validateLogin | AUTO_RECEIPT_NUMBER | bool/int | **String** | `"1"` |
| validateLogin | show_mia_agreement_upload | bool/int | **String** | `"1"` |
| validateLogin | accept_terms_condtions | bool/int | **String** | `"0"` |
| validateLogin | access_distributor_wise | bool/int | **String** | `"0"` |
| validateLogin | show_service_extension | bool/int | **String** | `"1"` |
| validateLogin | edit_quantity | bool/int | **String** | `"1"` |
| validateLogin | enable_box_wise_payment | bool/int | **String** | `"0"` |
| getaccesscontrollRest | int_stb_activation | int | **String** | `"1"` |
| getaccesscontrollRest | int_stb_deactivation | int | **String** | `"1"` |
| getaccesscontrollRest | int_stb_reactivation | int | **String** | `"1"` |
| getCustomerDetailsRest | online_customer | bool/int | **String** | `"0"` |
| getCustomerDetailsRest | status | int | **String** | `"1"` |
| getCustomerDetailsRest | bill_type | int | **String** | `"1"` |
| getCustomerDetailsRest | is_direct_lco | bool/int | **String** | `"0"` |
| getCustomerBoxDetailsRest | status | int | **String** | `"1"` |
| getCustomerBoxDetailsRest | is_temp_deactivated | bool/int | **String** | `"0"` |
| getCustomerTypesRest | status | int | **String** | `"1"` |
| getCustomerTypesRest | is_commercial_multi_box | bool/int | **String** | `"0"` |
| getCustomerTypesRest | enable_display | bool/int | **String** | `"1"` |
| getDeactiveReasonsRest | global_reason | bool/int | **String** | `"1"` |
| getUnassignedPackages_splitRest | is_fta | bool/int | **String** | `"0"` |

### Category: Mixed Types in Same Response (MOST DANGEROUS)

| Endpoint | Field A (int) | Field B (STRING) | Notes |
|----------|--------------|-----------------|-------|
| dashBoardDetailsRest | totalStbs: `790` (int) | outStandingAmount: `"139655.05"` (String) | Money = string, count = int |
| dashBoardDetailsRest | msoShare: `28242.5` (double) | currentMonthOutstanding: `"46.34"` (String) | BOTH are money but different types! |
| getaccesscontrollRest | int_bulk_payment: `0` (int) | int_stb_activation: `"1"` (String) | Same prefix `int_` but different types! |
| validateLogin | blockpayment: `0` (int) | is_unpaidlco: `"0"` (String) | Similar flags, different types |
| validateLogin | notifyCount: `0` (int) | invoicepaymentsearchlimit: `"600"` (String) | Both numeric, different types |
| validateLogin | allow_top_up: `1` (int) | edit_quantity: `"1"` (String) | Both feature flags, different types |

### Category: Nullable Fields (Can Be null)

| Endpoint | Field | Normal Type | Can Be null | Notes |
|----------|-------|-------------|-------------|-------|
| validateLogin | address2 | String | YES | |
| validateLogin | address3 | String | YES | |
| validateLogin | phone | String | YES | |
| validateLogin | dob | String | YES | |
| validateLogin | adate | String | YES | |
| validateLogin | employeeParentId | String | YES | |
| validateLogin | employeeParentType | String | YES | |
| dashBoardDetailsRest | lcocurrentmonthdueamount | double? | YES | Always null in test data |
| getCustomerDetailsRest | baid | String | YES | |
| empCollectionRest | employee_id | int/String | YES | Null even on success |
| empCollectionRest | name | String | YES | Null even on success |
| empCollectionRest | Amt | double/String | YES | Null even on success |

### Category: Unexpected Collection Types

| Endpoint | Field | Expected Type | Actual Server Type | Notes |
|----------|-------|--------------|-------------------|-------|
| validateLogin | userNotifications | int (per Android) | **List/Array** | `[]` -- empty array, not 0 |
| validateLogin | config_values_array | flat fields | **Map/Object** | Nested JSON object |

---

## Recommended Safe Parsing Helper (Dart)

Based on the data type anomalies above, every Dart model MUST use safe parsing:

```dart
/// Safe int parsing -- handles String, int, double, and null
int? safeInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Safe double parsing -- handles String, int, double, and null
double? safeDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Safe bool parsing -- handles String "0"/"1", int 0/1, bool, and null
bool safeBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) return value == "1" || value.toLowerCase() == "true";
  return false;
}

/// Safe String -- handles null
String safeString(dynamic value) {
  if (value == null) return "";
  return value.toString();
}
```

---

## Endpoint Coverage Summary

| # | Category | Total | Verified | Needs Testing |
|---|----------|-------|----------|---------------|
| 1 | Authentication | 2 | 2 | 0 |
| 2 | Dashboard | 5 | 3 | 2 |
| 3 | Customer | 6 | 3 | 3 |
| 4 | Payments | 8 | 3 | 5 |
| 5 | Complaints | 9 | 3 | 6 |
| 6 | STB/Box | 10 | 2 | 8 |
| 7 | Packages | 10 | 1 | 9 |
| 8 | Reports | 7 | 2 | 5 |
| 9 | Employees | 2 | 2 | 0 |
| 10 | Master Data | 11 | 8 | 3 |
| | **TOTAL** | **70** | **29** | **41** |

> 29 endpoints have verified server response data. 41 endpoints still need live testing to confirm exact response shapes and data types.

---

## Key Takeaways for Flutter Team

1. **NEVER trust field names** -- a field prefixed with `int_` can be a String (`int_stb_activation: "1"`)
2. **NEVER assume consistent types within a response** -- `msoShare` is a double but `outStandingAmount` is a String in the SAME dashboard response
3. **ALL IDs from the server are Strings** -- customer_id, employee_id, product_id, district_id, etc.
4. **ALL monetary values are Strings** -- deposit_amount, pending_amount, product_price, etc.
5. **ALL boolean flags are Strings** -- "0" or "1", never true/false
6. **Nullable fields exist everywhere** -- address2, phone, dob, baid, lcocurrentmonthdueamount
7. **One endpoint uses different key names** -- `getCustomerDetailsRest` returns `statusCode`/`statusMessage` (camelCase) not `status_code`/`status_msg`
8. **The `getCountriesRest` status_msg contains employee ID** instead of "Success"
9. **Use `safeInt()`, `safeDouble()`, `safeBool()` for EVERY field** -- no exceptions
