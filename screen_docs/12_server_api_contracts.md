# EzyBill Server API Contracts - Complete Reference

> **Source file:** `server_code/LcoRestServices.php` (8771 lines)
> **Base URL pattern:** `POST /LcoRestServices/{methodName}`
> **All responses are encrypted** via `Encryption_lib::app_data_encryption()` before sending.

---

## Table of Contents

1. [Global Architecture](#global-architecture)
2. [Encryption Flow](#encryption-flow)
3. [Authentication (Auth)](#auth-endpoints)
4. [Dashboard](#dashboard-endpoints)
5. [Customer Management](#customer-endpoints)
6. [Payment](#payment-endpoints)
7. [STB / Box Management](#stb-endpoints)
8. [Package / Service Management](#package-endpoints)
9. [Complaint Management](#complaint-endpoints)
10. [Master Data (Geo, IDs, Types)](#master-data-endpoints)
11. [Reports](#report-endpoints)
12. [Employee / Access Control](#employee-endpoints)
13. [Wallet / Transactions](#wallet-endpoints)

---

## Global Architecture

### Authentication Flow
- **Login endpoint (`validateLogin`)** does NOT require JWT - all other endpoints do.
- JWT token is passed in the HTTP `Authorization` header.
- The server extracts `authtoken` from JWT, then looks up `employeeId` and `dealerId` from the database.
- **employeeId and dealerId are NEVER sent by the client** (except for login) -- they are extracted from the JWT token via `$this->getEmployeeId()` and `$this->getDealerId()`.

### Payload Encryption
All request payloads are encrypted. The server decrypts via `Encryption_lib::checkPayload()`:
1. Client sends `{payload: "encrypted_string", hash: "hash_string"}`
2. Server decrypts `payload` using custom hex-based encryption (NOT AES)
3. Decrypted payload is available as `$this->payload` (cast to object)

### Response Encryption
All responses are encrypted via `Encryption_lib::app_data_encryption()`:
1. Server JSON-encodes the response array
2. Converts to hex via `bin2hex()`
3. Encrypts each hex character via double-hex encoding
4. Adds random 5-digit prefix and suffix
5. Returns `{payload: "encrypted_string", hash: "original_hex"}`

### Status Code Convention
- **`status_code: 0`** = SUCCESS (for almost all endpoints)
- **`status_code: 1`** = FAILURE / error
- **`status_code: 2`** = Special case (user deactivated, password change required) -- only in `validateLogin`

### Important Response Notes
- Some endpoints use `sendResponse()` (encrypts + exits)
- Some older endpoints use `$this->encryption_lib->app_data_encryption()` + `$this->response()` directly
- A few endpoints use `statusCode`/`statusMessage` (camelCase) instead of `status_code`/`status_msg` -- this is a **known inconsistency**
- When no data is found, some endpoints return empty arrays `[]`, others return arrays with empty placeholder objects

### CRITICAL: Response Field Name Inconsistency
The `getCustomerDetailsRest` endpoint uses **`statusCode`** and **`statusMessage`** (camelCase) instead of the standard `status_code` / `status_msg`. The Flutter app must handle both.

---

## Encryption Flow

**File:** `server_code/Encryption_lib.php`

### Encryption (`encrypt`)
```
Input string -> bin2hex -> split to chars -> bin2hex each char -> prepend random 5-digit number -> append random 5-digit number
```

### Decryption (`decrypt`)
```
Strip 5 chars from front + 5 from back -> split into pairs -> hex2bin each pair -> hex2bin result -> json_decode
```

### Payload Encryption for API (`app_data_encryption`)
```
Input array -> json_encode -> bin2hex -> encrypt() -> return {payload: encrypted, hash: original_hex}
```

### Payload Decryption (`checkPayload`)
```
Extract 'payload' and 'hash' from POST -> decrypt(payload) -> verify hash matches -> return decoded array
```

### AES Encryption (`do_encryption`)
Uses AES-256-CBC with HMAC-SHA256 for a different purpose (not the main API flow). Used for specific data encryption needs.

---

## Auth Endpoints

### 1. validateLogin
| Property | Value |
|----------|-------|
| **Method** | `validateLogin_post()` |
| **Endpoint** | `POST /LcoRestServices/validateLogin` |
| **Auth Required** | NO (only endpoint without JWT check) |

**Input Parameters (from payload):**

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `UserName` | string | YES | Note: PascalCase |
| `PassWord` | string | YES | Note: PascalCase, md5 hashed before DB query |
| `mobile_no` | string | No | |
| `imei` | string | No | Used for IMEI validation if provided |

**Response Fields:**

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| `status_code` | int | 1 | 0=success, 1=fail, 2=deactivated/pwd change |
| `status_msg` | string | "Failed" | |
| `token` | string | "" | JWT token (2160 hours = 90 days expiry) |
| `employeeId` | int | 0 | |
| `first_name` | string | "" | |
| `last_name` | string | "" | |
| `address1` | string | "" | |
| `address2` | string | "" | |
| `address3` | string | "" | |
| `copy_rights` | string | "" | |
| `short_name` | string | "" | |
| `pin_code` | string | "" | |
| `phone` | string | "" | |
| `email` | string | "" | |
| `country` | string | "" | Country code e.g. "IN" |
| `state` | string/int | "" | State ID from DB |
| `district` | int | 0 | District ID |
| `city` | int | 0 | City/Location ID |
| `username` | string | "" | |
| `dob` | string | "" | Date of birth |
| `adate` | string | "" | Anniversary date |
| `employeeName` | string | "" | |
| `dealerId` | int | 0 | |
| `userType` | string | "" | "RESELLER", "EMPLOYEE", "DISTRIBUTOR", "SUBDISTRIBUTOR", "SERVICE", "ADMIN" |
| `useCRF` | int/string | 0 | LOV value |
| `useCAF` | string | "" | LOV value |
| `useLastName` | int/string | 0 | LOV value |
| `useDiscount` | int/string | 0 | LOV value |
| `useDataFromMasterTable` | int/string | 0 | LOV value |
| `useMandatoryForHotel` | int/string | 0 | LOV value |
| `useAccountNumber` | int/string | 0 | Auto-gen number |
| `employeeParentId` | string | "" | |
| `employeeParentType` | string | "" | |
| `useLcoDeposit` | string | "" | LOV value |
| `deposit_amount` | string | "" | |
| `defaultCountry` | string | "" | LOV value (country code) |
| `country_name` | string | "" | |
| `defaultState` | string | "" | LOV value |
| `defaultDistrict` | string | "" | LOV value |
| `defaultCity` | string | "" | LOV value |
| `recurringServiceEdit` | string | "" | LOV value |
| `showLcoComplaint` | string | "" | LOV value |
| `lcoCode` | string | "" | |
| `lcoLocation` | string | "" | |
| `lcoMobileNo` | string | "" | |
| `freezecustomerparamsinapp` | int/string | 0 | LOV value |
| `blockpayment` | int | 0 | 1 if DISTRIBUTOR/SUBDISTRIBUTOR/EMPLOYEE with parent |
| `business_name` | string | "" | |
| `is_unpaidlco` | int | 0 | |
| `appMenuFormat` | string | "" | LOV value |
| `invoicepaymentsearchlimit` | string | "" | LOV value |
| `lco_billtype` | string | "" | LOV value |
| `use_lco_deposits` | string | "" | LOV value |
| `userNotifications` | array | [] | Array of notification objects |
| `notifyCount` | int | 0 | Always 0 |
| `note_duration` | int | 0 | Max duration from notifications |
| `customer_billtype` | string | "" | LOV value |
| `AUTO_RECEIPT_NUMBER` | int/string | 1 | LOV value |
| `CURRENCY_CODE` | string | "" | Currency symbol e.g. "Rs", "&#8377" |
| `allow_top_up` | int | 0 | From CAS access |
| `show_caf_mobile_validation` | int | 0 | LOV value |
| `patch_information` | int/object | 0 | Latest patch info |
| `stb_pairing` | int | 0 | From CAS access |
| `stb_unpairing` | int | 0 | From CAS access |
| `show_mia_agreement_upload` | int | 0 | LOV value |
| `accept_terms_condtions` | int | 1 | Default 1 |
| `agreement_details_count` | int | 0 | |
| `access_distributor_wise` | int | 0 | |
| `is_direct_lco` | int | 0 | |
| `show_serial_vc` | int/string | 0 | LOV: DEFAULT_APP_DISPLAY_OF_STB |
| `user_image` | string | "" | Base64-encoded image |
| `show_service_extension` | int/string | 0 | LOV value |
| `config_values_array` | object | `{min_mobile_length:10, max_mobile_length:10, pincode_length:6, country_code:91}` | |
| `edit_quantity` | int/string | 0 | LOV value |
| `enable_box_wise_payment` | int/string | 0 | LOV: BOX_WISE_PAYMENT |
| `baid_label` | string | "" | |

**CRITICAL TYPE NOTE:** Most LOV values come from database as **strings** (e.g., "0", "1"). The Flutter app must parse these as dynamic types. Fields like `employeeId`, `dealerId` are integers. Fields like `district`, `city`, `state` may be int or string depending on DB value.

---

## Dashboard Endpoints

### 2. dashBoardDetailsRest
| Property | Value |
|----------|-------|
| **Method** | `dashBoardDetailsRest_post()` |
| **Endpoint** | `POST /LcoRestServices/dashBoardDetailsRest` |
| **Auth Required** | YES (JWT) |

**Input Parameters:**

| Field | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `use_lco_deposits` | int | No | 0 | |
| `lco_billtype` | int | No | 0 | |

**Response Fields:**

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| `status_code` | int | 1 | 0=success |
| `status_msg` | string | | |
| `totalStbs` | int | 0 | |
| `totalAssignedStbs` | int | 0 | |
| `totalUnAssignedStbs` | int | 0 | |
| `totalComplaints` | int | 0 | |
| `totalClosedComplaints` | int | 0 | Always 0 (not populated) |
| `totalActiveCustomers` | int | 0 | Actually totalActiveAssignedStbs |
| `totalDeactiveCustomers` | int | 0 | Actually totalDeactiveAssignedStbs |
| `totalCurrentMonthBill` | int | 0 | Always 0 (not populated from new dashboard) |
| `totalDueAmount` | int | 0 | Always 0 |
| `totalPaidCustomers` | int | 0 | Always 0 |
| `totalUnPaidCustomers` | int | 0 | Always 0 |
| `gettotalPaidCustomers` | int | -1 | Always -1 |
| `gettotalUnPaidCustomers` | int | -1 | Always -1 |
| `outStandingAmount` | float | -1 | |
| `msoShare` | float | 0 | |
| `totalActiveAssignedStbs` | int | 0 | |
| `totalDeactiveAssignedStbs` | int | 0 | |
| `totalCurrentMonthMsoShare` | float | 0 | |
| `currentMonthOutstanding` | float | 0 | |
| `currentMonthLCOBill` | float | 0 | |
| `lcocurrentmonthdueamount` | float | 0 | |

**CRITICAL TYPE NOTE:** All numeric dashboard values may come as **strings from DB queries** (e.g., "0" instead of 0). The Flutter model must handle both string and numeric types.

### 3. lco_deposit_amountRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/lco_deposit_amountRest` |

**Input:** None (employeeId/dealerId from JWT)

**Response:**

| Field | Type | Notes |
|-------|------|-------|
| `status_code` | int | 0=success |
| `status_msg` | string | |
| `deposit_amount` | string | Could be empty string |

---

## Customer Endpoints

### 4. getCustomerDetailsCountRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getCustomerDetailsCountRest` |

**Input Parameters:**

| Field | Type | Required | Default |
|-------|------|----------|---------|
| `customerNumber` | string | No | "" |
| `use_lco_deposits` | int | No | 0 |
| `customerName` | string | No | "" |
| `mobileNumber` | string | No | "" |
| `boxNumber` | string | No | "" |
| `lcoCustomerId` | string | No | "" |

**Response:**

| Field | Type | Notes |
|-------|------|-------|
| `status_code` | int | 0=success |
| `status_msg` | string | |
| `customerCount` | int | Count of matching customers |

### 5. getCustomerDetailsRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getCustomerDetailsRest` |
| **CRITICAL** | Uses `statusCode`/`statusMessage` NOT `status_code`/`status_msg` |

**Input Parameters:**

| Field | Type | Required | Default |
|-------|------|----------|---------|
| `customerNumber` | string | No | "" |
| `customerName` | string | No | "" |
| `mobileNumber` | string | No | "" |
| `boxNumber` | string | No | "" |
| `lcoCustomerId` | string | No | "" |
| `cafNumber` | string | No | "" |
| `startValue` | int | No | 0 |
| `endValue` | int | No | 0 |

**Response:**

| Field | Type | Notes |
|-------|------|-------|
| **`statusCode`** | int | **NOTE: camelCase, not status_code!** |
| **`statusMessage`** | string | **NOTE: camelCase, not status_msg!** |
| `customerDetailsList` | array | Array of customer detail objects |
| `total_amount` | string/float | |
| `mso_share` | string/float | |
| `tot_mso_share` | string/float | |
| `lco_share` | string/float | |
| `baid_label` | string | |

**Customer object fields (when no data):** `customerId, customerName, cafNumber, mobileNumber, status, billingAddress, installationAddress, pinCode, crfNumber, stbCount, box_number, vc_number, account_number, pending_amount("0"), total_amount("0"), mso_share("0"), tot_mso_share("0"), lco_share("0"), latitude("0.0"), longitude("0.0"), bill_type, baid_label`

### 6. existingCustomerRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/existingCustomerRest` |

**Input:**

| Field | Type | Required | Default |
|-------|------|----------|---------|
| `accountNumber` | string | No | "" |
| `stbNumber` | string | No | "" |
| `cafNumber` | string | No | "" |
| `tempActivation` | string | No | "" |

**Response:**

| Field | Type | Notes |
|-------|------|-------|
| `status_code` | int | |
| `status_msg` | string | |
| `existCustomerDetails` | array | Array of customer detail objects (many fields from DB) |

### 7. editCustomerRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/editCustomerRest` |

**Input:** Very large - includes `customerId, customerTypeId, cafNumber, businessName, firstName, lastName, idType, idNumber, fatherName, gender, group, customer_sla_id, country, state, district, city, email, mobile, pin, address, installationAddress, reseller_id, old_mobile, phone, address2, address3, remarks, mandal, dateofbirth, dateofanniversary, ipAddress, accountNumber, latitude, longitude, username, password, changeAddrs, customerVerification, baid, billType`. Also supports `idProofImg, customerImg, signatureImg` as multipart POST fields (not in encrypted payload).

**Response:**

| Field | Type |
|-------|------|
| `status_code` | int |
| `error_code` | string |
| `status_msg` | string |

### 8. saveCustomerRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/saveCustomerRest` |

**Input:** Similar to editCustomerRest plus: `boxNumber, packageId, dateType, quantity, packageEndDate, is_surrender, resellerId, customerTypeTypesId, pricingStructureType, validityDays, lcoCustomerId, signatureImg, customerapplicationformImg, customerImg, idProofImg`

**Response:**

| Field | Type |
|-------|------|
| `status_code` | int |
| `status_msg` | string |

### 9. updateCustomerLocation
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/updateCustomerLocation` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `latitude` | string | No |
| `longitude` | string | No |
| `customer_id` | int | No |

**Response:** `{status_code, status_msg}`

---

## Payment Endpoints

### 10. getPendingAmountRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getPendingAmountRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `altCustomerId` | int | YES |
| `serial_no` | string | No (for box-wise payment) |

**Response:**

| Field | Type | Notes |
|-------|------|-------|
| `status_code` | int | |
| `status_msg` | string | |
| `customerName` | string | |
| `mobileNumber` | string | |
| `pendingAmount` | string | The amount field |
| `billingId` | string | |
| `msoShare` | string | |
| `lcoShare` | string | |

### 11. getPaymentModesRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getPaymentModesRest` |

**Input:** None

**Response:**

| Field | Type | Notes |
|-------|------|-------|
| `status_code` | int | |
| `status_msg` | string | |
| `paymentModesList` | array | `[{paymentModeId, paymentModeName}]` |

### 12. makePaymentsRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/makePaymentsRest` |

**Input:**

| Field | Type | Required | Default |
|-------|------|----------|---------|
| `receipt_number` | string | No | "" |
| `altCustomerId` | string | No | "" |
| `amount` | string | No | 0 |
| `chequeNo` | string | No | "" |
| `bank` | string | No | "" |
| `branch` | string | No | "" |
| `chequeDate` | date | No | 0 |
| `altReceiptNumber` | string | No | "" |
| `remarks` | string | No | "" |
| `billingId` | string | No | "" |
| `rrnNo` | string | No | "" |
| `cardholderName` | string | No | "" |
| `modeType` | string | No | "" |
| `voucherCode` | string | No | "" |
| `serial_no` | string | No | "" (for box-wise payment) |
| `customerid_Amt` | string(JSON) | No | JSON array of `{customer_id, amount}` |

**Response (success):**

| Field | Type |
|-------|------|
| `status_code` | int |
| `status_msg` | string |
| `customerName` | string |
| `mobile` | string |
| `email` | string |
| `city` | string |
| `state` | string |
| `pin` | string |
| `billNumber` | string |
| `receiptNumber` | string |
| `altReceiptNumber` | string |
| `amount` | string |
| `billAmount` | string |
| `customNumber` | string |
| `lco_business_name` | string |
| `lco_city` | string |
| `lco_state` | string |
| `lco_pincode` | string |
| `last_paid_amt` | string |
| `last_paid_date` | string |
| `mode` | string |
| `collection_employee` | string |
| `format` | string |
| `lco_balance` | string |
| `voucherCode` | string |
| `successCount` | int |
| `failureCount` | int |
| `error_msg` | string |

### 13. PaymentServiceRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/PaymentServiceRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `dealer_id` | int | No |
| `customer_id` | int | No |

**Response:**

| Field | Type |
|-------|------|
| `status_code` | int |
| `status_msg` | string |
| `payment_details` | array |

### 14. empCustomerCollectionDetailsRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/empCustomerCollectionDetailsRest` |

**Input:**

| Field | Type | Required | Default |
|-------|------|----------|---------|
| `dealer_id` | int | Yes | |
| `fromDate` | date | No | first day of month |
| `toDate` | date | No | last day of month |

**Response:**

| Field | Type |
|-------|------|
| `status_code` | int |
| `status_msg` | string |
| `collectionList` | array | `[{customerName, lcoCustomerId, paymentDate, paymentMode, amount}]` |

---

## STB Endpoints

### 15. getCustomerBoxDetailsRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getCustomerBoxDetailsRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `customerId` | int | YES |

**Response:**

| Field | Type |
|-------|------|
| `status_code` | int |
| `status_msg` | string |
| `customerBoxList` | array | Box detail objects from DB |

### 16. getCustomerParticularBoxDetailsRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getCustomerParticularBoxDetailsRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `customerId` | int | No |
| `stockId` | int | No |
| `userType` | string | No (read directly from payload) |

**Response:**

| Field | Type |
|-------|------|
| `status_code` | int |
| `status_msg` | string |
| `is_temp_deactivated` | int |
| `customerParticularBoxList` | array |
| `is_expired_service` | int |
| `show_replacement` | int |
| `replacement_types` | array | `[{replacement_type_id, replacement_type}]` |
| `stb_replacement_form_validations` | object | `{amount_mandatory, receipt_number_mandatory}` |

### 17. stbPairRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/stbPairRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `serialNumber` | string | YES |
| `vcNumber` | string | YES |

**Response:** `{status_code, error_code, status_msg}`

### 18. stbUnpairRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/stbUnpairRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `serialNumber` | string | YES |

**Response:** `{status_code, error_code, status_msg}`

### 19. deactivateBoxRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/deactivateBoxRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `customerId` | int | YES |
| `serialNumber` | string | YES |
| `vcNumber` | string | YES |
| `boxNumber` | string | YES |
| `macAddress` | string | YES |
| `stockId` | int | YES |
| `deviceId` | int | No |
| `backEndSetupId` | int | YES |
| `reasonId` | int | YES |
| `remarks` | string | YES |
| `from_mobileapp` | int | No | 0 |
| `resellerId` | int | YES |

**Response:** `{status_code, status_msg, is_temp_deactivated}`

### 20. reactivateBoxRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/reactivateBoxRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `stockId` | int | YES |
| `serialNumber` | string | No |
| `boxNumber` | string | No |
| `macAddress` | string | No |
| `deviceId` | int | No |
| `backEndSetupId` | int | No |
| `reinitialize` | int | No |

**Response:** `{status_code, error_code, status_msg}`

### 21. temporaryActivationRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/temporaryActivationRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `customerId` | int | YES |
| `stockId` | int | YES |

**Response:** `{status_code, error_code, status_msg}`

### 22. validateBoxInfoRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/validateBoxInfoRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `boxNumber` | string | YES |

**Response:**

| Field | Type |
|-------|------|
| `status_code` | int |
| `status_msg` | string |
| `boxNumber` | string |
| `resellerId` | int |

### 23. stb_replacement
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/stb_replacement` |

**Input:**

| Field | Type | Required | Default |
|-------|------|----------|---------|
| `serial_number` | string | Yes | |
| `account_nmber` | string | Yes | Note: typo in server code |
| `replacement_type_id` | int | Yes | 0 (1=DEFECTIVE, 2=UPGRADE, 4=SURRENDER, 6=OTHERS) |
| `amount` | string | No | "0" |
| `receipt_number` | string | No | "" |
| `remarks` | string | No | "" |
| `replace_serial_number` | string | No | "" |
| `replace_vc_number` | string | No | "" |
| `is_permanent_surrender` | int | No | 0 |
| `pair_condition` | int | No | 2 (1=Unpair, 2=No Unpair) |

**Response:**

| Field | Type |
|-------|------|
| `status_code` | int |
| `status_msg` | string |
| `response_details` | object |

---

## Package Endpoints

### 24. getCustomerPackages_splitRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getCustomerPackages_splitRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `customerId` | int | No |
| `boxNumber` | string | No |

**Response:**

| Field | Type |
|-------|------|
| `status_code` | int |
| `status_msg` | string |
| `packageList_base` | array |
| `packageList_addon` | array |
| `packageList_ala` | array |
| `packageList_broadcaster` | array |

Each package object contains: `base_price, is_taxable, customer_service_id, product_name, product_id, sd_channels_count, hd_channels_count, alacarte, is_base_package, is_broadcaster_package, validity, validity_days, service_start_date, service_end_date, cas_server_type, extend_service_enddate, service_type, service_validity_days_v2, service_end_date`

### 25. getUnassignedPackages_splitRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getUnassignedPackages_splitRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `customerId` | int | No |
| `boxNumber` | string | No |

**Response:**

| Field | Type |
|-------|------|
| `status_code` | int |
| `status_msg` | string |
| `packageList_base` | array |
| `packageList_addon` | array |
| `packageList_ala` | array |
| `packageList_broadcaster` | array |
| `deactivate_customerservices` | array |

Package fields: `product_id, pname, base_price, sd_channels_count, hd_channels_count, is_base_package, is_broadcaster_package, alacarte, monthly_or_yearly, validity, validity_days, pricing_structure_type, is_taxble, tax1-tax6, broadcaster_id, end_date, bill_types, billing_schedules, service_durations, default_end_date`

### 26. channel_listRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/channel_listRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `dealer_id` | int | No |
| `product_id` | int | No |

**Response:** `{status_code, status_msg, channel_details: [...]}`

### 27. getCasPackagesRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getCasPackagesRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `boxNumber` | string | YES |

**Response:** `{status_code, status_msg, caspackageList: [{product_id, pname, base_price, sd_channels_count, hd_channels_count, is_base_package, is_broadcaster_package, alacarte, monthly_or_yearly, validity, validity_days, pricing_structure_type, is_taxble, tax1-tax6, broadcaster_id}]}`

### 28. deactivateServiceRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/deactivateServiceRest` |

**Input:**

| Field | Type | Required | Default |
|-------|------|----------|---------|
| `customerId` | int | YES | |
| `serviceId` | string | No | 0 |
| `reasonId` | int | No | 0 |
| `remarks` | string | No | "" |
| `stockId` | int | YES | |
| `resellerId` | int | YES | |
| `fromMobileApp` | int | No | 0 |
| `fromCustomerPortal` | int | No | 0 |
| `deactservice_customer_portal` | int | No | 0 |
| `callFromDigi` | int | No | 0 |
| `digi_config_value` | int | No | 0 |
| `bill_dealer_id` | int | No | 0 |
| `check_validation` | int | No | 0 |

**Response:** `{status_code, status_msg}`

### 29. activateServiceRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/activateServiceRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `customerId` | string | YES |
| `productId` | string | YES |
| `stockId` | string | YES |
| `resellerId` | string | YES |
| `fromCustomerPortal` | string | No |

**Response:** `{status_code, status_msg}`

### 30. extendCustomerServices
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/extendCustomerServices` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `customer_id` | int | No |
| `product_id` | int | No |
| `stock_id` | int | No |
| `quantity` | int | No |
| `fromMobileApp` | int | No |
| `customer_service_id` | int | No |
| `extend_date` | string | No |
| `plugin_id` | int | No |

**Response:** `{status_code, error_code, status_msg}`

### 31. renewServicesList
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/renewServicesList` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `customer_id` | int | No |
| `customer_service_id` | string | No |
| `product_ids` | string | No (comma-separated) |

**Response:** `{status_code, status_msg}`

### 32. getRenewServicesList
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getRenewServicesList` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `customer_id` | int | No |

**Response:** `{status_code, status_msg, getRenewServices: [...]}`

### 33. getDeactiveReasonsRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getDeactiveReasonsRest` |

**Input:**

| Field | Type | Required | Default |
|-------|------|----------|---------|
| `showforlco` | int | No | 0 |
| `stockId` | int | No | 0 |

**Response:** `{status_code, status_msg, reasonList: [{reasonId, reasonName}]}`

### 34. getbilldetailsRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getbilldetailsRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `serial_number` | string | YES |
| `package_id` | string | YES (comma-separated IDs) |
| `bill_type` | int | No |
| `customer_id` | int | YES |
| `employee_id` | int | No |

**Response:**

| Field | Type | Notes |
|-------|------|-------|
| `status_code` | int | |
| `status_msg` | string | |
| `basePrice` | object | See fields below |

**basePrice object:**

| Field | Type |
|-------|------|
| `lco_share` | float |
| `mso_share` | float |
| `total_amount` | float |
| `pend_mso_share` | float |
| `tax_amount` | float |
| `bill_amount` | float |
| `flaot_tax1` through `flaot_tax6` | float | Note: "flaot" typo is in server code |
| `float_total_tax` | float |
| `flaot_discount_amount` | float |
| `flaot_amount_before_discount` | float |
| `ncf_total_amount` | float |
| `encf_total_amount` | float (always 0) |
| `ncf_display_name` | string |
| `encf_display_name` | string |
| `mso_share_payble` | string (sprintf formatted) |

---

## Complaint Endpoints

### 35. complaintCategoriesRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/complaintCategoriesRest` |

**Input:** None

**Response:** `{status_code, status_msg, complaintCategories: [{categoryId, categoryName}]}`

### 36. complaintTypesRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/complaintTypesRest` |

**Input:** None

**Response:**

| Field | Type |
|-------|------|
| `status_code` | int |
| `status_msg` | string |
| `complaintStatuses` | array | `[{statusName}]` |
| `ticket_closer_categories` | array | `[{category_id, parent_category_id, category_name, sub_category_name}]` |

### 37. ComplaintHistoryRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/ComplaintHistoryRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `dealer_id` | int | YES |
| `customer_id` | int | YES |

**Response:** `{status_code, status_msg, complaint_details: [...]}`

### 38. getCustomerComplaintListRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getCustomerComplaintListRest` |

**Input:**

| Field | Type | Required | Default |
|-------|------|----------|---------|
| `altCustomerId` | int | No | 0 |
| `status` | string | No | "" |
| `userType` | string | No | "" |

**Response:** `{status_code, status_msg, customerComplaintList: [{customerId, customNumber, customerName, group, complaintId, ticketNumber, complaint, complaintTime, status}]}`

### 39. getComplaintsubCategory
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getComplaintsubCategory` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `complaintcategory` | int | No |

**Response:** `{status_code, status_msg, complaintSubCategories: [{complaint_category_id, complaint_category_name}]}`

### 40. createComplaintRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/createComplaintRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `customerId` | string | YES |
| `complaint` | string | YES |
| `category` | int | YES |
| `error` | string | No |
| `assignedTo` | int | No (defaults to employeeId) |

**Response:** `{status_code, status_msg, ticketNumber}`

### 41. closeComplaintRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/closeComplaintRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `complaintId` | int | YES |
| `assignedemp` | string | YES |
| `ticketNumber` | string | YES |
| `comment` | string | YES |
| `status` | string | YES | e.g., "CLOSED", "RESOLVED" |
| `closer_ticket_type_id` | int | No | 0 |
| `closer_reason_id` | int | No | 0 |

**Response:** `{status_code, status_msg}`

### 42. getComplaintList
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getComplaintList` |

**Input:**

| Field | Type | Required | Default |
|-------|------|----------|---------|
| `serviceemployeeid` | int | No | 0 |
| `login_users_type` | string | No | "RESELLER" |

**Response:** `{status_code, status_msg, lcoComplaintlist: [...]}` (excludes CLOSED complaints)

### 43. getLcoEmployeeList
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getLcoEmployeeList` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `employee_id` | int | No |

**Response:** `{status_code, status_msg, lcoEmployeelist: [{lco_employee_id, lco_employee_name}]}`

---

## Master Data Endpoints

### 44. getGroupsRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getGroupsRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `serialNumber` | string | No |

**Response:** `{status_code, status_msg, groupsList: [...]}`

### 45. getCustomerTypesRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getCustomerTypesRest` |

**Input:** None

**Response:** `{status_code, status_msg, customerTypeList: [...]}`

### 46. getmandalsRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getmandalsRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `districtId` | int | No |

**Response:** `{status_code, status_msg, mandalList: [...]}`

### 47. getLocationsOfDistrictRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getLocationsOfDistrictRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `districtId` | int | YES |

**Response:** `{status_code, status_msg, districtLocationsList: [{location_id, location_name, district_id, mandal_id}]}`

### 48. getcustomerTypeTypesRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getcustomerTypeTypesRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `resellerId` | int | YES |
| `customerTypeId` | int | YES |

**Response:** `{status_code, status_msg, customerTypeTypesInfoList: [{customerTypeTypesId, name}]}`

### 49. getIdsRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getIdsRest` |

**Input:** None

**Response:** `{status_code, status_msg, idList: [{id, name}]}`

### 50. getCitiesRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getCitiesRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `stateId` | int | YES |
| `boxNumber` | string | YES |

**Response:** `{status_code, status_msg, citiesList: [{location_id, location_name}]}`

### 51. getdistrictsRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getdistrictsRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `stateId` | int | YES |

**Response:** `{status_code, status_msg, districtList: [{district_id, district_name}]}`

### 52. getStatesRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getStatesRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `countryCode` | string | YES | e.g., "IN", "US" |

**Response:** `{status_code, status_msg, statesList: [{id, name}]}`

### 53. getCountriesRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getCountriesRest` |

**Input:** None

**Response:** `{status_code, status_msg (NOTE: actually returns employeeId here!), countriesList: [{iso, name}]}`

**BUG:** The `status_msg` field actually contains `$employeeId` instead of the status message string.

### 54. dynamicformvalidationsRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/dynamicformvalidationsRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `table_name` | string | YES | e.g., "eb_stock" |

**Response:** `{status_msg: <form validation data>}`

---

## Report Endpoints

### 55. DailyreportRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/DailyreportRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `dealer_id` | int | YES |
| `date` | date | YES | format: YYYY-MM-DD |

**Response:** `{status_code, status_msg, Dailyreport_details: [...]}`

### 56. empCollectionRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/empCollectionRest` |

**Input:**

| Field | Type | Required | Default |
|-------|------|----------|---------|
| `dealer_id` | int | YES | |
| `fromDate` | date | YES | Y-m-01 |
| `toDate` | date | YES | Y-m-t |

**Response:** `{status_code, status_msg, collectionList: [{employeeId, employeeName, collectionAmount}]}`

### 57. InvoiceServiceRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/InvoiceServiceRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `customer_id` | int | YES |
| `dealer_id` | int | YES |

**Response:** `{status_code, status_msg, invoice_details: [...]}`

### 58. getReceiptRanges
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getReceiptRanges` |

**Input:** None (employeeId from JWT)

**Response:** `{status_code, status_msg, ReceiptRanges: [string array of receipt numbers]}`

---

## Employee / Access Control Endpoints

### 59. getaccesscontrollRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getaccesscontrollRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `employeeParentType` | string | No |
| `dealer_id` | int | YES |
| `userstype` | string | YES |
| `employeeParentId` | int | No |

**Response:**

| Field | Type |
|-------|------|
| `status_code` | int |
| `status_msg` | string |
| `int_bulk_payment` | int |
| `invoice_page_access` | int |
| `payment_hist_page_access` | int |
| `access_for_complaints` | int |
| `int_stb_activation` | int |
| `int_stb_deactivation` | int |
| `int_stb_reactivation` | int |
| `int_payment_transaction_report_access` | int (always 1) |

### 60. getServiceEmployeeList
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getServiceEmployeeList` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `dealer_id` | int | YES |

**Response:** `{status_code, status_msg, getServiceEmployeeList: [...]}`

---

## Wallet / Transaction Endpoints

### 61. getlcowalletRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getlcowalletRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `start_date` | date | YES |
| `end_date` | date | YES |
| `dealer_id` | int | YES |

**Response:** `{status_code, status_msg, getLcoWalletReport: [...]}`

### 62. pgTransactionLogs
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/pgTransactionLogs` |

**Input:**

| Field | Type | Required | Default |
|-------|------|----------|---------|
| `dealer_id` | int | No | 0 |
| `payment_status` | int | No | 0 |
| `end_date` | date | No | today |

**Note:** `start_date` is always hardcoded to 3 months ago on the server.

**Response:** `{status_code, status_msg, paymentresult: [...]}`

### 63. customer_transaction_reponseRest
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/customer_transaction_reponseRest` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `employee_id` | int | YES |
| `dealer_id` | int | YES |

**Response:** `{status_code, status_msg, response_details: [...]}`

### 64. gettotalcomplaintslist
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/gettotalcomplaintslist` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `dealer_id` | int | No |

**Response:** `{status_code, status_msg, gettotalcomplaintslist: [...]}`

### 65. getdashboardlist
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getdashboardlist` |

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `from_dashboard` | int | YES | 1=assigned, 2=unassigned, 3=total, 4=active, 5=inactive |
| `dealer_id` | int | YES |

**Response:** `{status_code, status_msg, getDashboardDataList: [{serial_number, mac_address, stock_id, box_number, vc_number, dealer_id, reseller_id, is_assigned, assigned_date, customer_name, account_number, mobile_no, customer_id, cas, is_active, activate_date, installation_address, service_enddate}]}`

### 66. customer_deduction_logs
| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/customer_deduction_logs` |

**Input:**

| Field | Type | Required | Default |
|-------|------|----------|---------|
| `dateRange` | string | No | "current_month" | Options: "current_month", "last_3_months", "all_time" |
| `customerId` | int | No | 0 |

**Response:** `{status_code, status_msg, deduction_logs: [{date (formatted dd-mm-yyyy HH:ii:ss), ...}]}`

---

## CRITICAL: Type Issues for Flutter Models

### Fields that come as STRINGS from DB but should be parsed as numbers:

1. **All LOV values** (useCRF, useCAF, useLastName, etc.) - returned as **string** from DB, e.g., "0" or "1"
2. **`employeeId`** - int in PHP but may be string in JSON
3. **`dealerId`** - int in PHP but may be string in JSON
4. **`district`, `city`, `state`** - may be int 0 or string ""
5. **`deposit_amount`** - string
6. **`pending_amount`, `total_amount`, `mso_share`, `lco_share`** - string "0" or "0.00"
7. **`latitude`, `longitude`** - string "0.0"
8. **`customerCount`** - could be string from COUNT query
9. **Dashboard values** (`totalStbs`, `totalAssignedStbs`, etc.) - may be string from DB aggregate queries
10. **`outStandingAmount`** - initialized as -1 (int) but DB returns float/string

### Fields with naming inconsistencies:

| Server Field | Expected Flutter Field | Issue |
|-------------|----------------------|-------|
| `statusCode` (getCustomerDetailsRest) | `status_code` | camelCase vs snake_case |
| `statusMessage` (getCustomerDetailsRest) | `status_msg` | camelCase vs snake_case |
| `flaot_tax1` | `float_tax1` | Typo in server code |
| `flaot_discount_amount` | `float_discount_amount` | Typo in server code |
| `account_nmber` (stb_replacement) | `account_number` | Typo in server code |
| `status_msg` (getCountriesRest) | should be string | Actually returns employeeId (bug) |

### Default values when auth fails:
- Most endpoints return `status_code: 1` with descriptive message
- Some endpoints return empty placeholder objects with all fields as empty strings
- Some endpoints return empty arrays `[]`

### Endpoints that use old encryption (not sendResponse):
These endpoints call `$this->encryption_lib->app_data_encryption()` + `$this->response()` directly instead of `sendResponse()`:
- `empCustomerCollectionDetailsRest`
- `getCustomerComplaintListRest`
- `getGroupsRest`
- `getCustomerTypesRest`
- `getmandalsRest`
- `extendCustomerServices`
- `renewServicesList`
- `getRenewServicesList`
- `getComplaintsubCategory`
- `updateCustomerLocation`
- `getReceiptRanges`
- `getLcoEmployeeList`
- `getComplaintList`
- `stbPairRest`
- `stbUnpairRest`
- `reactivateBoxRest`
- `temporaryActivationRest`
- `editCustomerRest`
- `getExpiryServicesDateWiseCount` (not a _post endpoint in name but exists)

**Both methods produce the same encrypted output format**, so the Flutter client decrypts them the same way.
