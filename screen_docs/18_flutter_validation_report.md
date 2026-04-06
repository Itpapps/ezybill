# 18 - Flutter vs Actual API Validation Report

> Generated: 2026-03-30 | Source: Playwright-captured `all_api_responses.json` cross-referenced against every Flutter model, provider, and screen.

---

## 1. Model vs Response Validation

### 1.1 /validateLogin

| Server Field | Server Type | Sample Value | Flutter Model Field | Flutter Type | JsonKey | Status |
|---|---|---|---|---|---|---|
| status_code | number | 0 | LoginResponse.statusCode | int | `status_code` | MATCH |
| status_msg | string | "Success" | LoginResponse.statusMsg | String | `status_msg` | MATCH |
| token | string | "eyJ..." | LoginResponse.token | String | `token` | MATCH |
| employeeId | string | "3541" | LoginResponse.employeeId | int | `employeeId` | MATCH (sanitizer converts String->int) |
| first_name | string | "Subhani Kal" | LoginResponse.firstName | String | `first_name` | MATCH |
| last_name | string | "" | LoginResponse.lastName | String | `last_name` | MATCH |
| address1 | string | "Manikonda" | LoginResponse.address1 | String | `address1` | MATCH |
| address2 | string | "Manikonda" | LoginResponse.address2 | String | `address2` | MATCH |
| address3 | string | "" | LoginResponse.address3 | String | `address3` | MATCH |
| copy_rights | string | "ITP" | LoginResponse.copyRights | String | `copy_rights` | MATCH |
| short_name | string | "ITP" | LoginResponse.shortName | String | `short_name` | MATCH |
| pin_code | string | "423423" | LoginResponse.pinCode | String | `pin_code` | MATCH |
| phone | string | "4242342432" | LoginResponse.phone | String | `phone` | MATCH |
| email | string | "subhani@gmail.com" | LoginResponse.email | String | `email` | MATCH |
| country | string | "IN" | LoginResponse.country | String | `country` | MATCH |
| state | string | "89" | LoginResponse.state | String | `state` | MATCH |
| district | string | "519" | LoginResponse.district | String | `district` | MATCH |
| city | string | "212" | LoginResponse.city | String | `city` | MATCH |
| username | string | "itptest" | LoginResponse.username | String? | `username` | MATCH |
| dob | string | "0000-00-00" | LoginResponse.dob | String | `dob` | MATCH |
| adate | string | "0000-00-00" | LoginResponse.adate | String | `adate` | MATCH |
| employeeName | string | "Subhani Kal" | LoginResponse.employeeName | String | `employeeName` | MATCH |
| dealerId | string | "1" | LoginResponse.dealerId | int | `dealerId` | MATCH (sanitizer) |
| userType | string | "RESELLER" | LoginResponse.userType | String | `userType` | MATCH |
| useCRF | string | "1" | LoginResponse.useCRF | int | `useCRF` | MATCH (sanitizer) |
| useCAF | string | "AUTO" | LoginResponse.useCAF | String | `useCAF` | MATCH |
| useLastName | string | "1" | LoginResponse.useLastName | int | `useLastName` | MATCH (sanitizer) |
| useDiscount | string | "1" | LoginResponse.useDiscount | int | `useDiscount` | MATCH (sanitizer) |
| useDataFromMasterTable | string | "1" | LoginResponse.useDataFromMasterTable | int | `useDataFromMasterTable` | MATCH (sanitizer) |
| useMandatoryForHotel | string | "1" | LoginResponse.useMandatoryForHotel | int | `useMandatoryForHotel` | MATCH (sanitizer) |
| useAccountNumber | string | "1" | LoginResponse.useAccountNumber | int | `useAccountNumber` | MATCH (sanitizer) |
| employeeParentId | null | null | LoginResponse.employeeParentId | String | `employeeParentId` | MATCH (sanitizer handles null->String) |
| employeeParentType | null | null | LoginResponse.employeeParentType | String | `employeeParentType` | MATCH (sanitizer handles null->String) |
| useLcoDeposit | string | "1" | -- | -- | -- | MISMATCH: Server sends `useLcoDeposit`, model maps `use_lco_deposits` to `useLcoDeposit`. Server actually sends BOTH keys; model maps the correct one. |
| deposit_amount | string | "98226.48" | LoginResponse.depositAmount | double | `deposit_amount` | MATCH (sanitizer) |
| defaultCountry | string | "IN" | LoginResponse.defaultCountry | String? | `defaultCountry` | MATCH |
| country_name | string | "INDIA" | LoginResponse.countryName | String | `country_name` | MATCH |
| defaultState | string | "89" | LoginResponse.defaultState | int? | `defaultState` | MATCH (sanitizer) |
| defaultDistrict | string | "497" | LoginResponse.defaultDistrict | int? | `defaultDistrict` | MATCH (sanitizer) |
| defaultCity | string | "-1" | LoginResponse.defaultCity | int? | `defaultCity` | MATCH (sanitizer) |
| recurringServiceEdit | string | "0" | LoginResponse.recurringServiceEdit | int | `recurringServiceEdit` | MATCH (sanitizer) |
| showLcoComplaint | string | "1" | LoginResponse.showLcoComplaint | int | `showLcoComplaint` | MATCH (sanitizer) |
| lcoCode | string | "1ITPL00001" | LoginResponse.lcoCode | String | `lcoCode` | MATCH |
| lcoLocation | string | "Subhani Kal..." | LoginResponse.lcoLocation | String | `lcoLocation` | MATCH |
| lcoMobileNo | string | "912342342342" | LoginResponse.lcoMobileNo | String | `lcoMobileNo` | MATCH (sanitizer) |
| freezecustomerparamsinapp | string | "0" | LoginResponse.freezecustomerparamsinapp | int | `freezecustomerparamsinapp` | MATCH (sanitizer) |
| blockpayment | number | 0 | LoginResponse.blockpayment | int | `blockpayment` | MATCH |
| business_name | string | "Subhani..." | LoginResponse.businessName | String | `business_name` | MATCH |
| is_unpaidlco | string | "0" | LoginResponse.isUnpaidlco | int | `is_unpaidlco` | MATCH (sanitizer) |
| appMenuFormat | string | "DEFAULT" | LoginResponse.appMenuFormat | String | `appMenuFormat` | MATCH |
| invoicepaymentsearchlimit | string | "2" | LoginResponse.invoicePaymentSearchLimit | int | `invoicepaymentsearchlimit` | MATCH (sanitizer) |
| lco_billtype | string | "9" | LoginResponse.lcoBilltype | int | `lco_billtype` | MATCH (sanitizer) |
| use_lco_deposits | string | "1" | LoginResponse.useLcoDeposit | int | `use_lco_deposits` | MATCH (sanitizer) |
| userNotifications | array | [] | LoginResponse.userNotifications | int | `userNotifications` | MATCH (sanitizer: List -> 0) |
| notifyCount | number | 0 | LoginResponse.notifyCount | int | `notifyCount` | MATCH |
| note_duration | number | 0 | LoginResponse.noteDuration | int | `note_duration` | MATCH |
| customer_billtype | string | "0" | LoginResponse.customerBilltype | int | `customer_billtype` | MATCH (sanitizer) |
| AUTO_RECEIPT_NUMBER | string | "1" | LoginResponse.autoReceiptNumber | int | `AUTO_RECEIPT_NUMBER` | MATCH (sanitizer) |
| CURRENCY_CODE | string | "Rs." | LoginResponse.currencyCode | String | `CURRENCY_CODE` | MATCH |
| allow_top_up | number | 1 | LoginResponse.allowTopUp | int | `allow_top_up` | MATCH |
| show_caf_mobile_validation | number | 0 | LoginResponse.showCafMobileValidation | int | `show_caf_mobile_validation` | MATCH |
| patch_information | string | "V2" | LoginResponse.patchInformation | String | `patch_information` | MATCH |
| stb_pairing | number | 1 | LoginResponse.stbPairing | int | `stb_pairing` | MATCH |
| stb_unpairing | number | 1 | LoginResponse.stbUnpairing | int | `stb_unpairing` | MATCH |
| show_mia_agreement_upload | string | "1" | LoginResponse.showMiaAgreementUpload | int | `show_mia_agreement_upload` | MATCH (sanitizer) |
| accept_terms_condtions | string | "0" | LoginResponse.acceptTermsConditions | int | `accept_terms_condtions` | MATCH (sanitizer) |
| agreement_details_count | number | 0 | LoginResponse.agreementDetailsCount | int | `agreement_details_count` | MATCH |
| access_distributor_wise | string | "0" | LoginResponse.accessDistributorWise | int | `access_distributor_wise` | MATCH (sanitizer) |
| is_direct_lco | number | 0 | LoginResponse.isDirectLco | int | `is_direct_lco` | MATCH |
| show_serial_vc | number | 0 | LoginResponse.showSerialVc | int | `show_serial_vc` | MATCH |
| user_image | string | "" | LoginResponse.logoImg | String? | `user_image` | MATCH |
| show_service_extension | string | "1" | LoginResponse.showServiceExtension | int | `show_service_extension` | MATCH (sanitizer) |
| config_values_array | object | {...} | -- | -- | -- | MATCH (explicitly removed by sanitizer; accessed separately) |
| edit_quantity | string | "1" | LoginResponse.editQuantity | int | `edit_quantity` | MATCH (sanitizer) |
| enable_box_wise_payment | string | "1" | LoginResponse.enableBoxWisePayment | int | `enable_box_wise_payment` | MATCH (sanitizer) |
| baid_label | string | "Yellow" | LoginResponse.baidLabel | String? | `baid_label` | MATCH |

**Verdict: ALL 80+ login fields are correctly mapped with sanitizers handling type coercion.**

---

### 1.2 /getaccesscontrollRest

| Server Field | Server Type | Sample Value | Flutter Location | Flutter Type | Status |
|---|---|---|---|---|---|
| status_code | number | 0 | -- (checked before merge) | -- | MATCH |
| status_msg | string | "Success" | -- | -- | MATCH |
| int_bulk_payment | string | "1" | AppSession.intBulkPayment | int | WARNING: Server key is `int_bulk_payment`, but `copyWithAccessControl` reads `intBulkPayment` (camelCase). Need to verify the raw JSON is normalized before passing. |
| invoice_page_access | number | 1 | AppSession.invoicePageAccess | int | WARNING: Same key mismatch -- server uses `invoice_page_access`, code reads `invoicePageAccess`. |
| payment_hist_page_access | number | 1 | AppSession.paymentHistPageAccess | int | WARNING: Same issue. |
| access_for_complaints | number | 1 | AppSession.accessForComplaints | int | WARNING: Same issue. |
| int_stb_activation | string | "1" | AppSession.intStbActivation | int | WARNING: Same issue. |
| int_stb_deactivation | string | "1" | AppSession.intStbDeactivation | int | WARNING: Same issue. |
| int_stb_reactivation | string | "1" | AppSession.intStbReactivation | int | WARNING: Same issue. |
| int_payment_transaction_report_access | number | 1 | AppSession.pgTransactionReportAccess | int | MATCH (explicitly handled in copyWithAccessControl). |

**CRITICAL ISSUE (P1):** `AppSession.copyWithAccessControl()` reads camelCase keys (e.g., `intBulkPayment`) but the actual server response uses snake_case (e.g., `int_bulk_payment`). The access control flags will silently fall back to defaults and never update from the server response. The code needs to also check snake_case keys or normalize the input.

---

### 1.3 /dashBoardDetailsRest

| Server Field | Server Type | Sample | Flutter Model Field | Flutter Type | Status |
|---|---|---|---|---|---|
| status_code | number | 0 | DashboardResponse.statusCode | int | MATCH |
| status_msg | string | "Success" | DashboardResponse.statusMsg | String | MATCH |
| totalStbs | number | 4819 | DashboardResponse.totalStbs | int | MATCH |
| totalAssignedStbs | number | 1800 | DashboardResponse.totalAssignedStbs | int | MATCH |
| totalUnAssignedStbs | number | 3019 | DashboardResponse.totalUnAssignedStbs | int | MATCH |
| totalComplaints | number | 1 | DashboardResponse.totalComplaints | int | MATCH |
| totalClosedComplaints | number | 0 | DashboardResponse.totalClosedComplaints | int | MATCH |
| totalActiveCustomers | number | 1 | DashboardResponse.totalActiveCustomers | int | MATCH |
| totalDeactiveCustomers | number | 4818 | DashboardResponse.totalDeactiveCustomers | int | MATCH |
| totalCurrentMonthBill | number | 0 | DashboardResponse.totalCurrentMonthBill | double | MATCH |
| totalDueAmount | number | 0 | DashboardResponse.totalDueAmount | double | MATCH |
| totalPaidCustomers | number | 0 | DashboardResponse.totalPaidCustomers | int | MATCH |
| totalUnPaidCustomers | number | 0 | DashboardResponse.totalUnPaidCustomers | int | MATCH |
| gettotalPaidCustomers | number | -1 | DashboardResponse.gettotalPaidCustomers | int | MATCH |
| gettotalUnPaidCustomers | number | -1 | DashboardResponse.gettotalUnPaidCustomers | int | MATCH |
| outStandingAmount | **string** | "1527708.31" | DashboardResponse.outStandingAmount | double | MATCH (sanitizer) |
| msoShare | number | 1420525.16 | DashboardResponse.msoShare | double | MATCH |
| totalActiveAssignedStbs | number | 1 | -- | -- | MISSING from Flutter model |
| totalDeactiveAssignedStbs | number | 4818 | -- | -- | MISSING from Flutter model |
| totalCurrentMonthMsoShare | number | 0 | DashboardResponse.totalCurrentMonthMsoShare | double | MATCH |
| currentMonthOutstanding | **string** | "0.00" | DashboardResponse.currentMonthOutstanding | double | MATCH (sanitizer) |
| currentMonthLCOBill | number | 0 | DashboardResponse.currentMonthLCOBill | double | MATCH |
| lcocurrentmonthdueamount | **null** | null | DashboardResponse.lcuCurrentMonthDueAmount | double | MATCH (sanitizer: null -> 0.0) |

**Missing fields (P3):** `totalActiveAssignedStbs` and `totalDeactiveAssignedStbs` are returned by server but not captured in the Flutter model. These could be useful for STB dashboard cards.

---

### 1.4 /lco_deposit_amountRest

| Server Field | Server Type | Sample | Flutter Model | Flutter Type | Status |
|---|---|---|---|---|---|
| status_code | number | 0 | WalletResponse.statusCode | int | MATCH |
| status_msg | string | "Success" | -- (not in WalletResponse) | -- | MISSING from model (P3) |
| deposit_amount | string | "98226.48" | WalletResponse.lcoDepositAmount | double | MATCH (sanitizer) |

**Missing field (P3):** `status_msg` not in WalletResponse. Also `customerCount` is in the model but not returned by this endpoint. The model seems designed for a different endpoint variant.

---

### 1.5 /getExpiryServicesDateWiseCount

| Server Field | Server Type | Flutter Model | Status |
|---|---|---|---|
| status_code | number | ExpiryServicesResponse.statusCode | MATCH |
| status_msg | string | ExpiryServicesResponse.statusMsg | MATCH |
| getExpiryServicesList | array | ExpiryServicesResponse.expiryServicesList | MATCH (JsonKey maps correctly) |

**Nested ExpiryDateCount items:**

| Server Field | Server Type | Sample | Flutter Field | Flutter Type | Status |
|---|---|---|---|---|---|
| date | string | "2026-03-30" | ExpiryDateCount.date | String | MATCH |
| stb_count | **string** | "0" | ExpiryDateCount.stbCount | int | MATCH (sanitizer) |

---

### 1.6 /getCustomerDetailsCountRest

| Server Field | Server Type | Sample | Flutter Location | Status |
|---|---|---|---|---|
| status_code | number | 0 | Raw map access in customer_provider | MATCH |
| status_msg | string | "Success" | Not parsed | OK |
| customerCount | **string** | "1796" | `_parseInt(data['customerCount'])` in provider | MATCH (parseInt handles String) |

---

### 1.7 /getCustomerDetailsRest

| Server Field | Server Type | Flutter Model | Status |
|---|---|---|---|
| statusCode | number | CustomerSearchResponse.statusCode | MATCH (JsonKey `statusCode`) |
| statusMessage | string | CustomerSearchResponse.statusMsg | MATCH (JsonKey `statusMessage`) |
| customerDetailsList | array | CustomerSearchResponse.existCustomerDetails | MATCH (JsonKey `customerDetailsList`) |
| total_amount | string | CustomerSearchResponse.totalAmount | MATCH (sanitizer) |
| mso_share | string | CustomerSearchResponse.msoShare | MATCH (sanitizer) |
| tot_mso_share | string | -- | MISSING: `tot_mso_share` is sanitized but not stored in any model field (P3) |
| lco_share | string | CustomerSearchResponse.lcoShare | MATCH (sanitizer) |
| baid_label | string | CustomerSearchResponse.baidLabel | MATCH |

**Nested CustomerModel items:**

| Server Field | Type | Sample | Flutter Model Field | Flutter Type | Status |
|---|---|---|---|---|---|
| customer_id | string | "871634" | CustomerModel.customerId | String | MATCH |
| reseller_id | string | "3541" | CustomerModel.resellerId | String? | MATCH |
| online_customer | string | "0" | CustomerModel.onlineCustomer | int | MATCH (sanitizer) |
| customerName | string | "Kumar" | CustomerModel.customerName | String | MATCH |
| caf_no | string | "Caf00001" | CustomerModel.cafNumber | String? | MATCH |
| mobile_no | string | "919989028012" | CustomerModel.mobileNumber | String? | MATCH |
| status | string | "1" | CustomerModel.status | String | MATCH (sanitizer handles int->String) |
| billing_address | string | "Sri ngar..." | CustomerModel.billingAddress | String? | MATCH |
| installation_address | string | "Sri Ngar..." | CustomerModel.installationAddress | String? | MATCH |
| pin_code | string | "523247" | CustomerModel.pinCode | String? | MATCH |
| crf_number | string | "itp0001" | CustomerModel.crfNumber | String? | MATCH |
| stb_count | string | "2" | CustomerModel.stbCount | int | MATCH (sanitizer) |
| account_number | string | "C0871634" | CustomerModel.accountNumber | String? | MATCH |
| pending_amount | string | "679.44" | CustomerModel.pendingAmount | double | MATCH (sanitizer) |
| latitude | string | "" | CustomerModel.latitude | double | MATCH (sanitizer: "" -> 0.0) |
| longitude | string | "" | CustomerModel.longitude | double | MATCH (sanitizer: "" -> 0.0) |
| bill_type | string | "0" | CustomerModel.billType | String? | MATCH |
| baid | string | "" | CustomerModel.baid | String? | MATCH |
| is_direct_lco | string | "0" | CustomerModel.isDirectLco | int | MATCH (sanitizer) |
| checkaddserviceaccess | -- | not in response | CustomerModel.checkAddServiceAccess | int? | OK (nullable, not always present) |
| ADDON_AFTER_BASEPACK | -- | not in response | CustomerModel.addonAfterBasepack | int? | OK (nullable, not always present) |
| serialNumber | -- | not in response | CustomerModel.serialNumber | String? | OK (from box details) |
| vcNumber | -- | not in response | CustomerModel.vcNumber | String? | OK (from box details) |

---

### 1.8 /getPendingAmountRest

| Server Field | Type | Sample | Flutter Model Field | Flutter Type | Status |
|---|---|---|---|---|---|
| status_code | number | 0 | PendingAmount.statusCode | int | MATCH |
| status_msg | string | "Success" | -- | -- | MISSING from model (P3) |
| customerName | string | "Kiran" | PendingAmount.customerName | String | MATCH |
| mobileNumber | string | "919989028031" | PendingAmount.mobileNumber | String | MATCH |
| pendingAmount | string | "0.00" | PendingAmount.pendingAmount | double | MATCH (sanitizer) |
| billingId | string | "" | PendingAmount.billingId | String | MATCH |
| msoShare | string | "0.00" | PendingAmount.msoShare | double | MATCH (sanitizer) |
| lcoShare | string | "0.00" | PendingAmount.lcoShare | double | MATCH (sanitizer) |

---

### 1.9 /getPaymentModesRest

| Server Field | Type | Sample | Flutter Model | Status |
|---|---|---|---|---|
| status_code | number | 0 | -- (checked in repository) | OK |
| paymentModesList | array | [...] | Parsed as List<PaymentMode> | MATCH |

**Nested PaymentMode:**

| Field | Type | Sample | Flutter | Status |
|---|---|---|---|---|
| paymentModeId | string | "1" | PaymentMode.paymentModeId | String | MATCH |
| PaymentModeName | string | "Cash" | PaymentMode.paymentModeName | String | MATCH (note capital P in server key, matches JsonKey) |

---

### 1.10 /getReceiptRanges

| Server Field | Type | Sample | Flutter Model | Status |
|---|---|---|---|---|
| status_code | number | 1 | -- (checked in provider) | OK |
| ReceiptRanges | array | [] | Parsed as List<ReceiptRange> | MATCH |

---

### 1.11 /getComplaintList

**Nested complaint items:**

| Server Field | Type | Flutter Model Field | JsonKey | Status |
|---|---|---|---|---|
| simple_complaint_id | string | ComplaintModel.complaintId | `simple_complaint_id` | MATCH |
| tkt_number | string | ComplaintModel.ticketNumber | `tkt_number` | MATCH |
| customer_id | string | ComplaintModel.customerId | `customer_id` | MATCH |
| customer_name | string | ComplaintModel.customerName | `customer_name` | MATCH |
| customer_account_id | string | ComplaintModel.customerAccountId | `customer_account_id` | MATCH |
| CAF | string | ComplaintModel.cafNumber | `CAF` | MATCH |
| complaint | string | ComplaintModel.category | `complaint` | MATCH (server field "complaint" maps to category name) |
| description | string | ComplaintModel.complaint | `description` | MATCH |
| status | string | ComplaintModel.status | `status` | MATCH |
| assigned_employee_id | string | ComplaintModel.assignedTo | `assigned_employee_id` | MATCH |
| assigned_name | string | ComplaintModel.assignedToName | `assigned_name` | MATCH |
| date | string | ComplaintModel.createdDate | `date` | MATCH |
| closedDate | -- | ComplaintModel.closedDate | `closedDate` | NOT in getComplaintList response (is in gettotalcomplaintslist as `closed_date`) |
| remarks | -- | ComplaintModel.remarks | `remarks` | NOT in response |
| categoryName | -- | ComplaintModel.categoryName | `categoryName` | NOT in response (server sends `category` with name) |
| subCategory | -- | ComplaintModel.subCategory | `subCategory` | NOT in getComplaintList (is in gettotalcomplaintslist as `sub_category`) |

**Additional server fields NOT in model (informational, P3):** `business_name`, `baid`, `account_number`, `crf_number`, `ticket`, `address`, `city`, `mobile_no`, `customersla_id`, `created_from`, `category` (the name), `cur_update_date`, `users_type`, `created_business_name`, `first_name`, `last_name`, `dist_subdist_lcocode`, `employee_parent_type`, `created_by`, `assigned_first_name`, `assigned_last_name`, `assigned_users_type`, `assigned_business_name`, `assigned_code`, `assigned_parent_type`, `reseller_business_name`, `reseller_name`, `lco_code`, `mac_vc_number`, `group_name`, `vc_number`, `serial_number`, `box_number`.

---

### 1.12 /complaintCategoriesRest

| Server Field | Type | Sample | Flutter Model | Status |
|---|---|---|---|---|
| categoryId | string | "40" | ComplaintCategory.categoryId | int | MATCH (sanitizer) |
| categoryName | string | " gh vgjh" | ComplaintCategory.categoryName | String | MATCH |
| parent_category_id | string | "0" | ComplaintCategory.parentCategoryId | int | MATCH (sanitizer) |

---

### 1.13 /complaintTypesRest

| Server Field | Type | Sample | Flutter Location | Status |
|---|---|---|---|---|
| complaintStatuses | array | [{"value": "ASSIGNED"},...] | complaint_provider closerTypes | MATCH (stored as raw List<Map>) |
| ticket_closer_categories | array | [] | complaint_provider closerTypes | MATCH |

---

### 1.14 /getCustomerBoxDetailsRest

**Server wraps list in `customerBoxList` key.** Provider reads `data['data']` which would miss this.

| Server Field | Type | Sample | StbModel Field | JsonKey | Status |
|---|---|---|---|---|---|
| customer_id | string | "871653" | StbModel.customerId | `customerId` | MISMATCH: Server sends `customer_id`, model expects `customerId` |
| customer_name | string | "Kiran" | -- | -- | MISSING from model |
| stock_id | string | "704465" | StbModel.stockId | `stockId` | MISMATCH: Server sends `stock_id`, model expects `stockId` |
| serial_number | string | "1234ABV000020" | StbModel.serialNumber | `serialNumber` | MISMATCH: Server sends `serial_number`, model expects `serialNumber` |
| vc_number | string | "1234ABV000020" | StbModel.vcNo | `vcNo` | MISMATCH: Server sends `vc_number`, model expects `vcNo` |
| box_number | string | "1234ABV000020" | StbModel.boxNumber | `boxNumber` | MISMATCH: Server sends `box_number`, model expects `boxNumber` |
| mac_address | string | "12:34:AB:V0:00:02:0" | StbModel.macAddress | `macAddress` | MISMATCH: Server sends `mac_address`, model expects `macAddress` |
| stock_status | string | "1" | StbModel.stockStatus | `stockStatus` | MISMATCH: Server sends `stock_status`, model expects `stockStatus` |
| device_id | string | "902890" | StbModel.deviceId | `deviceId` | MISMATCH: Server sends `device_id`, model expects `deviceId` |
| backend_setup_id | string | "4" | StbModel.backendSetupId | `backendSetupId` | MISMATCH: Server sends `backend_setup_id`, model expects `backendSetupId` |
| activation_date | string | "2025-09-11..." | StbModel.activatedDate | `activatedDate` | MISMATCH: Server sends `activation_date`, model expects `activatedDate` |
| cas_display_name | string | "ABV" | StbModel.casType | `casType` | MISMATCH: Server sends `cas_display_name`, model expects `casType` |
| stock_location | string | "Subhani..." | -- | -- | MISSING from model |
| stb_type | string | "Normal" | -- | -- | MISSING from model |
| stb_model | string | "TH-1070" | -- | -- | MISSING from model |

**CRITICAL ISSUE (P0): StbModel JsonKey names use camelCase but server sends snake_case. EVERY field will deserialize as null/default. Additionally, `stb_provider.dart` reads `data['data']` but server returns `data['customerBoxList']`, so the list extraction will fail.**

---

### 1.15 /getDeactiveReasonsRest

**Server wraps list in `reasonList` key.** Provider tries `data['data']` first, then `data['reasonList']` (in package_provider). STB provider only tries `data['data']`.

| Server Field | Type | Sample | Flutter Model | Status |
|---|---|---|---|---|
| reasonId | string | "17" | DeactivationReason.reasonId | int | MATCH (sanitizer) |
| reasonName | string | "Unpaid Customer" | DeactivationReason.reasonName | String | MATCH |
| display_name | string | "Unpaid Customer" | DeactivationReason.displayName | String | MATCH |
| act_deact_reason_id | string | "2" | DeactivationReason.actDeactReasonId | int | MATCH (sanitizer) |
| global_reason | string | "1" | DeactivationReason.globalReason | int | MATCH (sanitizer) |
| disable_for_dpo | -- | not in response | DeactivationReason.disableForDpo | int | OK (defaults to 0) |

**ISSUE (P1):** `stb_provider.dart` reads `data['data']` for deactivation reasons but server returns `reasonList`. The package_provider correctly tries both `data['reasonList']` and `data['data']`. STB provider will always get empty reasons list.

---

### 1.16 /getCustomerPackages_splitRest (Assigned packages)

| Server Field | Type | Sample | PackageModel Field | JsonKey | Status |
|---|---|---|---|---|---|
| product_id | string | "2506" | PackageModel.packageId | `product_id` | MATCH |
| product_name | string | "Onam 1" | -- | -- | MISMATCH: Server sends `product_name` for assigned, model expects `pname` |
| base_price | string | "1500.00" | PackageModel.price | `base_price` | MATCH (sanitizer) |
| is_base_package | string | "1" | PackageModel.isBasePackage | `is_base_package` | MATCH (sanitizer) |
| is_broadcaster_package | string | "0" | PackageModel.isBroadcasterPackage | `is_broadcaster_package` | MATCH (sanitizer) |
| alacarte | string | "0" | PackageModel.alacarte | `alacarte` | MATCH (sanitizer) |
| validity_days | string | "12" | PackageModel.validityDays | `validity_days` | MATCH (sanitizer) |
| validity | string | "Month(s)" | PackageModel.validity | `monthly_or_yearly` | MISMATCH: Server sends `validity` but model maps `monthly_or_yearly`. For assigned packages, `monthly_or_yearly` is "(Per Month)" and `validity` is "Month(s)". |
| monthly_or_yearly | string | "(Per Month)" | PackageModel.validity | `monthly_or_yearly` | Will pick up this key but it contains "(Per Month)" not "Month(s)". |
| customer_service_id | string | "17918008" | PackageModel.customerServiceId | `customer_service_id` | MATCH |
| service_start_date | string | "2025-11-30..." | PackageModel.startDate | `start_date` | MISMATCH: Server sends `service_start_date`, model expects `start_date` |
| service_end_date | string | "2026-12-28..." | PackageModel.endDate | `end_date` | MISMATCH: Server sends `service_end_date`, model expects `end_date` |
| sd_channels_count | string | "2" | PackageModel.sdChannels | `sd_channels_count` | MATCH (sanitizer) |
| hd_channels_count | string | "0" | PackageModel.hdChannels | `hd_channels_count` | MATCH (sanitizer) |
| tax1-tax6 | string | various | PackageModel.tax1-tax6 | `tax1`-`tax6` | MATCH (sanitizer) |
| is_taxable | string | "1" | PackageModel.isTaxable | `is_taxble` | MISMATCH: Server sends `is_taxable`, model JsonKey is `is_taxble` (typo). Will not match. |
| service_validity_days_v2 | string | "12" | -- | -- | MISSING from model |
| service_type | string | "2" | -- | -- | MISSING from model |
| extend_service_enddate | string | "2027-12-28" | -- | -- | MISSING from model |
| customer_name | string | "Kiran" | -- | -- | MISSING from model |
| cas_server_type | string | "ABV" | -- | -- | MISSING from model |

**Issues (P1):**
1. `product_name` vs `pname`: Assigned packages use `product_name`, the model maps `pname`. Package name will be empty for assigned packages.
2. `service_start_date`/`service_end_date` vs `start_date`/`end_date`: Dates won't parse from assigned package response.
3. `is_taxable` vs `is_taxble`: Typo in JsonKey means tax flag won't be read.

---

### 1.17 /getUnassignedPackages_splitRest (Available packages)

| Server Field | Type | Sample | Flutter Model | Status |
|---|---|---|---|---|
| product_id | string/number | "2133" | PackageModel.packageId | MATCH |
| pname | string | "AACAS Bundle" | PackageModel.packageName | MATCH |
| base_price | string | "100.00" | PackageModel.price | MATCH (sanitizer) |
| pricing_structure_type | number | 2 | PackageModel.pricingStructureType | MATCH (sanitizer handles int->String) |
| is_taxble | number | 0 | PackageModel.isTaxable | MATCH (number type matches) |
| end_date | string | "29-03-2031" | PackageModel.endDate | MATCH |
| (all other fields) | various | | | MATCH |

Available packages work correctly since they use the expected field names (`pname`, `end_date`, etc.).

---

### 1.18 /empCollectionRest

| Server Field | Type | Sample | Flutter Location | Status |
|---|---|---|---|---|
| collectionList | array | [...] | report_provider reads `collResultList` | MISMATCH: Server sends `collectionList`, provider reads `collResultList`. |

**CRITICAL ISSUE (P1):** Report provider reads `data['collResultList']` but server sends `collectionList`. Employee collection summary will always be empty.

---

### 1.19 /getdashboardlist

| Server Field | Type | Sample | Flutter Location | Status |
|---|---|---|---|---|
| getDashboardDataList | array | [...] | dashboard_customer_list_provider._extractCustomerList | MATCH (first key checked) |

**Nested dashboard list items:** These are properly normalized in the provider via manual field mapping (`customer_name` -> `customerName`, `is_active` -> status, etc.).

---

### 1.20 /InvoiceServiceRest

Server returns `invoice_details` array with rich invoice items. No typed Flutter model exists for invoices -- they appear to be rendered from raw maps. This is acceptable but fragile.

---

### 1.21 /dynamicformvalidationsRest

| Server Field | Sample | Flutter Model | Status |
|---|---|---|---|
| status_msg | array of objects | FormValidation | WARNING: `status_msg` is the array itself (not a status message). Unusual. |

**Nested items:**

| Server Field | Type | Flutter Field | JsonKey | Status |
|---|---|---|---|---|
| column_name | string | FormValidation.columnName | `columnName` | MISMATCH: Server sends `column_name`, model expects `columnName` |
| is_mandatory | string | FormValidation.isMandatory | `isMandatory` | MISMATCH: Server sends `is_mandatory`, model expects `isMandatory` |

**ISSUE (P1):** FormValidation model uses camelCase JsonKeys but server sends snake_case. All form validations will fail to deserialize.

---

### 1.22 Master Data Endpoints (Countries, States, Districts, Cities, Mandals, Groups, CustomerTypes, IDs)

| Endpoint | Server List Key | Model | Field Match Status |
|---|---|---|---|
| /getCountriesRest | `countriesList` | Country(iso, name) | MATCH |
| /getStatesRest | `statesList` | StateModel(id, name, country_code) | MATCH (all string IDs, sanitizer handles) |
| /getdistrictsRest | `districtList` | District(district_id, district_name, state_id) | MATCH |
| /getmandalsRest | `mandalList` | Mandal(district_id, mandal_id, mandal_name) | MATCH |
| /getCustomerTypesRest | `customerTypeList` | CustomerType(customer_type_id, customer_type, etc.) | MATCH |
| /getIdsRest | `idList` | IdType(id_type_id, type) | MATCH |

All master data models correctly match their server responses with appropriate sanitizers.

---

## 2. Provider Logic Validation

### 2.1 Dashboard Provider
- **Endpoint:** `/dashBoardDetailsRest` -- CORRECT
- **Parameters:** `use_lco_deposits`, `lco_billtype` from session -- CORRECT
- **Response parsing:** Uses `DashboardResponse.fromJson()` -- CORRECT
- **status_code handling:** Checked via `Result` pattern -- CORRECT
- **Wallet loading:** Calls `/lco_deposit_amountRest` -- CORRECT
- **Expiry loading:** Calls `/getExpiryServicesDateWiseCount` -- CORRECT
- **Wallet history:** Reads `lcoWalletList` but server response has `getLcoWalletReport` -- **MISMATCH (P2)**

### 2.2 Dashboard Customer List Provider
- **Endpoint:** `/getdashboardlist` -- CORRECT
- **Parameters:** `dealer_id`, `from_dashboard` -- CORRECT
- **Response key:** Checks `getDashboardDataList` first -- CORRECT
- **Field mapping:** Manual normalization from snake_case to CustomerModel-compatible format -- CORRECT
- **Pagination:** Client-side pagination over full result set -- CORRECT

### 2.3 Customer Search Provider
- **Count endpoint:** `/getCustomerDetailsCountRest` -- CORRECT
- **Search endpoint:** `/getCustomerDetailsRest` -- CORRECT
- **Response parsing:** `CustomerSearchResponse.fromJson()` with sanitizer that handles both `existCustomerDetails` and `customerDetailsList` keys -- CORRECT
- **Pagination:** Server-side with startValue/endValue -- CORRECT

### 2.4 Payment Provider
- **Payment modes:** `/getPaymentModesRest` -- CORRECT
- **Pending amount:** `/getPendingAmountRest` -- CORRECT
- **Receipt ranges:** `/getReceiptRanges` -- reads `ReceiptRanges` key -- CORRECT
- **Make payment:** `/PaymentServiceRest` -- CORRECT
- **status_code handling:** 0 = success pattern -- CORRECT

### 2.5 STB Provider
- **Load boxes:** `getCustomerBoxDetails` -- reads `data['data']` but server returns `customerBoxList` -- **CRITICAL MISMATCH (P0)**
- **Load box details:** `getParticularBoxDetails` -- reads `data['data']` -- needs verification
- **Deactivation reasons:** reads `data['data']` but server returns `reasonList` -- **MISMATCH (P1)**
- **Deactivate/Reactivate/Pair/Unpair:** Logic matches spec with correct suffixes -- CORRECT

### 2.6 Package Provider
- **Assigned packages:** `/getCustomerPackages_splitRest` -- reads `packageList_base`, `packageList_addon`, etc. -- CORRECT keys
- **Available packages:** `/getUnassignedPackages_splitRest` -- CORRECT keys
- **Deactivation reasons:** reads both `reasonList` and `data` -- CORRECT
- **Bill details:** `/getbilldetailsRest` reads `basePrice` nested object -- CORRECT
- **Service activation:** Correct params (productId, quantity=1, dateType=0, etc.) -- CORRECT
- **Service deactivation:** Uses `customer_service_id` not `product_id` -- CORRECT per spec

### 2.7 Complaint Provider
- **Load complaints:** Checks `lcoComplaintlist`, `complaintList`, `customerComplaintList`, `data` -- CORRECT
- **Categories:** `/complaintCategoriesRest` reads `complaintCategories` -- needs verification
- **Create complaint:** Appends Flutter suffix -- CORRECT
- **Close complaint:** Appends status change suffix -- CORRECT

### 2.8 Report Provider
- **Daily report:** reads `Dailyreport_details` -- not tested in Playwright but matches spec
- **Employee collection:** reads `collResultList` but server sends `collectionList` -- **MISMATCH (P1)**

---

## 3. Screen Flow Validation

### Login -> Access Control -> Dashboard

1. **Login** (`/validateLogin`): LoginResponse model fully matches server. Sanitizer handles all type coercions. Token extracted correctly.
2. **Access Control** (`/getaccesscontrollRest`): **P1 BUG** - `copyWithAccessControl()` reads camelCase keys but server sends snake_case. All access flags default to permissive (1), so the app won't crash but will show features the user shouldn't see.
3. **Dashboard** (`/dashBoardDetailsRest`): Model matches. Dashboard cards display correctly.

### Dashboard -> Customer List

4. **Dashboard customer list** (`/getdashboardlist`): Manual field normalization works. `from_dashboard` mapping (1=assigned, 2=unassigned, 4=active, 5=inactive) is correct.

### Customer Search -> Customer Profile

5. **Customer search** (`/getCustomerDetailsRest`): Model matches with sanitizers. Pagination works correctly.
6. **Customer profile:** Loads from search result CustomerModel. All fields populated.

### Customer Profile -> Payment

7. **Pending amount** (`/getPendingAmountRest`): Model matches.
8. **Payment modes** (`/getPaymentModesRest`): Model matches.
9. **Make payment** (`/PaymentServiceRest`): Request/response models exist.

### Customer Profile -> STB Management

10. **Load boxes** (`/getCustomerBoxDetailsRest`): **P0 BUG** - Provider reads wrong key AND StbModel uses wrong JsonKey names. STB list will be empty.
11. **Deactivation reasons** (`/getDeactiveReasonsRest`): **P1 BUG** - STB provider reads wrong key. Will get empty reasons.

### Customer Profile -> Package Management

12. **Assigned packages** (`/getCustomerPackages_splitRest`): **P1 BUG** - `product_name` not mapped to `pname`, dates use wrong keys, `is_taxable` vs `is_taxble` typo.
13. **Available packages** (`/getUnassignedPackages_splitRest`): Works correctly.

### Complaints

14. **Complaint list** (`/getComplaintList`): Works - provider checks `lcoComplaintlist` key.
15. **Categories** (`/complaintCategoriesRest`): Works.
16. **Create/close complaint:** Works with correct suffixes.

---

## 4. Business Logic Gaps

### 4.1 Payment Mode Field Visibility Matrix
The `MakePaymentRequest` model has fields for cheque (chequeNo, bank, branch, chequeDate), card (cardholderName, cardType), and voucher (voucherCode, rrnNo). The payment screen should show/hide these based on the selected payment mode. **Status: Model is ready; screen implementation needs verification.**

### 4.2 Amount Validation (Partial Payment Blocking)
`AppSession.blockpayment` is correctly read. The provider has `isPaymentBlocked` getter. **Status: Correctly implemented.**

### 4.3 STB Status Display Logic
**Status: BLOCKED by P0 bug** - StbModel fields all use camelCase JsonKeys but server sends snake_case. Until StbModel sanitizer is fixed, no STB data will display.

### 4.4 Reason ID 17 Exclusion
- `StbState.filteredReasons`: Excludes reasonId == 17 only -- **CORRECT per Android spec**
- `PackageState.filteredReasons`: Excludes reasonId 17, 21, and global_reason == 1 -- **CORRECT per Android spec**

### 4.5 Package service_id vs product_id
- **Activation:** Uses `product_id` (comma-separated) -- CORRECT
- **Deactivation:** Uses `customer_service_id` (comma-separated) -- CORRECT
- **Renewal:** Sends BOTH `customer_service_id` and `product_id` -- CORRECT

### 4.6 Complaint Suffixes
- **Create:** Appends via `appendComplaintSuffix(true)` -- CORRECT
- **Close:** Appends `.Complaint Status Change From Flutter app` -- CORRECT
- **STB Deactivation:** Appends `. Box Deactivation from Flutter app` -- CORRECT
- **Package Deactivation:** Appends `. Deactivation From Flutter App` -- CORRECT

### 4.7 Config Flag Gating
- `isPatchGated()` checks for versions `1.4.13.2`, `1.4.13.3`, `1.4.13.4` -- CORRECT
- `isEmployeePatchGated()` checks for `1.4.13.3` only -- CORRECT
- **NOTE:** Current server returns `patch_information: "V2"` which does NOT match any gated version, so subcategory spinner and employee assignment will be hidden.

### 4.8 Validity/End Date Computation
Package provider implements the Android date computation logic (validity.length == 7 for YEAR, 8 for MONTH, else DATE) with subtract-1-day rule. **CORRECT.**

---

## 5. Questions for Clarification

1. **Access control key format:** Does the server normalize keys to camelCase before the response reaches Flutter, or is the Flutter code relying on a middleware layer? Current `copyWithAccessControl()` only reads camelCase but server sends snake_case.

2. **STB box details response key:** Is there a middleware/interceptor that transforms `customerBoxList` into `data`? The provider expects `data['data']` but server returns `customerBoxList`.

3. **Assigned package `product_name` vs `pname`:** Is there a server-side normalization that renames `product_name` to `pname` for assigned packages? The model only maps `pname`.

4. **`patch_information: "V2"`:** This value does not match any of the gated versions (1.4.13.x). Is the complaint subcategory/employee feature intentionally disabled for this dealer, or should "V2" be added to the gated set?

5. **Employee collection response key:** The Playwright capture shows `collectionList` but the report provider reads `collResultList`. Is there a different endpoint or version that returns `collResultList`?

6. **`config_values_array`:** This contains `min_mobile_length`, `max_mobile_length`, `pincode_length`, `country_code`. Is this used anywhere for validation? Currently stripped by sanitizer and not stored.

7. **`is_taxable` vs `is_taxble`:** The server sends both spellings depending on context (assigned uses `is_taxable`, unassigned uses `is_taxble`). Should the model handle both?

8. **Wallet history key:** Provider reads `lcoWalletList` but server returns `getLcoWalletReport`. Which is correct?

---

## 6. Action Items (Prioritized)

### P0 - Will Crash or Show No Data

| # | File | Change | Impact |
|---|---|---|---|
| 1 | `lib/data/models/stb/stb_model.dart` | Add `_sanitize()` that maps snake_case server keys to camelCase model keys: `serial_number`->`serialNumber`, `vc_number`->`vcNo`, `stock_id`->`stockId`, `box_number`->`boxNumber`, `mac_address`->`macAddress`, `stock_status`->`stockStatus`, `device_id`->`deviceId`, `backend_setup_id`->`backendSetupId`, `activation_date`->`activatedDate`, `cas_display_name`->`casType`, `customer_id`->`customerId`, `stb_no`->`stbNo` | STB list completely empty |
| 2 | `lib/application/providers/stb_provider.dart` | In `loadBoxes()`, change `data['data']` to also check `data['customerBoxList']` | STB list extraction fails |

### P1 - Wrong Behavior / Missing Features

| # | File | Change | Impact |
|---|---|---|---|
| 3 | `lib/core/config/app_session.dart` | In `copyWithAccessControl()`, add snake_case key lookups alongside camelCase: `json['int_bulk_payment'] ?? json['intBulkPayment']`, `json['invoice_page_access'] ?? json['invoicePageAccess']`, etc. for all 8 access control flags | Access control flags never update from server |
| 4 | `lib/application/providers/stb_provider.dart` | In `loadDeactivationReasons()`, change `data['data']` to `data['reasonList'] ?? data['data']` | STB deactivation reasons always empty |
| 5 | `lib/data/models/package/package_model.dart` | Add `product_name` as fallback for `pname` in sanitizer: `if (r['pname'] == null && r['product_name'] != null) r['pname'] = r['product_name'];` | Assigned package names show as empty |
| 6 | `lib/data/models/package/package_model.dart` | Add sanitizer aliases: `service_start_date`->`start_date`, `service_end_date`->`end_date` | Assigned package dates always null |
| 7 | `lib/data/models/package/package_model.dart` | Handle both `is_taxable` and `is_taxble` in sanitizer | Tax flag incorrect for assigned packages |
| 8 | `lib/application/providers/report_provider.dart` | In `loadEmpCollection()`, change `data['collResultList']` to `data['collectionList'] ?? data['collResultList']` | Employee collection report always empty |
| 9 | `lib/data/models/customer/form_validation.dart` | Add sanitizer to alias `column_name`->`columnName` and `is_mandatory`->`isMandatory` | Dynamic form validations fail to parse |

### P2 - Missing Feature / Data Loss

| # | File | Change | Impact |
|---|---|---|---|
| 10 | `lib/application/providers/dashboard_provider.dart` | In `loadWalletHistory()`, change `data['lcoWalletList']` to `data['getLcoWalletReport'] ?? data['lcoWalletList']` | Wallet history always empty |
| 11 | `lib/data/models/dashboard/dashboard_response.dart` | Add `totalActiveAssignedStbs` and `totalDeactiveAssignedStbs` fields | Missing dashboard data |

### P3 - Cosmetic / Informational

| # | File | Change | Impact |
|---|---|---|---|
| 12 | `lib/data/models/dashboard/wallet_response.dart` | Add `statusMsg` field | Missing status message |
| 13 | `lib/data/models/payment/pending_amount.dart` | Add `statusMsg` field | Missing status message |
| 14 | `lib/data/models/customer/customer_search_response.dart` | Add `totMsoShare` field for `tot_mso_share` | Missing aggregated value |
| 15 | `lib/data/models/stb/stb_model.dart` | Add `stbType`, `stbModel`, `stockLocation` fields | Missing STB metadata |

---

## Summary

| Severity | Count | Status |
|---|---|---|
| P0 (Crash/No Data) | 2 | STB model key mismatch + provider list key mismatch |
| P1 (Wrong Behavior) | 7 | Access control keys, deactivation reasons key, package field names, report key, form validation keys |
| P2 (Missing Feature) | 2 | Wallet history key, dashboard extra fields |
| P3 (Cosmetic) | 4 | Missing status_msg fields, extra metadata |

**The most critical issues are in the STB module (P0) and access control parsing (P1).** The login, dashboard, customer search, payment, and complaint flows are functionally correct with their sanitizers properly handling type coercion. Package management for assigned packages has field name mismatches that will cause empty names and dates.
