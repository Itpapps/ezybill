/**
 * EzyBill REST API - Playwright Test Suite
 *
 * Tests all API endpoints with encrypted payloads, validates responses
 * against the Flutter app's expected field structure.
 *
 * Usage:
 *   npx playwright test tests/api_test.spec.js --reporter=html
 *
 * Setup:
 *   npm init -y && npm i -D @playwright/test
 */

const { test, expect } = require('@playwright/test');

// ============================================================
// CONFIG
// ============================================================
const API_BASE = 'http://183.83.216.66:8882/v2_release/index.php';
const REST_BASE = `${API_BASE}/LcoRestServices`;
const TEST_USER = { UserName: '58948', PassWord: '1234' };

// Store across tests
let JWT_TOKEN = '';
let LOGIN_DATA = {};

// ============================================================
// ENCRYPTION ENGINE (matches PHP Encryption_lib)
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

function decryptHash(hash) {
  try {
    return JSON.parse(hexToBin(hash));
  } catch {
    return null;
  }
}

function decryptResponse(responseData) {
  if (responseData && typeof responseData === 'object') {
    if (responseData.hash && typeof responseData.hash === 'string') {
      return decryptHash(responseData.hash);
    }
    return responseData;
  }
  return null;
}

// ============================================================
// HELPER: Make encrypted API call
// ============================================================
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
  try { rawJson = JSON.parse(rawBody); } catch { rawJson = rawBody; }

  const decrypted = decryptResponse(rawJson);

  return {
    status: response.status(),
    raw: rawJson,
    data: decrypted,
    encrypted: { payload: encrypted.payload.substring(0, 30) + '...', hash: encrypted.hash.substring(0, 30) + '...' },
  };
}

// ============================================================
// TEST SUITES
// ============================================================

test.describe.serial('EzyBill API Tests', () => {

  // ======== AUTH ========
  test.describe('1. Authentication', () => {

    test('1.1 Login - validateLogin', async ({ request }) => {
      const res = await apiCall(request, '/validateLogin', TEST_USER, { skipAuth: true });

      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      expect(res.data.status_code).toBe(0);
      expect(res.data.status_msg).toBe('Success');

      // Validate fields used by Flutter AuthProvider
      expect(res.data.token).toBeTruthy();
      expect(res.data.employeeId).toBeTruthy();
      expect(res.data.dealerId).toBeTruthy();
      expect(res.data.userType).toBeTruthy();
      expect(res.data.first_name).toBeDefined();
      expect(res.data.last_name).toBeDefined();
      expect(res.data.email).toBeDefined();
      expect(res.data.phone).toBeDefined();
      expect(res.data.lcoCode).toBeTruthy();
      expect(res.data.business_name).toBeTruthy();
      expect(res.data.employeeName).toBeTruthy();

      // Config fields used by the app
      expect(res.data).toHaveProperty('useCRF');
      expect(res.data).toHaveProperty('useCAF');
      expect(res.data).toHaveProperty('useDiscount');
      expect(res.data).toHaveProperty('useLcoDeposit');
      expect(res.data).toHaveProperty('deposit_amount');
      expect(res.data).toHaveProperty('defaultCountry');
      expect(res.data).toHaveProperty('defaultState');
      expect(res.data).toHaveProperty('defaultDistrict');
      expect(res.data).toHaveProperty('blockpayment');
      expect(res.data).toHaveProperty('appMenuFormat');
      expect(res.data).toHaveProperty('CURRENCY_CODE');
      expect(res.data).toHaveProperty('AUTO_RECEIPT_NUMBER');
      expect(res.data).toHaveProperty('config_values_array');
      expect(res.data).toHaveProperty('stb_pairing');
      expect(res.data).toHaveProperty('stb_unpairing');
      expect(res.data).toHaveProperty('show_service_extension');

      // Save for subsequent tests
      JWT_TOKEN = res.data.token;
      LOGIN_DATA = res.data;

      console.log(`  ✓ Logged in as: ${res.data.employeeName} (${res.data.lcoCode})`);
      console.log(`  ✓ JWT Token: ${JWT_TOKEN.substring(0, 50)}...`);
      console.log(`  ✓ Employee ID: ${res.data.employeeId}, Dealer ID: ${res.data.dealerId}`);
    });

    test('1.2 Access Control - getaccesscontrollRest', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed, skipping');

      const res = await apiCall(request, '/getaccesscontrollRest', {
        authToken: JWT_TOKEN,
        dealer_id: parseInt(LOGIN_DATA.dealerId) || 1,
        userstype: LOGIN_DATA.userType || 'RESELLER',
        employeeParentType: LOGIN_DATA.employeeParentType || '',
        employeeParentId: LOGIN_DATA.employeeParentId || '',
      });

      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ Access control response keys: ${Object.keys(res.data).join(', ')}`);
    });
  });

  // ======== DASHBOARD ========
  test.describe('2. Dashboard', () => {

    test('2.1 Dashboard Details', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/dashBoardDetailsRest', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ Dashboard keys: ${Object.keys(res.data).slice(0, 10).join(', ')}...`);
    });

    test('2.2 LCO Deposit Amount', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/lco_deposit_amountRest', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ Deposit amount response: ${JSON.stringify(res.data).substring(0, 150)}`);
    });

    test('2.3 LCO Wallet', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/getlcowalletRest', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ Wallet response keys: ${Object.keys(res.data).join(', ')}`);
    });

    test('2.4 Dashboard List', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/getdashboardlist', {});
      expect(res.status).toBe(200);
      console.log(`  ✓ Dashboard list: ${JSON.stringify(res.data).substring(0, 150)}`);
    });

    test('2.5 Expiry Services Count', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/getExpiryServicesDateWiseCount', {});
      expect(res.status).toBe(200);
      console.log(`  ✓ Expiry count: ${JSON.stringify(res.data).substring(0, 150)}`);
    });
  });

  // ======== CUSTOMER ========
  test.describe('3. Customer Operations', () => {

    test('3.1 Customer Details Count', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/getCustomerDetailsCountRest', {
        customerName: 'a',
      });
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      // Flutter expects: status_code, total_count or count
      console.log(`  ✓ Customer count response: ${JSON.stringify(res.data).substring(0, 200)}`);
    });

    test('3.2 Customer Details (search)', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/getCustomerDetailsRest', {
        customerName: 'a',
        startValue: 0,
        endValue: 5,
      });
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      // Flutter expects: status_code, customerDetailsListRest or customerDetailsList
      const listKey = Object.keys(res.data).find(k => k.toLowerCase().includes('customer') && k.toLowerCase().includes('list'));
      console.log(`  ✓ Customer list key: "${listKey}", status_code: ${res.data.status_code}`);
      if (listKey && Array.isArray(res.data[listKey]) && res.data[listKey].length > 0) {
        const sample = res.data[listKey][0];
        console.log(`  ✓ Sample customer fields: ${Object.keys(sample).join(', ')}`);
      }
    });

    test('3.3 Existing Customer Check', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/existingCustomerRest', {
        mobileNumber: '9999999999',
      });
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ Existing customer check: ${JSON.stringify(res.data).substring(0, 200)}`);
    });
  });

  // ======== PAYMENTS ========
  test.describe('4. Payment Operations', () => {

    test('4.1 Payment Modes', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/getPaymentModesRest', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      // Flutter expects: status_code, paymentModesList
      expect(res.data).toHaveProperty('status_code');
      const modes = res.data.paymentModesList || res.data.PaymentModesList;
      console.log(`  ✓ Payment modes: ${JSON.stringify(modes).substring(0, 300)}`);
    });

    test('4.2 Receipt Ranges', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/getReceiptRanges', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ Receipt ranges: ${JSON.stringify(res.data).substring(0, 200)}`);
    });
  });

  // ======== COMPLAINTS ========
  test.describe('5. Complaint Operations', () => {

    test('5.1 Complaint List (Open)', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/getComplaintList', {
        serviceemployeeid: 0,
        login_users_type: LOGIN_DATA.userType || 'RESELLER',
      });
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ Open complaints: ${JSON.stringify(res.data).substring(0, 200)}`);
    });

    test('5.2 Total Complaints List', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/gettotalcomplaintslist', {
        serviceemployeeid: 0,
        login_users_type: LOGIN_DATA.userType || 'RESELLER',
      });
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ All complaints: ${JSON.stringify(res.data).substring(0, 200)}`);
    });

    test('5.3 Complaint Categories', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/complaintCategoriesRest', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      // Flutter expects: status_code, complaintCategoryList
      const cats = res.data.complaintCategoryList;
      console.log(`  ✓ Complaint categories: ${cats ? cats.length + ' items' : JSON.stringify(res.data).substring(0, 150)}`);
    });

    test('5.4 Complaint Types', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/complaintTypesRest', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      // Flutter expects: status_code, complaintTypesList
      const types = res.data.complaintTypesList;
      console.log(`  ✓ Complaint types: ${types ? types.length + ' items' : JSON.stringify(res.data).substring(0, 150)}`);
    });
  });

  // ======== STB / BOX ========
  test.describe('6. STB Operations', () => {

    test('6.1 Deactivation Reasons', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/getDeactiveReasonsRest', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ Deactivation reasons: ${JSON.stringify(res.data).substring(0, 200)}`);
    });
  });

  // ======== PACKAGES ========
  test.describe('7. Package Operations', () => {

    test('7.1 CAS Packages', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/getCasPackagesRest', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ CAS packages: ${JSON.stringify(res.data).substring(0, 200)}`);
    });

    test('7.2 Channel List', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/channel_listRest', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ Channel list: ${JSON.stringify(res.data).substring(0, 200)}`);
    });
  });

  // ======== REPORTS ========
  test.describe('8. Reports', () => {

    test('8.1 Daily Report', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const today = new Date().toISOString().split('T')[0];
      const res = await apiCall(request, '/DailyreportRest', {
        fromDate: today,
        toDate: today,
      });
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ Daily report: ${JSON.stringify(res.data).substring(0, 200)}`);
    });

    test('8.2 Employee Collection', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const today = new Date().toISOString().split('T')[0];
      const res = await apiCall(request, '/empCollectionRest', {
        fromDate: today,
        toDate: today,
      });
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ Employee collection: ${JSON.stringify(res.data).substring(0, 200)}`);
    });
  });

  // ======== EMPLOYEES ========
  test.describe('9. Employees', () => {

    test('9.1 LCO Employee List', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/getLcoEmployeeList', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ LCO employees: ${JSON.stringify(res.data).substring(0, 200)}`);
    });

    test('9.2 Service Employee List', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/getServiceEmployeeList', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ Service employees: ${JSON.stringify(res.data).substring(0, 200)}`);
    });
  });

  // ======== MASTER DATA ========
  test.describe('10. Master Data', () => {

    test('10.1 Countries', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/getCountriesRest', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      // Flutter expects: status_code, countriesList
      const list = res.data.countriesList;
      console.log(`  ✓ Countries: ${list ? list.length + ' items' : JSON.stringify(res.data).substring(0, 150)}`);
    });

    test('10.2 States', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const countryId = LOGIN_DATA.defaultCountry || 'IN';
      const res = await apiCall(request, '/getStatesRest', { countryId });
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      // Flutter expects: status_code, statesList
      const list = res.data.statesList;
      console.log(`  ✓ States (${countryId}): ${list ? list.length + ' items' : JSON.stringify(res.data).substring(0, 150)}`);
    });

    test('10.3 Districts', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const stateId = LOGIN_DATA.defaultState || '101';
      const res = await apiCall(request, '/getdistrictsRest', { stateId });
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      // Flutter expects: status_code, districtsList
      const list = res.data.districtsList;
      console.log(`  ✓ Districts (state ${stateId}): ${list ? list.length + ' items' : JSON.stringify(res.data).substring(0, 150)}`);
    });

    test('10.4 Cities', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const districtId = LOGIN_DATA.defaultDistrict || '20';
      const res = await apiCall(request, '/getCitiesRest', { districtId });
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      // Flutter expects: status_code, citiesList
      const list = res.data.citiesList;
      console.log(`  ✓ Cities (district ${districtId}): ${list ? list.length + ' items' : JSON.stringify(res.data).substring(0, 150)}`);
    });

    test('10.5 Mandals', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const districtId = LOGIN_DATA.defaultDistrict || '20';
      const res = await apiCall(request, '/getmandalsRest', { districtId });
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ Mandals: ${JSON.stringify(res.data).substring(0, 150)}`);
    });

    test('10.6 Groups', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/getGroupsRest', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      // Flutter expects: status_code, groupsList
      console.log(`  ✓ Groups: ${JSON.stringify(res.data).substring(0, 150)}`);
    });

    test('10.7 Customer Types', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/getCustomerTypesRest', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      // Flutter expects: status_code, customerTypesList
      const list = res.data.customerTypesList;
      console.log(`  ✓ Customer types: ${list ? list.length + ' items' : JSON.stringify(res.data).substring(0, 150)}`);
    });

    test('10.8 ID Types', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/getIdsRest', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      // Flutter expects: status_code, idTypesList
      console.log(`  ✓ ID types: ${JSON.stringify(res.data).substring(0, 150)}`);
    });

    test('10.9 Dynamic Form Validations', async ({ request }) => {
      test.skip(!JWT_TOKEN, 'Login failed');
      const res = await apiCall(request, '/dynamicformvalidationsRest', {});
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      console.log(`  ✓ Form validations: ${JSON.stringify(res.data).substring(0, 200)}`);
    });
  });

  // ======== ENCRYPTION VALIDATION ========
  test.describe('11. Encryption Validation', () => {

    test('11.1 Verify encrypt/decrypt round-trip', async () => {
      const testData = { foo: 'bar', num: 123, special: '@#$%^&*()' };
      const encrypted = encryptPayload(testData);

      expect(encrypted.payload).toBeTruthy();
      expect(encrypted.hash).toBeTruthy();

      // Verify hash decodes back to original
      const decoded = decryptHash(encrypted.hash);
      expect(decoded).toEqual(testData);

      // Verify payload format: 5 digits + hex + 5 digits
      expect(encrypted.payload).toMatch(/^\d{5}[0-9a-f]+\d{5}$/);

      console.log('  ✓ Encryption round-trip: PASS');
    });

    test('11.2 Verify against known old-app payload', async () => {
      // Known payload from old Android app
      const oldHash = '7b22557365724e616d65223a2261646d696e222c22696d6569223a22383630333938303437363838303338222c22656d706c6f7965654964223a22313635222c2250617373576f7264223a224050726f566964656e7440233230323324227d';
      const decoded = decryptHash(oldHash);

      expect(decoded).toEqual({
        UserName: 'admin',
        imei: '860398047688038',
        employeeId: '165',
        PassWord: '@ProVident@#2023$',
      });

      // Verify our encryption produces same hash for same data
      const ourHash = binToHex(JSON.stringify(decoded));
      expect(ourHash).toBe(oldHash);

      console.log('  ✓ Old-app compatibility: PASS');
    });

    test('11.3 Server accepts and decrypts our payload correctly', async ({ request }) => {
      // Send login with encryption, verify server decrypts it correctly
      const res = await apiCall(request, '/validateLogin', TEST_USER, { skipAuth: true });
      expect(res.status).toBe(200);
      expect(res.data).toBeTruthy();
      expect(res.data.status_code).toBe(0);
      expect(res.data.username).toBe(TEST_USER.UserName);

      console.log('  ✓ Server encryption acceptance: PASS');
    });
  });
});
