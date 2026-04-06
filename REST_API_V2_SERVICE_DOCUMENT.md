# EzyBill REST API v2 - Service Document

> **Source:** Verified against server-side code `LcoRestServices.php` (470KB, 70 endpoints)
> **Important:** ALL endpoints have REST implementations. No SOAP calls needed.
> **⚠️ URL CORRECTION (2026-03-26):** All endpoint paths in this document were originally written as `/customerRestservices/`. The correct controller path for Flutter is `/LcoRestServices/`. See Base Configuration below.

## Base Configuration

| Property | Value |
|----------|-------|
| **Current Server IP** | `183.83.216.66:8882` |
| **App Path** | `/v2_release/index.php` |
| **REST Controller** | `LcoRestServices` |
| **REST Base URL** | `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices` |
| **Full Example** | `POST http://183.83.216.66:8882/v2_release/index.php/LcoRestServices/validateLogin` |
| **Protocol** | HTTP POST (form-urlencoded or JSON, encrypted via `Encryption_lib`) |
| **Auth Mechanism** | JWT token in header + `authtoken` in payload |
| **IP Restriction** | Server validates client IP via `iprestriction_check()` |

> **Flutter Dart constant:**
> ```dart
> const String kApiBase = 'http://183.83.216.66:8882/v2_release/index.php/LcoRestServices';
> // Make configurable — server IP may change per deployment
> ```

> **Why `/LcoRestServices/` not `/LcoRestServices/`:**
> The Android app uses `configg.properties` entries like `cscate=/customerRestservices/getComplaintsubCategory`
> which it appends to the SOAP URL after stripping `/wsController`. The `/LcoRestServices/` path is
> a CodeIgniter route alias that maps to the same `LcoRestServices` controller — both paths work on the
> server. However, `api_test.html` (the Flutter project's own API test tool) uses `/LcoRestServices/`
> as the canonical path and this should be used in all Flutter code.

> **Old dev server (Android hardcoded):** `http://itpworld.linkpc.net:81/developers/satyam/ezybmsys/app/index.php`
> This is the legacy BMS dev server referenced in `configg.properties`. Do NOT use this for Flutter.

## Special Controllers (NOT LcoRestServices)

Some endpoints use separate CI controllers on the same server:

| Property Key | Path | Controller |
|-------------|------|-----------|
| `payweb` | `/paymentgateway/mobile_paymentsview` | Payment Gateway |
| `ctransac` | `/selfcare_rest_mobileapp/customer_transaction_reponse` | Selfcare REST |
| `cvwm` | `/selfcare_rest_mobileapp/customer_validationwithmobile` | Selfcare REST |
| `cov` | `/selfcare_rest_mobileapp/customer_otp_validation` | Selfcare REST |

Full URL for these: `http://183.83.216.66:8882/v2_release/index.php{path}`

## Authentication Flow (Server-Side)

1. Client sends POST to `{REST_BASE}/validateLogin` with `UserName`, `PassWord`, `mobile_no`, `imei`
2. Server returns JWT token + user details
3. All subsequent requests must include JWT token in header
4. Server decrypts payload via `Encryption_lib->checkPayload()` before processing
5. Server validates token via `WsModel->isValidPassToken()` and extracts `employeeId` + `dealerId`
6. Parallel login restriction: if enabled, only one active session per employee

## Common Response Format

All endpoints return JSON:
```json
{
  "status_code": 1,        // 1 = success, 0 = error
  "status_msg": "Success",
  "...data fields..."
}
```

**⚠️ Status Code Exception — `getaccesscontrollRest`:**
This endpoint uses the **opposite convention**: `status_code: 0` = success, `status_code: 1` = failure.
Confirmed from `LoginActivity.java` line 1397: `if (statusCode == 0)` navigates to app home.
All other endpoints follow `1 = success, 0 = error`.

---

## 1. AUTHENTICATION

### 1.1 validateLogin
- **Server Method:** `validateLogin_post()` (Line 153)
- **Endpoint:** `POST /LcoRestServices/validateLogin`
- **Auth Required:** No (excluded from `checkAuthentication`)
- **Payload Parameters:**
  | Field | Type | Required | Description |
  |-------|------|----------|-------------|
  | `UserName` | String | Yes | Login username |
  | `PassWord` | String | Yes | Login password |
  | `mobile_no` | String | No | Mobile number |
  | `imei` | String | No | Device IMEI |
- **Response Fields:** `status_code`, `status_msg`, `token`, `employeeId`, `first_name`, `last_name`, `address1`, `address2`, `address3`, `copy_rights`, `short_name`, `pin_code`, `phone`, `email`, `country`, `state`, `district`, `city`, `username`, `dob`, `adate`, `employeeName`, `dealerId`, `userType`, `useCRF`, `useCAF`, `useLastName`, `useDiscount`, `useDataFromMasterTable`, `useMandatoryForHotel`, `useAccountNumber`, `employeeParentId`, `employeeParentType`, `useLcoDeposit`, `deposit_amount`, `defaultCountry`, `country_name`, `defaultState`, `defaultDistrict`, `defaultCity`, `recurringServiceEdit`, `showLcoComplaint`, `lcoCode`, `lcoLocation`, `lcoMobileNo`, `freezecustomerparamsinapp`, `blockpayment`, `business_name`, `is_unpaidlco`, `appMenuFormat`, `invoicepaymentsearchlimit`, `lco_billtype`, `use_lco_deposits`, `userNotifications`, `notifyCount`, `note_duration`, `customer_billtype`, `AUTO_RECEIPT_NUMBER`, `CURRENCY_CODE`, `allow_top_up`, `show_caf_mobile_validation`, `patch_information`, `stb_pairing`, `stb_unpairing`, `show_mia_agreement_upload`, `accept_terms_condtions`, `agreement_details_count`, `access_distributor_wise`, `is_direct_lco`, `show_serial_vc`, `user_image`, `show_service_extension`, `config_values_array`, `edit_quantity`, `enable_box_wise_payment`, `baid_label`

### 1.2 getaccesscontrollRest
- **Server Method:** `getaccesscontrollRest_post()` (Line 7228)
- **Endpoint:** `POST /LcoRestServices/getaccesscontrollRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `employeeParentType` | String | From login response |
  | `dealer_id` | int | Dealer ID |
  | `userstype` | String | User type from login |
  | `employeeParentId` | String | Parent ID from login |
  | `authToken` | String | Auth token |
- **Response Fields:** `status_code`, `status_msg`, `report`, `int_bulk_payment`, `invoice_page_access`, `payment_hist_page_access`, `access_for_complaints`, `int_stb_activation`, `int_stb_deactivation`, `int_stb_reactivation`

---

## 2. DASHBOARD

### 2.1 dashBoardDetailsRest
- **Server Method:** `dashBoardDetailsRest_post()` (Line 609)
- **Endpoint:** `POST /LcoRestServices/dashBoardDetailsRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `use_lco_deposits` | String | LCO deposit flag |
  | `lco_billtype` | String | LCO bill type |
- **Response Fields:** `status_code`, `status_msg`, `totalStbs`, `totalAssignedStbs`, `totalUnAssignedStbs`, `totalComplaints`, `totalClosedComplaints`, `totalActiveCustomers`, `totalDeactiveCustomers`, `totalCurrentMonthBill`, `totalDueAmount`, `totalPaidCustomers`, `totalUnPaidCustomers`, `gettotalPaidCustomers`, `gettotalUnPaidCustomers`, `outStandingAmount`, `msoShare`, `totalCurrentMonthMsoShare`, `currentMonthOutstanding`, `currentMonthLCOBill`, `lcocurrentmonthdueamount`, `lov_emp_grp_customers`

### 2.2 lco_deposit_amountRest
- **Server Method:** `lco_deposit_amountRest_post()` (Line 929)
- **Endpoint:** `POST /LcoRestServices/lco_deposit_amountRest`
- **Payload:** None (uses authenticated employee/dealer from JWT)
- **Response Fields:** `deposit_amount`, `customerCount`

### 2.3 getlcowalletRest
- **Server Method:** `getlcowalletRest_post()` (Line 7991)
- **Endpoint:** `POST /LcoRestServices/getlcowalletRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `start_date` | String | Filter start date |
  | `end_date` | String | Filter end date |
  | `dealer_id` | int | Dealer ID |
- **Response Fields:** `status_code`, `status_msg`, `paymentresult`

### 2.4 getdashboardlist
- **Server Method:** `getdashboardlist_post()` (Line 8255)
- **Endpoint:** `POST /LcoRestServices/getdashboardlist`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `from_dashboard` | int | Dashboard source flag |
  | `dealer_id` | int | Dealer ID |
- **Response Fields:** `status_code`, `status_msg`, `getDashboardDataList`

### 2.5 getExpiryServicesDateWiseCount
- **Server Method:** `getExpiryServicesDateWiseCount_post()` (Line 5994)
- **Endpoint:** `POST /LcoRestServices/getExpiryServicesDateWiseCount`
- **Payload:** None (uses authenticated dealer)
- **Response Fields:** `getExpiryServicesList`, `status`, `errro_msg`

---

## 3. CUSTOMER MANAGEMENT

### 3.1 getCustomerDetailsCountRest
- **Server Method:** `getCustomerDetailsCountRest_post()` (Line 972)
- **Endpoint:** `POST /LcoRestServices/getCustomerDetailsCountRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `customerNumber` | String | Customer number search |
  | `use_lco_deposits` | String | LCO deposits flag |
  | `customerName` | String | Name search |
  | `mobileNumber` | String | Mobile search |
  | `boxNumber` | String | STB serial search |
  | `lcoCustomerId` | String | LCO customer ID search |
- **Response Fields:** `status_code`, `status_msg`, `customerCount`, `existCustomerDetails`

### 3.2 getCustomerDetailsRest
- **Server Method:** `getCustomerDetailsRest_post()` (Line 1065)
- **Endpoint:** `POST /LcoRestServices/getCustomerDetailsRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `customerNumber` | String | Customer number |
  | `customerName` | String | Customer name |
  | `mobileNumber` | String | Mobile number |
  | `boxNumber` | String | STB serial number |
  | `lcoCustomerId` | String | LCO customer ID |
  | `cafNumber` | String | CAF number |
  | `startValue` | int | Pagination start |
  | `endValue` | int | Pagination end |
- **Response Fields:** `status_code`, `status_msg`, `lco_share`, `existCustomerDetails`

### 3.3 existingCustomerRest
- **Server Method:** `existingCustomerRest_post()` (Line 1208)
- **Endpoint:** `POST /LcoRestServices/existingCustomerRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `accountNumber` | String | Account number |
  | `stbNumber` | String | STB number |
  | `cafNumber` | String | CAF number |
  | `tempActivation` | String | Temp activation flag |
- **Response Fields:** `status_code`, `status_msg`, `existCustomerDetails`, `lcoShare`

### 3.4 saveCustomerRest
- **Server Method:** `saveCustomerRest_post()` (Line 5517)
- **Endpoint:** `POST /LcoRestServices/saveCustomerRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `customerTypeId` | int | Customer type |
  | `cafNumber` | String | CAF number |
  | `businessName` | String | Business name |
  | `firstName` | String | First name |
  | `lastName` | String | Last name |
  | `idType` | int | ID proof type |
  | `idNumber` | String | ID proof number |
  | `fatherName` | String | Father's name |
  | `gender` | String | Gender |
  | `group` | int | Group ID |
- **Response Fields:** `status_code`, `status_msg`, `customer_id`, `online_customer`, `stb_count`, `email`, `pin_code`, `int_operation_id`, `form_validations`, `NCF_ENCF`, `dealer_id`, `array_dealer_setting`

### 3.5 editCustomerRest
- **Server Method:** `editCustomerRest_post()` (Line 4942)
- **Endpoint:** `POST /LcoRestServices/editCustomerRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `firstName` | String | First name |
  | `lastName` | String | Last name |
  | `reseller_id` | int | Reseller ID |
  | `customerTypeId` | int | Customer type |
  | `gender` | String | Gender |
  | `group` | int | Group ID |
  | `customer_sla_id` | int | SLA ID |
  | `country` | int | Country ID |
  | `state` | int | State ID |
  | `district` | int | District ID |
- **Response Fields:** `status_code`, `status_msg`

### 3.6 updateCustomerLocation
- **Server Method:** `updateCustomerLocation_post()` (Line 3681)
- **Endpoint:** `POST /LcoRestServices/updateCustomerLocation`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `latitude` | double | GPS latitude |
  | `longitude` | double | GPS longitude |
  | `customer_id` | int | Customer ID |
- **Response Fields:** `status_code`, `status_msg`

---

## 4. PAYMENTS

### 4.1 getPendingAmountRest
- **Server Method:** `getPendingAmountRest_post()` (Line 1279)
- **Endpoint:** `POST /LcoRestServices/getPendingAmountRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `altCustomerId` | int | Customer ID |
  | `serial_no` | String | STB serial number |
- **Response Fields:** `status_code`, `status_msg`, `lcoShare`, `paymentModesList`

### 4.2 makePaymentsRest
- **Server Method:** `makePaymentsRest_post()` (Line 1431)
- **Endpoint:** `POST /LcoRestServices/makePaymentsRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `receipt_number` | String | Receipt number |
  | `altCustomerId` | int | Customer ID |
  | `amount` | double | Payment amount |
  | `authToken` | String | Auth token |
  | `chequeNo` | String | Cheque number (if cheque) |
  | `bank` | String | Bank name (if cheque) |
  | `branch` | String | Branch name (if cheque) |
  | `chequeDate` | String | Cheque date |
  | `altReceiptNumber` | String | Alternate receipt |
  | `remarks` | String | Payment remarks |
- **Response Fields:** `status_code`, `status_msg`, `error_msg`, `digi_activation_from`, `statusMessage`, `modeType`, `use_lco_deposit`, `voucherCode`, `payment_records`, `digi_key`, `receipt_number`, `customerBoxList`

### 4.3 getPaymentModesRest
- **Server Method:** `getPaymentModesRest_post()` (Line 1384)
- **Endpoint:** `POST /LcoRestServices/getPaymentModesRest`
- **Payload:** None
- **Response Fields:** `paymentModesList`, `status_msg`

### 4.4 getReceiptRanges
- **Server Method:** `getReceiptRanges_post()` (Line 3751)
- **Endpoint:** `POST /LcoRestServices/getReceiptRanges`
- **Payload:** None
- **Response Fields:** `status_code`, `status_msg`, `ReceiptRanges`

### 4.5 getbilldetailsRest
- **Server Method:** `getbilldetailsRest_post()` (Line 7406)
- **Endpoint:** `POST /LcoRestServices/getbilldetailsRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `serial_number` | String | STB serial number |
  | `package_id` | int | Package ID |
  | `bill_type` | String | Bill type |
  | `customer_id` | int | Customer ID |
  | `employee_id` | int | Employee ID |
- **Response Fields:** `status_code`, `status_msg`, `dealer_id`, `array_dealer_setting`, `enum_add_on_after_base`, `double_stb_discount`, `int_customer_id`, `end_time`, `service_enddate_time`, `ENABLE_PRORATA_DISCOUNT`, `arr_box_details`, `arr_act_package_details`, `tax_amount`, `extra_parameters`

### 4.6 pgTransactionLogs
- **Server Method:** `pgTransactionLogs_post()` (Line 8050)
- **Endpoint:** `POST /LcoRestServices/pgTransactionLogs`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `dealer_id` | int | Dealer ID |
  | `payment_status` | String | "-1"=all, "1"=success, "2"=failed |
  | `start_date` | String | Start date filter |
  | `end_date` | String | End date filter |
- **Response Fields:** `status_code`, `status_msg`, `paymentresult`

### 4.7 PaymentServiceRest
- **Server Method:** `PaymentServiceRest_post()` (Line 2690)
- **Endpoint:** `POST /LcoRestServices/PaymentServiceRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `dealer_id` | int | Dealer ID |
  | `customer_id` | int | Customer ID |
- **Response Fields:** `status_code`, `status_msg`, `payment_details`

### 4.8 customer_transaction_reponseRest
- **Server Method:** `customer_transaction_reponseRest_post()` (Line 8430)
- **Endpoint:** `POST /LcoRestServices/customer_transaction_reponseRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `employee_id` | int | Employee ID |
  | `dealer_id` | int | Dealer ID |
  | `auth_key` | String | Auth key |
- **Response Fields:** `status_code`, `status_msg`, `response_details`

---

## 5. COMPLAINTS

### 5.1 getComplaintList
- **Server Method:** `getComplaintList_post()` (Line 3884)
- **Endpoint:** `POST /LcoRestServices/getComplaintList`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `serviceemployeeid` | int | Service employee filter |
  | `login_users_type` | String | Login user type |
- **Response Fields:** `status_code`, `status_msg`

### 5.2 gettotalcomplaintslist
- **Server Method:** `gettotalcomplaintslist_post()` (Line 8172)
- **Endpoint:** `POST /LcoRestServices/gettotalcomplaintslist`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `dealer_id` | int | Dealer ID |
- **Response Fields:** `gettotalcomplaintslist`, `getDashboardDataList`

### 5.3 getCustomerComplaintListRest
- **Server Method:** `getCustomerComplaintListRest_post()` (Line 2825)
- **Endpoint:** `POST /LcoRestServices/getCustomerComplaintListRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `altCustomerId` | int | Customer ID |
  | `status` | String | Complaint status filter |
  | `userType` | String | User type |
- **Response Fields:** `status_code`, `status_msg`, `customerComplaintList`

### 5.4 complaintCategoriesRest
- **Server Method:** `complaintCategoriesRest_post()` (Line 2519)
- **Endpoint:** `POST /LcoRestServices/complaintCategoriesRest`
- **Payload:** None
- **Response Fields:** `complaintCategories`, `status_msg`

### 5.5 getComplaintsubCategory
- **Server Method:** `getComplaintsubCategory_post()` (Line 3599)
- **Endpoint:** `POST /LcoRestServices/getComplaintsubCategory`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `complaintcategory` | int | Parent category ID |
- **Response Fields:** `status_code`, `status_msg`, `complaintSubCategories`

### 5.6 createComplaintRest
- **Server Method:** `createComplaintRest_post()` (Line 7082)
- **Endpoint:** `POST /LcoRestServices/createComplaintRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `customerId` | int | Customer ID |
  | `assignedTo` | int | Assigned employee ID |
  | `complaint` | String | Complaint description |
  | `category` | int | Category ID |
  | `error` | int | Error type ID |
- **Response Fields:** `status_code`, `status_msg`, `requestId`, `requestServerIp`, `assignedTo`, `ticketNumber`, `Success`, `tkt_number`, `int_stb_reactivation`

### 5.7 complaintTypesRest
- **Server Method:** `complaintTypesRest_post()` (Line 2572)
- **Endpoint:** `POST /LcoRestServices/complaintTypesRest`
- **Payload:** None
- **Response Fields:** `ticket_closer_categories`, `status_msg`

### 5.8 closeComplaintRest
- **Server Method:** `closeComplaintRest_post()` (Line 6928)
- **Endpoint:** `POST /LcoRestServices/closeComplaintRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `complaintId` | int | Complaint ID |
  | `ticketNumber` | String | Ticket number |
  | `comment` | String | Resolution comment |
  | `assignedemp` | int | Assigned employee |
  | `status` | String | New status |
  | `closer_ticket_type_id` | int | Closer ticket type |
  | `closer_reason_id` | int | Closer reason |
- **Response Fields:** `status_code`, `status_msg`

### 5.9 ComplaintHistoryRest
- **Server Method:** `ComplaintHistoryRest_post()` (Line 2630)
- **Endpoint:** `POST /LcoRestServices/ComplaintHistoryRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `dealer_id` | int | Dealer ID |
  | `customer_id` | int | Customer ID |
- **Response Fields:** `status_code`, `status_msg`, `complaint_details`

---

## 6. STB / BOX OPERATIONS

### 6.1 getCustomerBoxDetailsRest
- **Server Method:** `getCustomerBoxDetailsRest_post()` (Line 1743)
- **Endpoint:** `POST /LcoRestServices/getCustomerBoxDetailsRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `customerId` | int | Customer ID |
- **Response Fields:** `status_code`, `status_msg`, `customerBoxList`, `is_expired_service`

### 6.2 getCustomerParticularBoxDetailsRest
- **Server Method:** `getCustomerParticularBoxDetailsRest_post()` (Line 1812)
- **Endpoint:** `POST /LcoRestServices/getCustomerParticularBoxDetailsRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `customerId` | int | Customer ID |
  | `stockId` | int | Stock/device ID |
  | `userType` | String | User type |
- **Response Fields:** `status_code`, `status_msg`, `stb_replacement_form_validations`, `reasonList`

### 6.3 deactivateBoxRest
- **Server Method:** `deactivateBoxRest_post()` (Line 4195)
- **Endpoint:** `POST /LcoRestServices/deactivateBoxRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `customerId` | int | Customer ID |
  | `serialNumber` | String | STB serial |
  | `vcNumber` | String | VC number |
  | `boxNumber` | String | Box number |
  | `macAddress` | String | MAC address |
  | `stockId` | int | Stock ID |
  | `deviceId` | int | Device ID |
  | `backEndSetupId` | int | Backend setup ID |
  | `reasonId` | int | Deactivation reason |
  | `remarks` | String | Remarks |
- **Response Fields:** `status_code`, `status_msg`, `is_temp_deactivated`

### 6.4 reactivateBoxRest
- **Server Method:** `reactivateBoxRest_post()` (Line 4378)
- **Endpoint:** `POST /LcoRestServices/reactivateBoxRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `serialNumber` | String | STB serial |
  | `boxNumber` | String | Box number |
  | `macAddress` | String | MAC address |
  | `deviceId` | int | Device ID |
  | `backEndSetupId` | int | Backend setup ID |
- **Response Fields:** `status_code`, `status_msg`

### 6.5 getDeactiveReasonsRest
- **Server Method:** `getDeactiveReasonsRest_post()` (Line 1947)
- **Endpoint:** `POST /LcoRestServices/getDeactiveReasonsRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `showforlco` | String | Show for LCO flag |
  | `stockId` | int | Stock ID |
- **Response Fields:** `reasonList`, `packageList_broadcaster`

### 6.6 temporaryActivationRest
- **Server Method:** `temporaryActivationRest_post()` (Line 4562)
- **Endpoint:** `POST /LcoRestServices/temporaryActivationRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `customerId` | int | Customer ID |
  | `stockId` | int | Stock ID |
- **Response Fields:** `status_code`, `status_msg`, `employee_id`, `authToken`, `is_customer_temp_reason_exist`, `operation_name`

### 6.7 validateBoxInfoRest
- **Server Method:** `validateBoxInfoRest_post()` (Line 6203)
- **Endpoint:** `POST /LcoRestServices/validateBoxInfoRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `boxNumber` | String | Scanned STB serial |
- **Response Fields:** `status_code`, `status_msg`, `resellerId`

### 6.8 stbPairRest
- **Server Method:** `stbPairRest_post()` (Line 3961)
- **Endpoint:** `POST /LcoRestServices/stbPairRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `serialNumber` | String | STB serial |
  | `vcNumber` | String | VC/smart card number |
- **Response Fields:** `status_code`, `status_msg`

### 6.9 stbUnpairRest
- **Server Method:** `stbUnpairRest_post()` (Line 4081)
- **Endpoint:** `POST /LcoRestServices/stbUnpairRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `serialNumber` | String | STB serial |
- **Response Fields:** `status_code`, `status_msg`

### 6.10 stb_replacement
- **Server Method:** `stb_replacement_post()` (Line 8604)
- **Endpoint:** `POST /LcoRestServices/stb_replacement`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `serial_number` | String | Old STB serial |
  | `account_nmber` | String | Account number |
  | `replacement_type_id` | int | Replacement type |
  | `amount` | double | Amount |
  | `receipt_number` | String | Receipt number |
  | `remarks` | String | Remarks |
  | `replace_serial_number` | String | New STB serial |
  | `replace_vc_number` | String | New VC number |
  | `is_permanent_surrender` | boolean | Permanent surrender flag |
  | `pair_condition` | String | Pair condition |
- **Response Fields:** `status_code`, `status_msg`, `response_details`

---

## 7. PACKAGE / SERVICE OPERATIONS

### 7.1 getCustomerPackages_splitRest
- **Server Method:** `getCustomerPackages_splitRest_post()` (Line 2036)
- **Endpoint:** `POST /LcoRestServices/getCustomerPackages_splitRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `customerId` | int | Customer ID |
  | `boxNumber` | String | STB serial |
- **Response Fields:** `status_code`, `status_msg`, `packageList_broadcaster`

### 7.2 getUnassignedPackages_splitRest
- **Server Method:** `getUnassignedPackages_splitRest_post()` (Line 2208)
- **Endpoint:** `POST /LcoRestServices/getUnassignedPackages_splitRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `customerId` | int | Customer ID |
  | `boxNumber` | String | STB serial |
- **Response Fields:** `status_code`, `status_msg`, `deactivate_customerservices`, `channel_details`

### 7.3 activateServiceRest
- **Server Method:** `activateServiceRest_post()` (Line 4801)
- **Endpoint:** `POST /LcoRestServices/activateServiceRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `customerId` | int | Customer ID |
  | `productId` | int | Product/package ID |
  | `customerDeviceId` | int | Customer device ID |
  | `dateType` | String | Date type |
  | `pricingStructureType` | String | Pricing type |
  | `validityDays` | int | Validity in days |
- **Response Fields:** `status_code`, `status_msg`

### 7.4 deactivateServiceRest
- **Server Method:** `deactivateServiceRest_post()` (Line 4653)
- **Endpoint:** `POST /LcoRestServices/deactivateServiceRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `digi_config_value` | String | Digi config |
  | `bill_dealer_id` | int | Billing dealer ID |
  | `customerId` | int | Customer ID |
  | `serviceId` | int | Service ID |
  | `reasonId` | int | Deactivation reason |
  | `remarks` | String | Remarks |
  | `check_validation` | boolean | Validate flag |
  | `fromCustomerPortal` | boolean | From portal flag |
  | `deactservice_customer_portal` | boolean | Portal deactivation flag |
  | `fromMobileApp` | boolean | From mobile app flag |
- **Response Fields:** `status_code`, `status_msg`, `statusMessage`

### 7.5 extendCustomerServices
- **Server Method:** `extendCustomerServices_post()` (Line 3172)
- **Endpoint:** `POST /LcoRestServices/extendCustomerServices`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `customer_id` | int | Customer ID |
  | `product_id` | int | Product/package ID |
  | `stock_id` | int | Stock/device ID |
  | `quantity` | int | Quantity |
  | `fromMobileApp` | boolean | From mobile app flag |
- **Response Fields:** `status_code`, `status_msg`, `employee_parent_id`, `dealer_setting`, `int_operation_id`, `validation_operation_names`, `is_service_extension`, `arr_act_package_details`, `arr_box_details`, `arr_customer_details`, `plugin_id`, `extra_parameters`

### 7.6 getCasPackagesRest
- **Server Method:** `getCasPackagesRest_post()` (Line 6119)
- **Endpoint:** `POST /LcoRestServices/getCasPackagesRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `boxNumber` | String | STB serial |
- **Response Fields:** `status_code`, `status_msg`, `caspackageList`

### 7.7 channel_listRest
- **Server Method:** `channel_listRest_post()` (Line 2454)
- **Endpoint:** `POST /LcoRestServices/channel_listRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `dealer_id` | int | Dealer ID |
  | `product_id` | int | Product/package ID |
- **Response Fields:** `status_code`, `status_msg`, `channel_details`

### 7.8 renewServicesList
- **Server Method:** `renewServicesList_post()` (Line 3392)
- **Endpoint:** `POST /LcoRestServices/renewServicesList`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `customer_id` | int | Customer ID |
  | `customer_service_id` | int | Service ID |
  | `product_ids` | String | Product IDs |
- **Response Fields:** `status_msg`

### 7.9 getRenewServicesList
- **Server Method:** `getRenewServicesList_post()` (Line 3533)
- **Endpoint:** `POST /LcoRestServices/getRenewServicesList`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `customer_id` | int | Customer ID |
- **Response Fields:** `status_code`, `status_msg`, `getRenewServices`

### 7.10 customerAgingServices
- **Server Method:** `customerAgingServices_post()` (Line 8490)
- **Endpoint:** `POST /LcoRestServices/customerAgingServices`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `start_date` | String | Start date |
  | `end_date` | String | End date |
  | `serial_number_search` | String | Serial filter |
  | `vc_number_search` | String | VC filter |
  | `baid_search` | String | BAID filter |

---

## 8. REPORTS

### 8.1 DailyreportRest
- **Server Method:** `DailyreportRest_post()` (Line 6339)
- **Endpoint:** `POST /LcoRestServices/DailyreportRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `dealer_id` | int | Dealer ID |
  | `date` | String | Report date |
- **Response Fields:** `status_code`, `status_msg`, `Dailyreport_details`

### 8.2 empCollectionRest
- **Server Method:** `empCollectionRest_post()` (Line 6402)
- **Endpoint:** `POST /LcoRestServices/empCollectionRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `dealer_id` | int | Dealer ID |
  | `fromDate` | String | Start date |
  | `toDate` | String | End date |
- **Response Fields:** `status_code`, `status_msg`

### 8.3 empCustomerCollectionDetailsRest
- **Server Method:** `empCustomerCollectionDetailsRest_post()` (Line 2752)
- **Endpoint:** `POST /LcoRestServices/empCustomerCollectionDetailsRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `dealer_id` | int | Dealer ID |
  | `fromDate` | String | Start date |
  | `toDate` | String | End date |
- **Response Fields:** `status_code`, `status_msg`

### 8.4 InvoiceServiceRest
- **Server Method:** `InvoiceServiceRest_post()` (Line 6856)
- **Endpoint:** `POST /LcoRestServices/InvoiceServiceRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `dealer_id` | int | Dealer ID |
  | `customer_id` | int | Customer ID |
- **Response Fields:** `status_code`, `status_msg`, `invoice_details`

### 8.5 empCollectionReportDownload
- **Server Method:** `empCollectionReportDownload_post()` (Line 8574)
- **Endpoint:** `POST /LcoRestServices/empCollectionReportDownload`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `fromDate` | String | Start date |
  | `toDate` | String | End date |
- **Response:** Binary file download (CSV/Excel)

### 8.6 pgTransactionReportDownload
- **Server Method:** `pgTransactionReportDownload_get()` (Line 8545)
- **Endpoint:** `GET /LcoRestServices/pgTransactionReportDownload`
- **Payload:** None
- **Response:** Binary file / `status_msg` on error

### 8.7 customer_deduction_logs
- **Server Method:** `customer_deduction_logs_post()` (Line 8696)
- **Endpoint:** `POST /LcoRestServices/customer_deduction_logs`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `dateRange` | String | Date range |
  | `customerId` | int | Customer ID |
- **Response Fields:** `status_code`, `success`, `deduction_logs`

---

## 9. EMPLOYEE MANAGEMENT

### 9.1 getLcoEmployeeList
- **Server Method:** `getLcoEmployeeList_post()` (Line 3803)
- **Endpoint:** `POST /LcoRestServices/getLcoEmployeeList`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `employee_id` | int | Employee/reseller ID |
- **Response Fields:** `status_code`, `status_msg`

### 9.2 getServiceEmployeeList
- **Server Method:** `getServiceEmployeeList_post()` (Line 8117)
- **Endpoint:** `POST /LcoRestServices/getServiceEmployeeList`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `dealer_id` | int | Dealer ID |
- **Response Fields:** `status_code`, `status_msg`, `getServiceEmployeeList`

---

## 10. MASTER DATA

### 10.1 getCountriesRest
- **Server Method:** `getCountriesRest_post()` (Line 6805)
- **Endpoint:** `POST /LcoRestServices/getCountriesRest`
- **Payload:** None
- **Response Fields:** `countriesList`

### 10.2 getStatesRest
- **Server Method:** `getStatesRest_post()` (Line 6735)
- **Endpoint:** `POST /LcoRestServices/getStatesRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `countryCode` | int | Country code |
- **Response Fields:** `status_code`, `status_msg`, `statesList`

### 10.3 getdistrictsRest
- **Server Method:** `getdistrictsRest_post()` (Line 6668)
- **Endpoint:** `POST /LcoRestServices/getdistrictsRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `stateId` | int | State ID |
- **Response Fields:** `status_code`, `status_msg`, `districtList`

### 10.4 getCitiesRest
- **Server Method:** `getCitiesRest_post()` (Line 6590)
- **Endpoint:** `POST /LcoRestServices/getCitiesRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `stateId` | int | State ID |
  | `boxNumber` | String | Box number filter |
- **Response Fields:** `status_code`, `status_msg`, `citiesList`

### 10.5 getmandalsRest
- **Server Method:** `getmandalsRest_post()` (Line 3099)
- **Endpoint:** `POST /LcoRestServices/getmandalsRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `districtId` | int | District ID |
- **Response Fields:** `status_code`, `status_msg`, `mandalList`

### 10.6 getLocationsOfDistrictRest
- **Server Method:** `getLocationsOfDistrictRest_post()` (Line 6052)
- **Endpoint:** `POST /LcoRestServices/getLocationsOfDistrictRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `districtId` | int | District ID |
- **Response Fields:** `status_code`, `status_msg`, `districtLocationsList`

### 10.7 getGroupsRest
- **Server Method:** `getGroupsRest_post()` (Line 2957)
- **Endpoint:** `POST /LcoRestServices/getGroupsRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `serialNumber` | String | Serial number filter |
- **Response Fields:** `status_code`, `status_msg`, `groupsList`

### 10.8 getCustomerTypesRest
- **Server Method:** `getCustomerTypesRest_post()` (Line 3026)
- **Endpoint:** `POST /LcoRestServices/getCustomerTypesRest`
- **Payload:** None
- **Response Fields:** `customerTypeList`

### 10.9 getcustomerTypeTypesRest
- **Server Method:** `getcustomerTypeTypesRest_post()` (Line 6470)
- **Endpoint:** `POST /LcoRestServices/getcustomerTypeTypesRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `resellerId` | int | Reseller ID |
  | `customerTypeId` | int | Customer type ID |
- **Response Fields:** `status_code`, `status_msg`, `customerTypeTypesInfoList`

### 10.10 getIdsRest
- **Server Method:** `getIdsRest_post()` (Line 6538)
- **Endpoint:** `POST /LcoRestServices/getIdsRest`
- **Payload:** None
- **Response Fields:** `idList`

### 10.11 dynamicformvalidationsRest
- **Server Method:** `dynamicformvalidationsRest_post()` (Line 6290)
- **Endpoint:** `POST /LcoRestServices/dynamicformvalidationsRest`
- **Payload Parameters:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `table_name` | String | Table name for validation rules |
- **Response Fields:** `status_code`, `status_msg`

---

## API Endpoint Summary

| # | Category | Count | Endpoints |
|---|----------|-------|-----------|
| 1 | Authentication | 2 | validateLogin, getaccesscontrollRest |
| 2 | Dashboard | 5 | dashBoardDetailsRest, lco_deposit_amountRest, getlcowalletRest, getdashboardlist, getExpiryServicesDateWiseCount |
| 3 | Customer | 6 | getCustomerDetailsCountRest, getCustomerDetailsRest, existingCustomerRest, saveCustomerRest, editCustomerRest, updateCustomerLocation |
| 4 | Payments | 8 | getPendingAmountRest, makePaymentsRest, getPaymentModesRest, getReceiptRanges, getbilldetailsRest, pgTransactionLogs, PaymentServiceRest, customer_transaction_reponseRest |
| 5 | Complaints | 9 | getComplaintList, gettotalcomplaintslist, getCustomerComplaintListRest, complaintCategoriesRest, getComplaintsubCategory, createComplaintRest, complaintTypesRest, closeComplaintRest, ComplaintHistoryRest |
| 6 | STB/Box | 10 | getCustomerBoxDetailsRest, getCustomerParticularBoxDetailsRest, deactivateBoxRest, reactivateBoxRest, getDeactiveReasonsRest, temporaryActivationRest, validateBoxInfoRest, stbPairRest, stbUnpairRest, stb_replacement |
| 7 | Packages | 10 | getCustomerPackages_splitRest, getUnassignedPackages_splitRest, activateServiceRest, deactivateServiceRest, extendCustomerServices, getCasPackagesRest, channel_listRest, renewServicesList, getRenewServicesList, customerAgingServices |
| 8 | Reports | 7 | DailyreportRest, empCollectionRest, empCustomerCollectionDetailsRest, InvoiceServiceRest, empCollectionReportDownload, pgTransactionReportDownload, customer_deduction_logs |
| 9 | Employees | 2 | getLcoEmployeeList, getServiceEmployeeList |
| 10 | Master Data | 11 | getCountriesRest, getStatesRest, getdistrictsRest, getCitiesRest, getmandalsRest, getLocationsOfDistrictRest, getGroupsRest, getCustomerTypesRest, getcustomerTypeTypesRest, getIdsRest, dynamicformvalidationsRest |
| | **TOTAL** | **70** | All REST - no SOAP needed |

---

## Implementation Notes for Flutter

1. **Payload Encryption:** The server uses `Encryption_lib->checkPayload()` to decrypt incoming payloads. The Flutter app must implement the same encryption scheme. Check the `Encryption_lib` PHP library for the algorithm used.

2. **JWT Authentication:** Token is sent via HTTP header (not body). The server uses `getJwtTokenData()` to extract and verify the JWT from the header.

3. **Employee/Dealer ID Auto-Injection:** The server extracts `employeeId` and `dealerId` from the JWT token automatically. Many endpoints don't need these in the payload - they're derived from the authenticated session.

4. **Error Handling:** The `error_res()` method returns `status_code: 0` with the error message. Check for HTTP status 401 for auth failures.

5. **Parallel Login:** If `ENABLE_PARALLEL_LOGIN` is enabled for the dealer, only one session per employee is allowed. Login from another device terminates the previous session.

6. **IP Restriction:** The server validates client IPs. The Flutter app's requests must originate from an allowed IP or network.

7. **Dio Configuration for Flutter:**
   ```dart
   final dio = Dio(BaseOptions(
     baseUrl: 'http://183.83.216.66:8882/v2_release/index.php/LcoRestServices',
     contentType: 'application/x-www-form-urlencoded',
   ));
   // Add JWT token header interceptor
   // Add payload encryption interceptor
   ```
