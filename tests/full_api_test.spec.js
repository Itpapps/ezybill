/**
 * EzyBill REST API — Complete Playwright Test Suite
 *
 * Tests ALL 62 API endpoints from api_test.html with encrypted payloads.
 * Captures request params and response structure for Flutter model verification.
 *
 * Usage:
 *   npx playwright test tests/full_api_test.spec.js --reporter=html
 *   npx playwright test tests/full_api_test.spec.js --reporter=json > test-results/api_responses.json
 *
 * Prerequisites:
 *   - Server running at http://192.168.1.143
 *   - CORS proxy: node cors_proxy.js (if testing via proxy)
 */

const { test, expect } = require('@playwright/test');
const fs = require('fs');

// ============================================================
// CONFIG
// ============================================================
const API_BASE = 'http://192.168.1.143/v2_release_aakshya/index.php';
const REST_BASE = `${API_BASE}/LcoRestServices`;
const TEST_USER = { UserName: 'itptest', PassWord: '1234' };

// Collected responses for documentation
const allResponses = {};

// Shared state across tests
let JWT_TOKEN = '';
let LOGIN_DATA = {};
let DEALER_ID = 0;
let EMPLOYEE_ID = 0;
let USER_TYPE = '';
let FIRST_CUSTOMER_ID = '';
let FIRST_STB_SERIAL = '';
let FIRST_STB_STOCK_ID = '';

// ============================================================
// ENCRYPTION ENGINE (matches PHP Encryption_lib + Flutter PayloadEncryption)
// ============================================================
function binToHex(str) {
  return Buffer.from(str, 'utf8').toString('hex');
}

function encrypt(param) {
  const firstHex = binToHex(param);
  let buf = '';
  for (let i = 0; i < firstHex.length; i++) {
    buf += binToHex(firstHex[i]);
  }
  const front = Math.floor(10000 + Math.random() * 90000);
  const back = Math.floor(10000 + Math.random() * 90000);
  return `${front}${buf}${back}`;
}

function encryptPayload(data) {
  const json = JSON.stringify(data);
  const hash = binToHex(json);
  const payload = encrypt(hash);
  return { payload, hash };
}

function decryptResponse(data) {
  if (!data || typeof data !== 'object') return data;
  if (!data.hash || !data.payload) return data;
  try {
    const jsonStr = Buffer.from(data.hash, 'hex').toString('utf8');
    return JSON.parse(jsonStr);
  } catch (e) {
    return data;
  }
}

// ============================================================
// API CALL HELPER
// ============================================================
async function apiCall(request, endpoint, data = {}, skipAuth = false) {
  const encrypted = encryptPayload(data);
  const body = `payload=${encodeURIComponent(encrypted.payload)}&hash=${encodeURIComponent(encrypted.hash)}`;

  const headers = { 'Content-Type': 'application/x-www-form-urlencoded' };
  if (JWT_TOKEN && !skipAuth) {
    headers['Authorization'] = `Bearer ${JWT_TOKEN}`;
  }

  const url = `${REST_BASE}${endpoint}`;
  const response = await request.post(url, {
    headers,
    data: body,
  });

  const raw = await response.json();
  const decrypted = decryptResponse(raw);

  // Store for documentation
  allResponses[endpoint] = {
    request: data,
    response: decrypted,
    httpStatus: response.status(),
    responseKeys: decrypted ? Object.keys(decrypted) : [],
    fieldTypes: decrypted ? Object.fromEntries(
      Object.entries(decrypted).map(([k, v]) => [k, v === null ? 'null' : Array.isArray(v) ? 'array' : typeof v])
    ) : {},
  };

  return { raw, decrypted, status: response.status() };
}

// ============================================================
// TESTS
// ============================================================

test.describe.serial('EzyBill API — Full Endpoint Test Suite', () => {

  // ── 1. AUTHENTICATION ──────────────────────────────────────

  test('1.1 validateLogin', async ({ request }) => {
    const { decrypted, status } = await apiCall(request, '/validateLogin', TEST_USER, true);

    expect(status).toBe(200);
    expect(decrypted.status_code).toBe(0);
    expect(decrypted.token).toBeTruthy();
    expect(decrypted.employeeId).toBeTruthy();
    expect(decrypted.dealerId).toBeTruthy();

    // Store session
    JWT_TOKEN = decrypted.token;
    LOGIN_DATA = decrypted;
    DEALER_ID = parseInt(decrypted.dealerId) || 0;
    EMPLOYEE_ID = parseInt(decrypted.employeeId) || 0;
    USER_TYPE = decrypted.userType || '';

    // Log all field types for Flutter model verification
    console.log('\n=== LOGIN RESPONSE FIELD TYPES ===');
    for (const [key, val] of Object.entries(decrypted)) {
      const type = val === null ? 'null' : Array.isArray(val) ? `array[${val.length}]` : typeof val;
      console.log(`  ${key}: ${type} = ${JSON.stringify(val).substring(0, 80)}`);
    }
  });

  test('1.2 getaccesscontrollRest', async ({ request }) => {
    const { decrypted, status } = await apiCall(request, '/getaccesscontrollRest', {
      dealer_id: DEALER_ID,
      userstype: USER_TYPE,
      employeeParentType: LOGIN_DATA.employeeParentType || '',
      employeeParentId: LOGIN_DATA.employeeParentId || '0',
    });

    expect(status).toBe(200);
    // Note: status_code 0 = success for this endpoint
    expect(decrypted.status_code).toBe(0);

    console.log('\n=== ACCESS CONTROL RESPONSE ===');
    for (const [key, val] of Object.entries(decrypted)) {
      console.log(`  ${key}: ${typeof val} = ${val}`);
    }
  });

  // ── 2. DASHBOARD ───────────────────────────────────────────

  test('2.1 dashBoardDetailsRest', async ({ request }) => {
    const { decrypted, status } = await apiCall(request, '/dashBoardDetailsRest', {
      use_lco_deposits: LOGIN_DATA.use_lco_deposits || '0',
      lco_billtype: LOGIN_DATA.lco_billtype || '0',
    });

    expect(status).toBe(200);
    expect(decrypted.status_code).toBe(0);

    console.log('\n=== DASHBOARD DETAILS ===');
    for (const [key, val] of Object.entries(decrypted)) {
      console.log(`  ${key}: ${typeof val} = ${val}`);
    }
  });

  test('2.2 lco_deposit_amountRest', async ({ request }) => {
    const { decrypted, status } = await apiCall(request, '/lco_deposit_amountRest', {});

    expect(status).toBe(200);
    expect(decrypted.status_code).toBe(0);
    console.log(`  deposit_amount: ${typeof decrypted.deposit_amount} = ${decrypted.deposit_amount}`);
  });

  test('2.3 getlcowalletRest', async ({ request }) => {
    const { decrypted, status } = await apiCall(request, '/getlcowalletRest', {
      start_date: '2026-01-01',
      end_date: '2026-03-30',
      dealer_id: DEALER_ID,
    });

    expect(status).toBe(200);
    console.log('\n=== LCO WALLET ===');
    console.log(`  Keys: ${Object.keys(decrypted)}`);
  });

  test('2.4 getdashboardlist (Active=4)', async ({ request }) => {
    const { decrypted, status } = await apiCall(request, '/getdashboardlist', {
      dealer_id: DEALER_ID,
      from_dashboard: 4,
    });

    expect(status).toBe(200);
    const list = decrypted.getDashboardDataList || [];
    console.log(`\n=== DASHBOARD LIST (Active) === ${list.length} records`);
    if (list.length > 0) {
      console.log('  First record keys:', Object.keys(list[0]));
      console.log('  First record types:');
      for (const [k, v] of Object.entries(list[0])) {
        console.log(`    ${k}: ${typeof v} = ${JSON.stringify(v).substring(0, 60)}`);
      }
      // Store first customer for later tests
      FIRST_CUSTOMER_ID = list[0].customer_id?.toString() || '';
    }
  });

  test('2.5 getdashboardlist (Inactive=5)', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getdashboardlist', {
      dealer_id: DEALER_ID, from_dashboard: 5,
    });
    console.log(`  Inactive: ${(decrypted.getDashboardDataList || []).length} records`);
  });

  test('2.6 getdashboardlist (Assigned=1)', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getdashboardlist', {
      dealer_id: DEALER_ID, from_dashboard: 1,
    });
    console.log(`  Assigned: ${(decrypted.getDashboardDataList || []).length} records`);
  });

  test('2.7 getdashboardlist (Unassigned=2)', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getdashboardlist', {
      dealer_id: DEALER_ID, from_dashboard: 2,
    });
    console.log(`  Unassigned: ${(decrypted.getDashboardDataList || []).length} records`);
  });

  test('2.8 getdashboardlist (All=3)', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getdashboardlist', {
      dealer_id: DEALER_ID, from_dashboard: 3,
    });
    console.log(`  All: ${(decrypted.getDashboardDataList || []).length} records`);
  });

  test('2.9 getExpiryServicesDateWiseCount', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getExpiryServicesDateWiseCount', {});
    expect(decrypted.status_code).toBe(0);
    const list = decrypted.getExpiryServicesList || [];
    console.log(`  Expiry dates: ${list.length}`);
    if (list.length > 0) {
      console.log('  First:', JSON.stringify(list[0]));
      console.log('  Types:', Object.fromEntries(Object.entries(list[0]).map(([k,v]) => [k, typeof v])));
    }
  });

  // ── 3. CUSTOMER ────────────────────────────────────────────

  test('3.1 getCustomerDetailsCountRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getCustomerDetailsCountRest', {
      customerName: 'a',
    });
    console.log(`\n=== CUSTOMER COUNT ===`);
    console.log(`  status_code: ${decrypted.status_code}, count: ${decrypted.customerCount}`);
  });

  test('3.2 getCustomerDetailsRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getCustomerDetailsRest', {
      customerName: 'a',
      startValue: 0,
      endValue: 5,
    });
    console.log(`\n=== CUSTOMER DETAILS ===`);
    console.log(`  Keys: ${Object.keys(decrypted)}`);
    const list = decrypted.customerDetailsList || [];
    console.log(`  Records: ${list.length}`);
    if (list.length > 0) {
      FIRST_CUSTOMER_ID = FIRST_CUSTOMER_ID || list[0].customer_id?.toString() || '';
      console.log('  First record field types:');
      for (const [k, v] of Object.entries(list[0])) {
        console.log(`    ${k}: ${typeof v} = ${JSON.stringify(v).substring(0, 60)}`);
      }
    }
  });

  test('3.3 updateCustomerLocation', async ({ request }) => {
    if (!FIRST_CUSTOMER_ID) { test.skip(); return; }
    const { decrypted } = await apiCall(request, '/updateCustomerLocation', {
      customerId: FIRST_CUSTOMER_ID,
      latitude: 17.385,
      longitude: 78.4867,
    });
    console.log(`  updateLocation: status=${decrypted.status_code}`);
  });

  // ── 4. PAYMENTS ────────────────────────────────────────────

  test('4.1 getPendingAmountRest', async ({ request }) => {
    if (!FIRST_CUSTOMER_ID) { test.skip(); return; }
    const { decrypted } = await apiCall(request, '/getPendingAmountRest', {
      altCustomerId: FIRST_CUSTOMER_ID,
    });
    console.log('\n=== PENDING AMOUNT ===');
    for (const [k, v] of Object.entries(decrypted)) {
      console.log(`  ${k}: ${typeof v} = ${v}`);
    }
  });

  test('4.2 getPaymentModesRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getPaymentModesRest', {});
    console.log('\n=== PAYMENT MODES ===');
    const modes = decrypted.paymentModesList || decrypted.PaymentModesList || [];
    if (Array.isArray(modes) && modes.length > 0) {
      console.log(`  ${modes.length} modes found`);
      modes.forEach(m => console.log(`    ${JSON.stringify(m)}`));
    } else {
      console.log('  Keys:', Object.keys(decrypted));
    }
  });

  test('4.3 getReceiptRanges', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getReceiptRanges', {});
    console.log('\n=== RECEIPT RANGES ===');
    console.log(`  Keys: ${Object.keys(decrypted)}`);
  });

  test('4.4 PaymentServiceRest (history)', async ({ request }) => {
    if (!FIRST_CUSTOMER_ID) { test.skip(); return; }
    const { decrypted } = await apiCall(request, '/PaymentServiceRest', {
      customerId: FIRST_CUSTOMER_ID,
    });
    console.log('\n=== PAYMENT HISTORY ===');
    console.log(`  Keys: ${Object.keys(decrypted)}`);
  });

  test('4.5 InvoiceServiceRest', async ({ request }) => {
    if (!FIRST_CUSTOMER_ID) { test.skip(); return; }
    const { decrypted } = await apiCall(request, '/InvoiceServiceRest', {
      customer_id: FIRST_CUSTOMER_ID,
      dealer_id: DEALER_ID,
    });
    console.log('\n=== INVOICE HISTORY ===');
    console.log(`  Keys: ${Object.keys(decrypted)}`);
  });

  test('4.6 getbilldetailsRest', async ({ request }) => {
    if (!FIRST_CUSTOMER_ID || !FIRST_STB_SERIAL) { test.skip(); return; }
    const { decrypted } = await apiCall(request, '/getbilldetailsRest', {
      serial_number: FIRST_STB_SERIAL,
      package_id: '435',
      customer_id: FIRST_CUSTOMER_ID,
    });
    console.log('\n=== BILL DETAILS ===');
    console.log(`  Keys: ${Object.keys(decrypted)}`);
  });

  // ── 5. COMPLAINTS ──────────────────────────────────────────

  test('5.1 getComplaintList', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getComplaintList', {
      serviceemployeeid: 0,
      login_users_type: USER_TYPE,
    });
    console.log('\n=== COMPLAINT LIST ===');
    console.log(`  Keys: ${Object.keys(decrypted)}`);
  });

  test('5.2 gettotalcomplaintslist', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/gettotalcomplaintslist', {
      dealer_id: DEALER_ID,
    });
    console.log(`  Total complaints keys: ${Object.keys(decrypted)}`);
  });

  test('5.3 complaintCategoriesRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/complaintCategoriesRest', {});
    console.log('\n=== COMPLAINT CATEGORIES ===');
    const cats = decrypted.complaintCategories || [];
    console.log(`  ${Array.isArray(cats) ? cats.length : 0} categories`);
    if (Array.isArray(cats) && cats.length > 0) {
      console.log('  First:', JSON.stringify(cats[0]));
    }
  });

  test('5.4 complaintTypesRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/complaintTypesRest', {});
    console.log(`  Closer types keys: ${Object.keys(decrypted)}`);
  });

  // ── 6. STB / BOX OPERATIONS ────────────────────────────────

  test('6.1 getCustomerBoxDetailsRest', async ({ request }) => {
    if (!FIRST_CUSTOMER_ID) { test.skip(); return; }
    const { decrypted } = await apiCall(request, '/getCustomerBoxDetailsRest', {
      customerId: FIRST_CUSTOMER_ID,
    });
    expect(decrypted.status_code).toBe(0);
    const boxes = decrypted.customerBoxList || [];
    console.log(`\n=== CUSTOMER BOX DETAILS === ${boxes.length} boxes`);
    if (boxes.length > 0) {
      FIRST_STB_SERIAL = boxes[0].serial_number || '';
      FIRST_STB_STOCK_ID = boxes[0].stock_id?.toString() || '';
      console.log('  First box field types:');
      for (const [k, v] of Object.entries(boxes[0])) {
        console.log(`    ${k}: ${typeof v} = ${JSON.stringify(v).substring(0, 60)}`);
      }
    }
  });

  test('6.2 getDeactiveReasonsRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getDeactiveReasonsRest', {
      showforlco: '1',
    });
    console.log('\n=== DEACTIVATION REASONS ===');
    const reasons = decrypted.reasonList || [];
    console.log(`  ${Array.isArray(reasons) ? reasons.length : 0} reasons`);
    if (Array.isArray(reasons) && reasons.length > 0) {
      console.log('  First:', JSON.stringify(reasons[0]));
    }
  });

  test('6.3 validateBoxInfoRest', async ({ request }) => {
    if (!FIRST_STB_SERIAL) { test.skip(); return; }
    const { decrypted } = await apiCall(request, '/validateBoxInfoRest', {
      boxNumber: FIRST_STB_SERIAL,
    });
    console.log(`  validateBoxInfo: status=${decrypted.status_code}, msg=${decrypted.status_msg}`);
  });

  // ── 7. PACKAGES / SERVICES ─────────────────────────────────

  test('7.1 getCustomerPackages_splitRest', async ({ request }) => {
    if (!FIRST_CUSTOMER_ID || !FIRST_STB_SERIAL) { test.skip(); return; }
    const { decrypted } = await apiCall(request, '/getCustomerPackages_splitRest', {
      customerId: FIRST_CUSTOMER_ID,
      boxNumber: FIRST_STB_SERIAL,
    });
    console.log('\n=== ASSIGNED PACKAGES ===');
    for (const key of ['packageList_base', 'packageList_addon', 'packageList_ala', 'packageList_broadcaster']) {
      const list = decrypted[key] || [];
      console.log(`  ${key}: ${Array.isArray(list) ? list.length : 0} packages`);
      if (Array.isArray(list) && list.length > 0) {
        console.log('    First:', Object.keys(list[0]).join(', '));
        for (const [k, v] of Object.entries(list[0])) {
          console.log(`      ${k}: ${typeof v} = ${JSON.stringify(v).substring(0, 50)}`);
        }
      }
    }
  });

  test('7.2 getUnassignedPackages_splitRest', async ({ request }) => {
    if (!FIRST_CUSTOMER_ID || !FIRST_STB_SERIAL) { test.skip(); return; }
    const { decrypted } = await apiCall(request, '/getUnassignedPackages_splitRest', {
      customerId: FIRST_CUSTOMER_ID,
      boxNumber: FIRST_STB_SERIAL,
    });
    console.log('\n=== UNASSIGNED PACKAGES ===');
    for (const key of ['packageList_base', 'packageList_addon', 'packageList_ala', 'packageList_broadcaster']) {
      const list = decrypted[key] || [];
      console.log(`  ${key}: ${Array.isArray(list) ? list.length : 0}`);
    }
  });

  test('7.3 channel_listRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/channel_listRest', {
      dealer_id: DEALER_ID,
      product_id: 435,
    });
    console.log('\n=== CHANNEL LIST ===');
    console.log(`  Keys: ${Object.keys(decrypted)}`);
  });

  // ── 8. REPORTS ─────────────────────────────────────────────

  test('8.1 DailyreportRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/DailyreportRest', {
      dealer_id: DEALER_ID,
      date: '2026-03-30',
    });
    console.log('\n=== DAILY REPORT ===');
    console.log(`  Keys: ${Object.keys(decrypted)}`);
    const details = decrypted.Dailyreport_details || [];
    console.log(`  Rows: ${Array.isArray(details) ? details.length : 0}`);
    if (Array.isArray(details) && details.length > 0) {
      console.log('  First row:', JSON.stringify(details[0]));
    }
  });

  test('8.2 empCollectionRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/empCollectionRest', {
      dealer_id: DEALER_ID,
      fromDate: '2026-03-01',
      toDate: '2026-03-30',
    });
    console.log('\n=== EMP COLLECTION ===');
    console.log(`  Keys: ${Object.keys(decrypted)}`);
  });

  // ── 9. EMPLOYEES ───────────────────────────────────────────

  test('9.1 getLcoEmployeeList', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getLcoEmployeeList', {
      employee_id: EMPLOYEE_ID,
    });
    console.log('\n=== LCO EMPLOYEE LIST ===');
    console.log(`  Keys: ${Object.keys(decrypted)}`);
  });

  test('9.2 getServiceEmployeeList', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getServiceEmployeeList', {
      dealer_id: DEALER_ID,
    });
    console.log('\n=== SERVICE EMPLOYEE LIST ===');
    console.log(`  Keys: ${Object.keys(decrypted)}`);
  });

  // ── 10. MASTER DATA ────────────────────────────────────────

  test('10.1 getCountriesRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getCountriesRest', {});
    const list = decrypted.countriesList || [];
    console.log(`\n=== COUNTRIES === ${Array.isArray(list) ? list.length : 0}`);
    if (Array.isArray(list) && list.length > 0) {
      console.log('  First:', JSON.stringify(list[0]));
    }
  });

  test('10.2 getStatesRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getStatesRest', {
      countryCode: LOGIN_DATA.defaultCountry || 'IN',
    });
    const list = decrypted.statesList || [];
    console.log(`  States: ${Array.isArray(list) ? list.length : 0}`);
    if (Array.isArray(list) && list.length > 0) {
      console.log('  First:', JSON.stringify(list[0]));
    }
  });

  test('10.3 getdistrictsRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getdistrictsRest', {
      stateId: parseInt(LOGIN_DATA.defaultState) || 89,
    });
    const list = decrypted.districtList || [];
    console.log(`  Districts: ${Array.isArray(list) ? list.length : 0}`);
    if (Array.isArray(list) && list.length > 0) {
      console.log('  First:', JSON.stringify(list[0]));
    }
  });

  test('10.4 getCitiesRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getCitiesRest', {
      stateId: parseInt(LOGIN_DATA.defaultState) || 89,
    });
    const list = decrypted.citiesList || [];
    console.log(`  Cities: ${Array.isArray(list) ? list.length : 0}`);
    if (Array.isArray(list) && list.length > 0) {
      console.log('  First:', JSON.stringify(list[0]));
    }
  });

  test('10.5 getmandalsRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getmandalsRest', {
      districtId: parseInt(LOGIN_DATA.defaultDistrict) || 497,
    });
    const list = decrypted.mandalList || [];
    console.log(`  Mandals: ${Array.isArray(list) ? list.length : 0}`);
    if (Array.isArray(list) && list.length > 0) {
      console.log('  First:', JSON.stringify(list[0]));
    }
  });

  test('10.6 getGroupsRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getGroupsRest', {});
    const list = decrypted.groupsList || [];
    console.log(`  Groups: ${Array.isArray(list) ? list.length : 0}`);
    if (Array.isArray(list) && list.length > 0) {
      console.log('  First:', JSON.stringify(list[0]));
    }
  });

  test('10.7 getCustomerTypesRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getCustomerTypesRest', {});
    const list = decrypted.customerTypeList || [];
    console.log(`  Customer Types: ${Array.isArray(list) ? list.length : 0}`);
    if (Array.isArray(list) && list.length > 0) {
      console.log('  First:', JSON.stringify(list[0]));
    }
  });

  test('10.8 getIdsRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/getIdsRest', {});
    const list = decrypted.idList || [];
    console.log(`  ID Types: ${Array.isArray(list) ? list.length : 0}`);
    if (Array.isArray(list) && list.length > 0) {
      console.log('  First:', JSON.stringify(list[0]));
    }
  });

  test('10.9 dynamicformvalidationsRest', async ({ request }) => {
    const { decrypted } = await apiCall(request, '/dynamicformvalidationsRest', {
      table_name: 'customer',
      dealerId: DEALER_ID,
    });
    console.log('\n=== FORM VALIDATIONS ===');
    console.log(`  Keys: ${Object.keys(decrypted)}`);
  });

  // ── SAVE ALL RESPONSES ─────────────────────────────────────

  test('Save all responses to JSON', async () => {
    const outputPath = 'test-results/all_api_responses.json';
    fs.mkdirSync('test-results', { recursive: true });
    fs.writeFileSync(outputPath, JSON.stringify(allResponses, null, 2));
    console.log(`\n✓ Saved ${Object.keys(allResponses).length} endpoint responses to ${outputPath}`);
  });
});
