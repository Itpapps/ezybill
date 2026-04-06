# EzyBill API Summary

> **Base URL:** `http://183.83.216.66:8882/v2_release/index.php`
> **REST Controller:** `LcoRestServices`
> **Auth:** All requests (except login) require `Authorization: Bearer <jwt_token>` header
> **Encryption:** All POST payloads are encrypted (triple hex encoding). All responses are encrypted (single hex decode).
> **Content-Type:** `application/x-www-form-urlencoded`
> **Test Credentials:** Username: `58948`, Password: `1234`

---

## Table of Contents

1. [Authentication](#authentication)
2. [Dashboard](#dashboard)
3. [Customer Management](#customer-management)
4. [Payments](#payments)
5. [Complaints](#complaints)
6. [STB / Packages](#stb-packages)
7. [Master Data - Geography](#master-data-geography)
8. [Master Data - Dropdowns](#master-data-dropdowns)
9. [Employees](#employees)
10. [Reports](#reports)

---

## Issues Found During Testing (Flutter App Fixes Needed)

| # | Issue | Correct Value | Wrong Value (Flutter) |
|---|-------|---------------|----------------------|
| 1 | Complaint categories response key | `complaintCategories` | `complaintCategoryList` |
| 2 | Complaint statuses response key | `complaintStatuses` | `complaintTypesList` |
| 3 | Districts response key | `districtList` | `districtsList` |
| 4 | Customer types response key | `customerTypeList` | `customerTypesList` |
| 5 | States API param name | `countryCode` | `countryId` |
| 6 | Cities API requires both params | `stateId` + `districtId` | only `districtId` |
| 7 | Reports/Employees need dealer_id | `dealer_id` required | missing param |

---

## Authentication

### Login (Validate Login)

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/validateLogin`
- **Notes:** Returns JWT token, user profile, dealer config, and feature flags. Token used as Bearer auth for all subsequent calls.

**Request Parameters:**
```json
{
  "UserName": "58948",
  "PassWord": "****"
}
```

**Response (Decrypted):**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdXRodG9rZW4iOiI2OWMzODc1MmQzM2FkMi4yNTUwNTc3OCIsImlhdCI6MTc3NDQyNDkzOSwiZXhwIjoxNzgyMjAwOTM5fQ.JKhGKk4_-GhmVVZ01VXo9bNiXdcactky-F7Ng7G43cs",
  "employeeId": "1054",
  "first_name": "MD.ABDUL WAJEED",
  "last_name": "",
  "address1": "13-5-610/3/3/1,YOUSUFNAGAR,TAPPACHABUTRA,HYDERABAD-500028 13-5-610/3/3/1,YOUSUFNAGAR,TAPPACHABUTRA,HYDERABAD-500028  HYDERABAD-500028 HYDERABAD HYDERABAD(INDIA)",
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

**Status:** `0` - Success

**Key Response Fields:** `token`, `employeeId`, `dealerId`, `userType`, `first_name`, `lcoCode`, `business_name`, `config_values_array`

---

### Get Access Control

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getaccesscontrollRest`
- **Notes:** Returns feature access flags for the logged-in user. Controls which screens/features are visible in the app.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1,
  "userstype": "RESELLER",
  "employeeParentType": "",
  "employeeParentId": ""
}
```

**Response (Decrypted):**
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

**Status:** `0` - Success

**Key Response Fields:** `int_bulk_payment`, `invoice_page_access`, `access_for_complaints`, `int_stb_activation`

---

## Dashboard

### Dashboard Summary

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getDashboardDetails`
- **Notes:** Main dashboard statistics. Shows STB counts, customer counts, financials.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1
}
```

**Response (Decrypted):**
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

**Status:** `0` - Success

**Key Response Fields:** `totalStbs`, `totalActiveCustomers`, `totalComplaints`, `outStandingAmount`, `msoShare`, `totalActiveAssignedStbs`

---

### LCO Deposit Balance

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getLcoDepositeBalance`
- **Notes:** Returns current deposit/wallet balance for the LCO.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1
}
```

**Response (Decrypted):**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "deposit_amount": "7467.76"
}
```

**Status:** `0` - Success

**Key Response Fields:** `deposit_amount`

---

### Wallet Transactions

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getWalletTransactions`
- **Notes:** Returns wallet transaction history. Requires startDate and endDate params.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1,
  "startDate": "2026-01-01",
  "endDate": "2026-03-25"
}
```

**Response (Decrypted):**
```json
{
  "status_code": 1,
  "status_msg": "Start Date is  required."
}
```

**Status:** `1` - Start Date is  required.

---

### Expiry Service Count

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getExpiryServiceCount`
- **Notes:** Returns STB count expiring per day in the given date range.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1,
  "startDate": "2026-03-25",
  "endDate": "2026-03-30"
}
```

**Response (Decrypted):**
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
    "... (3 more items)"
  ]
}
```

**Status:** `0` - Success

**Key Response Fields:** `getExpiryServicesList[].date`, `getExpiryServicesList[].stb_count`

---

### Customer Count

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getCustomerCount`
- **Notes:** Returns total customer count for the dealer.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1
}
```

**Response (Decrypted):**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "customerCount": "512"
}
```

**Status:** `0` - Success

**Key Response Fields:** `customerCount`

---

## Customer Management

### Customer Details List

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getCustomerDetails`
- **Notes:** Paginated customer list. Response key is `customerDetailsList` (not `customerList`). Note: uses `statusCode` / `statusMessage` (not `status_code` / `status_msg`).

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1,
  "searchType": "name",
  "searchValue": "",
  "limit": 10,
  "offset": 0
}
```

**Response (Decrypted):**
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
    },
    {
      "customer_id": "1428",
      "reseller_id": "1054",
      "online_customer": "0",
      "customerName": "HARISH  ",
      "caf_no": "13530100",
      "mobile_no": "919949919911",
      "status": "1",
      "billing_address": "GOKULE NAGAR RAMANTHAPUR,,HYDERABAD,Telangana,INDIA",
      "installation_address": "GOKULE NAGAR RAMANTHAPUR,,HYDERABAD,Hyderabad,Telangana,INDIA",
      "pin_code": "2339",
      "crf_number": "",
      "stb_count": "1",
      "account_number": "13530100",
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

**Status:** `0` - Success

**Key Response Fields:** `customerDetailsList[].customer_id`, `customerDetailsList[].customerName`, `customerDetailsList[].caf_no`, `customerDetailsList[].mobile_no`, `customerDetailsList[].status`, `customerDetailsList[].stb_count`, `customerDetailsList[].pending_amount`

---

### Existing Customer Search

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getExistCustomerDetails`
- **Notes:** Search for existing customer by mobile number. Response key is `existCustomerDetails`.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1,
  "mobile_no": "9999999999"
}
```

**Response (Decrypted):**
```json
{
  "status_code": 1,
  "status_msg": "Customer Details Not found",
  "existCustomerDetails": []
}
```

**Status:** `1` - Customer Details Not found

**Key Response Fields:** `existCustomerDetails[]`

---

## Payments

### Payment Modes

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getPaymentModes`
- **Notes:** Returns available payment modes (Cash, Bank, Card, Voucher). Response key: `paymentModesList`.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1
}
```

**Response (Decrypted):**
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
    "... (1 more items)"
  ]
}
```

**Status:** `0` - Success

**Key Response Fields:** `paymentModesList[].paymentModeId`, `paymentModesList[].PaymentModeName`

---

### Receipt Number Ranges

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getReceiptNumberRanges`
- **Notes:** Returns receipt number ranges. Response key: `ReceiptRanges` (capital R).

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1
}
```

**Response (Decrypted):**
```json
{
  "status_code": 1,
  "status_msg": "No Receipt range found.",
  "ReceiptRanges": []
}
```

**Status:** `1` - No Receipt range found.

**Key Response Fields:** `ReceiptRanges[]`

---

## Complaints

### Complaint List

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getLcoComplaintList`
- **Notes:** Returns complaints filtered by status. Response key: `lcoComplaintlist`.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1,
  "status": "ASSIGNED"
}
```

**Response (Decrypted):**
```json
{
  "status_code": 1,
  "status_msg": "No records found.",
  "lcoComplaintlist": []
}
```

**Status:** `1` - No records found.

**Key Response Fields:** `lcoComplaintlist[]`

---

### Complaint Categories

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getComplaintCategories`
- **Notes:** Returns complaint category dropdown options. Response key: `complaintCategories` (NOT `complaintCategoryList`).

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1
}
```

**Response (Decrypted):**
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
      "categoryId": "7",
      "categoryName": "awzsfawerawrsfv",
      "parent_category_id": "0"
    },
    "... (5 more items)"
  ]
}
```

**Status:** `0` - Success

**Key Response Fields:** `complaintCategories[].categoryId`, `complaintCategories[].categoryName`

---

### Complaint Statuses/Types

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getComplaintTypes`
- **Notes:** Returns complaint status values and ticket closer categories. Response key: `complaintStatuses` (NOT `complaintTypesList`). Also returns `ticket_closer_categories`.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1
}
```

**Response (Decrypted):**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "complaintStatuses": [
    {
      "value": "ASSIGNED"
    },
    {
      "value": "INPROCESS"
    },
    {
      "value": "ONHOLD"
    },
    "... (3 more items)"
  ],
  "ticket_closer_categories": []
}
```

**Status:** `0` - Success

**Key Response Fields:** `complaintStatuses[].value`, `ticket_closer_categories[]`

---

## STB / Packages

### Deactivation Reasons

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getDeactivationReasons`
- **Notes:** Returns STB deactivation reason dropdown. Response key: `reasonList`.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1
}
```

**Response (Decrypted):**
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
    "... (1 more items)"
  ]
}
```

**Status:** `0` - Success

**Key Response Fields:** `reasonList[].reasonId`, `reasonList[].reasonName`, `reasonList[].display_name`

---

## Master Data - Geography

### Countries

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getCountries`
- **Notes:** Returns all countries. Response key: `countriesList`. Each item has `iso` (country code) and `name`.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1
}
```

**Response (Decrypted):**
```json
{
  "status_code": 0,
  "status_msg": "1054",
  "countriesList": [
    {
      "iso": "AD",
      "name": "ANDORRA"
    },
    {
      "iso": "AE",
      "name": "UNITED ARAB EMIRATES"
    },
    {
      "iso": "AF",
      "name": "AFGHANISTAN"
    },
    "... (236 more items)"
  ]
}
```

**Status:** `0` - 1054

**Key Response Fields:** `countriesList[].iso`, `countriesList[].name`

---

### States

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getStates`
- **Notes:** Returns states for a country. Param is `countryCode` (NOT `countryId`). Response key: `statesList`.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1,
  "countryCode": "IN"
}
```

**Response (Decrypted):**
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
      "id": "67",
      "name": "Arunachal Pradesh",
      "country_code": "IN"
    },
    {
      "id": "68",
      "name": "Assam",
      "country_code": "IN"
    },
    "... (33 more items)"
  ]
}
```

**Status:** `0` - Success

**Key Response Fields:** `statesList[].id`, `statesList[].name`, `statesList[].country_code`

---

### Districts

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getDistricts`
- **Notes:** Returns districts for a state. Response key: `districtList` (NOT `districtsList`).

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1,
  "stateId": 101
}
```

**Response (Decrypted):**
```json
{
  "status_code": 0,
  "status_msg": "Success",
  "districtList": [
    {
      "district_id": "15",
      "district_name": "Adilabad",
      "state_id": "101"
    },
    {
      "district_id": "852",
      "district_name": "Bhadradri Kothagudem",
      "state_id": "101"
    },
    {
      "district_id": "20",
      "district_name": "Hyderabad",
      "state_id": "101"
    },
    "... (29 more items)"
  ]
}
```

**Status:** `0` - Success

**Key Response Fields:** `districtList[].district_id`, `districtList[].district_name`, `districtList[].state_id`

---

### Cities

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getCities`
- **Notes:** Returns cities. Requires BOTH `stateId` AND `districtId`. Error returned if missing.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1,
  "stateId": 101,
  "districtId": 20
}
```

**Response (Decrypted):**
```json
{
  "status_code": 1,
  "status_msg": "Box Number is  required."
}
```

**Status:** `1` - Box Number is  required.

---

### Mandals

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getMandals`
- **Notes:** Returns mandals for a district. Response key: `mandalList`.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1,
  "districtId": 20
}
```

**Response (Decrypted):**
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

**Status:** `0` - Success

**Key Response Fields:** `mandalList[].mandal_id`, `mandalList[].mandal_name`, `mandalList[].district_id`

---

## Master Data - Dropdowns

### Customer Types

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getCustomerTypes`
- **Notes:** Returns customer type dropdown. Response key: `customerTypeList` (NOT `customerTypesList`).

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1
}
```

**Response (Decrypted):**
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
      "customer_type_id": "9",
      "customer_type": "DIRECT POINT",
      "description": "DIRECT POINT",
      "status": "1",
      "is_commercial_multi_box": "0",
      "enable_display": "0"
    },
    {
      "customer_type_id": "8",
      "customer_type": "Hospital",
      "description": "Hospital",
      "status": "1",
      "is_commercial_multi_box": "0",
      "enable_display": "0"
    },
    "... (7 more items)"
  ]
}
```

**Status:** `0` - Success

**Key Response Fields:** `customerTypeList[].customer_type_id`, `customerTypeList[].customer_type`, `customerTypeList[].is_commercial_multi_box`

---

### ID Types

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getIdTypes`
- **Notes:** Returns ID proof type dropdown (PAN, Aadhar, Voter ID, etc.). Response key: `idList`.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1
}
```

**Response (Decrypted):**
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
      "id_type_id": "2",
      "type": "VOTER ID"
    },
    {
      "id_type_id": "3",
      "type": "PASSPORT"
    },
    "... (9 more items)"
  ]
}
```

**Status:** `0` - Success

**Key Response Fields:** `idList[].id_type_id`, `idList[].type`

---

## Employees

### LCO Employees

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getLcoEmployees`
- **Notes:** Returns employees under an LCO. Requires `lcoId` param. Response key: `lcoEmployeelist`.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1,
  "lcoId": 1054
}
```

**Response (Decrypted):**
```json
{
  "status_code": 1,
  "status_msg": "Please Enter LCO Id",
  "lcoEmployeelist": []
}
```

**Status:** `1` - Please Enter LCO Id

**Key Response Fields:** `lcoEmployeelist[]`

---

### Service Employees

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getServiceEmployees`
- **Notes:** Returns service/field employees. Response key: `getServiceEmployeeList`.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1
}
```

**Response (Decrypted):**
```json
{
  "status_code": 1,
  "status_msg": "No Services Employees.",
  "getServiceEmployeeList": []
}
```

**Status:** `1` - No Services Employees.

**Key Response Fields:** `getServiceEmployeeList[]`

---

## Reports

### Daily Collection Report

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getDailyCollectionReport`
- **Notes:** Returns daily collection report. Requires `date` param.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1,
  "date": "2026-03-25"
}
```

**Response (Decrypted):**
```json
{
  "status_code": 1,
  "status_msg": "Date is  required."
}
```

**Status:** `1` - Date is  required.

---

### Employee Collection Report

- **Method:** `POST`
- **URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/getEmployeeCollectionReport`
- **Notes:** Returns employee-wise collection summary. Response key: `collectionList`.

**Request Parameters:**
```json
{
  "authToken": "<jwt_token>",
  "dealer_id": 1
}
```

**Response (Decrypted):**
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

**Status:** `0` - Success

**Key Response Fields:** `collectionList[].employee_id`, `collectionList[].name`, `collectionList[].Amt`

---

## Encryption Details

### Request Encryption (Payload)

```
1. JSON stringify the request params
2. bin2hex(json_string) → this becomes the "hash"
3. bin2hex each character of hash → level 2
4. bin2hex each character of level 2 → level 3 (the "payload")
5. Prepend 5 random hex digits + append 5 random hex digits to payload
6. Send as: { payload: <padded_payload>, hash: <hash_from_step_2> }
```

### Response Decryption

```
1. Response body is: { payload: ..., hash: "..." }
2. Take the "hash" field
3. hex2bin(hash) → this is the JSON string
4. JSON.parse the result
```

### Integrity Check (Server Side)

```
1. Server receives { payload, hash }
2. Strips first 5 and last 5 chars from payload
3. Reverse triple hex decode → gets JSON
4. bin2hex(JSON) and compares with received hash
5. If match → request is valid; if not → rejected
```

---

*Generated on 2026-03-25 from live API responses using test credentials (58948/1234)*
