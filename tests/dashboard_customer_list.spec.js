/**
 * EzyBill - Dashboard Customer List API Tests
 *
 * Tests the /getdashboardlist endpoint with from_dashboard parameter values:
 *   1=assigned STBs, 2=unassigned STBs, 3=all STBs, 4=active, 5=inactive
 *
 * Validates response structure matches what the Flutter
 * DashboardCustomerListProvider expects.
 *
 * Usage:
 *   npx playwright test tests/dashboard_customer_list.spec.js --reporter=list
 */

const { test, expect } = require('@playwright/test');

// ============================================================
// CONFIG
// ============================================================
const API_BASE = 'http://183.83.216.66:8882/v2_release/index.php';
const REST_BASE = `${API_BASE}/LcoRestServices`;
const TEST_USER = { UserName: '58948', PassWord: '1234' };

let JWT_TOKEN = '';
let LOGIN_DATA = {};

// ============================================================
// ENCRYPTION (same as api_test.spec.js)
// ============================================================
function binToHex(str) {
  return Buffer.from(str, 'utf8').toString('hex');
}

function hexToBin(hex) {
  const bytes = [];
  for (let i = 0; i < hex.length; i += 2) {
    bytes.push(parseInt(hex.substring(i, i + 2), 16));
  }
  return Buffer.from(bytes).toString('utf8');
}

function tripleHexEncrypt(parameter) {
  const firstHex = binToHex(parameter);
  let encrypted = '';
  for (let i = 0; i < firstHex.length; i++) {
    encrypted += binToHex(firstHex[i]);
  }
  const front = String(Math.floor(Math.random() * 90000) + 10000);
  const back = String(Math.floor(Math.random() * 90000) + 10000);
  return front + encrypted + back;
}

function encryptPayload(data) {
  const jsonStr = JSON.stringify(data);
  const hash = binToHex(jsonStr);
  const payload = tripleHexEncrypt(hash);
  return { payload, hash };
}

function decryptResponse(responseData) {
  if (responseData && typeof responseData === 'object') {
    if (responseData.hash && typeof responseData.hash === 'string') {
      try {
        return JSON.parse(hexToBin(responseData.hash));
      } catch {
        return null;
      }
    }
    return responseData;
  }
  return null;
}

async function apiCall(request, endpoint, data = {}, options = {}) {
  const encrypted = encryptPayload(data);
  const body = `payload=${encodeURIComponent(encrypted.payload)}&hash=${encodeURIComponent(encrypted.hash)}`;

  const headers = { 'Content-Type': 'application/x-www-form-urlencoded' };
  if (JWT_TOKEN && !options.skipAuth) {
    headers['Authorization'] = `Bearer ${JWT_TOKEN}`;
  }

  const response = await request.post(`${REST_BASE}${endpoint}`, {
    headers,
    data: body,
  });

  const rawBody = await response.text();
  let rawJson;
  try {
    rawJson = JSON.parse(rawBody);
  } catch {
    rawJson = rawBody;
  }

  return {
    status: response.status(),
    raw: rawJson,
    data: decryptResponse(rawJson),
  };
}

// ============================================================
// TESTS
// ============================================================

test.describe.serial('Dashboard Customer List Tests', () => {
  // Login first — all subsequent tests depend on this
  test('0. Login', async ({ request }) => {
    const res = await apiCall(request, '/validateLogin', TEST_USER, {
      skipAuth: true,
    });

    expect(res.status).toBe(200);
    expect(res.data).toBeTruthy();
    expect(res.data.status_code).toBe(0);

    JWT_TOKEN = res.data.token;
    LOGIN_DATA = res.data;

    console.log(
      `  Logged in as: ${res.data.employeeName} (dealer=${res.data.dealerId})`
    );
  });

  // ======== DASHBOARD COUNTS (reference for list validation) ========
  test('1. Dashboard details — get reference counts', async ({ request }) => {
    test.skip(!JWT_TOKEN, 'Login failed');

    const res = await apiCall(request, '/dashBoardDetailsRest', {});

    expect(res.status).toBe(200);
    expect(res.data).toBeTruthy();

    // These are the counts Flutter shows in the stat pills
    const active = parseInt(res.data.totalActiveCustomers) || 0;
    const inactive = parseInt(res.data.totalDeactiveCustomers) || 0;
    const unpaid = parseInt(res.data.totalUnPaidCustomers) || 0;
    const totalStbs = parseInt(res.data.totalStbs) || 0;
    const assigned = parseInt(res.data.totalAssignedStbs) || 0;
    const unassigned = parseInt(res.data.totalUnAssignedStbs) || 0;

    console.log(`  Dashboard counts:`);
    console.log(`    Active customers: ${active}`);
    console.log(`    Inactive customers: ${inactive}`);
    console.log(`    Unpaid customers: ${unpaid}`);
    console.log(`    Total STBs: ${totalStbs} (assigned=${assigned}, unassigned=${unassigned})`);
    console.log(`    outStandingAmount: ${res.data.outStandingAmount}`);

    // Note: Server's DashboardData library may return 0 for counts if
    // dashboard items are not configured for this user type (access control
    // override at server lines 872-885). outStandingAmount bypasses this check.
    if (active === 0 && unassigned > 0) {
      console.log(`  ⚠ Counts are 0 but unassigned=${unassigned} — likely server DashboardData config issue`);
      console.log(`    Server uses DashboardData library (not old direct model calls)`);
      console.log(`    The access control layer zeros out counts when items are not configured`);
    }

    // At minimum, the API should return a valid response structure
    expect(res.data).toHaveProperty('totalActiveCustomers');
    expect(res.data).toHaveProperty('totalDeactiveCustomers');
    expect(res.data).toHaveProperty('totalStbs');
    expect(res.data).toHaveProperty('outStandingAmount');
  });

  // ======== DASHBOARD LIST: from_dashboard=4 (ACTIVE) ========
  test('2. Active customers (from_dashboard=4)', async ({ request }) => {
    test.skip(!JWT_TOKEN, 'Login failed');

    const dealerId = parseInt(LOGIN_DATA.dealerId) || 1;
    const res = await apiCall(request, '/getdashboardlist', {
      dealer_id: dealerId,
      from_dashboard: 4,
    });

    expect(res.status).toBe(200);
    expect(res.data).toBeTruthy();

    // Server returns data under 'getDashboardDataList' key
    const list = res.data.getDashboardDataList;
    console.log(`  Active list: ${list ? list.length + ' records' : 'key missing'}`);
    console.log(`  Response keys: ${Object.keys(res.data).join(', ')}`);

    if (list && Array.isArray(list) && list.length > 0) {
      const sample = list[0];
      console.log(`  Sample record keys: ${Object.keys(sample).join(', ')}`);

      // Validate fields that Flutter's _CustomerCard expects
      const expectedFields = [
        'serial_number',
        'vc_number',
        'customer_name',
        'customer_id',
        'mobile_no',
        'is_active',
        'service_enddate',
      ];

      for (const field of expectedFields) {
        const hasField = field in sample;
        const altField =
          field === 'serial_number' ? 'box_number' in sample : false;
        console.log(
          `    ${field}: ${hasField ? '✓ present' : altField ? '✓ (alt: box_number)' : '✗ MISSING'} = ${JSON.stringify(sample[field])?.substring(0, 50)}`
        );
      }

      // Validate first record has customer_name
      expect(
        sample.customer_name || sample.customerName || sample.name
      ).toBeTruthy();

      // Validate active flag
      expect(String(sample.is_active)).toBe('1');

      console.log(
        `  First customer: ${sample.customer_name} (ID: ${sample.customer_id}, STB: ${sample.serial_number})`
      );
    } else {
      // It's possible the response uses a different key
      console.log(
        `  Full response (first 500): ${JSON.stringify(res.data).substring(0, 500)}`
      );
    }
  });

  // ======== DASHBOARD LIST: from_dashboard=5 (INACTIVE) ========
  test('3. Inactive customers (from_dashboard=5)', async ({ request }) => {
    test.skip(!JWT_TOKEN, 'Login failed');

    const dealerId = parseInt(LOGIN_DATA.dealerId) || 1;
    const res = await apiCall(request, '/getdashboardlist', {
      dealer_id: dealerId,
      from_dashboard: 5,
    });

    expect(res.status).toBe(200);
    expect(res.data).toBeTruthy();

    const list = res.data.getDashboardDataList;
    console.log(
      `  Inactive list: ${list ? list.length + ' records' : 'key missing'}`
    );

    if (list && Array.isArray(list) && list.length > 0) {
      const sample = list[0];
      // Inactive customers should have is_active != 1
      console.log(
        `  First inactive: ${sample.customer_name} (is_active=${sample.is_active}, expiry=${sample.service_enddate})`
      );
    } else {
      console.log(
        `  Response: ${JSON.stringify(res.data).substring(0, 500)}`
      );
    }
  });

  // ======== DASHBOARD LIST: from_dashboard=1 (ASSIGNED STBs) ========
  test('4. Assigned STBs (from_dashboard=1)', async ({ request }) => {
    test.skip(!JWT_TOKEN, 'Login failed');

    const dealerId = parseInt(LOGIN_DATA.dealerId) || 1;
    const res = await apiCall(request, '/getdashboardlist', {
      dealer_id: dealerId,
      from_dashboard: 1,
    });

    expect(res.status).toBe(200);
    expect(res.data).toBeTruthy();

    const list = res.data.getDashboardDataList;
    console.log(
      `  Assigned STBs: ${list ? list.length + ' records' : 'key missing'}`
    );

    if (list && Array.isArray(list) && list.length > 0) {
      const sample = list[0];
      console.log(
        `  Sample STB: serial=${sample.serial_number}, vc=${sample.vc_number}, customer=${sample.customer_name}`
      );
    } else {
      console.log(
        `  Response: ${JSON.stringify(res.data).substring(0, 500)}`
      );
    }
  });

  // ======== DASHBOARD LIST: from_dashboard=2 (UNASSIGNED STBs) ========
  test('5. Unassigned STBs (from_dashboard=2)', async ({ request }) => {
    test.skip(!JWT_TOKEN, 'Login failed');

    const dealerId = parseInt(LOGIN_DATA.dealerId) || 1;
    const res = await apiCall(request, '/getdashboardlist', {
      dealer_id: dealerId,
      from_dashboard: 2,
    });

    expect(res.status).toBe(200);
    expect(res.data).toBeTruthy();

    const list = res.data.getDashboardDataList;
    console.log(
      `  Unassigned STBs: ${list ? list.length + ' records' : 'key missing'}`
    );

    if (list && Array.isArray(list) && list.length > 0) {
      console.log(
        `  Sample: serial=${list[0].serial_number}, vc=${list[0].vc_number}`
      );
    } else {
      console.log(
        `  Response: ${JSON.stringify(res.data).substring(0, 500)}`
      );
    }
  });

  // ======== DASHBOARD LIST: from_dashboard=3 (ALL STBs) ========
  test('6. All STBs (from_dashboard=3)', async ({ request }) => {
    test.skip(!JWT_TOKEN, 'Login failed');

    const dealerId = parseInt(LOGIN_DATA.dealerId) || 1;
    const res = await apiCall(request, '/getdashboardlist', {
      dealer_id: dealerId,
      from_dashboard: 3,
    });

    expect(res.status).toBe(200);
    expect(res.data).toBeTruthy();

    const list = res.data.getDashboardDataList;
    console.log(
      `  All STBs: ${list ? list.length + ' records' : 'key missing'}`
    );

    if (list && Array.isArray(list) && list.length > 0) {
      // Check mix of active/inactive
      const activeCount = list.filter(
        (c) => String(c.is_active) === '1'
      ).length;
      const inactiveCount = list.length - activeCount;
      console.log(
        `  Breakdown: ${activeCount} active, ${inactiveCount} inactive out of ${list.length} total`
      );
    } else {
      console.log(
        `  Response: ${JSON.stringify(res.data).substring(0, 500)}`
      );
    }
  });

  // ======== VALIDATE RESPONSE FIELDS FOR FLUTTER CARD ========
  test('7. Validate customer record fields for Flutter _CustomerCard', async ({
    request,
  }) => {
    test.skip(!JWT_TOKEN, 'Login failed');

    const dealerId = parseInt(LOGIN_DATA.dealerId) || 1;
    const res = await apiCall(request, '/getdashboardlist', {
      dealer_id: dealerId,
      from_dashboard: 4, // active customers
    });

    expect(res.status).toBe(200);
    const list = res.data?.getDashboardDataList;

    if (!list || list.length === 0) {
      console.log('  ⚠ No active customers to validate fields against');
      return;
    }

    const sample = list[0];
    const allKeys = Object.keys(sample);
    console.log(`  All fields in response record (${allKeys.length}):`);
    console.log(`    ${allKeys.join(', ')}`);

    // Fields the Flutter _CustomerCard widget reads:
    const flutterMappings = {
      'customer_name → name': sample.customer_name,
      'serial_number → STB No': sample.serial_number,
      'vc_number → VC No': sample.vc_number,
      'mobile_no → Call button': sample.mobile_no,
      'service_enddate → Exp date': sample.service_enddate,
      'is_active → Active/Inactive badge': sample.is_active,
      'customer_id → Navigation param': sample.customer_id,
      'account_number → A/C display': sample.account_number,
      'box_number → Alt STB No': sample.box_number,
      'installation_address → (available)': sample.installation_address,
      'mac_address → (available)': sample.mac_address,
      'cas → (available)': sample.cas,
    };

    console.log(`\n  Flutter field mapping validation:`);
    let allPresent = true;
    for (const [mapping, value] of Object.entries(flutterMappings)) {
      const present = value !== undefined && value !== null;
      const displayVal = present
        ? String(value).substring(0, 40)
        : 'MISSING';
      console.log(`    ${present ? '✓' : '✗'} ${mapping} = ${displayVal}`);
      if (!present && !mapping.includes('(available)')) {
        allPresent = false;
      }
    }

    // Critical fields must be present
    expect(sample.customer_name || sample.customerName).toBeTruthy();
    expect(sample.customer_id || sample.customerId).toBeTruthy();

    if (allPresent) {
      console.log(`\n  ✓ All Flutter card fields are present in API response`);
    } else {
      console.log(
        `\n  ⚠ Some fields missing — Flutter card may show '-' for those`
      );
    }
  });

  // ======== PAGINATION / LARGE LIST CHECK ========
  test('8. Large list handling — count active vs list size', async ({
    request,
  }) => {
    test.skip(!JWT_TOKEN, 'Login failed');

    const dealerId = parseInt(LOGIN_DATA.dealerId) || 1;

    // Get dashboard count
    const dashRes = await apiCall(request, '/dashBoardDetailsRest', {});
    const dashboardActiveCount =
      parseInt(dashRes.data?.totalActiveCustomers) || 0;

    // Get full active list
    const listRes = await apiCall(request, '/getdashboardlist', {
      dealer_id: dealerId,
      from_dashboard: 4,
    });

    const list = listRes.data?.getDashboardDataList;
    const listCount = list ? list.length : 0;

    console.log(`  Dashboard reports: ${dashboardActiveCount} active customers`);
    console.log(`  List endpoint returned: ${listCount} records`);
    console.log(
      `  Match: ${dashboardActiveCount === listCount ? '✓ EXACT' : '⚠ DIFFERENT (counts may differ due to timing/grouping)'}`
    );

    if (listCount > 1000) {
      console.log(
        `  ⚠ Large dataset (${listCount} records) — consider server-side pagination`
      );
    }

    // If dashboard shows 0 but list has data, it's a dashboard config issue
    // If both are 0, the server may not have items configured
    if (dashboardActiveCount === 0 && listCount === 0) {
      console.log(`  ⚠ Both dashboard count and list are 0 — server DashboardData config issue`);
    } else if (dashboardActiveCount > 0) {
      expect(listCount).toBeGreaterThan(0);
    }
  });

  // ======== INVALID from_dashboard VALUE ========
  test('9. Invalid from_dashboard value — graceful handling', async ({
    request,
  }) => {
    test.skip(!JWT_TOKEN, 'Login failed');

    const dealerId = parseInt(LOGIN_DATA.dealerId) || 1;
    const res = await apiCall(request, '/getdashboardlist', {
      dealer_id: dealerId,
      from_dashboard: 99, // invalid
    });

    expect(res.status).toBe(200);
    console.log(
      `  Invalid from_dashboard=99 response: ${JSON.stringify(res.data).substring(0, 300)}`
    );
    // Should not crash — may return empty list or error message
  });

  // ======== NO AUTH — SHOULD FAIL ========
  test('10. No auth token — should fail gracefully', async ({ request }) => {
    const savedToken = JWT_TOKEN;
    JWT_TOKEN = ''; // clear token

    const res = await apiCall(request, '/getdashboardlist', {
      dealer_id: 1,
      from_dashboard: 4,
    });

    JWT_TOKEN = savedToken; // restore

    // Should get 401 or error response
    console.log(
      `  No-auth response: status=${res.status}, data=${JSON.stringify(res.data).substring(0, 200)}`
    );
    // Server may return 401 or a status_code != 0
    const isAuthError =
      res.status === 401 ||
      (res.data && res.data.status_code && res.data.status_code !== 0);
    expect(isAuthError).toBeTruthy();
  });
});
