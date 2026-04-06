/**
 * EzyBill Flutter App — Screenshot Capture
 *
 * Opens the app in a browser, waits for you to login manually,
 * then captures all screens automatically via hash navigation.
 *
 * Prerequisites:
 *   1. Start CORS proxy:  node cors_proxy.js
 *   2. Start Flutter web:  flutter run -d chrome --web-port=8080
 *   3. Run:  node tests/capture_screenshots.spec.js
 *   4. Login manually in the browser window that opens
 *   5. Screenshots are captured automatically after login
 *
 * Output:
 *   test-results/screenshots/  — all PNG screenshots
 *   test-results/screen_guide.html — HTML report
 */

const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');
const readline = require('readline');

const APP_URL = 'http://localhost:8080';
const SCREENSHOT_DIR = path.join(__dirname, '..', 'test-results', 'screenshots');

// Clean and recreate screenshot dir
if (fs.existsSync(SCREENSHOT_DIR)) {
  fs.readdirSync(SCREENSHOT_DIR).filter(f => f.endsWith('.png')).forEach(f => {
    fs.unlinkSync(path.join(SCREENSHOT_DIR, f));
  });
}
fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });

// ── Helpers ────────────────────────────────────────────────────────
async function snap(page, name, waitMs = 2000) {
  await page.waitForTimeout(waitMs);
  await page.screenshot({
    path: path.join(SCREENSHOT_DIR, `${name}.png`),
    fullPage: false,
  });
  console.log(`  📸 ${name}.png`);
}

function askUser(question) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  return new Promise(resolve => {
    rl.question(question, () => { rl.close(); resolve(); });
  });
}

// Screen metadata for HTML guide
const screenMeta = [];
function logScreen(id, name, description, route) {
  screenMeta.push({ id, name, description, route });
}

// ── Main ───────────────────────────────────────────────────────────
async function main() {
  console.log('\n  ══════════════════════════════════════════════════');
  console.log('  EzyBill Screenshot Capture');
  console.log('  ══════════════════════════════════════════════════\n');

  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
  });
  const page = await context.newPage();

  // ─── STEP 1: Open the app ─────────────────────────────────────
  console.log('  → Opening app...');
  await page.goto(APP_URL);
  await page.waitForTimeout(3000);

  // ─── STEP 2: Wait for user to login ────────────────────────────
  console.log('\n  ┌─────────────────────────────────────────────┐');
  console.log('  │  Please login in the browser window.        │');
  console.log('  │  Waiting for dashboard to appear...         │');
  console.log('  └─────────────────────────────────────────────┘\n');

  // Poll URL until we leave /login or /registration (max 120 seconds)
  for (let i = 0; i < 120; i++) {
    await page.waitForTimeout(1000);
    const currentUrl = page.url();
    if (!currentUrl.includes('/login') && !currentUrl.includes('/registration')) {
      console.log(`  ✅ Logged in! URL: ${currentUrl}`);
      break;
    }
    if (i % 10 === 9) {
      console.log(`  ... waiting for login (${i + 1}s)...`);
    }
    if (i === 119) {
      console.log('  ❌ Timeout — login not detected after 120s. Aborting.');
      await browser.close();
      return;
    }
  }

  // Extra wait for dashboard data to load
  await page.waitForTimeout(5000);

  console.log('  ✅ Starting screenshot capture...\n');

  // ─── Screen definitions: [num, route, name, desc, codeFiles, apiEndpoints] ─
  const allScreens = [
      {n:'01', route:'/', name:'Dashboard — Home',
       desc:'Overview stats, donut chart, wallet card, Active customer list with tabs (Active/Inactive/Fresh/Assigned)',
       files:['presentation/screens/home/home_screen.dart','presentation/screens/home/widgets/overview_donut.dart','presentation/screens/home/widgets/wallet_card.dart','presentation/screens/home/widgets/dashboard_stats_row.dart','presentation/screens/home/widgets/customer_filter_list.dart'],
       providers:['dashboardProvider','dashboardCustomerListProvider'],
       apis:['/dashBoardDetailsRest — Dashboard stats & counts','/getdashboardlist — Filtered customer/STB list','/getCustomerBoxDetailsRest — STB details for cards']},

      {n:'02', route:'/subscribers', name:'Subscribers',
       desc:'Customer search with 6 filter chips (Name, Phone, STB, VC, Account, All)',
       files:['presentation/screens/customers/customer_search_screen.dart'],
       providers:['customerSearchProvider'],
       apis:['/getCustomerDetailsRest — Search customers by field','/getCustomerDetailsCountRest — Get count before fetching']},

      {n:'03', route:'/reports', name:'Reports Hub',
       desc:'Navigation hub for reports (Mini Day Report, Employee Collection)',
       files:['presentation/screens/reports/reports_screen.dart'],
       providers:[],
       apis:[]},

      {n:'04', route:'/transactions', name:'Transactions',
       desc:'Transaction history list with payment and PG transaction logs',
       files:['presentation/screens/transactions/transactions_screen.dart'],
       providers:['paymentProvider'],
       apis:['/PaymentServiceRest — Payment history','/pgTransactionLogs — PG transaction logs']},

      {n:'05', route:'/settings', name:'Settings',
       desc:'Profile info, theme toggle, language selector, debug console, logout',
       files:['presentation/screens/settings/settings_screen.dart'],
       providers:['themeProvider','localeProvider','authLocalDatasourceProvider'],
       apis:[]},

      {n:'06', route:'/customer/new', name:'New Customer',
       desc:'4-step wizard: Basic Info → Address → STB/Package → Confirm & Save',
       files:['presentation/screens/customers/new_customer_screen.dart','presentation/screens/customers/new_customer_package_screen.dart','presentation/screens/customers/new_customer_confirm_screen.dart'],
       providers:['masterDataProvider','customerRemoteDatasourceProvider','packageRemoteDatasourceProvider'],
       apis:['/getCountriesRest','/getStatesRest','/getdistrictsRest','/getCitiesRest','/getmandalsRest','/getGroupsRest','/getCustomerTypesRest','/getcustomerTypeTypesRest','/getIdsRest','/validateBoxInfoRest','/existingCustomerRest','/saveCustomerRest','/getCasPackagesRest']},

      {n:'07', route:'/make-payment', name:'Make Payment',
       desc:'5 payment modes: Cash, Cheque, Online, Payment Gateway, Wallet',
       files:['presentation/screens/payments/make_payment_screen.dart','presentation/screens/payments/payment_receipt_screen.dart'],
       providers:['paymentProvider'],
       apis:['/getPaymentModesRest — Available payment modes','/getPendingAmountRest — Customer pending amount','/makePaymentsRest — Submit payment','/getReceiptRanges','/getbilldetailsRest — Bill details']},

      {n:'08', route:'/pg-transactions', name:'PG Transactions',
       desc:'Payment gateway transaction report with status filter',
       files:['presentation/screens/payments/pg_transaction_report_screen.dart'],
       providers:['paymentProvider'],
       apis:['/pgTransactionLogs — PG transaction report']},

      {n:'09', route:'/complaints', name:'Create Complaint',
       desc:'Complaint creation with category → sub-category → type cascade dropdowns',
       files:['presentation/screens/complaints/complaint_screen.dart','presentation/screens/complaints/complaint_history_screen.dart','presentation/screens/complaints/update_complaint_screen.dart'],
       providers:['complaintProvider'],
       apis:['/getComplaintList — Open complaints','/complaintCategoriesRest','/getComplaintsubCategory','/complaintTypesRest','/createComplaintRest','/closeComplaintRest','/ComplaintHistoryRest','/getLcoEmployeeList']},

      {n:'10', route:'/stb-operations', name:'STB Operations',
       desc:'Deactivate / Reactivate / Temporary Activate set-top boxes',
       files:['presentation/screens/stb/stb_operations_screen.dart'],
       providers:['stbProvider'],
       apis:['/getCustomerBoxDetailsRest — STB list for customer','/getDeactiveReasonsRest — Deactivation reasons','/deactivateBoxRest — Deactivate STB']},

      {n:'11', route:'/stb-pair-unpair', name:'STB Pair Unpair',
       desc:'Pair or unpair set-top boxes with validation',
       files:['presentation/screens/stb/stb_pair_unpair_screen.dart'],
       providers:['stbProvider'],
       apis:['/validateBoxInfoRest — Validate STB','/stbPairRest — Pair STB','/stbUnpairRest — Unpair STB']},

      {n:'12', route:'/stb-replacement', name:'STB Replacement',
       desc:'Replace old STB with new one',
       files:['presentation/screens/stb/stb_replacement_screen.dart'],
       providers:['stbProvider'],
       apis:['/getCustomerParticularBoxDetailsRest — Old STB details','/stb_replacement — Replace STB']},

      {n:'13', route:'/package-operations', name:'Package Operations',
       desc:'4-tab interface: Activate, Deactivate, Renew, Channel list',
       files:['presentation/screens/packages/package_operations_screen.dart'],
       providers:['packageProvider'],
       apis:['/getCustomerPackages_splitRest — Assigned packages','/getUnassignedPackages_splitRest — Available packages','/getbilldetailsRest — Bill preview','/activateServiceRest','/deactivateServiceRest','/extendCustomerServices']},

      {n:'14', route:'/package-renewal', name:'Package Renewal',
       desc:'Renew expiring/expired packages',
       files:['presentation/screens/packages/package_renewal_screen.dart'],
       providers:['packageProvider'],
       apis:['/getRenewServicesList — Renewable packages','/renewServicesList — Renew packages']},

      {n:'15', route:'/reports/mini-day', name:'Mini Day Report',
       desc:'Daily collection summary with payment breakdown',
       files:['presentation/screens/reports/mini_day_report_screen.dart'],
       providers:['reportProvider'],
       apis:['/DailyreportRest — Daily collection report']},

      {n:'16', route:'/reports/emp-collection/filter', name:'Employee Collection',
       desc:'Employee collection report with date range filter',
       files:['presentation/screens/reports/emp_collection_filter_screen.dart','presentation/screens/reports/emp_collection_list_screen.dart','presentation/screens/reports/emp_collection_detail_screen.dart'],
       providers:['reportProvider'],
       apis:['/empCollectionRest — Employee collection summary']},

      {n:'17', route:'/lco-payment', name:'LCO Payment',
       desc:'LCO payment interface for operator payments',
       files:['presentation/screens/lco/lco_payment_screen.dart'],
       providers:['lcoPaymentProvider'],
       apis:['/getlcoadvanceamountdue — LCO balance','/lcopaymentfunc — Make LCO payment']},

      {n:'18', route:'/lco-topup', name:'LCO Topup',
       desc:'Wallet topup with preset amount grid and payment gateway',
       files:['presentation/screens/lco/lco_topup_screen.dart'],
       providers:['dashboardProvider'],
       apis:['/getlcowalletRest — LCO wallet balance']},

      {n:'19', route:'/lco-wallet-history', name:'LCO Wallet History',
       desc:'Wallet transaction history with date filter',
       files:['presentation/screens/lco/lco_wallet_history_screen.dart'],
       providers:['lcoPaymentProvider'],
       apis:['/getlcowalletRest — Wallet history']},

      {n:'20', route:'/employees', name:'Employee List',
       desc:'LCO and service employee list with GPS tracking',
       files:['presentation/screens/employees/employee_list_screen.dart','presentation/screens/employees/employee_tracking_screen.dart'],
       providers:['employeeProvider'],
       apis:['/getLcoEmployeeList','/getServiceEmployeeList','/getEmployeeTrackInfo — GPS tracking']},

      {n:'21', route:'/settings/change-password', name:'Change Password',
       desc:'Password change form with current/new/confirm fields',
       files:['presentation/screens/settings/change_password_screen.dart'],
       providers:[],
       apis:['/changePasswordRest — Change password']},

      {n:'22', route:'/settings/about', name:'About',
       desc:'App version, build info, credits',
       files:['presentation/screens/settings/about_screen.dart'],
       providers:[],
       apis:[]},

      {n:'23', route:'/settings/privacy-policy', name:'Privacy Policy',
       desc:'Privacy policy and legal text',
       files:['presentation/screens/settings/privacy_policy_screen.dart'],
       providers:[],
       apis:[]},

      {n:'24', route:'/settings/debug-console', name:'Debug Console',
       desc:'Developer debug tool with API request/response logs',
       files:['presentation/screens/settings/debug_console_screen.dart'],
       providers:['debugLogProvider'],
       apis:[]},
    ];

  try {
    // ─── STEP 4: Capture dashboard ─────────────────────────────────
    await snap(page, '01_dashboard_home', 2000);
    logScreen('01', allScreens[0].name, allScreens[0].desc, '/');

    // ─── STEP 5: Capture all other screens via hash routes ─────────
    for (const s of allScreens.slice(1)) {
      await page.goto(`${APP_URL}/#${s.route}`);
      const fileName = `${s.n}_${s.name.toLowerCase().replace(/[\s\/]+/g, '_')}`;
      await snap(page, fileName, 3000);
      logScreen(s.n, s.name, s.desc, s.route);
    }

    // Back to dashboard for final shot
    await page.goto(`${APP_URL}/#/`);
    await page.waitForTimeout(2000);

  } finally {
    // ─── STEP 6: Generate HTML report ───────────────────────────
    const screenshots = fs.readdirSync(SCREENSHOT_DIR)
      .filter(f => f.endsWith('.png'))
      .sort();

    const screensInfo = screenshots.map((file) => {
      const num = file.replace('.png', '').split('_')[0];
      const meta = screenMeta.find(m => m.id === num) || {};
      const screenData = allScreens.find(s => s.n === num) || {};
      const label = meta.name || file.replace('.png', '').replace(/_/g, ' ').replace(/^\d+\s*/, '');
      const desc = meta.description || '';
      const route = meta.route || '';
      const files = screenData.files || [];
      const providers = screenData.providers || [];
      const apis = screenData.apis || [];
      return { file, label, desc, route, files, providers, apis };
    });

    // Static auth screen data (no screenshots captured)
    const staticScreens = [
      { label: 'Registration', desc: 'Device registration with MSO key and username via BMS SOAP service',
        route: '/registration',
        files: ['presentation/screens/auth/registration_screen.dart', 'data/datasources/remote/bms_remote_datasource.dart', 'data/models/auth/bms_registration_response.dart'],
        providers: ['bmsProvider'],
        apis: ['SOAP: validateUserAuthentication — Device registration via XML envelope'] },
      { label: 'Login', desc: 'LCO credentials login with Remember Me and auto-login on web',
        route: '/login',
        files: ['presentation/screens/auth/login_screen.dart', 'application/providers/auth_provider.dart', 'data/datasources/remote/auth_remote_datasource.dart'],
        providers: ['authProvider'],
        apis: ['/validateLogin — Authenticate user', '/getaccesscontrollRest — Get user permissions & menu access'] },
    ];

    const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>EzyBill Flutter App — Screen Guide</title>
<style>
  :root { --red: #e53935; --bg: #f5f5f5; --card: #fff; --text: #333; --muted: #666; --border: #eee; }
  * { box-sizing: border-box; }
  body { font-family: 'Segoe UI', system-ui, sans-serif; max-width: 960px; margin: 0 auto; padding: 24px; background: var(--bg); color: var(--text); }
  h1 { color: var(--red); border-bottom: 3px solid var(--red); padding-bottom: 12px; font-size: 28px; }
  .meta { color: var(--muted); font-size: 14px; line-height: 1.6; margin-bottom: 24px; }
  .meta code { background: #f0f0f0; padding: 1px 6px; border-radius: 3px; font-size: 13px; }
  .toc { background: var(--card); border-radius: 12px; padding: 20px 24px; margin: 24px 0; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
  .toc-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 4px 24px; }
  .toc a { display: block; padding: 4px 0; color: #1976d2; text-decoration: none; font-size: 14px; }
  .toc a:hover { text-decoration: underline; }
  .screen { background: var(--card); border-radius: 12px; padding: 24px; margin: 24px 0; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
  .screen-header { display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 8px; }
  .screen-name { font-size: 18px; font-weight: 700; }
  .screen-route { font-size: 12px; color: var(--muted); font-family: monospace; background: #f5f5f5; padding: 2px 8px; border-radius: 4px; }
  .screen-desc { font-size: 14px; color: var(--muted); margin-bottom: 16px; }
  .screen img { max-width: 100%; border: 1px solid var(--border); border-radius: 8px; }
  .code-section { margin-top: 16px; padding: 14px; background: #f8f9fa; border-radius: 8px; border: 1px solid var(--border); }
  .code-section h4 { margin: 0 0 8px 0; font-size: 13px; color: var(--text); font-weight: 600; }
  .code-section code { display: block; font-family: 'JetBrains Mono', 'Consolas', monospace; font-size: 12px; color: #555; line-height: 1.7; }
  .code-section code a { color: #1976d2; text-decoration: none; }
  .code-section code a:hover { text-decoration: underline; }
  .api-tag { display: inline-block; background: #e3f2fd; color: #1565c0; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-family: monospace; margin: 2px 4px 2px 0; }
  .provider-tag { display: inline-block; background: #f3e5f5; color: #7b1fa2; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-family: monospace; margin: 2px 4px 2px 0; }
  .static-note { background: #fff3e0; border: 1px solid #ffe0b2; border-radius: 8px; padding: 10px 14px; margin-bottom: 16px; font-size: 13px; color: #e65100; }
  @media print { .screen { break-inside: avoid; } }
</style>
</head>
<body>
<h1>EzyBill Flutter App — Screen Guide</h1>
<div class="meta">
  <strong>Generated:</strong> ${new Date().toLocaleDateString('en-IN', { year: 'numeric', month: 'long', day: 'numeric' })}<br>
  <strong>Server:</strong> <code>http://192.168.1.143/v2_release_aakshya/index.php</code><br>
  <strong>Test User:</strong> <code>itptest / 1234</code><br>
  <strong>Screenshots:</strong> ${screenshots.length} screens captured
</div>
<div class="toc">
<h2 style="margin-top:0">Table of Contents</h2>
<div class="toc-grid">
<a href="#s-reg">0a. Registration</a>
<a href="#s-login">0b. Login</a>
${screensInfo.map((s, i) => `<a href="#s-${i}">${i + 1}. ${s.label}</a>`).join('\n')}
</div>
</div>

<h2>Auth Screens</h2>
${staticScreens.map((s, i) => `
<div class="screen" id="s-${i === 0 ? 'reg' : 'login'}">
  <div class="screen-header">
    <div class="screen-name">0${i === 0 ? 'a' : 'b'}. ${s.label}</div>
    <span class="screen-route">${s.route}</span>
  </div>
  <div class="screen-desc">${s.desc}</div>
  <div class="static-note">Screenshot not captured (requires manual BMS registration / login interaction)</div>
  <div class="code-section">
    <h4>Code Files</h4>
    <code>${s.files.map(f => `lib/${f}`).join('<br>')}</code>
  </div>
  ${s.providers.length ? `<div class="code-section"><h4>Providers</h4><div>${s.providers.map(p => `<span class="provider-tag">${p}</span>`).join('')}</div></div>` : ''}
  ${s.apis.length ? `<div class="code-section"><h4>API Endpoints</h4><div>${s.apis.map(a => `<span class="api-tag">${a}</span>`).join('<br>')}</div></div>` : ''}
</div>`).join('\n')}

<h2>App Screens</h2>
${screensInfo.map((s, i) => `
<div class="screen" id="s-${i}">
  <div class="screen-header">
    <div class="screen-name">${i + 1}. ${s.label}</div>
    ${s.route ? `<span class="screen-route">${s.route}</span>` : ''}
  </div>
  ${s.desc ? `<div class="screen-desc">${s.desc}</div>` : ''}
  <img src="screenshots/${s.file}" alt="${s.label}" loading="lazy">
  ${s.files.length ? `<div class="code-section"><h4>Code Files</h4><code>${s.files.map(f => `lib/${f}`).join('<br>')}</code></div>` : ''}
  ${s.providers.length ? `<div class="code-section"><h4>Providers</h4><div>${s.providers.map(p => `<span class="provider-tag">${p}</span>`).join('')}</div></div>` : ''}
  ${s.apis.length ? `<div class="code-section"><h4>API Endpoints</h4><div>${s.apis.map(a => `<span class="api-tag">${a}</span>`).join('<br>')}</div></div>` : ''}
</div>`).join('\n')}
</body>
</html>`;

    const outPath = path.join(SCREENSHOT_DIR, '..', 'screen_guide.html');
    fs.writeFileSync(outPath, html);
    console.log(`\n  ══════════════════════════════════════════════════`);
    console.log(`  ✅ Done! ${screenshots.length} screenshots captured`);
    console.log(`  📄 HTML report: test-results/screen_guide.html`);
    console.log(`  📁 Screenshots: test-results/screenshots/`);
    console.log(`  ══════════════════════════════════════════════════\n`);

    await browser.close();
  }
}

main().catch(err => {
  console.error('❌ Error:', err.message);
  process.exit(1);
});
