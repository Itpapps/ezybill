// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'EzyBill';

  @override
  String get login => 'लॉगिन';

  @override
  String get username => 'उपयोगकर्ता नाम';

  @override
  String get password => 'पासवर्ड';

  @override
  String get rememberMe => 'मुझे याद रखें';

  @override
  String get loginButton => 'साइन इन';

  @override
  String get loginFailed => 'लॉगिन विफल';

  @override
  String get noInternet => 'इंटरनेट कनेक्शन नहीं है';

  @override
  String get apiBaseUrl => 'API बेस URL';

  @override
  String get editServerUrl => 'API अनुरोधों के लिए सर्वर URL संपादित करें।';

  @override
  String get resetToDefault => 'डिफ़ॉल्ट पर रीसेट करें';

  @override
  String get save => 'सेव';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get ok => 'ठीक है';

  @override
  String get version => 'संस्करण';

  @override
  String get overview => 'अवलोकन';

  @override
  String get active => 'सक्रिय';

  @override
  String get inactive => 'निष्क्रिय';

  @override
  String get fresh => 'नया';

  @override
  String get assigned => 'सौंपा गया';

  @override
  String get unassigned => 'असौंपित';

  @override
  String get totalStbs => 'कुल STB';

  @override
  String get outstanding => 'बकाया';

  @override
  String get health => 'स्वास्थ्य';

  @override
  String get recharged => 'रीचार्ज किया गया';

  @override
  String get expiring7d => '7 दिनों में समाप्त';

  @override
  String get wallet => 'वॉलेट';

  @override
  String get overdue => 'अतिदेय';

  @override
  String get balance => 'शेष';

  @override
  String get topUp => 'टॉप अप';

  @override
  String get lastRecharge => 'अंतिम रीचार्ज';

  @override
  String get ledger => 'खाता बही';

  @override
  String get tapToAssign => 'सौंपने के लिए टैप करें';

  @override
  String get newCustomer => 'नया ग्राहक';

  @override
  String showingCount(int count) {
    return '$count दिखा रहे हैं';
  }

  @override
  String get searchPlaceholder => 'फ़ोन, नाम, या सेटअप बॉक्स ID';

  @override
  String get noSubscribersFound => 'कोई सब्सक्राइबर नहीं मिला';

  @override
  String get tryDifferentSearch => 'कोई अलग खोज या फ़िल्टर आज़माएँ';

  @override
  String get name => 'नाम';

  @override
  String get dueDate => 'देय तिथि';

  @override
  String get area => 'क्षेत्र';

  @override
  String get list => 'सूची';

  @override
  String get recharge => 'रीचार्ज';

  @override
  String get refresh => 'रिफ़्रेश';

  @override
  String get upgrade => 'अपग्रेड';

  @override
  String get deactivate => 'निष्क्रिय करें';

  @override
  String get activate => 'सक्रिय करें';

  @override
  String get addPackage => 'पैकेज जोड़ें';

  @override
  String get pairing => 'पेयरिंग';

  @override
  String get subscriberDetail => 'सब्सक्राइबर विवरण';

  @override
  String get mobile => 'मोबाइल';

  @override
  String get stbSerial => 'STB सीरियल';

  @override
  String get vcNumber => 'VC नंबर';

  @override
  String get stbType => 'STB प्रकार';

  @override
  String get monthlyBill => 'मासिक बिल';

  @override
  String get activePackages => 'सक्रिय पैकेज';

  @override
  String get packages => 'पैकेज';

  @override
  String get support => 'सहायता';

  @override
  String get home => 'होम';

  @override
  String get subscribers => 'सब्सक्राइबर';

  @override
  String get reports => 'रिपोर्ट';

  @override
  String get transactions => 'लेनदेन';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get makePayment => 'भुगतान करें';

  @override
  String get payByCash => 'नकद से भुगतान';

  @override
  String get payByCheque => 'चेक से भुगतान';

  @override
  String get payByCard => 'कार्ड से भुगतान';

  @override
  String get payByVoucher => 'वाउचर से भुगतान';

  @override
  String get pay => 'भुगतान';

  @override
  String get amount => 'राशि';

  @override
  String get receiptNumber => 'रसीद नंबर';

  @override
  String get remarks => 'टिप्पणी';

  @override
  String get chequeNo => 'चेक/DD नंबर';

  @override
  String get bankName => 'बैंक का नाम';

  @override
  String get branch => 'शाखा';

  @override
  String get chequeDate => 'चेक तिथि';

  @override
  String get voucherCode => 'वाउचर कोड';

  @override
  String get cardType => 'कार्ड प्रकार';

  @override
  String get pendingAmount => 'लंबित राशि';

  @override
  String get paymentSuccessful => 'भुगतान सफल';

  @override
  String get paymentFailed => 'भुगतान विफल';

  @override
  String get invalidAmount => 'अमान्य राशि';

  @override
  String get emptyFields => 'खाली फ़ील्ड';

  @override
  String get amountShouldNotBeEmpty => 'राशि खाली नहीं होनी चाहिए';

  @override
  String get selectValidReceipt => 'वैध रसीद नंबर चुनें';

  @override
  String get fieldsShouldNotBeEmpty => 'फ़ील्ड खाली नहीं होने चाहिए';

  @override
  String get print => 'प्रिंट';

  @override
  String get share => 'शेयर';

  @override
  String get done => 'पूरा हुआ';

  @override
  String get paymentHistory => 'भुगतान इतिहास';

  @override
  String get invoiceHistory => 'चालान इतिहास';

  @override
  String get pgTransactions => 'PG लेनदेन';

  @override
  String get complaints => 'शिकायतें';

  @override
  String get openComplaints => 'खुली शिकायतें';

  @override
  String get createNew => 'नया बनाएँ';

  @override
  String get category => 'श्रेणी';

  @override
  String get subcategory => 'उपश्रेणी';

  @override
  String get description => 'विवरण';

  @override
  String get assignTo => 'सौंपें';

  @override
  String get submit => 'सबमिट';

  @override
  String get ticketNumber => 'टिकट नंबर';

  @override
  String get complaintCreated => 'शिकायत दर्ज की गई';

  @override
  String get updateComplaint => 'शिकायत अपडेट';

  @override
  String get comment => 'टिप्पणी';

  @override
  String get status => 'स्थिति';

  @override
  String get complaintHistory => 'शिकायत इतिहास';

  @override
  String get totalComplaints => 'कुल शिकायतें';

  @override
  String get stbOperations => 'STB संचालन';

  @override
  String get deactivateStb => 'STB निष्क्रिय करें';

  @override
  String get reactivateStb => 'STB पुनः सक्रिय करें';

  @override
  String get temporaryActivate => 'STB अस्थायी सक्रियण';

  @override
  String get selectReason => 'कारण चुनें';

  @override
  String get deactivationRemarks => 'टिप्पणी';

  @override
  String get confirmDeactivate => 'क्या आप इस STB को निष्क्रिय करना चाहते हैं?';

  @override
  String get confirmReactivate =>
      'क्या आप इस STB को पुनः सक्रिय करना चाहते हैं?';

  @override
  String get pairStb => 'STB पेयर';

  @override
  String get unpairStb => 'STB अनपेयर';

  @override
  String get serialNumber => 'सीरियल नंबर';

  @override
  String get replacement => 'STB रिप्लेसमेंट';

  @override
  String get packageOperations => 'पैकेज संचालन';

  @override
  String get activatePackage => 'सक्रिय करें';

  @override
  String get deactivatePackage => 'निष्क्रिय करें';

  @override
  String get renewPackage => 'नवीनीकरण';

  @override
  String get getBill => 'बिल प्राप्त करें';

  @override
  String get billSummary => 'बिल सारांश';

  @override
  String get lcoShare => 'LCO हिस्सा';

  @override
  String get msoShare => 'MSO हिस्सा';

  @override
  String get total => 'कुल';

  @override
  String get confirmActivate => 'क्या आप पैकेज सक्रिय करना चाहते हैं?';

  @override
  String get confirmDeactivatePackage =>
      'क्या आप पैकेज निष्क्रिय करना चाहते हैं?';

  @override
  String get confirmRenewal => 'नवीनीकरण की पुष्टि करें';

  @override
  String get miniDayReport => 'मिनी डे रिपोर्ट';

  @override
  String get employeeCollection => 'कर्मचारी संग्रह';

  @override
  String get fromDate => 'तिथि से';

  @override
  String get toDate => 'तिथि तक';

  @override
  String get search => 'खोजें';

  @override
  String get grandTotal => 'कुल योग';

  @override
  String get paymentMode => 'भुगतान माध्यम';

  @override
  String get customerCount => 'ग्राहक संख्या';

  @override
  String get customerSearch => 'ग्राहक खोज';

  @override
  String get customerNumber => 'ग्राहक#';

  @override
  String get customerName => 'नाम';

  @override
  String get mobileNumber => 'मोबाइल';

  @override
  String get stbNumber => 'STB#';

  @override
  String get lcoCustomerId => 'LCO ID';

  @override
  String get cafNumber => 'CAF#';

  @override
  String get noCustomersFound => 'कोई ग्राहक नहीं मिला';

  @override
  String get editCustomer => 'ग्राहक संपादित करें';

  @override
  String get firstName => 'पहला नाम';

  @override
  String get lastName => 'अंतिम नाम';

  @override
  String get email => 'ईमेल';

  @override
  String get gender => 'लिंग';

  @override
  String get customerType => 'ग्राहक प्रकार';

  @override
  String get group => 'समूह';

  @override
  String get idType => 'ID प्रकार';

  @override
  String get idNumber => 'ID नंबर';

  @override
  String get fatherName => 'पिता का नाम';

  @override
  String get businessName => 'व्यापार का नाम';

  @override
  String get accountNumber => 'खाता नंबर';

  @override
  String get billingAddress => 'बिलिंग पता';

  @override
  String get installationAddress => 'इंस्टॉलेशन पता';

  @override
  String get pinCode => 'पिन कोड';

  @override
  String get country => 'देश';

  @override
  String get state => 'राज्य';

  @override
  String get district => 'जिला';

  @override
  String get city => 'शहर';

  @override
  String get mandal => 'मंडल';

  @override
  String get sameAsBilling => 'बिलिंग पते के समान';

  @override
  String get update => 'अपडेट';

  @override
  String get createCustomer => 'ग्राहक बनाएँ';

  @override
  String get changePassword => 'पासवर्ड बदलें';

  @override
  String get oldPassword => 'पुराना पासवर्ड';

  @override
  String get newPassword => 'नया पासवर्ड';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get about => 'के बारे में';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get logoutConfirm => 'क्या आप लॉगआउट करना चाहते हैं?';

  @override
  String get theme => 'थीम';

  @override
  String get light => 'लाइट';

  @override
  String get dark => 'डार्क';

  @override
  String get system => 'सिस्टम';

  @override
  String get language => 'भाषा';

  @override
  String get english => 'English';

  @override
  String get telugu => 'తెలుగు';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get developerTools => 'डेवलपर टूल्स';

  @override
  String get debugConsole => 'डीबग कंसोल';

  @override
  String get enableDebugLogging => 'डीबग लॉगिंग सक्षम करें';

  @override
  String get debugOn => 'चालू — सभी API कॉल लॉग हो रहे हैं';

  @override
  String get debugOff => 'बंद';

  @override
  String get debugEnabled => 'डीबग लॉगिंग सक्षम — सभी API कॉल कैप्चर होंगे';

  @override
  String get debugDisabled => 'डीबग लॉगिंग अक्षम';

  @override
  String get walletTopUp => 'वॉलेट टॉप-अप';

  @override
  String get customAmount => 'कस्टम राशि';

  @override
  String get addToWallet => 'वॉलेट में जोड़ें';

  @override
  String get walletHistory => 'वॉलेट इतिहास';

  @override
  String get lcoPayment => 'LCO भुगतान';

  @override
  String get lcoCode => 'LCO कोड';

  @override
  String get paymentAmount => 'भुगतान राशि';

  @override
  String get cash => 'नकद';

  @override
  String get bank => 'बैंक';

  @override
  String get bluetoothPrinter => 'ब्लूटूथ प्रिंटर';

  @override
  String get notConnected => 'कनेक्ट नहीं है';

  @override
  String get scanForDevices => 'डिवाइस स्कैन करें';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get retry => 'पुनः प्रयास';

  @override
  String get error => 'त्रुटि';

  @override
  String get success => 'सफल';

  @override
  String get noData => 'कोई डेटा उपलब्ध नहीं';

  @override
  String get tapToRetry => 'पुनः प्रयास के लिए टैप करें';

  @override
  String get quickAction => 'त्वरित कार्रवाई';

  @override
  String get enterStbNo => 'STB नंबर दर्ज करें...';

  @override
  String get enterVcNo => 'VC नंबर दर्ज करें...';

  @override
  String get enterMobile => 'मोबाइल दर्ज करें...';

  @override
  String get enterName => 'नाम दर्ज करें...';

  @override
  String get enterAccountNo => 'A/C नंबर दर्ज करें...';

  @override
  String get pressEnterOrSearch => 'Enter दबाएं या खोजें क्लिक करें';

  @override
  String get poweredByEzybill => 'Ezybill क्विक एक्शन्स द्वारा संचालित';

  @override
  String get activePackagesLabel => 'सक्रिय पैकेज';

  @override
  String get lastDeactivatedPackages => 'अंतिम निष्क्रिय पैकेज';

  @override
  String get activated => 'सक्रिय किया गया';

  @override
  String get lco => 'LCO';

  @override
  String get tempActivate => 'अस्थायी सक्रिय';

  @override
  String get aiAssistant => 'AI सहायक';

  @override
  String get comingSoon => 'जल्द आ रहा है';

  @override
  String get describeAction => 'बताएं कि आप क्या करना चाहते हैं...';

  @override
  String get exampleRecharge => 'CONAX123 बॉक्स रीचार्ज करें';

  @override
  String get exampleDeactivate => '108045 निष्क्रिय करें...';

  @override
  String get exampleStatus => '9177 की स्थिति जांचें...';

  @override
  String get deviceRegistration => 'डिवाइस पंजीकरण';

  @override
  String get registerDevice => 'MSO के साथ अपना डिवाइस पंजीकृत करें';

  @override
  String get msoKey => 'MSO कुंजी';

  @override
  String get enterMsoKey => 'MSO कुंजी दर्ज करें';

  @override
  String get register => 'पंजीकरण करें';

  @override
  String get registrationSuccessful => 'पंजीकरण सफल';

  @override
  String get registrationFailed => 'पंजीकरण विफल';

  @override
  String get deviceId => 'डिवाइस ID';

  @override
  String get enterValidDetails => 'कृपया सही विवरण दर्ज करें';

  @override
  String get registrationSuccess =>
      'इस डिवाइस के साथ आपका पंजीकरण सफल हुआ। लॉगिन करने के लिए OK दबाएं।';

  @override
  String get maxRegistrations => 'अधिकतम पंजीकरण सीमा पूरी हो गई';

  @override
  String get subscriptionExpired =>
      'आपकी ऐप सदस्यता समाप्त हो गई है, कृपया नवीनीकरण करें';

  @override
  String get appDoesNotExist => 'ऐप मौजूद नहीं है';

  @override
  String get employeeNotFound => 'कर्मचारी मौजूद नहीं है';
}
