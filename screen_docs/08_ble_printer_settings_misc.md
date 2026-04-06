# EzyBill Android - BLE Printer, Scanner, Signature, GPS/Maps, Settings & Misc
## Flutter Migration Reference Document

> **Source files analyzed:**
> - `activities_fragments/Bluetooth_Fragment.java`
> - `activities_fragments/DeviceListActivity.java`
> - `activities_fragments/PairedDeviceList.java`
> - `activities_fragments/ActivityDevice.java`
> - `activities_fragments/ConnectionDevice.java`
> - `BluetoothChatService.java`
> - `N910Util.java`
> - `activities_fragments/ScannerFrag.java`
> - `activities_fragments/CaptureSignature.java`
> - `activities_fragments/SignatureCapture_Fragment.java`
> - `activities_fragments/SignaturecaptureFrag.java`
> - `activities_fragments/MapsActivity.java`
> - `activities_fragments/MapActivity_Fragment.java`
> - `activities_fragments/MapsFragmentlocupdate.java`
> - `activities_fragments/Route.java`
> - `complexclasses/getEmployeeTrackInfo.java`
> - `complexclasses/employeeTrackInfoList.java`
> - `activities_fragments/AccountActivation.java`
> - `utils/EzyBillConstants.java`
> - `utils/EzybillApplication.java`
> - `utils/DetectSession.java`
> - `complexclasses/AppVersionCheckRequest.java`
> - `complexclasses/getServerIp.java`
> - `complexclasses/getServerTerminology.java`
> - `complexclasses/passwordChange.java`
> - `activities_fragments/LoginActivity.java` (partial, for session/URL context)

---

## Table of Contents

1. [BLE/Bluetooth Printer System](#1-blebluetooth-printer-system)
2. [Receipt Print Formats (Complete Layouts)](#2-receipt-print-formats-complete-layouts)
3. [Report Print Formats](#3-report-print-formats)
4. [Barcode Scanner](#4-barcode-scanner)
5. [Signature Capture](#5-signature-capture)
6. [GPS / Google Maps](#6-gps--google-maps)
7. [Employee Tracking](#7-employee-tracking)
8. [Payment Gateway Account Activation](#8-payment-gateway-account-activation)
9. [EzyBillConstants - All Constants Reference](#9-ezybillconstants---all-constants-reference)
10. [SharedPreferences - All Keys Reference](#10-sharedpreferences---all-keys-reference)
11. [Session Management & Auth Token](#11-session-management--auth-token)
12. [Application Class (EzybillApplication)](#12-application-class-ezybillapplication)
13. [DetectSession - Cross-Fragment Communication](#13-detectsession---cross-fragment-communication)
14. [App Version Check](#14-app-version-check)
15. [Server IP Configuration](#15-server-ip-configuration)
16. [SOAP Request Models (Complex Classes)](#16-soap-request-models-complex-classes)
17. [Flutter Migration Notes](#17-flutter-migration-notes)

---

## 1. BLE/Bluetooth Printer System

### 1.1 Architecture Overview

The Bluetooth printing system is built around four cooperating components:

| Component | Class | Role |
|-----------|-------|------|
| UI Fragment | `Bluetooth_Fragment` | Orchestrates device search, connection, and print button |
| Device Discovery | `DeviceListActivity` / `ActivityDevice` | Lists paired + discovered devices; returns MAC address |
| Paired-Only List | `PairedDeviceList` | Shows only bonded (already paired) devices |
| BLE Service | `BluetoothChatService` | Manages socket connection threads, writes receipt bytes |
| Hardware-specific | `N910Util` | Newland N910 POS device printer (separate SDK) |

### 1.2 Connection Flow (Step by Step)

```
User taps "Scan/Connect" button in Bluetooth_Fragment
        |
        v
Bluetooth_Fragment.searchBtDev()
        |
        v
Launch DeviceListActivity (startActivityForResult, REQUEST_CONNECT_DEVICE = 1)
        |
        +-- On open: read "mytextfile.txt" from app internal storage
        |       If file exists --> extract first 17 chars as MAC address
        |                      --> immediately return RESULT_OK with MAC (skip discovery)
        |       If file missing --> show alert: "No devices found, Connect to device"
        |                       --> "yes" button navigates back to MainActivity
        |
        +-- "Scan" button: calls doDiscovery()
        |       --> mBtAdapter.startDiscovery()
        |       --> BroadcastReceiver adds non-bonded devices to mNewDevicesArrayAdapter
        |       --> On ACTION_DISCOVERY_FINISHED: show "none found" if list empty
        |
        +-- User taps a device in the list:
                --> mBtAdapter.cancelDiscovery()
                --> Extract MAC: info.substring(info.length() - 17)   // last 17 chars
                --> Extract name: info.split("\n")[0]
                --> Build string: address + "@" + device_name
                --> Write to "mytextfile.txt" (internal storage, MODE_PRIVATE)
                --> Return RESULT_OK with MAC address in intent
                        extra key: "device_address"
```

### 1.3 Device Persistence (mytextfile.txt)

The selected printer device is persisted to an internal file `mytextfile.txt`:

- **Location:** `getApplicationContext().getFilesDir()` + `"mytextfile.txt"`
- **Content format:** `"<MAC_ADDRESS>@<DEVICE_NAME>"` (e.g., `"AA:BB:CC:DD:EE:FF@ANTHERMAL"`)
- **MAC address:** Always the first 17 characters of the file content
- **Reading:** `deva = s.substring(0, 17)` — MAC is characters 0..16
- **Writing:** `openFileOutput("mytextfile.txt", Context.MODE_PRIVATE)` — overwrites previous
- **Read block size constant:** `READ_BLOCK_SIZE = 100` chars per read cycle

**Flutter equivalent:** Use `path_provider` package with `getApplicationDocumentsDirectory()` and write a plain text file. Store as `"<MAC>@<NAME>"`.

### 1.4 BluetoothChatService Connection States

```dart
// State constants to replicate in Flutter
const int STATE_NONE = 0;       // Idle / not connected
const int STATE_LISTEN = 1;     // Listening (server mode, not used in practice)
const int STATE_CONNECTING = 2; // Attempting to connect
const int STATE_CONNECTED = 3;  // Connected and ready to print
```

**Handler messages sent from service to UI Fragment:**

| Message Code | Constant | Meaning |
|---|---|---|
| 1 | `MESSAGE_STATE_CHANGE` | Connection state changed; `msg.arg1` = new state |
| 4 | `MESSAGE_DEVICE_NAME` | Connected; device name in `msg.getData().getString("device_name")` |
| 5 | `MESSAGE_TOAST` | Error/info text in `msg.getData().getString("toast")` |

### 1.5 BluetoothChatService - Socket Implementation

**ConnectThread (outbound connection):**
- Uses `createInsecureRfcommSocket` via Java reflection on port/channel 1
- Method: `device.getClass().getMethod("createInsecureRfcommSocket", int.class).invoke(device, 1)`
- This bypasses UUID requirement — important note for Flutter `flutter_bluetooth_serial`
- Calls `mmSocket.connect()` (blocking)
- On success: spawns `ConnectedThread`
- On failure: calls `connectionFailed()` → sends `MESSAGE_TOAST` "Unable to connect device"

**ConnectedThread (data transmission):**
- Holds `OutputStream mmOutStream` from `socket.getOutputStream()`
- All print methods write raw bytes directly to this stream
- After each write: `mmOutStream.flush()` + `SystemClock.sleep(3000)` (3-second pause between pages)
- After printing: `mConnectedThread.cancel()` → closes socket

### 1.6 Font/Printer ESC Commands (ESC/POS)

`SetFonts()` initializes a `byte[][] bufLinear` array (indices 1–16):

```java
// ESC/POS font size commands used:
bufLinear[1]  = {0x1B, 0x4B, 0x00}  // smallest
bufLinear[2]  = {0x1B, 0x4B, 0x01}
// ... increments through ...
bufLinear[13] = {0x1B, 0x4B, 0x0C}  // header/footer font (used for receipt header)
bufLinear[15] = {0x1B, 0x4B, 0x0E}  // body font (used for field labels and values)
bufLinear[12] = {0x1B, 0x4B, 0x0B}  // line separator font
```

**Carriage return:** `byte[] cr = {0x0D}` — written after each text line in the legacy `write()` method.

**Note:** The newer `write2()`, `write1()`, and report methods use plain `String.getBytes()` without ESC font commands — pure text mode.

### 1.7 Printer Model Detection

All write methods detect the printer model by inspecting the first 5 characters of the connected device name:

| Device Name Prefix | Printer Model | Line Separator Width |
|---|---|---|
| `ANTHERMAL` (or full `"AT2TV"`) | AnThermal 58mm | 32 dots `"................................"` |
| `97BT-` | 97BT 80mm | 40 chars `"----------------------------------------"` |
| (anything else) | Generic/default | 32 dots `"................................"` |

```java
// Detection logic:
String connecteddevice = mConnectedDeviceName.substring(0, 5);
if (connecteddevice.equalsIgnoreCase("ANTHERMAL")) { /* 58mm */ }
else if (connecteddevice.equalsIgnoreCase("97BT-")) { /* 80mm */ }
else { /* default, same as 58mm */ }
```

### 1.8 PairedDeviceList Screen

**Purpose:** Standalone activity that shows only already-bonded (paired) Bluetooth devices without requiring new discovery.

**Entry parameters (Intent extras):**
| Extra Key | Type | Description |
|---|---|---|
| `"custID"` | int | Customer alternate ID |
| `"custName"` | String | Customer name |
| `"pendingamount"` | String | Pending amount string |
| `"amount"` | String | Payment amount |
| `"origin"` | String | Request origin screen |
| `"billingId"` | int | Billing ID |
| `"remarks"` | String | Payment remarks |
| `"mobile"` | String | Customer mobile number |
| `"cardtype"` | int | Card type (default 1) |

**On device selection:**
- Saves selected device MAC to `SharedPreferences`: pref file `"vidslogin"`, key `"bluetoothmac"`
- Navigates to `PaymentTransactionActivity` passing all the above extras forward

**Buttons:**
- `btn_settings`: Launches `Settings.ACTION_SETTINGS` (system settings)
- `btn_search`: Restarts the activity (refreshes device list)

### 1.9 ConnectionDevice Screen

**Purpose:** Intermediate screen in the payment-to-print flow. Validates PNSOl SDK account activation before allowing Bluetooth connection.

**Key behavior:**
- On `onResume()`: checks `new AccountValidator(context).isAccountActivated()`
- If NOT activated: redirects to `AccountActivation` activity
- If activated: shows customer info (name, pending amount, amount) and a "Connect" button
- "Connect" button navigates to `PairedDeviceList` passing all extras forward

**Data displayed:**
- Customer Name (`tv_CustomerName`)
- Pending Amount (`tv_PendingAmount`)
- Amount (`tv_Amount`)

### 1.10 N910Util (Newland N910 POS Printer)

**Purpose:** Utility singleton for the Newland N910 POS hardware device (a physical POS terminal, not a generic BT printer).

```java
// SDK: com.newland.me / com.newland.mtype
// Driver: "com.newland.me.K21Driver"
// Connection params: NS3ConnParams
```

**Key methods:**
- `getInstance(context)`: Singleton accessor
- `connectDevice()`: Initializes DeviceManager with K21 driver, calls `deviceManager.connect()`
- `isDeviceAlive()`: Returns `deviceManager.getDevice().isAlive()`
- `getPrinter()`: Returns `(Printer) device.getStandardModule(ModuleType.COMMON_PRINTER)` after `printer.init()`
- `disconnect()`: Runs `deviceManager.disconnect()` on a background thread

**Flutter note:** N910 is proprietary hardware with a Java SDK. Flutter migration should use a method channel to call Android native code if N910 hardware support is required, OR use a different ESC/POS library for generic BT thermal printers.

### 1.11 Print Mode Codes (offline_report field)

`Bluetooth_Fragment` receives an `offline_report` integer from its arguments bundle that determines which print format to use:

| `offline_report` value | Print Format Called | Data Source |
|---|---|---|
| 4 | Payment Receipt (`DEFAULT` → `sendMessage2`, `FORMAT1` → `sendMessage1`) | Single customer payment |
| 2 | Employee collection report (`write_reports`) | `ArrayList<Empcustomercollection>` |
| 3 | Mini-day report (`write_minidayonline`) | `ArrayList<Minidayresult>` |
| 5 | Collection report (`write_onlinee`) | `ArrayList<collectionResult>` |
| 7 | Service/packages report (`write_services`) | `ArrayList<ShowPackages>` |
| 8 | Invoice history detail (`Invoicehistorydetail_write`) | Invoice fields |
| 9 | Payment history detail (`Paymenthistdetail_write`) | Payment history fields |

---

## 2. Receipt Print Formats (Complete Layouts)

### 2.1 DEFAULT Payment Receipt (`write2()`)

**Trigger:** `offline_report == 4` AND `str_format.equals("DEFAULT")` (or anything not "FORMAT1")

**Parameters:** `mConnectedDeviceName, custName, custId, mobileNo, custAdd, receiptNo, billAmt, paidAmt, dueAmt`

#### 97BT- (80mm) Layout:
```
----------------------------------------
              PAYMENT RECEIPT
----------------------------------------
       DDD MMM DD YYYY HH:MM:SS
----------------------------------------
CUSTOMER NAME    :<custName>
Customer ID      :<custId>
MOBILE no.       :<mobileNo>
CUSTOMER ADDRESS :<custAdd>
RECEIPT NUMBER   :<receiptNo>
BILL.AMT         :<billAmt>
PAID.AMT         :<paidAmt>
----------------------------------------



```
*(3 blank lines at end for paper feed)*

#### Default/Generic (58mm) Layout:
```
--------------------------------
         PAYMENT RECEIPT
--------------------------------
DDD MMM DD YYYY HH:MM:SS
--------------------------------
CUSTOMER NAME    :<custName>
Customer ID      :<custId>
MOBILE no.       :<mobileNo>
CUSTOMER ADDRESS :<custAdd>
RECEIPT NUMBER   :<receiptNo>
BILL.AMT         :<billAmt>
PAID.AMT         :<paidAmt>
--------------------------------



```

**Date format:** Java `Calendar.getInstance().getTime().toString()` split by spaces:
- `Datesttings[0]` = Day name (e.g., "Mon")
- `Datesttings[1]` = Month (e.g., "Mar")
- `Datesttings[2]` = Day (e.g., "26")
- `Datesttings[3]` = Time (e.g., "10:30:00")
- `Datesttings[5]` = Year (e.g., "2026")
- Formatted as: `"DDD MMM DD YYYY HH:MM:SS"` (97BT adds 7 spaces prefix)

**Write timing:** `sleep(1000)` → write → `sleep(1000)` → flush → `sleep(3000)`

### 2.2 FORMAT1 Payment Receipt - Cheque (`write1()`)

**Trigger:** `offline_report == 4` AND `str_format.equals("FORMAT1")`

**Parameters:** `mConnectedDeviceName, custName, custId, mobileNo, custAdd, receiptNo, billAmt, dueAmt, paidAmt, cheque, bankname, str_branch`

**Extra fields vs DEFAULT:**
```
CHEQUE NO.       :<cheque>
BANK NAME        :<bankname>
BRANCH           :<branch>
```
(All other fields identical to DEFAULT format.)

**Line separator:** `"--------------------------------"` (32 chars, NOT dots)

### 2.3 Legacy Payment Receipt (`write()`) — ESC/POS version

**Parameters:** `custName, custId, mobileNo, custAdd, receiptNo, billAmt, dueAmt, paidAmt, outAmt`

Uses ESC font commands (bufLinear bytes) before each field. Layout:

```
[bufLinear[13]] "         PAYMENT RECEIPT"
[CR]
[bufLinear[12]] "------------------------------------------------"
[bufLinear[13]] "<DDD MMM DD YYYY HH:MM:SS>"
[CR]
[bufLinear[12]] "------------------------------------------------"
[bufLinear[15]] "CUSTOMER NAME:<custName>"
[CR]
[bufLinear[15]] "CUSTOMER NUMBER:<custId>"
[CR]
[bufLinear[15]] "CUSTOMER ADDRESS:<custAdd>"
[CR]
[bufLinear[15]] "RECEIPT NUMBER:<receiptNo>"
[CR]
[bufLinear[12]] "------------------------------------------------"
[bufLinear[15]] "TOT.DUE.AMT:<dueAmt>"
[CR]
[bufLinear[15]] "PAID.AMT   :<paidAmt>"
[CR]
[bufLinear[12]] "------------------------------------------------"
[bufLinear[15]] "O/S.AMT    :<outAmt>"
[CR]
[bufLinear[12]] "------------------------------------------------"
[bufLinear[13]] "           POWERED BY"
[bufLinear[2]]  "      EZYBILL"
[CR][CR][CR]
```

**Line separator width:** 48 chars `"------------------------------------------------"`

**Note:** `BILL.AMT` field is commented out in source code. `outAmt` (outstanding amount) is only in this legacy format.

### 2.4 Payment History Receipt (`PaymentHistory_write()`)

**Parameters:** `mConnectedDeviceName, pcustname, pdate, pid, pmode, pamount, prno, prmks`

#### ANTHERMAL / AT2TV / 97BT- / Generic Layout:
```
................................  (or ---...--- for 97BT)
        PAYMENT HISTORY
................................
DDD MMM DD YYYY HH:MM:SS
................................
CUSTOMER NAME    :<pcustname>
PAYMENT DATE     :<pdate>
PAYMENT ID       :<pid>
PAYMENT MODE     :<pmode>
AMOUNT           :<pamount>
RECEIPT NO       :<prno>
REMARKS          :<prmks>
................................



```
*(Device detection: `ANTHERMAL` and `AT2TV` share same format; `97BT-` uses 40-char dashes)*

### 2.5 Invoice History Receipt (`InvoiceHistory_write()`)

**Parameters:** `mConnectedDeviceName, invcustName, invoicenumber, invdate, invduedate, invbaseprice, invsetupprice, invtaxamt, invpendamt, invdiscamt, invttlamt, invisadhoc`

#### Layout (all printer types):
```
................................
        INVOICE HISTORY
................................
DDD MMM DD YYYY HH:MM:SS
................................
CUSTOMER NAME    :<invcustName>
INVOICE NO.      :<invoicenumber>
INVOICE DATE     :<invdate>
DUE DATE         :<invduedate>
BASE PRICE       :<invbaseprice>
SET UP PRICE     :<invsetupprice>
TAX AMOUNT       :<invtaxamt>
PENDING AMOUNT   :<invpendamt>
DISCOUNT AMOUNT  :<invdiscamt>
TOTAL AMOUNT     :<invttlamt>
ADHOC BILLS      :<invisadhoc>
................................



```

---

## 3. Report Print Formats

### 3.1 Employee Collection Report (`write_reports()`)

**Parameters:** `mConnectedDeviceName, totalCount, custName, custId, paidAmt (double), paymentMode, status`

**Column layout (one row per record):**
```
<custId padded-left 12><paidAmt padded-left 15><paymentMode padded-left 10>\n
```

**Full receipt (ANTHERMAL/Generic):**
```
................................
        REPORTS
................................
DDD MMM DD YYYY HH:MM:SS
................................
ID          AMOUNT         MODE
................................
<row1>
<row2>
...
................................


```

**Pagination logic:** If `totalCount > 15`, prints in batches of 15 rows (flushes + `sleep(3000)` every 15), with a final page for the remainder. If `totalCount <= 15`, prints all at once.

**String formatting utility:**
- `EzyBillConstants.fixedLengthString_leftalign(str, n)` → `String.format("%-ns", str)` (left-pad with spaces to width n)
- `EzyBillConstants.fixedLengthString_Rightalign(str, n)` → `String.format("%n.ns", str)` (right-align, truncate to n)
- `EzyBillConstants.fixedLengthString(str, n)` → `String.format("%1$ns", str)` (right-pad)

### 3.2 Collection Report (`write_reportscollection()`)

**Parameters:** `mConnectedDeviceName, index, serialNo, name, amount (double), totalCount`

**Column layout:**
```
<sno padded-left 8><name padded-left 12><amount right-aligned 10>\n
```

**Header:**
```
      COLLECTION  REPORT
...
S.NO    NAME                AMOUNT
```
*(97BT header: `"S.NO    NAME            AMOUNT"` — narrower)*

**Footer (on last record):**
```
................................
TOTAL AMOUNT             <totalAmt right-10>
................................


```

### 3.3 Miniday Report (`write_miniday_reports()`)

**Parameters:** `mConnectedDeviceName, index, mode, custCount (int), amount (double), totalCount`

**Column layout:**
```
<mode padded-left 8><custCount padded-left 12><amount right-aligned 10>\n
```

**Header:**
```
      MINIDAY  REPORT
...
MODE    COUNT            AMOUNT
```

**Footer:** Same pattern as Collection Report with `TOTAL AMOUNT`.

### 3.4 Services/Packages Report (`write_servicesreports()`)

**Parameters:** `mConnectedDeviceName, index, packageName, startDate, endDate, amount (double), totalCount`

**Column layout:**
```
<name padded-left 12><startDate right-1>\n<endDate right-1><amount right-aligned 10>\n
```

**Header:**
```
          ACTIVATED PACKAGES
...
Name       Start & End Date            Amount
```

---

## 4. Barcode Scanner

### 4.1 Screen Identity

- **Class:** `ScannerFrag` (Fragment)
- **Title:** Not explicitly set (inherits parent activity title)
- **Purpose:** Scan a barcode (box number / STB number) to search for a customer

### 4.2 Scanner Technology

- **Library:** Google Mobile Vision API (`com.google.android.gms.vision`)
  - `BarcodeDetector.Builder` with `Barcode.ALL_FORMATS` (supports all barcode types)
  - `CameraSource` at 1920x1080 preview resolution with auto-focus
- **Camera permission:** `Manifest.permission.CAMERA` (runtime check, request code 201)
- **Camera lifecycle:**
  - `onPause()` → `cameraSource.release()`
  - `onResume()` → re-initializes detector and source

### 4.3 Scan Flow

```
Fragment opens
    |
    v
initialiseDetectorsAndSources()
    - Creates BarcodeDetector (ALL_FORMATS)
    - Creates CameraSource (1920x1080, autofocus)
    - surfaceCreated → cameraSource.start()
    - barcodeDetector.setProcessor:
        receiveDetections() → reads barcodes.valueAt(0).displayValue
                           → updates txtBarcodeValue text
                           → stores in `intentData` variable
    |
    v
User taps "Search" button (btnAction)
    - Checks intentData.length() > 0
    - Calls new GetCustomersListCount().execute()
```

### 4.4 API Call from Scanner

**AsyncTask:** `GetCustomersListCount`

- **Protocol:** SOAP (ksoap2)
- **SOAP Action:** `NAMESPACE + "/" + PropertyReader.getProperty("scount", context)`
- **Method name:** `PropertyReader.getProperty("scount", context)` (from properties file)
- **URL:** `LoginActivity.URL` (loaded from SharedPreferences at login)
- **Timeout:** 300,000 ms (5 minutes)

**Request object:** `getCustomerDetailsCount`
```java
count.authToken = LoginActivity.authToken;
count.customerNumber = "";   // empty (scanner mode)
count.customerName = "";     // empty
count.mobileNumber = "";     // empty
count.boxNumber = intentData; // ← the scanned barcode value
count.lcoCustomerId = "";    // empty
```

**Response parsing:**
```java
statusCode   = parseInt(response, "statusCode=")
statusMessage = parseString(response, "statusMessage=")
// On statusCode == 0:
cust_totalListCount = parseInt(response, "customerCount=")
```

**Navigation after successful scan:**
- If `cust_totalListCount >= 10000`: shows warning dialog (too many results)
- Else: navigates to `CustomerSearchList_Fragment` with bundle:
  ```
  count       = cust_totalListCount (String)
  custNo      = ""
  custName    = ""
  mobileNo    = ""
  boxNo       = intentData   ← scanned value
  lcoCustomerId = ""
  reqOrigin   = request_origin
  ```

### 4.5 Scanner Input Parameters

- **Origin:** `getArguments().getString("origin")` — passed from calling screen, forwarded to `CustomerSearchList_Fragment` as `"reqOrigin"` to track which screen launched the scanner.

### 4.6 Flutter Migration Notes for Scanner

Use the `mobile_scanner` or `flutter_barcode_scanner` package. Key points:
- Support ALL barcode formats (same as Android `Barcode.ALL_FORMATS`)
- The scanned value maps to `boxNumber` in the customer search SOAP request
- Use the REST API equivalent of `getCustomerDetailsCount` (check REST doc for `scount` endpoint)

---

## 5. Signature Capture

Three separate implementations exist in the codebase. They serve different use cases.

### 5.1 CaptureSignature (Activity — Customer Signature for New Customer)

- **Class:** `CaptureSignature` (AppCompatActivity)
- **Layout:** `R.layout.signature`
- **Canvas size:** Fixed 720×480 dp (added to LinearLayout with explicit dimensions)
- **Bitmap size:** 600×320 px, `Bitmap.Config.RGB_565`
- **Stroke width:** `5f` px, anti-aliased, black, `Paint.Style.STROKE`, round joins

**Buttons:**
| Button | ID | Behavior |
|---|---|---|
| Clear | `R.id.clear` | Resets path, disables Save button |
| Get Sign | `R.id.getsign` | Initially disabled; enabled on first touch event |
| Cancel | `R.id.cancel` | `setResult(RESULT_CANCELED)`, finish |

**Save flow:**
1. User touches screen → `mGetSign.setEnabled(true)`
2. User taps "Get Sign" → `captureSignature()` (currently always returns `false` = no error)
3. `mView.setDrawingCacheEnabled(true)` → `mSignature.save(mView)`
4. In `save()`: creates 600×320 bitmap → draws view onto canvas → `intent.putExtra("BitmapImage", mBitmap)` → `setResult(RESULT_OK, intent)` → finish
5. **Return value:** Bitmap object in intent extra `"BitmapImage"` (Parcelable)

**Back button:** Sets `RESULT_CANCELED`, finishes.

**Flutter equivalent:** Use `CustomPainter` with `GestureDetector`. Capture via `ui.Image` (from `dart:ui`). Return as bytes or file path rather than a Parcel.

### 5.2 SignatureCapture_Fragment (Payment Gateway Signature — ICC/Chip Card)

- **Class:** `SignatureCapture_Fragment` (Fragment) — implements `PaymentTransactionConstants` (PNSOl SDK)
- **Purpose:** Capture customer signature after an ICC (chip card) transaction, then submit to the payment gateway SDK
- **Canvas:** `MATCH_PARENT × MATCH_PARENT` inside a LinearLayout

**Input arguments:**
| Key | Type | Description |
|---|---|---|
| `"vo"` | Serializable (`ICCTransactionResponse`) | ICC transaction response from PNSOl SDK |
| `"paymentType"` | String | Payment type string |

**Save flow:**
1. `mSignature.save(signatureCapture)` — draws to bitmap (note: file save code is commented out in this version)
2. Reads bitmap from file: `BitmapFactory.decodeFile(filesDir + "/signature.bmp")`
3. Calls: `PaymentInitialization.initiateSignatureCapture(handler, referenceNumber, bitmapBytes)`
4. `UtilManager.convertBitmapToByteArray(bitmap)` — converts bitmap to byte array for SDK

**Handler response:**
- `SUCCESS` → navigates to `TransactionDetails_Frag_payswiff` with ICC response
- `FAIL` → shows toast "fail message"
- `ERROR_MESSAGE` → shows toast with error

**Signature file constant:** `public static final String SIGNATURE = "/signature.bmp"` (path appended to `filesDir`)

### 5.3 SignaturecaptureFrag (Payment Gateway Signature — TransactionVO)

- **Class:** `SignaturecaptureFrag` (Fragment) — implements `PaymentTransactionConstants`
- **Purpose:** Capture signature for PNSOl SDK `TransactionVO` payment type
- **Canvas:** `MATCH_PARENT × MATCH_PARENT`

**Input arguments:**
| Key | Type | Description |
|---|---|---|
| `"vo"` | Serializable (`TransactionVO`) | PNSOl transaction value object |
| `"custID"` | int | Customer ID |
| `"custName"` | String | Customer name |
| `"pendingamount"` | String | Pending amount |
| `"amount"` | String | Payment amount |
| `"billingId"` | int | Billing ID |

**Save flow (fully implemented):**
1. `mSignature.save(view)` — creates bitmap from `signatureCapture` layout dimensions
2. Opens `FileOutputStream` with `openFileOutput("signature.bmp", Context.MODE_PRIVATE)`
3. Draws view onto canvas: `v.draw(canvas)`
4. Compresses to PNG at quality 45: `bitmap.compress(Bitmap.CompressFormat.PNG, 45, fos)`
5. Saves to internal storage file `"signature.bmp"`
6. `PaymentInitialization` processes the saved file (incomplete in source — `bitmap != null` check commented out)

**Handler response:**
- `SUCCESS` → navigates to `Transacdetailfrag` with transaction data, message "TRANSACTION APPROVED"
- Fail → toast "Fail"

**Screen also shows:** Merchant name (`vo.getMerchantName()`), window flag `FLAG_KEEP_SCREEN_ON`

**Signature file path:**
```java
// Written to:
getContext().openFileOutput("signature.bmp", Context.MODE_PRIVATE)

// Read from:
getContext().getFilesDir().getPath() + "/signature.bmp"
```

### 5.4 Common Signature Drawing Logic

All three implementations use identical touch-event based drawing:

```
ACTION_DOWN  → path.moveTo(x, y); save lastTouchX, lastTouchY
ACTION_MOVE  → for each historical point: expandDirtyRect, path.lineTo
             → path.lineTo(eventX, eventY)
             → save.setEnabled(true)   (enables save only after actual draw)
             → invalidate dirty rect
ACTION_UP    → same as MOVE in CaptureSignature
             → break (no path draw) in SignatureCapture_Fragment / SignaturecaptureFrag
```

**Dirty rect pattern** (for efficient invalidation):
- `dirtyRect.left = min(lastX, eventX)`; `right = max(lastX, eventX)`
- `dirtyRect.top = min(lastY, eventY)`; `bottom = max(lastY, eventY)`
- Invalidate with `HALF_STROKE_WIDTH` (2.5px) padding on all sides

---

## 6. GPS / Google Maps

### 6.1 MapsActivity (Employee Collection Map View)

- **Class:** `MapsActivity` (AppCompatActivity) — implements `OnMapReadyCallback`
- **Purpose:** Display map pins for all customer locations collected by an employee in a report, connected by a red polyline route

**Input:** Intent extra `"empcollection_reports"` → `ArrayList<EmpCollection_ResponseModel>`

**Marker title format:**
```java
customer_name + " - " + paid_amount + " - " + alt_custom_number
```

**Filtering:** Skips records where latitude or longitude is `"null"`, empty, or `"0.0"`

**Map setup:**
- Camera: `zoom = 18`, positioned at last valid lat/lng in the list
- Polyline: connects all location points, `width = 12`, `color = Color.RED`, `geodesic = true`
- Markers: standard pins at each location

**Flutter equivalent:** Use `google_maps_flutter` package. Build `Marker` and `Polyline` collections from the same data.

### 6.2 MapActivity_Fragment (Employee Track Info — Date Range Query)

- **Class:** `MapActivity_Fragment` (Fragment, uses deprecated `android.app.Fragment`)
- **Purpose:** Query employee GPS track data for a date range and display the route on a map

**SOAP API call:**
- **Method:** `getEmployeeTrackInfo`
- **SOAP Action:** `EzyBillConstants.NAMESPACE + "/getEmployeeTrackInfo"`
- **URL:** `LoginActivity.URL`
- **Timeout:** 30,000 ms

**Request model:** `getEmployeeTrackInfo`
```java
trackInfo.authToken  = LoginActivity.authToken
trackInfo.startDate  = Date (parsed from "yyyy/MM/dd HH:mm:ss" format)
trackInfo.endDate    = Date
trackInfo.employeeId = int (from EditText input)
```

**Date format displayed:** `"d-M-yyyy"` (e.g., "26-3-2026")
**Date format sent to API:** `"yyyy-M-d "` (e.g., "2026-3-26 ")

**Date validation:** Start date must not be after today's date. Uses `SimpleDateFormat("yyyy-MM-dd")`.

**Response parsing:**
Iterates `SoapObject` properties named `"employeeTrackInfoList"`, extracts:
```
empListObj.latitude  = substring after "latitude="  until next ";"
empListObj.longitude = substring after "longitude=" until next ";"
empListObj.date_time = substring after "date_time=" until next ";"
```

**Navigation on success:** Launches `Route` activity with `"array"` extra containing `ArrayList<employeeTrackInfoList>` (Serializable).

**Input fields on screen:**
- `editEmployeeid` (EditText): employee ID (integer)
- `btnChangeStartDate` (Button): DatePickerDialog
- `btnChangeEndDate` (Button): DatePickerDialog

### 6.3 Route (Employee Track Route with Google Directions)

- **Class:** `Route` (FragmentActivity) — implements `OnMapReadyCallback`
- **Purpose:** Display employee track points and draw driving route using Google Directions API

**Input:** `getIntent().getSerializableExtra("array")` → `List<employeeTrackInfoList>`

**Map behavior:**
- Loads all lat/lng points from the list
- First point: green marker, title "My Position"
- Subsequent points: azure markers, title "My Position{n}"
- Between consecutive points: calls Google Directions API to get polyline route

**Google Directions API URL format:**
```
https://maps.googleapis.com/maps/api/directions/json?
  origin=<lat>,<lng>&
  destination=<lat>,<lng>&
  sensor=false&
  waypoints=<lat1>,<lng1>|<lat2>,<lng2>|...
```

**Response parsing:** Uses `DirectionsJSONParser` class (custom) to parse the JSON. Draws polyline in `Color.BLUE`, `width = 3`.

**Camera:** `moveCamera(newLatLngZoom(userposition, 13))` — zoom level 13 for each point update.

**GPS tracker:** `new GPSTracker(this)` (custom class for current location — not used in map display here).

### 6.4 MapsFragmentlocupdate (Customer Location Update)

- **Class:** `MapsFragmentlocupdate` (Fragment)
- **Purpose:** Show current device GPS location on map and update a customer's registered location to current coordinates

**GPS location source:** `GPSTracker` (custom class wrapping LocationManager)
```java
gpsTracker = new GPSTracker(getContext());
if (gpsTracker.canGetLocation()) {
    lat = gpsTracker.getLatitude();
    lang = gpsTracker.getLongitude();
} else {
    lat = 0.0; lang = 0.0;
}
```

**Live location updates:** Also uses `GoogleApiClient` + `FusedLocationApi` (deprecated but present):
- `LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY`
- Updates current marker and camera position as device moves

**Geocoder:** Reverse geocodes the GPS tracker location (not displayed, available for address display)

**Input arguments:**
| Key | Type | Description |
|---|---|---|
| `"altCustId"` | int | Customer ID to update |
| `"custName"` | String | Customer name |
| `"cafNo"` | String | CAF number |
| `"mobileNO"` | String | Mobile number (default "NA") |
| `"reseller_id"` | int | Reseller ID |
| `"status"` | int | Customer status |
| `"billAdd"` | String | Billing address |
| `"instAdd"` | String | Installation address |
| `"account_number"` | String | Account number |
| `"pinCode"` | int | Pin code |
| `"pending_amount"` | double | Pending amount |
| `"online"` | int | Online flag |
| `"addservice"` | int | Add service flag |
| `"lati"` | String | Current customer latitude |
| `"longi"` | String | Current customer longitude |
| `"userans"` | String | User answer/notes (default "NA") |

**Location Update REST API Call:**

- **URL:** `LoginActivity.URL.replace("/wsController","") + "/LcoRestServices/updateCustomerLocation"`
- **Method:** `POST` (Volley `StringRequest`)
- **Timeout:** 100,000 ms

**POST parameters:**
```
authtoken   = LoginActivity.authToken
dealer_id   = LoginActivity.dealerId (int as String)
latitude    = lat (double as String — device GPS latitude)
longitude   = lang (double as String — device GPS longitude)
customer_id = altCustId (int as String)
```

**Response:**
```json
{ "status_code": 0, "status_msg": "..." }
```
- `status_code == 0` → success toast: `"Location updated successfully\nCustomername: <name>\nCaf No.: <cafNo>\nRemarks: <userans>"` → `popBackStack()`
- `status_code == 1` → alert dialog "No records!"
- `status_code == 2` → toast with status message + ": Contact Support"

**Confirmation dialog before sending:** Shows customer name, LCO cust ID, CAF No, address before confirming location update.

**Map type:** `GoogleMap.MAP_TYPE_NORMAL`

**Current location marker:** Magenta pin, title "Current Position", snippet = LatLng string, shown with info window. Camera: `zoom = 18`.

**Permissions required:** `ACCESS_FINE_LOCATION` (runtime, request code 99)

---

## 7. Employee Tracking

### 7.1 getEmployeeTrackInfo (SOAP Request Model)

```java
// KvmSerializable SOAP complex type
public String authToken;  // property 0 (STRING)
public Date startDate;    // property 1 (STRING)
public Date endDate;      // property 2 (STRING)
public int employeeId;    // property 3 (INTEGER)
```

**Property names in SOAP envelope:**
- `"authToken"` (String)
- `"startDate"` (String)
- `"endDate"` (String)
- `"employeeId"` (Integer)

### 7.2 employeeTrackInfoList (SOAP Response Model)

```java
// KvmSerializable SOAP complex type (response list item)
public String latitude;   // property 0 (STRING)
public String longitude;  // property 1 (STRING)
public String date_time;  // property 2 (STRING)
```

**Parsed from response string:**
```java
latitude  = after "latitude="  → before next ";"
longitude = after "longitude=" → before next ";"
date_time = after "date_time=" → before next ";"
```

**Flutter/REST equivalent:** The REST API V2 document should have a `getEmployeeTrackInfo` equivalent endpoint. Use that REST endpoint instead of SOAP. Response will contain the same fields.

---

## 8. Payment Gateway Account Activation

### 8.1 AccountActivation Screen

- **Class:** `AccountActivation` (AppCompatActivity) — implements `PaymentTransactionConstants`
- **Purpose:** Activate the PNSOl payment SDK with a merchant key before allowing card payment processing

**Layout:** `R.layout.activation`
- `EditText edit_marchantkey` — 12-character merchant key input
- `Button btn_avtivation` — triggers activation

**Partner API Key (hardcoded constant):**
```java
// From EzyBillConstants:
public static final String PARTNER_KEY = "724BF3E4A636";  // Live key
// Testing key (commented out): "2016665A802D"
```

**Activation logic:**
```java
String mkey = edit_marchantkey.getText().toString();
if (mkey.length() == 12) {
    AccountValidator validator = new AccountValidator(context);
    validator.accountActivation(handler, mkey, partnerAPIKey);
} else {
    // Toast: "Enter the 12 characters key"
}
```

**Handler responses (from PNSOl SDK):**
- `SUCCESS` → navigate to `ConnectionDevice` → `PairedDeviceList` → `PaymentTransactionActivity`
- `FAIL` → show failure message

**Check (in ConnectionDevice):**
```java
if (!new AccountValidator(context).isAccountActivated()) {
    // Redirect to AccountActivation
}
```

**Input extras received:**
| Extra Key | Type | Description |
|---|---|---|
| `"custID"` | int | Customer ID |
| `"billingId"` | int | Billing ID |
| `"custName"` | String | Customer name |
| `"pendingamount"` | String | Pending amount |
| `"amount"` | String | Payment amount |
| `"origin"` | String | Origin screen |

**Flutter note:** The PNSOl SDK is an Android-only library. If card payment via PNSOl is needed in Flutter, implement via a method channel. If migrating to a different payment gateway, replace with Razorpay/PayU Flutter SDK.

---

## 9. EzyBillConstants - All Constants Reference

**File:** `utils/EzyBillConstants.java`

```java
// SOAP namespace (empty string — methods are called without namespace prefix)
public static final String NAMESPACE = "";

// BMS (Billing Management System) namespace — obfuscated hex string, decoded via Decryptions.decryptions1()
// Points to the version-check / BMS service base URL
public static final String NAMESPACE_BMS = "742143..."; // (hex-encoded live URL)

// PNSOl Payment SDK Partner Keys
public static final String PARTNER_KEY = "724BF3E4A636";  // LIVE key
// Testing: "2016665A802D"

// SharedPreferences keys (critical for Flutter migration — see Section 10)
public static final String SMSKEY       = "smsKey";
public static final String BMSAUTH      = "bmsAuth";
public static final String BMS_SHARED_PREF   = "bmsSharedPref";
public static final String LOGIN_URL         = "login_url";
public static final String EMP_ID            = "emp_id";
public static final String APP_THEME_COLOR   = "appThemeColor";
public static final String APP_DASHBOARD     = "appDashboard";
public static final String ENABLE_AADHAAR    = "enableAadhar";
public static final String APP_LOGO_PATH     = "appLogoPath";

// Currency sign (resolved at runtime from LoginActivity.CURRENCY_CODE)
public static final String RUPEES_SIGN = LoginActivity.CURRENCY_CODE; // default "₹"
```

**String formatting utilities:**
```java
// Left-align (pad right with spaces to width n):
fixedLengthString_leftalign(str, n)  → String.format("%-ns", str)

// Right-align (right-justify to width n, truncate to n chars):
fixedLengthString_Rightalign(str, n) → String.format("%n.ns", str)

// Right-justify (pad left with spaces to width n):
fixedLengthString(str, n)            → String.format("%1$ns", str)
```

**Logout utility:**
```java
EzyBillConstants.alertforLogout(context)
// Shows dialog: "Press 'Logout' to close the application."
// On confirm: Intent to LoginActivity with FLAG_ACTIVITY_CLEAR_TOP | FLAG_ACTIVITY_NEW_TASK
//             + putExtra("EXIT", true)
```

---

## 10. SharedPreferences - All Keys Reference

### 10.1 SharedPreferences File: `"bmsSharedPref"` (EzyBillConstants.BMS_SHARED_PREF)

This is the primary configuration preferences file, loaded at login time.

| Key Constant | Key String | Type | Value Description |
|---|---|---|---|
| `EzyBillConstants.LOGIN_URL` | `"login_url"` | String | Full SOAP endpoint URL (e.g., `http://host:port/wsController`) |
| `EzyBillConstants.EMP_ID` | `"emp_id"` | String | Employee ID (stored as string, parsed to int on read) |
| `EzyBillConstants.APP_THEME_COLOR` | `"appThemeColor"` | int | Theme: 1=Default, 2=Red, 3=Green, 4=Blue, 5=Purple |
| `EzyBillConstants.APP_DASHBOARD` | `"appDashboard"` | int | Dashboard layout type |
| `EzyBillConstants.ENABLE_AADHAAR` | `"enableAadhar"` | int | Aadhaar feature flag (0=off, 1=on) |
| `EzyBillConstants.APP_LOGO_PATH` | `"appLogoPath"` | String | URL path to app logo image |
| `EzyBillConstants.SMSKEY` | `"smsKey"` | String | SMS gateway key |
| `EzyBillConstants.BMSAUTH` | `"bmsAuth"` | String | BMS auth token |

**Written by:** `ACT_LoginActivity` / `CloudAuthentication` after successful `getServerIp` SOAP response.

**Read by:** `LoginActivity.onCreate()` at lines 254–259:
```java
authSharedPreferences = getSharedPreferences(EzyBillConstants.BMS_SHARED_PREF, 0);
APP_THEME    = authSharedPreferences.getInt(EzyBillConstants.APP_THEME_COLOR, 1);
employeeId   = Integer.parseInt(authSharedPreferences.getString(EzyBillConstants.EMP_ID, "0"));
URL          = authSharedPreferences.getString(EzyBillConstants.LOGIN_URL, "");
logo_img     = authSharedPreferences.getString(EzyBillConstants.APP_LOGO_PATH, "");
APP_DASHBOARD = authSharedPreferences.getInt(EzyBillConstants.APP_DASHBOARD, 1);
ENABLE_AADHAAR = authSharedPreferences.getInt(EzyBillConstants.ENABLE_AADHAAR, 0);
```

### 10.2 SharedPreferences File: `"vidslogin"` (SPF_NAME in LoginActivity/PairedDeviceList)

| Key String | Type | Value Description |
|---|---|---|
| `"username"` | String | Saved login username (written if "Remember Me" is checked) |
| `"bluetoothmac"` | String | Last selected Bluetooth printer MAC address (17 chars, e.g., `"AA:BB:CC:DD:EE:FF"`) |

**Note:** `"bluetoothmac"` is written by `PairedDeviceList` when a BT device is selected. The same MAC is also stored in `"mytextfile.txt"` (internal file storage) — there is duplication between the file and this SharedPreferences key.

### 10.3 SharedPreferences File: `"aadhaardetails"`

| Key String | Type | Value Description |
|---|---|---|
| (various) | mixed | Aadhaar-related configuration (read at login) |

### 10.4 Flutter Migration: SharedPreferences Mapping

Use the `shared_preferences` Flutter package. Map all keys exactly:

```dart
// Package: shared_preferences
const String BMS_SHARED_PREF = 'bmsSharedPref';
const String LOGIN_URL       = 'login_url';
const String EMP_ID          = 'emp_id';
const String APP_THEME_COLOR = 'appThemeColor';
const String APP_DASHBOARD   = 'appDashboard';
const String ENABLE_AADHAAR  = 'enableAadhar';  // note: typo preserved from Android
const String APP_LOGO_PATH   = 'appLogoPath';
const String SMSKEY          = 'smsKey';
const String BMSAUTH         = 'bmsAuth';

// vidslogin prefs
const String VIDS_PREFS      = 'vidslogin';
const String USERNAME        = 'username';
const String BLUETOOTH_MAC   = 'bluetoothmac';

// Internal file (mytextfile.txt) — store in:
// path_provider: getApplicationDocumentsDirectory() + '/mytextfile.txt'
```

---

## 11. Session Management & Auth Token

### 11.1 Auth Token Storage

The auth token is stored as a **static in-memory variable** in `LoginActivity`:

```java
public static String authToken;  // LoginActivity.authToken
```

This means:
- The token is **not persisted** to SharedPreferences or disk
- If the app process is killed, the token is lost and the user must log in again
- All SOAP/REST calls access it as `LoginActivity.authToken`
- BT fragment, scanner, maps, etc. all reference `LoginActivity.authToken` directly

**Flutter equivalent:** Store auth token in memory via a singleton service or riverpod/bloc state. For persistence across app restarts, use `flutter_secure_storage`.

### 11.2 Other Static Session Variables (in LoginActivity)

These are all in-memory statics, accessible globally throughout the app:

```java
public static String authToken;           // JWT/session token from server
public static String user;                // username
public static String business_name;       // Business/LCO name
public static int dealerId;               // Dealer/LCO ID
public static int employeeId;             // Current employee ID
public static String userType;            // User role type
public static String CURRENCY_CODE = "₹"; // Currency symbol
public static String URL = "";            // SOAP server URL (loaded from SharedPrefs)
public static int APP_THEME = 1;          // 1-5 theme selection
public static int APP_DASHBOARD = 1;      // Dashboard type
public static int ENABLE_AADHAAR = 0;     // Aadhaar feature flag
public static int LCO_PAYMENT = 0;        // 0=hide, 1=show LCO payment
public static int is_direct_lco = 0;      // Direct LCO flag
public static int AUTO_RECEIPT_NUMBER = 1;// Auto receipt numbering
public static int allow_top_up = 1;       // Top-up allowed flag
public static int stb_pairing = 0;        // STB pairing enabled
public static int stb_unpairing = 0;      // STB unpairing enabled
public static int pgtransaction = 0;      // Payment gateway transaction access
public static int useCRF;                 // CRF usage flag
public static String useCAF;              // CAF usage flag
public static int useLastName;            // Use last name field flag
public static int useDiscount;            // Discount field flag
public static int freezecustomerparamsinapp = 0; // Freeze customer params
public static int hidemakepayment = 0;    // Hide make payment button
public static int int_bulk_payment = 1;   // Bulk payment access
public static int invoice_page_access = 1; // Invoice page access
public static int payment_hist_page_access = 1; // Payment history access
public static int access_for_complaints = 1; // Complaints access
public static int int_stb_activation = 1; // STB activation access
public static int int_stb_deactivation = 1; // STB deactivation access
public static int int_stb_reactivation = 1; // STB reactivation access
public static String employeeParentId;    // Parent employee ID
public static String employeeParentType; // Parent employee type
public static String login_username;     // Logged-in username
public static String login_email;        // Logged-in email
public static String logo_img;           // Logo image URL
public static String imeiNo;             // Device IMEI number
public static String ipAddress;          // Device IP address
public static String mobilenumber;       // Device mobile number
public static String menuType = "";      // Menu format type
public static String patch_information = "1.4.13.2"; // App patch version
public static String defaultcountry;     // Default country
public static int defaultstate;          // Default state
public static int defaultdistrict;       // Default district
public static int defaultcity;           // Default city
public static double deposit_amount;     // Deposit amount
public static int lco_billtype;          // LCO bill type
public static int customerbilltype = 0;  // Customer bill type
public static int lcoMobileNo;           // LCO mobile number
public static int recurringService;      // Recurring service flag
public static int show_caf_mobile_validation = 0; // CAF mobile validation
public static int show_mia_agreement_upload = 0;  // MIA agreement upload
public static int accept_terms_condtions = 0;      // Accept T&C flag (typo preserved)
public static int agreement_details_count = 0;     // Agreement details count
public static int access_distributor_wise = 0;    // Distributor-wise access
public static int userLcoDeposit;        // LCO deposit flag
```

### 11.3 Logout Flow

```java
EzyBillConstants.alertforLogout(context)
    → Shows dialog "Are you sure? Press 'Logout' to close."
    → On "Logout":
        Intent intent = new Intent(context, LoginActivity.class);
        intent.addFlags(FLAG_ACTIVITY_CLEAR_TOP | FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("EXIT", true);
        context.startActivity(intent);
```

In `LoginActivity`: if `getIntent().getBooleanExtra("EXIT", false)` is true → `finish()` to exit.

**Flutter equivalent:** Clear all stored tokens (`flutter_secure_storage`), reset state (riverpod/bloc), navigate to login route with `pushAndRemoveUntil`.

### 11.4 "Remember Me" Feature

- `chkRememberMe` CheckBox on login screen
- If checked: saves `"username"` to `"vidslogin"` SharedPreferences
- If unchecked: clears `"vidslogin"` SharedPreferences entirely
- On next launch: reads `"username"` from `"vidslogin"` to pre-fill username field

---

## 12. Application Class (EzybillApplication)

- **Class:** `EzybillApplication` (extends `Application`)
- **Registered in:** `AndroidManifest.xml` (as the application class)
- **Purpose:** Application-level Volley request queue singleton

**Features:**
- `MultiDex.install(this)` in `attachBaseContext()` — required due to method count exceeding 64K
- Volley `RequestQueue` singleton: `Volley.newRequestQueue(getApplicationContext())`

**Public methods:**
```java
// Get singleton instance
EzybillApplication.getInstance()

// Add request to queue (with or without tag)
.addToRequestQueue(Request<T> req)
.addToRequestQueue(Request<T> req, String tag)

// Cancel all pending requests with a given tag
.cancelPendingRequests(Object tag)
```

**Usage example (in MapsFragmentlocupdate):**
```java
EzybillApplication.getInstance().addToRequestQueue(postRequest);
```

**Flutter equivalent:**
- Use `dio` or `http` package for HTTP requests
- No special application class needed; use a service/repository singleton
- MultiDex is not needed in Flutter (Dart compiles differently)

---

## 13. DetectSession - Cross-Fragment Communication

- **Class:** `DetectSession` (utility class, static methods only)
- **Purpose:** Provides a static callback bus for cross-fragment communication, specifically for:
  1. Triggering invoice printing from a list adapter/fragment
  2. Triggering invoice sharing from a list adapter/fragment
  3. Notifying selection state changes

**Interfaces registered:**
```java
// Set by a fragment that wants to be notified when invoice should be printed
DetectSession.setPrintInvoiceClickListener(PrintInvoiceClickListener listener)
// Called by adapter/another fragment:
DetectSession.getPrintInvoiceClickListener(int position)
    → listener.PrintInvoiceData(position)

// Set by a fragment that wants to be notified when invoice should be shared
DetectSession.setShareInvoiceClickListener(ShareInvoiceClickListener listener)
// Called by adapter/another fragment:
DetectSession.getShareInvoiceClickListener(int position)
    → listener.ShareInvoiceData(position)

// Set by a fragment to receive selection state changes
DetectSession.setSelectedOrNot(SelectedOrNot listener)
// Called when selection changes:
DetectSession.getSelectedOrNot(boolean[] isSelectedOrNot)
    → listener.IsSelectedOrNot(isSelectedOrNot)
```

**Flutter equivalent:** Use callbacks passed through constructors, or a state management solution (riverpod providers, bloc events) to communicate between widgets. Avoid global static callbacks.

---

## 14. App Version Check

### 14.1 Flow

Before login, `appVersionCheck` AsyncTask runs:

```
User taps Login
    |
    v
new appVersionCheck().execute()
    |
    v
SOAP call to BMS service (VERSION_URL, decoded from NAMESPACE_BMS)
Method: PropertyReader.getProperty("valauth", context)  // method name from properties file
Namespace: Decryptions.decryptions1(EzyBillConstants.NAMESPACE_BMS)  // decoded BMS URL
    |
    v
Request object: AppVersionCheckRequest
    .appVersionName = versionName    (from PackageInfo)
    .appVersionCode = versionCode    (int, as String)
    .appTypeId      = apptypeId0     (from app config)
    .appclientname  = ""             (empty)
    |
    v
Response:
    statusCode == 0 → version OK, proceed to LoginAsyncTask
    statusCode == 1 → show "Update Application!" dialog
                      → on "Update": open Play Store
                      → force non-dismissible (setCancelable(false))
    statusCode == 3 (no response) → show "Server is busy" dialog → finish()
    |
    v
On version OK: LoginAsyncTask().execute()
```

### 14.2 AppVersionCheckRequest SOAP Model

```java
// KvmSerializable, 4 properties
public String appVersionName;   // property 0 — app version name string (e.g., "1.4.13")
public String appVersionCode;   // property 1 — version code int as string (e.g., "114")
public String appTypeId;        // property 2 — identifies this as LCO app
public String appclientname;    // property 3 — empty string
```

**SOAP property names:** `"appVersionName"`, `"appVersionCode"`, `"appTypeId"`, `"appclientname"` (all String type in SOAP)

**Flutter equivalent:** Call the REST version check endpoint (check REST API doc for equivalent). Compare device app version (from `package_info_plus`) against server's minimum required version.

---

## 15. Server IP Configuration

### 15.1 Two-Stage URL Resolution

The server URL is configured through a two-stage process:

**Stage 1: Pre-login (ACT_LoginActivity / CloudAuthentication)**
1. User enters a dealer ID on the initial screen
2. App calls `getServerIp` SOAP method against BMS service (whose URL is hardcoded/obfuscated in `NAMESPACE_BMS`)
3. BMS service returns the dealer-specific server URL (`ipAddress`)
4. URL is saved to SharedPreferences

**Stage 2: At LoginActivity launch**
```java
authSharedPreferences = getSharedPreferences(EzyBillConstants.BMS_SHARED_PREF, 0);
URL = authSharedPreferences.getString(EzyBillConstants.LOGIN_URL, "");
```

### 15.2 getServerIp SOAP Request Model

```java
// KvmSerializable, 1 property
public int dealerId;  // property 0 (INTEGER) — the dealer ID entered by user
```

**Property name:** `"dealerId"` (INTEGER type in SOAP)

**Response:** Contains `ipAddress` (String) — the full SOAP endpoint URL for the dealer's server.

**Storage (from ACT_LoginActivity):**
```java
SharedPreferences.Editor edit = getSharedPreferences(EzyBillConstants.BMS_SHARED_PREF, 0).edit();
edit.putString(EzyBillConstants.LOGIN_URL, responseObject.getIpAddress());  // "login_url"
edit.putString(EzyBillConstants.EMP_ID,   responseObject.getEmployeeId()); // "emp_id"
edit.putInt(EzyBillConstants.APP_THEME_COLOR, appThemeColor);              // "appThemeColor"
edit.apply();
```

### 15.3 URL Structure

```
Stored URL format: "http://<host>:<port>/wsController"
                or "https://<host>/wsController"

REST API base derived as:
    String Urll = LoginActivity.URL.replace("/wsController", "");
    // REST endpoints: Urll + "/LcoRestServices/<endpoint>"
    // e.g.: http://host:port/LcoRestServices/updateCustomerLocation
```

### 15.4 getServerTerminology SOAP Request Model

```java
// KvmSerializable, 1 property
public String authToken;  // property 0 (STRING)
```

**Purpose:** Fetches dealer-specific terminology overrides (custom labels for UI text, e.g., replacing "Customer" with "Subscriber").

**Called after:** Successful login, to customize UI labels.

---

## 16. SOAP Request Models (Complex Classes)

### 16.1 passwordChange

```java
// KvmSerializable, 3 properties
public String authToken;    // property 0 (STRING) — current session token
public String oldPassword;  // property 1 (note: declared INTEGER in SOAP type but stored as String)
public String newPassword;  // property 2 (STRING)
```

**SOAP property type bug:** `oldPassword` is declared `PropertyInfo.INTEGER_CLASS` in `getPropertyInfo()` but `setProperty()` does `oldPassword = value.toString()`. The server must accept it as a string despite the INTEGER declaration.

**Usage:** Called by a password change screen (not in the analyzed files, but the model is used there).

### 16.2 Summary of All SOAP Complex Types Analyzed

| Class | Properties | Purpose |
|---|---|---|
| `AppVersionCheckRequest` | appVersionName, appVersionCode, appTypeId, appclientname | Version check before login |
| `getServerIp` | dealerId (int) | Get dealer's server URL |
| `getServerTerminology` | authToken | Fetch UI terminology overrides |
| `getEmployeeTrackInfo` | authToken, startDate, endDate, employeeId | Employee GPS track query |
| `employeeTrackInfoList` | latitude, longitude, date_time | Employee track data point (response) |
| `passwordChange` | authToken, oldPassword, newPassword | Change user password |

---

## 17. Flutter Migration Notes

### 17.1 Bluetooth Printing

**Recommended package:** `flutter_bluetooth_serial` or `flutter_blue_plus`

**Critical implementation details:**
1. Use insecure RFCOMM socket (channel 1) — same as Android's `createInsecureRfcommSocket(1)`
2. Detect printer model from device name prefix (first 5 chars): `"ANTHERMAL"` = 58mm, `"97BT-"` = 80mm
3. Persist selected printer: `SharedPreferences` key with `"<MAC>@<NAME>"` format
4. Add 3-second delays (`await Future.delayed(Duration(seconds: 3))`) between page flushes
5. Between pages in batch reports (>15 records): flush every 15 rows with 3s delay
6. For ESC/POS font sizes: use `print_bluetooth_thermal` or `esc_pos_utils` packages

**Line separator widths:**
- 58mm printers: 32 dots `................................`
- 80mm printers: 40 dashes `----------------------------------------`

**Date format for receipts:**
```dart
// Replicate Java's Date.toString() output format
String formatReceiptDate(DateTime now) {
  const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
  const months = ['Jan','Feb','Mar','Apr','May','Jun',
                  'Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${days[now.weekday-1]} ${months[now.month-1]} '
         '${now.day.toString().padLeft(2)} ${now.year} '
         '${now.hour.toString().padLeft(2,'0')}:'
         '${now.minute.toString().padLeft(2,'0')}:'
         '${now.second.toString().padLeft(2,'0')}';
}
```

### 17.2 Barcode Scanner

**Recommended package:** `mobile_scanner`

- Supports `BarcodeFormats.all` (equivalent to `Barcode.ALL_FORMATS`)
- Camera preview at high resolution with auto-focus
- Map scanned value to `boxNumber` field in customer search REST request

### 17.3 Signature Capture

**Recommended approach:** Custom `CustomPainter` with `GestureDetector`

```dart
// Canvas setup equivalent to Android:
// - Black stroke, width 5.0, round stroke join, anti-alias
// - White background
// - Save as PNG bytes (compress at 45% quality for payment gateway)
// - For customer creation: return as Uint8List (600x320 equivalent)
// - For payment gateway: save to app documents directory as 'signature.bmp'
```

### 17.4 Google Maps

**Recommended package:** `google_maps_flutter`

- `Marker` for customer locations with title `"<name> - <amount> - <alt_number>"`
- `Polyline` connecting all locations, color Red, width 12, geodesic true
- Employee track: Blue polyline, width 3 (from Google Directions API)
- Camera zoom: 18 for location updates, 13 for route display
- Fused location: use `geolocator` package

### 17.5 Location Update REST API

Use the REST endpoint directly (no SOAP needed):

```dart
// POST /LcoRestServices/updateCustomerLocation
Map<String, String> params = {
  'authtoken': authToken,
  'dealer_id': dealerId.toString(),
  'latitude':  lat.toString(),
  'longitude': lng.toString(),
  'customer_id': customerId.toString(),
};
```

### 17.6 Session Management

Store all `LoginActivity` static variables in a single `AuthState` class / riverpod provider:

```dart
class AuthState {
  final String authToken;
  final String serverUrl;   // was LoginActivity.URL
  final int dealerId;
  final int employeeId;
  final String currencyCode;  // default "₹"
  final int appTheme;         // 1-5
  // ... all other static fields from LoginActivity
}
```

Use `flutter_secure_storage` for token persistence between app restarts.

### 17.7 SharedPreferences Migration Checklist

| Android Pref File | Android Key | Flutter key | Type | Notes |
|---|---|---|---|---|
| `bmsSharedPref` | `login_url` | `login_url` | String | Server SOAP/REST URL |
| `bmsSharedPref` | `emp_id` | `emp_id` | String | Parse to int |
| `bmsSharedPref` | `appThemeColor` | `appThemeColor` | int | 1-5 |
| `bmsSharedPref` | `appDashboard` | `appDashboard` | int | |
| `bmsSharedPref` | `enableAadhar` | `enableAadhar` | int | Note typo |
| `bmsSharedPref` | `appLogoPath` | `appLogoPath` | String | URL |
| `bmsSharedPref` | `smsKey` | `smsKey` | String | |
| `bmsSharedPref` | `bmsAuth` | `bmsAuth` | String | |
| `vidslogin` | `username` | `username` | String | Remember-me |
| `vidslogin` | `bluetoothmac` | `bluetoothmac` | String | Last BT printer MAC |
| Internal file | `mytextfile.txt` | `printer_device.txt` | String | `"<MAC>@<NAME>"` |

### 17.8 Key SOAP → REST Replacements

| Feature | Android SOAP Method | REST Equivalent (from REST doc) |
|---|---|---|
| Barcode/STB search | `getCustomerDetailsCount` (scount) | Customer search REST endpoint |
| Employee track | `getEmployeeTrackInfo` | Employee track REST endpoint |
| Customer location update | REST already (`updateCustomerLocation`) | Same REST endpoint |
| Get server URL | `getServerIp` (BMS SOAP) | Pre-configured or cloud lookup |
| Server terminology | `getServerTerminology` | REST terminology endpoint |
| App version check | `appVersionCheck` (BMS SOAP) | REST version endpoint |
| Password change | `passwordChange` SOAP | REST password change endpoint |

### 17.9 Permissions Required

| Android Permission | Flutter Equivalent |
|---|---|
| `BLUETOOTH` + `BLUETOOTH_ADMIN` + `BLUETOOTH_CONNECT` + `BLUETOOTH_SCAN` | `permission_handler`: `Permission.bluetooth`, `Permission.bluetoothConnect`, `Permission.bluetoothScan` |
| `ACCESS_FINE_LOCATION` | `Permission.location` |
| `CAMERA` | `Permission.camera` |
| `READ_PHONE_STATE` | `Permission.phone` |
| `WRITE_EXTERNAL_STORAGE` | `Permission.storage` |

---

*Document generated from line-by-line analysis of Android source code.*
*Last updated: 2026-03-26*
