# BMS Registration / Cloud Authentication — Plan Document

> **Source:** `CloudAuthentication.java` (1112 lines), `ACT_LoginActivity.java`, `Validateauth.java`, `validateAuthenticationInfo.java`, `CloudAuthResponse.java`, `EzyBillConstants.java`, `Decryptions.java`

---

## 1. Business Flow Overview

The app has a **pre-login registration step** that authenticates the LCO's device with the BMS (Business Management System) server. This is a ONE-TIME process per device.

```
┌─────────────────────────────────────────────────────┐
│                    APP STARTUP                        │
│                                                       │
│  Check SharedPreferences: "smsKey" exists?            │
│           │                                           │
│     ┌─────┴─────┐                                    │
│     │ YES       │ NO                                  │
│     ▼           ▼                                     │
│  AUTO-LOGIN   SHOW REGISTRATION SCREEN                │
│  (validate    (MSO Key + Username fields)             │
│   IMEI with                                           │
│   BMS)        User enters MSO Key + Username          │
│     │              │                                  │
│     ▼              ▼                                  │
│  SOAP Call:    SOAP Call:                              │
│  validateUser  validateAuthentication                  │
│  Authentication (register new device)                  │
│     │              │                                  │
│     ▼              ▼                                  │
│  status=0?     status=0?                               │
│  YES → Store   YES → Store credentials →              │
│  server URL      Show "Registration Successful"       │
│  → Go to         → Go to Login                        │
│  Login                                                 │
│                                                       │
│  status>=1?    status>=1?                              │
│  Show          Show "Registration Failed"              │
│  registration  "Enter valid details"                   │
│  form                                                  │
└─────────────────────────────────────────────────────┘
```

## 2. Two SOAP Calls

### 2.1 Auto-Login Check: `validateUserAuthentication` (LOGIN_CODE=0)

**When:** App starts AND `smsKey` exists in SharedPreferences
**Purpose:** Verify this device is still registered with BMS

**SOAP Details:**
| Property | Value |
|----------|-------|
| Namespace | `Decryptions.decryptions1(NAMESPACE_BMS)` — encrypted BMS URL |
| URL | `{NAMESPACE}/validateAuthentication` |
| SOAP Action | `{NAMESPACE}/validateAuthentication` |
| Method | `validateUserAuthentication` |

**Request Params (Validateauth object):**
| Field | Type | Value |
|-------|------|-------|
| `smsCode` | String | `""` (empty for auto-login check) |
| `imei` | String | Device IMEI or Android ID (API 29+) |
| `appTypeId` | int | `2` (hardcoded — "For Bill" app) |
| `imeiValidNumber` | int | `0` (REGISTER_CODE — means "check if registered") |

**Response (CloudAuthResponse):**
| Field | Type | Description |
|-------|------|-------------|
| `statusCode` | int | 0=registered & active, ≥1=not registered |
| `statusMessage` | String | Success/error message |
| `ipAddress` | String | **THE SERVER URL** for REST API (stored as LOGIN_URL) |
| `employeeId` | String | Employee ID for this device |
| `appThemeColor` | int | Theme ID (1-5) |
| `appDashboard` | int | Dashboard layout ID |
| `appLogoPath` | String | URL to dealer logo |
| `enableAadhar` | int | Aadhaar feature flag |

**Response format:** Semicolon-separated key=value string, NOT JSON:
```
statusCode=0;statusMessage=Success;ipAddress=http://192.168.1.143/v2_release_aakshya/index.php/wsController;employeeId=3541;appThemeColor=1;appDashboard=0;appLogoPath=...;enableAadhar=0
```

**On `statusCode == 0` (registered):**
1. Store to SharedPreferences:
   - `smsKey` = sms_key
   - `bmsAuth` = true
   - `login_url` = `ipAddress` (THIS IS THE REST API SERVER URL!)
   - `emp_id` = employeeId
   - `appThemeColor`, `appDashboard`, `enableAadhar`, `appLogoPath`
2. Navigate to LoginActivity

**On `statusCode >= 1` (not registered):**
1. Show registration form (MSO Key + Username fields)
2. Show message: "You haven't registered with this device. Please enter SMS key/MSO key."

### 2.2 Register New Device: `validateAuthentication` (commented out but logic preserved)

**When:** User enters MSO Key + Username and taps "Register"
**Purpose:** Register this device with the BMS server

**NOTE:** The `CloudAuthRegisterAsyncTask` is **commented out** in the current Android code (lines 700-898). The active registration flow uses `ACT_LoginActivity` instead. But the business logic is identical.

**Request Params (validateAuthenticationInfo object):**
| Field | Type | Value |
|-------|------|-------|
| `smsCode` | String | User-entered MSO Key (e.g., "h1i2") |
| `imei` | String | Device IMEI or Android ID |
| `appTypeId` | int | `2` (hardcoded) |
| `imeiValidNumber` | int | Not sent in active code / `1` (LOGIN_CODE) |

**Additional field in ACT_LoginActivity version:**
| Field | Type | Value |
|-------|------|-------|
| `mso_key` | String | MSO Key from input |
| `userName` | String | Username from input |

**Response:** Same `CloudAuthResponse` format as above.

**On `statusCode == 0`:**
1. Store all credentials (same as auto-login)
2. Show dialog: "Your Registration with this device is Successful. Press OK to Login."
3. Navigate to LoginActivity

**On `statusCode >= 1`:**
1. Show error: "{statusMessage}. Please check and enter valid details"

## 3. BMS Server URL (Encrypted)

The BMS server URL is stored **encrypted** in `EzyBillConstants.NAMESPACE_BMS`:

```java
// Encrypted (triple-hex with 5-char padding):
public static final String NAMESPACE_BMS = "74214333633383337333433373334333733303337...16038";

// Decrypted (via Decryptions.decryptions1()):
// → http://c8747070a2f2f139322e31362e312e313636f6573796273797376e13617070f696e646578e70687022f →
// → BMS SOAP endpoint URL (e.g., http://bmsserver.com/ezybmsys/app/index.php)
```

The `Decryptions.decryptions1()` method:
1. Strip first 5 and last 5 chars (random padding)
2. Split into 2-char hex pairs
3. Convert hex → ASCII → get the actual URL

**CRITICAL:** The `ipAddress` field in BMS response provides the **REST API server URL** for the main app:
- BMS returns: `http://192.168.1.143/v2_release_aakshya/index.php/wsController`
- App strips `/wsController` → `http://192.168.1.143/v2_release_aakshya/index.php`
- This becomes the base URL for all `/LcoRestServices/*` REST API calls

## 4. Data Stored After Registration

| SharedPreferences Key | Value | Purpose |
|----------------------|-------|---------|
| `smsKey` | MSO Key string | Indicates device is registered (null = show registration) |
| `bmsAuth` | boolean true | Auth flag |
| `login_url` | Server URL from BMS | **THE REST API BASE URL** used by LoginActivity |
| `emp_id` | Employee ID string | Used in SOAP calls |
| `appThemeColor` | int (1-5) | App theme selection |
| `appDashboard` | int | Dashboard layout |
| `enableAadhar` | int (0/1) | Aadhaar feature flag |
| `appLogoPath` | URL string | Dealer logo image URL |

## 5. Security Checks

| Check | Action |
|-------|--------|
| **Root detection** | `RootBeer.isRooted()` or `detectTestKeys()` → "This app can't be run on this device" → force close |
| **Network check** | No internet → "Please turn on Wifi or Data Network" dialog |
| **Permission** | `READ_PHONE_STATE` required for IMEI |
| **IMEI source** | Android ≤ P: `telephonyManager.getDeviceId()`, Android Q+: `Settings.Secure.ANDROID_ID` |
| **Cache clear** | If `smsKey` exists but registration form shown → "Cache data exists, Press OK to clear and restart" |

## 6. Screen Flow Decision Logic

```
App Launch
    │
    ├── Is rooted? → YES → Block app, show error, force close
    │
    ├── Has READ_PHONE_STATE permission? → NO → Request permission
    │
    ├── Get IMEI/Android ID
    │
    ├── Has network? → NO → Show "No Internet" dialog
    │
    ├── Read SharedPreferences "smsKey"
    │   │
    │   ├── smsKey == null or length <= 1
    │   │   │
    │   │   ├── Auto-login SOAP call (imeiValidNumber=0, empty smsCode)
    │   │   │   │
    │   │   │   ├── status=0 → Store URL → Go to Login
    │   │   │   └── status>=1 → Show Registration form
    │   │   │
    │   │   └── User fills MSO Key + Username → Tap Register
    │   │       │
    │   │       ├── Register SOAP call (mso_key, userName, imei, appTypeId=2)
    │   │       │   │
    │   │       │   ├── status=0 → Store URL → "Registration Successful" → Go to Login
    │   │       │   └── status>=1 → "Registration Failed"
    │   │
    │   └── smsKey exists AND length > 1
    │       │
    │       ├── Auto-login SOAP call (imeiValidNumber=0, empty smsCode)
    │       │   │
    │       │   ├── status=0 → Store URL → Go to Login
    │       │   └── status>=1 → Show "Cache data exists, clear and restart"
    │
    └── Go to LoginActivity
```

## 7. Flutter Implementation Plan

### 7.1 Challenge: BMS Uses SOAP Only

The BMS server supports **ONLY SOAP** — no REST API. The Flutter app needs a SOAP client.

**Options:**

| Option | Pros | Cons |
|--------|------|------|
| A: Use `http` package to send raw SOAP XML | No extra dependency, full control | Must manually construct XML |
| B: Ask backend team to add REST endpoint to BMS | Clean, matches app architecture | Requires backend change |
| C: Create a thin REST proxy on the main server | No BMS change needed | Extra server component |
| **D: Send raw HTTP POST with SOAP XML envelope** | Simplest, works immediately | Verbose XML strings |

**Recommendation: Option D** — construct the SOAP XML manually and POST it via Dio. The BMS SOAP API is simple (just 2 calls), so hand-crafting XML is feasible.

### 7.2 Files to Create

```
lib/
  data/
    datasources/
      remote/
        bms_remote_datasource.dart    (NEW — SOAP calls to BMS)
    models/
      auth/
        bms_registration_response.dart (NEW — CloudAuthResponse equivalent)
  domain/
    repositories/
      bms_repository.dart             (NEW — interface)
  data/
    repositories/
      bms_repository_impl.dart        (NEW — implementation)
  application/
    providers/
      bms_provider.dart               (NEW — registration state)
  presentation/
    screens/
      auth/
        registration_screen.dart      (NEW — MSO Key + Username form)
```

### 7.3 Implementation Steps

| Step | Task | Effort |
|------|------|--------|
| 1 | Create `bms_remote_datasource.dart` with raw SOAP XML calls | M |
| 2 | Create `bms_registration_response.dart` model | S |
| 3 | Create `registration_screen.dart` — MSO Key + Username form | M |
| 4 | Add startup logic: check `smsKey` → registration or login | M |
| 5 | Store BMS response (server URL, theme, etc.) to SharedPreferences | S |
| 6 | Wire registration → login navigation | S |
| 7 | Add root detection (optional — `flutter_jailbreak_detection`) | S |
| 8 | Handle IMEI/Android ID for device identification | S |

### 7.4 SOAP XML Templates

**Auto-Login Check:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soap:Body>
    <validateUserAuthentication xmlns="{BMS_NAMESPACE}">
      <userInfo>
        <smsCode></smsCode>
        <imei>{DEVICE_IMEI}</imei>
        <appTypeId>2</appTypeId>
        <imeiValidNumber>0</imeiValidNumber>
      </userInfo>
    </validateUserAuthentication>
  </soap:Body>
</soap:Envelope>
```

**Register Device:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soap:Body>
    <validateAuthentication xmlns="{BMS_NAMESPACE}">
      <userInfo>
        <smsCode>{MSO_KEY}</smsCode>
        <imei>{DEVICE_IMEI}</imei>
        <appTypeId>2</appTypeId>
        <imeiValidNumber>0</imeiValidNumber>
      </userInfo>
    </validateAuthentication>
  </soap:Body>
</soap:Envelope>
```

### 7.5 BMS URL Configuration

The BMS URL is currently encrypted in the Android app. For Flutter:

**Option A (hardcode):** Store the decrypted BMS URL in `ApiConstants`:
```dart
static const String bmsBaseUrl = 'http://bmsserver.com/ezybmsys/app/index.php';
```

**Option B (configurable):** Make it editable like the REST API URL — add to the dev tools URL editor.

**Option C (encrypt same way):** Port the `Decryptions.decryptions1()` logic to Dart for parity.

### 7.6 Registration Screen UI Design

```
┌─────────────────────────────────────────┐
│            [EzyBill Logo]               │
│                                         │
│         Device Registration             │
│    Register your device with MSO        │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │  MSO Key                          │  │
│  │  [h1i2                         ]  │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │  Username                         │  │
│  │  [57016                        ]  │  │
│  └───────────────────────────────────┘  │
│                                         │
│  [========= Register ===============]   │
│                                         │
│  Device ID: abc123def456                │
│  BMS: http://bmsserver.com/...    ✏️    │
│  itpworld.com, All Rights Reserved      │
└─────────────────────────────────────────┘
```

## 8. Questions for Backend Team

| # | Question |
|---|----------|
| 1 | Can you provide a REST endpoint for BMS registration (to avoid SOAP in Flutter)? |
| 2 | What is the current BMS server URL? (Need decrypted value of `NAMESPACE_BMS`) |
| 3 | Is the `validateAuthentication` SOAP method still the active registration endpoint? (It's commented out in Android) |
| 4 | `ACT_LoginActivity` seems to be an alternative — which one is actually used in production? |
| 5 | Can the BMS response include the REST API URL directly (without `/wsController` suffix)? |
| 6 | Is root detection still required? Should we block rooted devices in Flutter? |
| 7 | For Flutter Web, there's no IMEI — what should we send as device identifier? |
| 8 | Is `appTypeId=2` still correct for the Flutter version? Or should it be a new ID? |

## 9. Priority

**This is a P1 blocker for production APK release** — without BMS registration, new devices can't get the server URL and can't connect to the REST API. Currently we hardcode the URL in `ApiConstants`, but production apps must get it from BMS.

For development/testing, the hardcoded URL works fine. BMS registration is needed for:
- New device onboarding
- Server URL discovery (multi-tenant support)
- Device-level authentication
- Theme/logo configuration per dealer
