const fs = require('fs');
const data = JSON.parse(fs.readFileSync('./api_responses.json', 'utf8'));

const BASE = 'http://183.83.216.66:8882/v2_release/index.php/LcoRestServices';

const endpoints = [
  {
    section: 'Authentication',
    apis: [
      {
        name: 'Login (Validate Login)',
        method: 'POST',
        url: `${BASE}/validateLogin`,
        params: { UserName: '58948', PassWord: '****' },
        responseKey: 'login',
        notes: 'Returns JWT token, user profile, dealer config, and feature flags. Token used as Bearer auth for all subsequent calls.',
        keyFields: ['token', 'employeeId', 'dealerId', 'userType', 'first_name', 'lcoCode', 'business_name', 'config_values_array']
      },
      {
        name: 'Get Access Control',
        method: 'POST',
        url: `${BASE}/getaccesscontrollRest`,
        params: { authToken: '<jwt_token>', dealer_id: 1, userstype: 'RESELLER', employeeParentType: '', employeeParentId: '' },
        responseKey: 'accessControl',
        notes: 'Returns feature access flags for the logged-in user. Controls which screens/features are visible in the app.',
        keyFields: ['int_bulk_payment', 'invoice_page_access', 'access_for_complaints', 'int_stb_activation']
      }
    ]
  },
  {
    section: 'Dashboard',
    apis: [
      {
        name: 'Dashboard Summary',
        method: 'POST',
        url: `${BASE}/getDashboardDetails`,
        params: { authToken: '<jwt_token>', dealer_id: 1 },
        responseKey: 'dashboard',
        notes: 'Main dashboard statistics. Shows STB counts, customer counts, financials.',
        keyFields: ['totalStbs', 'totalActiveCustomers', 'totalComplaints', 'outStandingAmount', 'msoShare', 'totalActiveAssignedStbs']
      },
      {
        name: 'LCO Deposit Balance',
        method: 'POST',
        url: `${BASE}/getLcoDepositeBalance`,
        params: { authToken: '<jwt_token>', dealer_id: 1 },
        responseKey: 'deposit',
        notes: 'Returns current deposit/wallet balance for the LCO.',
        keyFields: ['deposit_amount']
      },
      {
        name: 'Wallet Transactions',
        method: 'POST',
        url: `${BASE}/getWalletTransactions`,
        params: { authToken: '<jwt_token>', dealer_id: 1, startDate: '2026-01-01', endDate: '2026-03-25' },
        responseKey: 'wallet',
        notes: 'Returns wallet transaction history. Requires startDate and endDate params.',
        keyFields: []
      },
      {
        name: 'Expiry Service Count',
        method: 'POST',
        url: `${BASE}/getExpiryServiceCount`,
        params: { authToken: '<jwt_token>', dealer_id: 1, startDate: '2026-03-25', endDate: '2026-03-30' },
        responseKey: 'expiryCount',
        notes: 'Returns STB count expiring per day in the given date range.',
        keyFields: ['getExpiryServicesList[].date', 'getExpiryServicesList[].stb_count']
      },
      {
        name: 'Customer Count',
        method: 'POST',
        url: `${BASE}/getCustomerCount`,
        params: { authToken: '<jwt_token>', dealer_id: 1 },
        responseKey: 'custCount',
        notes: 'Returns total customer count for the dealer.',
        keyFields: ['customerCount']
      }
    ]
  },
  {
    section: 'Customer Management',
    apis: [
      {
        name: 'Customer Details List',
        method: 'POST',
        url: `${BASE}/getCustomerDetails`,
        params: { authToken: '<jwt_token>', dealer_id: 1, searchType: 'name', searchValue: '', limit: 10, offset: 0 },
        responseKey: 'custDetails',
        notes: 'Paginated customer list. Response key is `customerDetailsList` (not `customerList`). Note: uses `statusCode` / `statusMessage` (not `status_code` / `status_msg`).',
        keyFields: ['customerDetailsList[].customer_id', 'customerDetailsList[].customerName', 'customerDetailsList[].caf_no', 'customerDetailsList[].mobile_no', 'customerDetailsList[].status', 'customerDetailsList[].stb_count', 'customerDetailsList[].pending_amount']
      },
      {
        name: 'Existing Customer Search',
        method: 'POST',
        url: `${BASE}/getExistCustomerDetails`,
        params: { authToken: '<jwt_token>', dealer_id: 1, mobile_no: '9999999999' },
        responseKey: 'existingCust',
        notes: 'Search for existing customer by mobile number. Response key is `existCustomerDetails`.',
        keyFields: ['existCustomerDetails[]']
      }
    ]
  },
  {
    section: 'Payments',
    apis: [
      {
        name: 'Payment Modes',
        method: 'POST',
        url: `${BASE}/getPaymentModes`,
        params: { authToken: '<jwt_token>', dealer_id: 1 },
        responseKey: 'paymentModes',
        notes: 'Returns available payment modes (Cash, Bank, Card, Voucher). Response key: `paymentModesList`.',
        keyFields: ['paymentModesList[].paymentModeId', 'paymentModesList[].PaymentModeName']
      },
      {
        name: 'Receipt Number Ranges',
        method: 'POST',
        url: `${BASE}/getReceiptNumberRanges`,
        params: { authToken: '<jwt_token>', dealer_id: 1 },
        responseKey: 'receiptRanges',
        notes: 'Returns receipt number ranges. Response key: `ReceiptRanges` (capital R).',
        keyFields: ['ReceiptRanges[]']
      }
    ]
  },
  {
    section: 'Complaints',
    apis: [
      {
        name: 'Complaint List',
        method: 'POST',
        url: `${BASE}/getLcoComplaintList`,
        params: { authToken: '<jwt_token>', dealer_id: 1, status: 'ASSIGNED' },
        responseKey: 'complaintList',
        notes: 'Returns complaints filtered by status. Response key: `lcoComplaintlist`.',
        keyFields: ['lcoComplaintlist[]']
      },
      {
        name: 'Complaint Categories',
        method: 'POST',
        url: `${BASE}/getComplaintCategories`,
        params: { authToken: '<jwt_token>', dealer_id: 1 },
        responseKey: 'complaintCats',
        notes: 'Returns complaint category dropdown options. Response key: `complaintCategories` (NOT `complaintCategoryList`).',
        keyFields: ['complaintCategories[].categoryId', 'complaintCategories[].categoryName']
      },
      {
        name: 'Complaint Statuses/Types',
        method: 'POST',
        url: `${BASE}/getComplaintTypes`,
        params: { authToken: '<jwt_token>', dealer_id: 1 },
        responseKey: 'complaintTypes',
        notes: 'Returns complaint status values and ticket closer categories. Response key: `complaintStatuses` (NOT `complaintTypesList`). Also returns `ticket_closer_categories`.',
        keyFields: ['complaintStatuses[].value', 'ticket_closer_categories[]']
      }
    ]
  },
  {
    section: 'STB / Packages',
    apis: [
      {
        name: 'Deactivation Reasons',
        method: 'POST',
        url: `${BASE}/getDeactivationReasons`,
        params: { authToken: '<jwt_token>', dealer_id: 1 },
        responseKey: 'deactivationReasons',
        notes: 'Returns STB deactivation reason dropdown. Response key: `reasonList`.',
        keyFields: ['reasonList[].reasonId', 'reasonList[].reasonName', 'reasonList[].display_name']
      }
    ]
  },
  {
    section: 'Master Data - Geography',
    apis: [
      {
        name: 'Countries',
        method: 'POST',
        url: `${BASE}/getCountries`,
        params: { authToken: '<jwt_token>', dealer_id: 1 },
        responseKey: 'countries',
        notes: 'Returns all countries. Response key: `countriesList`. Each item has `iso` (country code) and `name`.',
        keyFields: ['countriesList[].iso', 'countriesList[].name']
      },
      {
        name: 'States',
        method: 'POST',
        url: `${BASE}/getStates`,
        params: { authToken: '<jwt_token>', dealer_id: 1, countryCode: 'IN' },
        responseKey: 'states',
        notes: 'Returns states for a country. Param is `countryCode` (NOT `countryId`). Response key: `statesList`.',
        keyFields: ['statesList[].id', 'statesList[].name', 'statesList[].country_code']
      },
      {
        name: 'Districts',
        method: 'POST',
        url: `${BASE}/getDistricts`,
        params: { authToken: '<jwt_token>', dealer_id: 1, stateId: 101 },
        responseKey: 'districts',
        notes: 'Returns districts for a state. Response key: `districtList` (NOT `districtsList`).',
        keyFields: ['districtList[].district_id', 'districtList[].district_name', 'districtList[].state_id']
      },
      {
        name: 'Cities',
        method: 'POST',
        url: `${BASE}/getCities`,
        params: { authToken: '<jwt_token>', dealer_id: 1, stateId: 101, districtId: 20 },
        responseKey: 'cities',
        notes: 'Returns cities. Requires BOTH `stateId` AND `districtId`. Error returned if missing.',
        keyFields: []
      },
      {
        name: 'Mandals',
        method: 'POST',
        url: `${BASE}/getMandals`,
        params: { authToken: '<jwt_token>', dealer_id: 1, districtId: 20 },
        responseKey: 'mandals',
        notes: 'Returns mandals for a district. Response key: `mandalList`.',
        keyFields: ['mandalList[].mandal_id', 'mandalList[].mandal_name', 'mandalList[].district_id']
      }
    ]
  },
  {
    section: 'Master Data - Dropdowns',
    apis: [
      {
        name: 'Customer Types',
        method: 'POST',
        url: `${BASE}/getCustomerTypes`,
        params: { authToken: '<jwt_token>', dealer_id: 1 },
        responseKey: 'customerTypes',
        notes: 'Returns customer type dropdown. Response key: `customerTypeList` (NOT `customerTypesList`).',
        keyFields: ['customerTypeList[].customer_type_id', 'customerTypeList[].customer_type', 'customerTypeList[].is_commercial_multi_box']
      },
      {
        name: 'ID Types',
        method: 'POST',
        url: `${BASE}/getIdTypes`,
        params: { authToken: '<jwt_token>', dealer_id: 1 },
        responseKey: 'idTypes',
        notes: 'Returns ID proof type dropdown (PAN, Aadhar, Voter ID, etc.). Response key: `idList`.',
        keyFields: ['idList[].id_type_id', 'idList[].type']
      }
    ]
  },
  {
    section: 'Employees',
    apis: [
      {
        name: 'LCO Employees',
        method: 'POST',
        url: `${BASE}/getLcoEmployees`,
        params: { authToken: '<jwt_token>', dealer_id: 1, lcoId: 1054 },
        responseKey: 'lcoEmployees',
        notes: 'Returns employees under an LCO. Requires `lcoId` param. Response key: `lcoEmployeelist`.',
        keyFields: ['lcoEmployeelist[]']
      },
      {
        name: 'Service Employees',
        method: 'POST',
        url: `${BASE}/getServiceEmployees`,
        params: { authToken: '<jwt_token>', dealer_id: 1 },
        responseKey: 'serviceEmployees',
        notes: 'Returns service/field employees. Response key: `getServiceEmployeeList`.',
        keyFields: ['getServiceEmployeeList[]']
      }
    ]
  },
  {
    section: 'Reports',
    apis: [
      {
        name: 'Daily Collection Report',
        method: 'POST',
        url: `${BASE}/getDailyCollectionReport`,
        params: { authToken: '<jwt_token>', dealer_id: 1, date: '2026-03-25' },
        responseKey: 'dailyReport',
        notes: 'Returns daily collection report. Requires `date` param.',
        keyFields: []
      },
      {
        name: 'Employee Collection Report',
        method: 'POST',
        url: `${BASE}/getEmployeeCollectionReport`,
        params: { authToken: '<jwt_token>', dealer_id: 1 },
        responseKey: 'empCollection',
        notes: 'Returns employee-wise collection summary. Response key: `collectionList`.',
        keyFields: ['collectionList[].employee_id', 'collectionList[].name', 'collectionList[].Amt']
      }
    ]
  }
];

function truncateJson(obj, maxItems) {
  if (Array.isArray(obj)) {
    if (obj.length > maxItems) {
      return [...obj.slice(0, maxItems), `... (${obj.length - maxItems} more items)`];
    }
    return obj;
  }
  if (obj && typeof obj === 'object') {
    const result = {};
    for (const [k, v] of Object.entries(obj)) {
      result[k] = truncateJson(v, maxItems);
    }
    return result;
  }
  return obj;
}

let md = '';
md += '# EzyBill API Summary\n\n';
md += '> **Base URL:** `http://183.83.216.66:8882/v2_release/index.php`\n';
md += '> **REST Controller:** `LcoRestServices`\n';
md += '> **Auth:** All requests (except login) require `Authorization: Bearer <jwt_token>` header\n';
md += '> **Encryption:** All POST payloads are encrypted (triple hex encoding). All responses are encrypted (single hex decode).\n';
md += '> **Content-Type:** `application/x-www-form-urlencoded`\n';
md += '> **Test Credentials:** Username: `58948`, Password: `1234`\n\n';
md += '---\n\n';

// Table of Contents
md += '## Table of Contents\n\n';
endpoints.forEach((section, i) => {
  const anchor = section.section.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/-+$/, '');
  md += `${i + 1}. [${section.section}](#${anchor})\n`;
});
md += '\n---\n\n';

// Issues found section
md += '## Issues Found During Testing (Flutter App Fixes Needed)\n\n';
md += '| # | Issue | Correct Value | Wrong Value (Flutter) |\n';
md += '|---|-------|---------------|----------------------|\n';
md += '| 1 | Complaint categories response key | `complaintCategories` | `complaintCategoryList` |\n';
md += '| 2 | Complaint statuses response key | `complaintStatuses` | `complaintTypesList` |\n';
md += '| 3 | Districts response key | `districtList` | `districtsList` |\n';
md += '| 4 | Customer types response key | `customerTypeList` | `customerTypesList` |\n';
md += '| 5 | States API param name | `countryCode` | `countryId` |\n';
md += '| 6 | Cities API requires both params | `stateId` + `districtId` | only `districtId` |\n';
md += '| 7 | Reports/Employees need dealer_id | `dealer_id` required | missing param |\n';
md += '\n---\n\n';

// Each section
endpoints.forEach(section => {
  md += `## ${section.section}\n\n`;

  section.apis.forEach(api => {
    md += `### ${api.name}\n\n`;
    md += `- **Method:** \`${api.method}\`\n`;
    md += `- **URL:** \`${api.url}\`\n`;
    md += `- **Notes:** ${api.notes}\n\n`;

    // Request params
    md += '**Request Parameters:**\n```json\n';
    md += JSON.stringify(api.params, null, 2);
    md += '\n```\n\n';

    // Response
    const resp = data[api.responseKey];
    if (resp) {
      const truncated = truncateJson(resp, 3);
      md += '**Response (Decrypted):**\n```json\n';
      md += JSON.stringify(truncated, null, 2);
      md += '\n```\n\n';

      // Status
      const sc = resp.status_code ?? resp.statusCode;
      const sm = resp.status_msg ?? resp.statusMessage;
      md += `**Status:** \`${sc}\` - ${sm}\n\n`;
    } else {
      md += '**Response:** _(no data collected)_\n\n';
    }

    if (api.keyFields && api.keyFields.length > 0) {
      md += '**Key Response Fields:** `' + api.keyFields.join('`, `') + '`\n\n';
    }

    md += '---\n\n';
  });
});

// Encryption section
md += '## Encryption Details\n\n';
md += '### Request Encryption (Payload)\n\n';
md += '```\n';
md += '1. JSON stringify the request params\n';
md += '2. bin2hex(json_string) → this becomes the "hash"\n';
md += '3. bin2hex each character of hash → level 2\n';
md += '4. bin2hex each character of level 2 → level 3 (the "payload")\n';
md += '5. Prepend 5 random hex digits + append 5 random hex digits to payload\n';
md += '6. Send as: { payload: <padded_payload>, hash: <hash_from_step_2> }\n';
md += '```\n\n';
md += '### Response Decryption\n\n';
md += '```\n';
md += '1. Response body is: { payload: ..., hash: "..." }\n';
md += '2. Take the "hash" field\n';
md += '3. hex2bin(hash) → this is the JSON string\n';
md += '4. JSON.parse the result\n';
md += '```\n\n';
md += '### Integrity Check (Server Side)\n\n';
md += '```\n';
md += '1. Server receives { payload, hash }\n';
md += '2. Strips first 5 and last 5 chars from payload\n';
md += '3. Reverse triple hex decode → gets JSON\n';
md += '4. bin2hex(JSON) and compares with received hash\n';
md += '5. If match → request is valid; if not → rejected\n';
md += '```\n\n';

md += '---\n\n';
md += `*Generated on ${new Date().toISOString().split('T')[0]} from live API responses using test credentials (58948/1234)*\n`;

fs.writeFileSync('./API_SUMMARY.md', md, 'utf8');
console.log(`API_SUMMARY.md generated (${md.length} chars, ${md.split('\n').length} lines)`);
