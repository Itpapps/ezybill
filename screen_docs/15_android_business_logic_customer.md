# Android Business Logic Extraction: Customer Management Screens

> **Source Files Analyzed:**
> - `NewCustCreation_Fragment.java` (5360 lines) — SOAP only, marked "We are not using this Fragment" at line 117
> - `Edit_Customer_Info.java` (3809 lines) — SOAP only
> - `CustomerOperations_Fragment.java` (1082 lines) — Mixed SOAP + 1 REST (Volley) call
> - `CustomerSearchList_Fragment.java` (1265 lines) — SOAP only
> - `NewCustomer_Confirm_Activity.java` (439 lines) — UI confirmation only, no API calls
> - `NewCust_AddPackage_Activity.java` — SOAP only
> - `configg.properties` — endpoint key mappings

> **CRITICAL NOTE:** Almost all customer screens use **SOAP (ksoap2)** — NOT Volley/REST V2. The only REST/Volley call found is `updateCustomerLocation` in `CustomerOperations_Fragment`. The V2 REST equivalents for customer CRUD must be built from the REST API documentation in `12_server_api_contracts.md` and `14_comprehensive_api_request_response.md`, using the business rules extracted below.

---

## 1. New Customer Creation (NewCustCreation_Fragment)

**API Type: SOAP — DO NOT PORT the transport layer. Port ONLY the business rules.**

### 1.1 Config Flags (from LoginActivity static fields, ~line 521-533)

| Config Flag | Source | Behavior |
|---|---|---|
| `useCRF` | `LoginActivity.useCRF` | `0` = use CRF Number label; `1` = use CAF Number label |
| `useCAF` | `LoginActivity.useCAF` | `"AUTO"` = hide CAF input (server auto-generates); `"MANUAL"` = show CAF input field, mandatory |
| `useLastName` | `LoginActivity.useLastName` | `0` = hide Last Name row, label = "Customer Name"; `1` = show Last Name row, label = "First Name" |
| `useDiscount` | `LoginActivity.useDiscount` | `0` = hide discount; `1` = show only for DEALER/ADMIN/EMPLOYEE; `2` = show for all |
| `useAccountNumber` | `LoginActivity.useAccountNumber` | `0` = show Account Number field (mandatory); `>0` = hide Account Number field |
| `useMandatoryForHotel` | `LoginActivity.useMandatoryForHotel` | `1` = require CustomerTypeTypes sub-selection |
| `useDataFromMasterTable` | `LoginActivity.useDataFromMasterTable` | Controls master data loading (not visibly used in validation) |
| `freezecustomerparamsinapp` | `LoginActivity.freezecustomerparamsinapp` | Controls field locking (variable declared at line 431 but no locking logic found in this SOAP fragment — only used in V2 REST screens) |
| `customerbilltype` | `LoginActivity.customerbilltype` | `0` = show both "Advance Billing" + "Postpaid"; `2` = only "Advance Billing"; `3` = only "Postpaid"; else = only "Postpaid" |

### 1.2 Dynamic Form Validations (`formValidations_modelArrayList`, ~line 871-943)

The `dynamicformvalidations` API returns per-dealer field requirements from table `customer`. These override default mandatory status:

| Column Name | Variable | Effect When `is_mandatory == "1"` |
|---|---|---|
| `last_name` | `is_lastname_mandatory` | Last Name field becomes required, label shows red asterisk |
| `email` | `is_email_mandatory` | Email field becomes required with format validation |
| `id_type` | `is_id_type_mandatory` | ID Type spinner must not be "Select" |
| `id_number` | `is_id_number_mandatory` | ID Number text must not be empty |
| `gender` | `is_gender_mandatory` | Gender label shows asterisk (no blocking validation found) |
| `mobile_no` | `is_mobile_no_mandatory` | Mobile must be >= 10 digits |
| `baid` | `is_baid_mandatory` | LCO Customer ID must not be empty |
| `mandal_id` | `is_mandal_id_mandatory` | Mandal spinner must not be "Select" |

**Flutter equivalent:** Call `dynamicformvalidations` REST endpoint with `dealer_id` and `table_name="customer"` at screen load. Store the results and use them to toggle mandatory indicators and validation checks.

### 1.3 Pre-API Validation Chain (~line 993-1393)

Validations execute as a sequential `if/else if` chain. First failure stops the chain.

| Order | Condition | Error Message | Config Dependency |
|---|---|---|---|
| 1 | `custType == "Select"` | "Please select a Customer Type!" | Always mandatory |
| 2 | `useMandatoryForHotel==1 && mandatory_check==1 && custTypeTypes=="Select"` | "Please select a Customer Type!" | `useMandatoryForHotel` flag |
| 3 | `useMandatoryForHotel==1 && mandatory_check==0 && edit_custType_multi is empty` | "Please Enter Customer Type!" | `useMandatoryForHotel` flag |
| 4 | `useCRF==1 && useCAF=="MANUAL" && cafNo is empty` | "CAF Number should not be empty" | `useCRF` + `useCAF` |
| 5 | `useCAF=="MANUAL" && lco_custid is empty` | "LCO Customer Id should not be empty" | `useCAF` |
| 6 | `is_baid_mandatory=="1" && lco_custid is empty` | "LCO Customer Id should not be empty" | Dynamic form validation |
| 7 | `firstName is empty` | "First Name should not be empty" | Always mandatory |
| 8 | `is_lastname_mandatory=="1" && lastName is empty` | "Last Name should not be empty" | Dynamic form validation |
| 9 | `useAccountNumber==0 && account_no is empty` | "Account Number should not be empty" | `useAccountNumber` flag |
| 10 | `useAccountNumber==0 && account_no !matches alphanumeric regex` | "Account Number should contain at least 1 numeric and 1 alphabet and min length 3" | `useAccountNumber` flag |
| 11 | `addLine1 is empty OR inst_addLine1 is empty` | "Address should not be empty" | Always mandatory |
| 12 | `is_mobile_no_mandatory=="1" && mobile < 10 digits` | "Mobile number should not be less than 10 digits" | Dynamic form validation |
| 13 | `pinCode < 6 digits` | "Pincode should not be less than 6 digits" | Always mandatory |
| 14 | `email.length > 0 && is_email_mandatory=="1" && !matches emailPattern` | "Email Id pattern is Invalid" | Dynamic form validation |
| 15 | `package text == "Select Package" or empty` | "Package should not be empty" | Always mandatory |
| 16 | `group == "Select"` | "Please select a Group" | Always mandatory |
| 17 | `is_id_type_mandatory=="1" && idType=="Select"` | "Please select ID Type" | Dynamic form validation |
| 18 | `is_id_number_mandatory=="1" && idNumber is empty` | "Please enter an ID Number" | Dynamic form validation |
| 19 | `is_mandal_id_mandatory=="1" && mandal=="Select"` | "Please select mandal" | Dynamic form validation |
| 20 | `cityItemValue==0 && city=="Select"` | "Please select city" | Always |

**Regex patterns used:**
- Email: `[a-zA-Z0-9._-]+@[a-z]+\\.+[a-z]+` (line 396)
- Account Number alphanumeric: `((?=.*\\d)(?=.*[a-z]).{3,30})` (line 399)

### 1.4 Default Values Pre-filled

| Field | Source | Line |
|---|---|---|
| STB Number (`et_boxNo`) | `bundle.getString("stbNo")` from previous screen | ~800 |
| Mobile number (`et_mobile`) | `bundle.getString("mobile")` from previous screen | ~754 |
| Default Country | `LoginActivity.defaultcountry` | spinner auto-selects position 100 (India) |
| Default State | `LoginActivity.defaultstate` | spinner auto-selects matching position |
| Default District | `LoginActivity.defaultdistrict` | spinner auto-selects matching position |
| Default City | `LoginActivity.defaultcity` | spinner auto-selects matching position |
| Reseller ID | `bundle.getInt("resellerid")` | ~511 |

### 1.5 Field Dependencies

#### Bill Type Spinner (~line 1601-1639)
| `LoginActivity.customerbilltype` | Options Shown | Default Value |
|---|---|---|
| `0` | Advance Billing, Postpaid | First item |
| `2` | Advance Billing only | 1 |
| `3` | Postpaid only | 2 |
| Other | Postpaid only | 2 |

Bill type value: `"Advance Billing"` = `billtypeitemvalue=1`, `"Postpaid"` = `billtypeitemvalue=2`

#### CAF Number Visibility (~line 574-592)
- `useCRF==1 && useCAF=="AUTO"` -> hide both CAF rows
- `useCRF==1 && useCAF!="AUTO"` -> show new CAF row (mandatory, with asterisk)
- `useCRF==0` -> hide both CAF rows

#### Account Number Visibility (~line 601-606)
- `useAccountNumber==0` -> show Account Number row (mandatory)
- `useAccountNumber>0` -> hide Account Number row

#### Discount Visibility (~line 611-621)
- `useDiscount==0` -> hidden
- `useDiscount==1` -> shown only for DEALER/ADMIN/EMPLOYEE user types
- `useDiscount==2` -> always shown

#### Last Name Visibility (~line 669-675)
- `useLastName==1` -> show Last Name row, first name label = "First Name"
- `useLastName==0` -> hide Last Name row, first name label = "Customer Name"

#### ID Type -> ID Number + ID Photo (~line 4542-4550)
- When ID Type spinner = "Select" -> disable ID Number field, hide ID Photo row
- When ID Type != "Select" -> enable ID Number field, show ID Photo row

#### "Same as billing address" Checkbox (~line 1562-1581)
- Checked: copies billing address lines 1 & 2 to installation address, disables installation fields
- Unchecked: clears installation address, re-enables fields
- Checkbox is only enabled when billing address line 1 has content (~line 1710-1717)

### 1.6 Address Cascade: Country -> State -> District -> Mandal -> City

All these use **SOAP** calls. The Flutter equivalent should use REST endpoints.

| Trigger | API Called | Params | Next Action |
|---|---|---|---|
| Country selected | `getStates` | `authToken`, `countryCode` | Populate State spinner |
| State selected | `getdistricts` + `getCities` | `authToken`, `stateId` | Populate District + City spinners; store `selected_state_id` |
| District selected | `getmandals` | `authToken`, `districtId` | Populate Mandal spinner (with "Select" default at index 0) |
| Mandal selected (pos != 0) | `getLocationsOfSelectedMandal` | `authToken`, `districtId` | Populate City spinner with mandal-filtered cities |
| Mandal selected (pos == 0) | `getCities` | `authToken`, `stateId` | Populate City spinner with all state cities |

**Flutter equivalent:** Use cascading REST API calls. Config property keys:
- Countries: `count` -> `getCountries`
- States: `stat` -> `getStates`
- Districts: `dist` -> `getdistricts`
- Mandals: `mand` -> `getmandals`
- Cities: `cit` -> `getCities`
- Cities by Mandal: `locselmand` -> `getLocationsOfSelectedMandal`

### 1.7 GPS Auto-fill Logic (~line 1474-1508)

On GPS button click:
1. Create `GPSTracker` instance
2. If GPS available: get lat/long, populate `tv_latitude` and `tv_longitude` fields
3. If longitude is "0.0" or empty, call `gps.stopUsingGPS()`
4. If GPS not available: show settings alert

### 1.8 API Call Chain for Save

**Step 1: Confirmation Screen**
After all validations pass (~line 1395), an Intent launches `NewCustomer_Confirm_Activity` with all form data as extras.

**Step 2: Signal Strength Check**
The confirmation screen checks signal strength before returning `conform_save=true`. Wifi signal < 25% or GSM signal <= -107dBm blocks the save.

**Step 3: Save Trigger** (~line 5231-5286)
When confirmation returns `conform_save=true`:
- Check internet connectivity
- If online: execute `NewCust_Save` AsyncTask

**Step 4: Save Customer (SOAP — DO NOT PORT transport)** (~line 4603-5100)

Fields sent to `saveCustomer` SOAP endpoint:

| SOAP Field | Source | Notes |
|---|---|---|
| `customerTypeId` | `custTypeItemValue` (int) | Spinner selection |
| `cafNumber` | `et_cafNo.getText()` | May be empty if AUTO |
| `businessName` | `et_businessName.getText()` | Optional |
| `lcoCustomerId` | `et_lco_cutid.getText()` | "baid" field |
| `firstName` | `et_firstName.getText()` | Mandatory |
| `lastName` | `et_lastName.getText()` | Conditional |
| `idType` | `idTypeItemValue` (int) | Spinner selection |
| `idNumber` | `et_idNumber.getText()` | Conditional |
| `fatherName` | `et_fatherName.getText()` | Optional |
| `gender` | `genderItemValue` (int) | 1=Male, 2=Female |
| `group` | `groupItemValue` (int) | Spinner selection |
| `discount` | `et_discount` parsed to int | Default 0 |
| `country` | `countryItemValue` (String/ISO) | Spinner selection |
| `state` | `stateItemValue` (int) | Spinner selection |
| `district` | `districtItemValue` (int) | Spinner selection |
| `city` | `cityItemValue` (int) | Spinner selection |
| `phone` | `et_phone.getText()` | Optional |
| `mobile` | `et_mobile.getText()` | Conditional |
| `email` | `et_email.getText()` | Conditional |
| `pin` | `et_pinCode` parsed to int | Mandatory |
| `address` | `addLine1 + " " + addLine2` | Mandatory |
| `remarks` | User text + ". Customer Created From Android App" | Default: "Customer Created From Android App" |
| `installationAddress` | `instAddLine1 + " " + instAddLine2` | Mandatory |
| `idProofImg` | Base64 encoded JPEG | Optional camera capture |
| `customerImg` | Base64 encoded JPEG | Optional camera capture |
| `signatureImg` | Base64 encoded JPEG | Optional capture |
| `boxNumber` | `et_boxNo.getText()` (pre-filled, non-editable) | From STB validation |
| `packageId` | `sel_packageId` (int) | From package selection |
| `dateType` | Derived: Month=1, Year=2, Day=3 | From activation cycle |
| `quantity` | `quantity` (int) | From package selection |
| `dateofbirth` | `yyyy-MM-dd` or `"0000-00-00"` | Optional |
| `dateofanniversary` | `yyyy-MM-dd` or `"0000-00-00"` | Optional |
| `authToken` | `LoginActivity.authToken` | Always |
| `latitude` | `tv_latitude.getText()` | GPS value |
| `longitude` | `tv_longitude.getText()` | GPS value |
| `ipAddress` | `LoginActivity.ipAddress` | Device IP |
| `billType` | `billtypeitemvalue` (int) | 1=Advance, 2=Postpaid |
| `pricingStructureType` | From package selection | 1=OneTime, 2=Recurring |
| `validityDays` | From package selection | Days count |
| `accountNumber` | `et_account_no.getText()` | Conditional |
| `customerTypeTypesId` | Depends on `mandatory_check`: 0=free text, 1=spinner value | Hotel type sub-type |
| `mandal` | `mandal_id` (String of int) | Spinner selection |

**Step 5: Response Handling** (~line 4882-5100)
| Status Code | Behavior |
|---|---|
| `0` | Success dialog -> navigate to Dashboard (MainActivity with frgToLoad=0) |
| `1` | "Failed creating customer!" dialog with "Try Again" / "Cancel" -> stay or go to Dashboard |
| `>=2` | Same as status 1 |
| `null` response | "Server connectivity error!" dialog |

### 1.9 Date Validations (~line 1851-2010)

- **DOB**: Must be before or equal to today's date. Format: `yyyy-MM-dd`
- **DOA (Anniversary)**: Must be after today's date. Format: `yyyy-MM-dd`
- Default display: "Select" (meaning no date selected, sent as `"0000-00-00"`)

---

## 2. Edit Customer (Edit_Customer_Info)

**API Type: SOAP — DO NOT PORT the transport layer. Port ONLY the business rules.**

### 2.1 Pre-populate Logic (~line 348-404)

Data comes from `EditCustomer_ResponseModel` (parcelable) via bundle:

| Field | Source Property | Processing |
|---|---|---|
| First Name | `getFirst_name()` | Direct |
| Last Name | `getLast_name()` | Direct |
| Father's Name | `getFathers_name()` | Direct |
| Billing Address | `getAddress1() + ", " + getAddress2()` | Concatenated |
| Pin Code | `getPin_code()` | Direct |
| Business Name | `getBusiness_name()` | Direct |
| Phone | `getPhone_no()` | Direct |
| Mobile | `getMobile_no()` | If 12 chars, strip first 2 (country code) |
| Email | `getEmail()` | Empty string if length <= 0 |
| CAF Number | `getCaf_no()` | Direct |
| Username | `getUser_name()` | Direct |
| Password | Always empty `""` | Never pre-filled |
| Installation Address | `getInstallation_address()` | Direct |
| Signup Date | `getSignup_date()` | Direct, non-editable |
| LCO Customer ID | `getBaid()` | Direct |
| Gender | `getGender()` parsed to int | 1=Male(pos 1), 2=Female(pos 2) |
| DOB | `getDate_of_birth()` | Direct |
| Anniversary | `getAnniversary_date()` | Direct |
| Account Number | `getAccount_number()` | Direct |
| Box Number | `getBox_number()` | Stored, not displayed in edit form |

### 2.2 Field Editability

| Field | Editable? | Condition |
|---|---|---|
| Account Number | `LoginActivity.useAccountNumber == 0` -> editable; else disabled | Line 393-401 |
| Billing Address | Only when "Change Address" checkbox is checked | Line 326-334 |
| Installation Address | Only when "Change Install Address" checkbox is checked | Line 337-346 |
| Address spinners (Country/State/District/City/Mandal) | Only visible when address checkbox checked | Same layout toggle |
| Password | Always editable (starts empty) | Line 372 |

### 2.3 Address Change Toggle (~line 326-346)

Two checkboxes control address editability:
1. **`address_chkbox`** ("Change Address"): toggles visibility of `address_layout` containing Country/State/District/City/Mandal spinners
2. **`install_addrs_chkbox`** ("Change Install Address"): toggles visibility of `install_addrs_layout`

When address checkbox is NOT checked, the update sends original values from `edit_responseObject`:
- `country_final = edit_responseObject.getCountry()`
- `city_final = 0`, `state_final = 0`, `district_final = 0`, `mandal_final = ""`

When checked, sends newly selected spinner values.

### 2.4 Dynamic Form Validations (Edit screen)

Edit screen calls `dynamicformvalidations` SOAP endpoint with `dealerId` and `table_name="customer"` (~line 3632-3805). Same field mapping as new customer but fetched independently via the `FormValidate` AsyncTask.

### 2.5 Pre-Save Validations (~line 408-546)

Uses a `check` variable (0=pass, 1=fail). Unlike new customer, does NOT use short-circuit if/else — multiple errors can show sequentially.

| Validation | Condition | Error Message |
|---|---|---|
| Location | `!getLocation()` returns false | "Please enable location" (Toast) |
| First Name | `et_firstname.length() == 0` | "First name shouldnot be empty" |
| Last Name | `is_lastname_mandatory=="1" && lastname is empty` | "Last Name should not be empty" |
| LCO Customer ID | `is_baid_mandatory=="1" && et_loc_cust_id.length() < 2` | "Lco customer id shouldnot be empty" |
| Mobile | `is_mobile_no_mandatory=="1" && mobile.length() < 10` | "Mobile number shouldnot be empty/enter valid mobile number" |
| Account Number | `et_acct_number.length() < 2` | "Account number shouldnot be empty/enter valid account number" |
| CAF Number | `et_caf_num.length() < 2` | "Caf number shouldnot be empty/enter valid caf number" |
| Email | `email.length() > 0 && !matches emailPattern && is_email_mandatory=="1"` | "Email Id shouldnot be empty/ Enter valid Email Id" |

If `check == 0` after all validations, executes `UpdateCust` AsyncTask.

### 2.6 Edit Customer API (SOAP — DO NOT PORT transport) (~line 3162-3458)

Fields sent to `editCustomer` SOAP endpoint:

| SOAP Field | Source |
|---|---|
| `customerId` | From bundle `getInt("customerId")` |
| `customerTypeId` | Spinner selected value |
| `lcoCustomerId` | `et_loc_cust_id.getText()` |
| `cafNumber` | `et_caf_num.getText()` |
| `businessName` | `et_businessname.getText()` |
| `firstName` | `et_firstname.getText()` |
| `lastName` | `et_lastname.getText()` |
| `idType` | Spinner selected value |
| `idNumber` | `et_id_number.getText()` |
| `fatherName` | `et_fathersname.getText()` |
| `gender` | Spinner selected value |
| `group` | Spinner selected value |
| `country` | Conditional: new selection or original |
| `state` | Conditional: new selection or 0 |
| `district` | Conditional: new selection or 0 |
| `city` | Conditional: new selection or 0 |
| `phone` | `et_phone.getText()` |
| `mobile` | `et_mobile.getText()` |
| `old_mobile` | `edit_responseObject.getMobile_no()` |
| `email` | `et_emailid.getText()` |
| `pin` | `et_pin.getText()` parsed to int |
| `address` | `et_billing_addr.getText()` |
| `remarks` | "CustomerUpdatedFromAndroidApp" (hardcoded) |
| `installationAddress` | `et_installation_addrs.getText()` |
| `boxNumber` | From original data |
| `dateofanniversary` | `et_anniversary_date.getText()` |
| `dateofbirth` | `et_dob.getText()` |
| `authToken` | `LoginActivity.authToken` |
| `latitude` | From GPS at save time |
| `longitude` | From GPS at save time |
| `billType` | From original data `edit_responseObject.getBill_type()` |
| `accountNumber` | `et_acct_number.getText()` |
| `mandal` | Conditional: new selection or original |
| `customersla_id` | From original `edit_responseObject.getCustomersla_id()` |
| `baid` | Same as lcoCustomerId |
| `customerImg` | Base64 only if upload_photo_chkbox checked |
| `idProofImg` | Base64 only if upload_photo_chkbox checked |
| `signatureImg` | Base64 only if upload_photo_chkbox checked |

**Response Handling:**
| Status Code | Behavior |
|---|---|
| `0` | "Updated Successfully" -> navigate to Dashboard |
| Other | "Failed updating customer!" with "Try Again" / "Exit" |

---

## 3. Customer Operations (CustomerOperations_Fragment)

**API Type: Mixed — SOAP for `existingCustomer`, REST/Volley for `updateCustomerLocation`**

### 3.1 Bundle Data Received (~line 164-187)

| Key | Type | Usage |
|---|---|---|
| `custName` | String | Display name |
| `custId` | int | `altCustId` — primary identifier |
| `cafNo` | String | CAF/CRF number |
| `mobileNO` | String | Default "NA" |
| `reseller_id` | int | Passed to sub-screens |
| `status` | int | 0=DEACTIVE, 1=ACTIVE |
| `billAdd` | String | Billing address |
| `instAdd` | String | Installation address |
| `account_number` | String | Default "NA" if null |
| `pinCode` | int | |
| `pending_amount` | double | Due amount |
| `online` | int | Online customer flag |
| `addservice` | int | Add service access flag |
| `lati` | String | Latitude (sanitized: empty/"null"/"anyType{}" -> "0.0") |
| `longi` | String | Longitude (same sanitization) |
| `bill_type` | int | Billing type |

### 3.2 Operation Buttons Visibility

| Button | Visibility Condition | Lines |
|---|---|---|
| Make Payment | `LoginActivity.int_bulk_payment==1` OR `LoginActivity.hidemakepayment==0` | 242-256 |
| Due Amount Pay | Same as Make Payment, also hidden if `pending_amount <= 0` | 211-216 |
| Box Operations | `LoginActivity.int_stb_activation==1 OR int_stb_deactivation==1 OR int_stb_reactivation==1` | 298-302 |
| Package Operations | `LoginActivity.int_stb_activation==1 OR int_stb_deactivation==1` | 652-656 |
| Invoice History | `LoginActivity.invoice_page_access==1` | 320-325 |
| Payment History | `LoginActivity.payment_hist_page_access==1` | 337-342 |
| Complaint History | `LoginActivity.access_for_complaints==1` | 354-361 |
| Complaint Operations | `LoginActivity.access_for_complaints==1` | 354-361 |
| Locate Customer | `LoginActivity.patch_information` in ("1.4.13.2", "1.4.13.3", "1.4.13.4") | 373-378 |
| Update Location | Same patch_information check | 526-531 |
| Edit Profile | Always visible | 718-727 |

### 3.3 Navigation Routing

| Button | Target Fragment | Bundle Data |
|---|---|---|
| Make Payment | `CustomerMgmtActivity_MakePayment_Fragment` | custId, reqOrigin="CustomerOperations", reseller_id |
| Box Operations | `Customer_STB_Select_Fragment` | custId, operationType="boxOperation", reqOrigin="CustomerOperations" |
| Package Operations | `Customer_STB_Select_Fragment` | custId, operationType="packageOperation", reqOrigin="CustomerOperations", pending_amount, bill_type |
| Complaint Operations | `Complaint_Operations_Fragment` | reseller_id, custId, custName, reqOrigin="CustomerOperations" |
| Edit Profile | Calls `existingCustomer` SOAP first, then navigates to `Edit_Customer_Info` | customerId, editdata (Parcelable) |
| Invoice History | `InvoiceHistory` | custname, custId |
| Payment History | `PaymentHistory` | custname, custId |
| Complaint History | `ComapliantHistory` | custId |

### 3.4 Package Operations — Online Customer Check (~line 661-690)

```
if (online == 0 || addservice == 1) {
    // Allow package operations
} else {
    // Show "Package operations not available for online customer"
}
```

**Business rule:** Package operations are blocked for online customers UNLESS `addservice == 1`.

### 3.5 Edit Profile — Existing Customer SOAP Call (~line 881-994)

**API Type: SOAP — DO NOT PORT transport**

Sends: `authToken`, `customerId=altCustId`, `accountNumber=String.valueOf(altCustId)`, `cafNumber=cafNo`

Response: `EditCustomer_ResponseModel` object with all customer fields.
- `statusCode == 0` -> navigate to Edit_Customer_Info with response data
- Other -> show error toast

### 3.6 Update Customer Location — REST/Volley (V2) (~line 998-1081)

**THIS IS THE ONLY REST CALL — PORT THIS**

| Property | Value |
|---|---|
| URL | `LoginActivity.URL.replace("/wsController","") + "/customerRestservices/updateCustomerLocation"` |
| Method | POST |
| Timeout | 100,000 ms |

**Request Params:**

| Param | Value |
|---|---|
| `authtoken` | `LoginActivity.authToken` |
| `dealer_id` | `String.valueOf(LoginActivity.dealerId)` |
| `latitude` | Current GPS latitude |
| `longitude` | Current GPS longitude |
| `customer_id` | `String.valueOf(altCustId)` |

**Response Handling:**

| `status_code` | Behavior |
|---|---|
| `0` | Pop backstack, Toast "Location updated successfully" with customer name, CAF, remarks |
| `1` | Dialog "No records!" |
| `2` | Toast with status message + ": Contact Support" |

### 3.7 Locate Customer Button Logic (~line 379-523)

If customer has no coordinates (lat=0.0 or long=0.0):
- POS device (N910): prompt to update location directly
- Other devices: show dialog to navigate to Maps update screen (`MapsFragmentlocupdate`)

If customer HAS coordinates:
- POS device: "Maps cannot be loaded In POS Machines"
- Other: open Google Maps with `daddr=lat,long`

---

## 4. Customer Search (CustomerSearchList_Fragment)

**API Type: SOAP — DO NOT PORT transport**

### 4.1 Search Parameters Received via Bundle (~line 166-176)

| Param | Bundle Key | Maps to SOAP Field |
|---|---|---|
| Customer Number | `custNo` | `customerNumber` |
| Customer Name | `custName` | `customerName` |
| Mobile Number | `mobileNo` | `mobileNumber` |
| Box Number | `boxNo` | `boxNumber` |
| LCO Customer ID | `lcoCustomerId` | `lcoCustomerId` |
| Box No for STB check | `boxno_stbcheck` | Used for STB mapping |
| Request Origin | `reqOrigin` | Controls navigation destination |
| Total Count | `count` | `TOTAL_LIST_ITEMS` |

### 4.2 Pagination Logic (~line 77-185)

| Parameter | Value |
|---|---|
| `NUM_ITEMS_PAGE` | 100 (hardcoded) |
| `startValue` | `NUM_ITEMS_PAGE * pageNo` (0-based) |
| `endValue` | `NUM_ITEMS_PAGE` (page size) |
| `pageCount` | `ceil(TOTAL_LIST_ITEMS / NUM_ITEMS_PAGE)` |

Navigation: First, Prev, numbered page buttons, Next, Last. Buttons disabled at boundaries.

### 4.3 Request Origin Routing (~line 427-563)

| `request_origin` | Target Fragment | Bundle Keys |
|---|---|---|
| `"payments"` | `CustomerMgmtActivity_MakePayment_Fragment` | custName, custId, reqOrigin, reseller_id |
| `"complaintMgmt"` | `Complaint_Operations_Fragment` | custName, custId, reqOrigin, reseller_id |
| `"packageMgmt"` | `Customer_STB_Select_Fragment` | custName, custId, reqOrigin, operationType="packageOperation", pending_amount, resellerid, bill_type |
| `"boxMgmt"` | `Customer_STB_Select_Fragment` | custName, custId, reqOrigin, operationType="boxOperation", pending_amount, resellerid |
| `"stb_Map_custID"` | Shows confirm dialog, then calls `customerCreationWithDevice` SOAP | boxNo, custId, custName |
| Default (customer search) | `CustomerOperations_Fragment` | Full customer data bundle (15+ fields) |

### 4.4 Package Management — Online Customer Block (~line 467-501)

```
if (onlinecustomer == 0 || checkonlineservice == 1) {
    // Allow navigation
} else {
    // "Package operations not available for online customer"
}
```

### 4.5 Customer Data Fields Parsed from SOAP Response (~line 898-1035)

| Field | SOAP Property | Default if missing |
|---|---|---|
| `customer_id` | int | Required |
| `customerName` | String | Required |
| `caf_no` | String | Required |
| `mobile_no` | String | "" if "anyType{}" |
| `status` | int | Required |
| `billing_address` | String | "" if "anyType{}" |
| `installation_address` | String | "" if "anyType{}" |
| `pin_code` | int | 0 if "anyType{}" |
| `crf_number` | String | "NA" if "anyType{}" |
| `pending_amount` | double | 0.0 on error |
| `online_customer` | int | 0 on error |
| `reseller_id` | int | 0 on error |
| `latitude` | String | "0.0" on error |
| `longitude` | String | "0.0" on error |
| `is_direct_lco` | int | 0 on error |
| `bill_type` | int | 0 on error |

### 4.6 CRF vs CAF Display (~line 1166-1208)

- `LoginActivity.useCRF == 0` -> display CRF number in list, CAF field uses `crfNumber`
- `LoginActivity.useCRF == 1` -> display CAF number in list, CAF field uses `cafNo`

---

## 5. New Customer Confirm + Add Package

### 5.1 Confirmation Screen (NewCustomer_Confirm_Activity)

**No API calls.** Pure display screen showing all customer data passed via Intent extras.

**Fields displayed:** custType, cafNo, lcocustId, bName, fName, gender, billtype, fatherName, address, instaddress, city, country, state, district, pincode, phone, mobile, email, dob, doa, group, boxNo, package, discount, remarks, idType, idNo, longitude, latitude, mandal.

**Save Button:** Checks signal strength before returning `conform_save=true`.
- Returns to parent via `setResult(RESULT_OK, intent)` with `conform_save` boolean.

### 5.2 Package Selection (NewCust_AddPackage_Activity)

**API Type: SOAP — DO NOT PORT transport**

**CAS Package Loading:**
- Endpoint: `getCasPackages` (config key: `caspck`)
- Params: `authToken`, `boxNumber`
- Returns: `caspackageList` with `product_id`, `pname`, `pricing_structure_type`

**Package Selection UI:**
- Searchable dialog with filter (TextWatcher filters package list)
- On package select, sets `productId`, `productName`, `pricing_structure_type`

**Activation Cycle Logic (~line 274-311):**

| `pricing_structure_type` | Activation Cycle Options | Quantity Behavior |
|---|---|---|
| `1` (OneTime) | Year, Month, Day | Editable, default "1" |
| `2` (Recurring) | Year only | Fixed "1", disabled |

**Validity Days:**
- Only enabled when activation cycle = "Day"
- Otherwise hidden and defaults to 1
- Mandatory when enabled

**Data Returned to Parent:**

| Extra Key | Type | Description |
|---|---|---|
| `selProductId` | int | Package ID |
| `selProductName` | String | Package name |
| `selQuantity` | int | Quantity |
| `selActiveCycle` | String | "Year"/"Month"/"Day" |
| `selValidDays` | int | Validity days (default 1) |
| `selPricingType` | int | 1=OneTime, 2=Recurring |

**Quantity Validation:**
- Must not be empty

**Validity Days Validation:**
- If enabled and empty -> error "Validity days should not be empty"
- If disabled and empty -> default to 1

---

## 6. Summary: What Flutter Must Implement

### 6.1 REST Endpoints to Use (from configg.properties)

| Operation | Config Key | REST Path | Method |
|---|---|---|---|
| Save Customer | `savecus` | `saveCustomer` | POST |
| Edit Customer | `edcust` | `editCustomer` | POST |
| Existing Customer (get details) | `eexisting` | `existingCustomer` | POST |
| Customer Search Count | `scount` | `getCustomerDetailsCount` | POST |
| Customer Search Details | `sdetails` | `getCustomerDetails` | POST |
| Update Location | `ulc` | `/customerRestservices/updateCustomerLocation` | POST |
| Validate Box Info | `vbinfo` | `validateBoxInfo` | POST |
| Dynamic Form Validations | `dyna` | `dynamicformvalidations` | POST |
| Get Countries | `count` | `getCountries` | POST |
| Get States | `stat` | `getStates` | POST |
| Get Districts | `dist` | `getdistricts` | POST |
| Get Cities | `cit` | `getCities` | POST |
| Get Mandals | `mand` | `getmandals` | POST |
| Get Locations of Mandal | `locselmand` | `getLocationsOfSelectedMandal` | POST |
| Get Customer Types | `gct` | `getCustomerTypes` | POST |
| Get Customer Type Types | `gctt` | `getcustomerTypeTypes` | POST |
| Get ID Types | `ids` | `getIds` | POST |
| Get Groups | `grp` | `getGroups` | POST |
| Get CAS Packages | `caspck` | `getCasPackages` | POST |

### 6.2 Complete Validation Rules to Implement in Flutter

| Rule | New Customer | Edit Customer | Condition |
|---|---|---|---|
| Customer Type required | Yes | No (pre-filled) | Always |
| CAF Number required | If `useCRF==1 && useCAF=="MANUAL"` | Min 2 chars always | Config |
| LCO Customer ID required | If `useCAF=="MANUAL"` OR `is_baid_mandatory=="1"` | If `is_baid_mandatory=="1"` and min 2 chars | Config + Dynamic |
| First Name required | Always | Always | Always |
| Last Name required | If `is_lastname_mandatory=="1"` | If `is_lastname_mandatory=="1"` | Dynamic |
| Account Number required | If `useAccountNumber==0` (alphanumeric, min 3 chars) | Min 2 chars always | Config |
| Address required | Both billing + installation Line 1 | Not validated on edit (only if checkbox changed) | Always |
| Mobile >= 10 digits | If `is_mobile_no_mandatory=="1"` | If `is_mobile_no_mandatory=="1"` | Dynamic |
| Pin Code >= 6 digits | Always | Not validated on edit | Always |
| Email format | If length > 0 AND `is_email_mandatory=="1"` | If length > 0 AND `is_email_mandatory=="1"` | Dynamic |
| Package required | Always | N/A (edit doesn't change package) | Always |
| Group required | Always | Not validated on edit | Always |
| ID Type required | If `is_id_type_mandatory=="1"` | Not validated on edit | Dynamic |
| ID Number required | If `is_id_number_mandatory=="1"` | Not validated on edit | Dynamic |
| Mandal required | If `is_mandal_id_mandatory=="1"` | Not validated on edit | Dynamic |
| City required | Always (if cityItemValue==0 and city=="Select") | Not validated on edit | Always |
| GPS/Location | Optional but button available | Required before save (`getLocation()` must return true) | Always on edit |

### 6.3 Config Flags to Fetch at Login and Store Globally

These are set during login and used throughout customer screens:

| Flag | Description |
|---|---|
| `useCRF` | CRF(0) vs CAF(1) labeling |
| `useCAF` | "AUTO" vs "MANUAL" CAF input |
| `useLastName` | Show/hide last name field |
| `useDiscount` | Discount field visibility level |
| `useAccountNumber` | Account number field visibility |
| `useMandatoryForHotel` | Customer type sub-type requirement |
| `freezecustomerparamsinapp` | Field locking (used in V2 screens) |
| `customerbilltype` | Bill type options |
| `defaultcountry` / `defaultstate` / `defaultdistrict` / `defaultcity` | Pre-selected address values |
| `int_bulk_payment` | Payment button visibility |
| `hidemakepayment` | Override for payment visibility |
| `int_stb_activation` / `int_stb_deactivation` / `int_stb_reactivation` | Box/Package operation visibility |
| `invoice_page_access` | Invoice history visibility |
| `payment_hist_page_access` | Payment history visibility |
| `access_for_complaints` | Complaint features visibility |
| `patch_information` | Feature gating by server version |
| `userType` | DEALER/ADMIN/EMPLOYEE/LCO — affects discount visibility |
| `dealerId` | Used in form validation and location update APIs |

### 6.4 Image Handling

Both create and edit screens support:
- **ID Photo**: Camera capture or gallery select, compressed JPEG at 70% quality, Base64 encoded
- **Customer Photo**: Camera capture or gallery select, compressed JPEG at 70% quality, Base64 encoded
- **Signature**: Captured via `CaptureSignature` activity, compressed JPEG at 70% quality, Base64 encoded

On edit screen, images are only sent if `upload_photo_chkbox` is checked.

### 6.5 Gender Mapping

| Display | Value (int) |
|---|---|
| Male | 1 |
| Female | 2 |

### 6.6 Date Type Mapping (for package activation)

| Activation Cycle String | `dateType` int |
|---|---|
| Month | 1 |
| Year | 2 |
| Day | 3 |
