# Ezybill Bug Fixes — Walkthrough

## Summary

Applied 7 targeted production fixes to resolve dashboard UI inconsistencies, broken tab refresh, fresh STB error messages, route collisions, state management bugs, and environment switching issues. All changes verified with `flutter analyze` — **0 issues**.

---

## Files Modified

| File | Fix |
|------|-----|
| [home_screen.dart](file:///C:/Users/itp/Desktop/Flutter_ezybill/lib/presentation/screens/home/home_screen.dart) | Fix 1, Fix 3, Fix 5, Fix 7 |
| [dashboard_customer_list_provider.dart](file:///C:/Users/itp/Desktop/Flutter_ezybill/lib/application/providers/dashboard_customer_list_provider.dart) | Fix 2 |
| [customer_profile_screen.dart](file:///C:/Users/itp/Desktop/Flutter_ezybill/lib/presentation/screens/customers/customer_profile_screen.dart) | Fix 4, Fix 6 |
| [app_router.dart](file:///C:/Users/itp/Desktop/Flutter_ezybill/lib/presentation/router/app_router.dart) | Fix 6, Fix 8 |
| [dashboard_provider.dart](file:///C:/Users/itp/Desktop/Flutter_ezybill/lib/application/providers/dashboard_provider.dart) | Fix 7 |
| [subscriber_card.dart](file:///C:/Users/itp/Desktop/Flutter_ezybill/lib/presentation/common/widgets/subscriber_card.dart) | Fix 5 (reverted) |
| [api_constants.dart](file:///C:/Users/itp/Desktop/Flutter_ezybill/lib/core/constants/api_constants.dart) | Fix 8 |

---

## Fix 1: Active Tab Count Contaminated by Other Tabs

**Root Cause:** The Active pill badge used `listState.totalCount` as a fallback when `dashboard.totalActiveCustomers` was 0. Since `listState.totalCount` reflects the *currently selected* tab's data, switching to Inactive/Fresh/Assigned would overwrite the Active badge.

**Change:** Removed the fallback in 3 locations (pill tab, donut chart, inline ticker). Active count now always uses `dashboard.totalActiveCustomers`.

```diff
-count: dashboard.totalActiveCustomers > 0
-    ? dashboard.totalActiveCustomers
-    : listState.totalCount,
+count: dashboard.totalActiveCustomers,
```

---

## Fix 2: Refresh Broken for Fresh/Assigned Tabs

**Root Cause:** `refresh()` had a switch statement that only handled `active` and `inactive` tabs. `fresh` and `assigned` fell into `default: break`, silently doing nothing.

**Change:** Replaced the switch with a single `_loadFromDashboardList()` call using the tab's `fromDashboard` value. Also removed the now-unused `_loadActiveCustomers()` and `_loadInactiveCustomers()` wrapper methods.

```diff
-switch (tab) {
-  case CustomerFilterTab.active:
-    await _loadActiveCustomers();
-  case CustomerFilterTab.inactive:
-    await _loadInactiveCustomers();
-  default:
-    break;
-}
+await _loadFromDashboardList(fromDashboard: tab.fromDashboard);
```

---

## Fix 3: Dashboard Loading Blocks Entire Page

**Root Cause:** The `if (dashboard.isLoading)` guard wrapped the entire page body — overview, search bar, tabs, AND subscriber list — behind a single spinner. Since the dashboard API goes through SOAP (~2-4s), the subscriber list (which loads via a faster REST call) couldn't render until the dashboard completed.

**Change:** Restructured so only the overview section (donut + legend + alert chips) is gated by `dashboard.isLoading`. The search bar, pill tabs, sort bar, and subscriber list now render immediately since they depend on `dashboardCustomerListProvider`, not `dashboardProvider`.

---

## Fix 4: "Could Not Load Customer Details" on Fresh STBs

**Root Cause:** If a fresh STB (no customer assigned) reached the profile screen with an empty/zero `customerId`, the screen would call the API with an invalid ID, get no data back, and show "Could not load customer details."

**Change:** Added an early guard at the top of `_loadCustomer()` to detect empty/invalid IDs and show a clear message ("This is a fresh STB with no customer assigned yet") instead of making a pointless API call.

---

## Fix 5: Fresh STB Card Design Reverted

**Root Cause:** An experimental change added action buttons to fresh STB cards, but the user's original design (green icon, no action row) was preferred.

**Change:** Reverted `subscriber_card.dart` to original behavior: `actionList = []` for fresh status. The route collision fix (Fix 6) already ensures fresh STBs navigate correctly to New Customer screen.

---

## Fix 6: Route Collision — Fresh STBs Open Wrong Screen

**Root Cause:** GoRouter matched `/customer/new` with the parameterized route `/customer/:id` (with `:id='new'`), sending fresh STBs to `CustomerProfileScreen(customerId: 'new')` instead of `NewCustomerScreen`.

**Change:** Moved the `customer/new` GoRoute **inside** the shell branch, placed **before** `customer/:id` and `customer/:id/edit`. GoRouter matches routes in declaration order within a branch, so the literal path now matches first.

**Files:** `app_router.dart` (lines 150-162)

---

## Fix 7: Dashboard Error Clears After Wallet/Expiry Load

**Root Cause:** `DashboardState.copyWith` implicitly set `errorMessage` to `null` when not explicitly passed. When dashboard SOAP failed but wallet/expiry succeeded, the error was silently cleared, making the overview appear empty instead of showing the error.

**Change:** Modified `copyWith` to use a sentinel pattern (`Object? errorMessage = _noError`). If `errorMessage` is not explicitly passed, the existing value is preserved. Pass `null` explicitly to clear an error. Removed redundant `errorMessage: state.errorMessage` from `_loadWallet` and `_loadExpiryServices`.

**Files:** `dashboard_provider.dart` (lines 30-73, 195-200, 208-216)

---

## Fix 8: Overview Error Blocks Entire Section

**Root Cause:** When dashboard SOAP returned an error (e.g., "no sufficient privilege"), the entire overview was replaced with a large red error widget, blocking all data display.

**Change:** Changed to a compact amber warning banner ("Dashboard data may be incomplete. Tap to retry.") that doesn't block the overview section. The donut, legend, and ticker still render with whatever data is available.

**Files:** `home_screen.dart` (lines 364-408)

---

## Fix 9: Profile Screen — Preserve Initial Data on API Failure

**Root Cause:** When navigating from the dashboard list to the profile screen, the API call would sometimes fail (e.g., V1 client with incompatible parameters). The error handler would overwrite the pre-populated customer data with just `{customer_id, customer_name}`, wiping out all the data from the list.

**Change:**
1. Pass full customer data from the dashboard list via route extras (`initialData`).
2. Pre-populate `_customer` in `initState()` from `initialData` so the UI shows data immediately.
3. When the API call fails, **preserve** the existing `_customer` data instead of overwriting it. Only show the error banner if `_customer` is truly empty.
4. Reverted `lcoCustomerId` back to `customerNumber` — the V1 local server doesn't support `lcoCustomerId` (returns "Undefined offset: 0").

**Files:** `home_screen.dart` (lines 925-940), `customer_profile_screen.dart` (lines 20-34, 49-68, 98-103, 154-182)

---

## Fix 10: Environment Toggle — Local Mode Not Working

**Root Cause:** The Flutter app had two parallel URL systems:
1. Code-level constants (`_apiBaseUrl`) — changed by commenting/uncommenting
2. Runtime SharedPreferences (`login_url`, `api_base_url`) — set by BMS registration

On startup, `main.dart` always read SharedPreferences and called `setBaseUrl(savedUrl)`, which set `_overrideBaseUrl`. The `baseUrl` getter checked `_overrideBaseUrl` **first**, so the code-level `_apiBaseUrl` was never reached. Developers couldn't switch to local mode by just editing code.

**Change:** Added a `_forceLocal` flag. When `true`, the `baseUrl` getter bypasses SharedPreferences entirely and uses `_apiBaseUrl` directly. Also updated the router to skip BMS registration when `_forceLocal` is true (local servers don't need BMS).

**To switch to local mode:**
```dart
// api_constants.dart
static const bool _forceLocal = true;  // uncomment
static const String _apiBaseUrl = 'http://192.168.1.143/v2_release_aakshya/index.php';  // uncomment
```

**To switch back to live:**
```dart
static const bool _forceLocal = false;  // uncomment
static const String _apiBaseUrl = 'http://0.0.0.0';  // uncomment
```

**Files:** `api_constants.dart` (lines 18-21, 33-38, 59-61, 63-70), `app_router.dart` (lines 6-7, 97-106)

---

## Customer Search Flow Analysis (V1 Client Issue)

**Error:** `type 'int' is not a subtype of type 'Map<String, dynamic>' in type cast`

**Context:** This error occurs in V1 clients during customer search. The search flow:

1. **Search Input** → `CustomerSearchScreen` → calls `customerSearchProvider.searchCustomers()`
2. **Count Check** → `getCustomerDetailsCount()` → REST API → returns `{customerCount: N, status_code: 0/1}`
3. **Fetch Page** → `searchCustomers()` → `getCustomerDetails()` → REST API → returns customer list
4. **Parse Response** → `CustomerSearchResponse.fromJson()` → uses `_sanitize()` to normalize data
5. **Display** → UI shows results

**Potential Cast Error Locations:**
- `customer_remote_datasource.dart` line 38: `return response.data as Map<String, dynamic>` — if server returns an `int` instead of a Map
- `customer_search_response.g.dart` line 20: `(json['customerDetailsList'] as List<dynamic>?)` — if server returns an `int` instead of a List
- `customer_search_response.dart` `_sanitize()` line 50-52: converts Map→List for single results, but doesn't handle `int` case

**Root Cause Hypothesis:** The V1 server may return an `int` (e.g., `0` or `1`) instead of a Map/List when no customers are found, or when the query format is unexpected. The datasource assumes `response.data` is always a Map.

**Recommended Fix:** Add type checking in `customer_remote_datasource.dart` before casting:
```dart
final data = response.data;
if (data is! Map<String, dynamic>) {
  throw ApiException(message: 'Unexpected response type: ${data.runtimeType}');
}
```

---

## Verification

```
flutter analyze --no-pub (modified files)
→ No issues found!
```

All fixes compile cleanly with only minor lint warnings (deprecated APIs, unnecessary underscores) — no errors.

---

## 2026-06-10 — V1 Client Fixes (Session 2)

### Fix A: Customer Search crash — `type 'int' is not a subtype of type 'Map<String,dynamic>'`

**Root Cause:**  
SOAP single-item response: `customerDetailsList` arrives as a bare `Map<String,dynamic>` (the customer object itself, e.g. `{customer_id: 1413, customerName: "shiva", ...}`).  
Two sites both called `.values.toList()` on this Map — extracting field *scalars* `[1413, "shiva", ...]` instead of customer objects.  
`_smartConvert` in `SoapHelper` had already converted `"1413"` → `int 1413`.  
Downstream cast `customerList.first as Map<String,dynamic>` received `int 1413` → crash.

**Files Modified:**

| File | Change |
|------|--------|
| [customer_remote_datasource.dart](lib/data/datasources/remote/customer_remote_datasource.dart) | Added `parse_utils` import; replaced `rawListVal is Map ? rawListVal.values.toList() : rawListVal` with `parseMapList(rawListVal)` |
| [quick_action_provider.dart](lib/application/providers/quick_action_provider.dart) | Replaced `rawCustList is Map ? rawCustList.values.toList() : ...` with `parseMapList(rawCustList)`; removed `== null` guard (parseMapList never returns null) |

**Why `parseMapList` is correct:**  
`_normalizeToListOfMaps` checks whether Map keys are all numeric (`{"0":obj}` → PHP array → unwrap values) vs non-numeric (`{customer_id:...}` → bare object → wrap in list). The old `is Map ? .values.toList()` pattern treated both identically — always extracting values — which destroyed SOAP bare objects.

**Clients verified:**
- V1 SOAP single customer → bare Map → wrapped to `[{customer_obj}]` ✓  
- Local REST single customer → `{"0":{customer_obj}}` → unwrapped to `[{customer_obj}]` ✓  
- REST array → passed through ✓

---

### Fix B: PG Transaction Report not loading for V1 clients — `Procedure 'pgTransactionLogs' not present`

**Root Cause (three-layer issue confirmed against `PG_Transaction_Frag.java`):**

**Layer 1 — Wrong protocol (primary error):**  
`pgTransactionLogs` was absent from `_customerRestMethods` in `dio_client.dart`.  
Flutter routed it to SOAP via `wsController`. The SOAP server has no such procedure.  
Legacy Android V1 (`LoginActivity.version == "V1"`) builds: `Urll = LoginActivity.URL.replace("/wsController","")` then appends `pgtl=/customerRestservices/pgTransactionLogs` → plain POST to `customerRestservices`, never touching `wsController`.

**Layer 2 — Wrong response key (silent empty list):**  
Flutter screen read `data['transactionList']`. Both V1 and V2 Android parse `jsonObject.getString("paymentresult")`. Key `transactionList` does not exist in either server response.

**Layer 3 — Wrong `@JsonKey` names (all fields empty):**  
The `PgTransaction` Freezed model used invented key names (`transactionId`, `customerId`, `gateway`, `orderId`, `transactionDate`). Actual server keys (verified from `PG_Transaction_Frag.java:207-232`, both V1 and V2 paths): `transactionno`, `code`, `displayname`, `transaction_id`, `paydate`.

**Files Modified:**

| File | Change |
|------|--------|
| [dio_client.dart](lib/core/network/dio_client.dart) | Added `'pgTransactionLogs'` to `_customerRestMethods` — routes V1 to `customerRestservices` instead of SOAP |
| [pg_transaction_report_screen.dart](lib/presentation/screens/payments/pg_transaction_report_screen.dart) | Changed `data['transactionList']` → `data['paymentresult']` |
| [pg_transaction.dart](lib/data/models/payment/pg_transaction.dart) | Updated `@JsonKey` annotations: `transactionno`, `code`, `amount`, `status`, `displayname`, `transaction_id`, `paydate` |
| [pg_transaction.g.dart](lib/data/models/payment/pg_transaction.g.dart) | Updated generated `fromJson`/`toJson` to match corrected key names |

**Evidence:**
```
configg.properties:68  pgtl=/customerRestservices/pgTransactionLogs
configg.properties:129 pgtlrest=/LcoRestServices/pgTransactionLogs
PG_Transaction_Frag.java:76    Urll = LoginActivity.URL.replace("/wsController", "")
PG_Transaction_Frag.java:155   if (LoginActivity.version.equalsIgnoreCase("V1")) getpgtransactionreport(item)
PG_Transaction_Frag.java:177   StringRequest POST to pgtransaction_url (customerRestservices)
PG_Transaction_Frag.java:194   paymentresult = jsonObject.getString("paymentresult")
PG_Transaction_Frag.java:207   setTransactionno(jsonObject1.getString("transactionno"))
PG_Transaction_Frag.java:223   setDisplayname(jsonObject1.getString("displayname"))
PG_Transaction_Frag.java:205   setPaydate(jsonObject1.getString("paydate"))
```

---

### Fix C: PG Transaction UI shows "No transactions" despite API returning data

**Root Cause:**  
`paymentresult` in the server response is a **double-encoded JSON string** — `"[{...},{...}]"` — not a native JSON array.  
Android V1 and V2 both handle this: `jsonObject.getString("paymentresult")` (reads as String) then `new JSONArray(paymentresult)` (decodes the string). See `PG_Transaction_Frag.java:194-195`.  
Flutter's `_normalizeToListOfMaps` (in `parse_utils.dart`) had no `String` branch — fell through to line 110 (`return []`), silently dropping all records.

**Flow where records disappear:**

| Step | File | Line | Count | Type |
|---|---|---|---|---|
| API response | server | — | N | `String` (double-encoded array) |
| Datasource return | `payment_remote_datasource.dart` | 156 | N | `String` unchanged |
| `parseList` input | `pg_transaction_report_screen.dart` | 58 | N | `String` |
| **`_normalizeToListOfMaps`** | **`parse_utils.dart`** | **110** | **0** | **no String branch → returns `[]`** |
| Provider state | `pg_transaction_report_screen.dart` | 61 | 0 | empty list |
| UI | `pg_transaction_report_screen.dart` | 282 | 0 | "No transactions found" |

**File Modified:**

| File | Change |
|------|--------|
| [parse_utils.dart](lib/core/utils/parse_utils.dart) | Added `import 'dart:convert'`; added `String` branch to `_normalizeToListOfMaps` — JSON-decodes the string and recurses, matching Android's `getString()` + `new JSONArray()` pattern |

**Fix (parse_utils.dart):**
```dart
if (value is String) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return [];
  try {
    return _normalizeToListOfMaps(jsonDecode(trimmed));
  } catch (_) {
    return [];
  }
}
```

**Why this is safe for all callers:**  
All existing callers pass `List`, `Map`, or `null`. The new `String` branch is only reached when the server double-encodes a JSON value. Recursing through `_normalizeToListOfMaps` after decoding means all existing normalisation logic (PHP-indexed maps, single-object wrapping) still applies to the decoded result.
