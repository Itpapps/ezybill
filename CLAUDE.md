# EzyBill Flutter App — Claude Code Context

## Project
- **Path:** D:\ITP2026\android\Flutter_ezybill
- **Type:** Flutter app (cable TV billing for Indian LCO/MSO operators)
- **Status:** All 10 implementation phases complete, 272 Dart files, 0 compile errors
- **Backup:** lib_backup_20260326/

## Server
- **API Base:** http://192.168.1.143/v2_release_aakshya/index.php/LcoRestServices
- **CORS Proxy:** `node cors_proxy.js` (port 3199) — required for Flutter Web
- **Test Credentials:** itptest / 1234
- **Protocol:** POST with encrypted payload (triple-hex encoding) + JWT Bearer token

## Critical Conventions
- **Status code 0 = success** for ALL endpoints
- **Server sends ALL DB values as Strings** ("1" not 1, "0.00" not 0.0)
- Every Freezed model MUST have a `_sanitize()` method for String→num conversion
- `getCustomerDetailsRest` uses `statusCode` (camelCase) — only exception to snake_case
- `userNotifications` may come as `[]` (empty array) instead of `0`

## Key Documents
- `PROGRESS.md` — Phase-by-phase implementation status
- `CHANGES_LOG.md` — All changes made
- `IMPLEMENTATION_PLAN_V2.md` — Master plan (2,203 lines)
- `screen_docs/18_flutter_validation_report.md` — Latest validation against real API
- `screen_docs/12_server_api_contracts.md` — Server PHP code analysis
- `screen_docs/14_comprehensive_api_request_response.md` — Real API responses
- `screen_docs/15-17_android_business_logic_*.md` — Android business rules
- `test-results/all_api_responses.json` — Playwright captured responses (37 endpoints)

## Architecture
- **State:** Riverpod 3.x with Notifier pattern
- **Models:** Freezed + json_serializable (sealed class pattern)
- **Navigation:** GoRouter with StatefulShellRoute.indexedStack (5-tab bottom nav)
- **Theme:** AppColors ThemeExtension (red palette from POC), Plus Jakarta Sans + JetBrains Mono
- **Encryption:** Custom PayloadEncryption matching PHP Encryption_lib

## Tabs (Dashboard)
- Active (from_dashboard=4), Inactive (5), Fresh/Unassigned (2), Assigned (1)
- Fresh STBs → tap to create new customer with STB pre-filled
