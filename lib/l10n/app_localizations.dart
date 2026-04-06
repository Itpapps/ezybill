import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('te'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'EzyBill'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @apiBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'API Base URL'**
  String get apiBaseUrl;

  /// No description provided for @editServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Edit the server URL for API requests.'**
  String get editServerUrl;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get resetToDefault;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'OVERVIEW'**
  String get overview;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @fresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get fresh;

  /// No description provided for @assigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assigned;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @totalStbs.
  ///
  /// In en, this message translates to:
  /// **'Total STBs'**
  String get totalStbs;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @recharged.
  ///
  /// In en, this message translates to:
  /// **'Recharged'**
  String get recharged;

  /// No description provided for @expiring7d.
  ///
  /// In en, this message translates to:
  /// **'Expiring 7d'**
  String get expiring7d;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'balance'**
  String get balance;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get topUp;

  /// No description provided for @lastRecharge.
  ///
  /// In en, this message translates to:
  /// **'Last Recharge'**
  String get lastRecharge;

  /// No description provided for @ledger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledger;

  /// No description provided for @tapToAssign.
  ///
  /// In en, this message translates to:
  /// **'Tap to assign'**
  String get tapToAssign;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get newCustomer;

  /// No description provided for @showingCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {count}'**
  String showingCount(int count);

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Phone, Name, or Setup Box ID'**
  String get searchPlaceholder;

  /// No description provided for @noSubscribersFound.
  ///
  /// In en, this message translates to:
  /// **'No subscribers found'**
  String get noSubscribersFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or filter'**
  String get tryDifferentSearch;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @recharge.
  ///
  /// In en, this message translates to:
  /// **'Recharge'**
  String get recharge;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @addPackage.
  ///
  /// In en, this message translates to:
  /// **'Add Pkg'**
  String get addPackage;

  /// No description provided for @pairing.
  ///
  /// In en, this message translates to:
  /// **'Pairing'**
  String get pairing;

  /// No description provided for @subscriberDetail.
  ///
  /// In en, this message translates to:
  /// **'Subscriber Detail'**
  String get subscriberDetail;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @stbSerial.
  ///
  /// In en, this message translates to:
  /// **'STB Serial'**
  String get stbSerial;

  /// No description provided for @vcNumber.
  ///
  /// In en, this message translates to:
  /// **'VC Number'**
  String get vcNumber;

  /// No description provided for @stbType.
  ///
  /// In en, this message translates to:
  /// **'STB Type'**
  String get stbType;

  /// No description provided for @monthlyBill.
  ///
  /// In en, this message translates to:
  /// **'Monthly Bill'**
  String get monthlyBill;

  /// No description provided for @activePackages.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE PACKAGES'**
  String get activePackages;

  /// No description provided for @packages.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get packages;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @subscribers.
  ///
  /// In en, this message translates to:
  /// **'Subscribers'**
  String get subscribers;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @makePayment.
  ///
  /// In en, this message translates to:
  /// **'Make Payment'**
  String get makePayment;

  /// No description provided for @payByCash.
  ///
  /// In en, this message translates to:
  /// **'Pay by Cash'**
  String get payByCash;

  /// No description provided for @payByCheque.
  ///
  /// In en, this message translates to:
  /// **'Pay by Cheque'**
  String get payByCheque;

  /// No description provided for @payByCard.
  ///
  /// In en, this message translates to:
  /// **'Pay by Card'**
  String get payByCard;

  /// No description provided for @payByVoucher.
  ///
  /// In en, this message translates to:
  /// **'Pay by Voucher'**
  String get payByVoucher;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @receiptNumber.
  ///
  /// In en, this message translates to:
  /// **'Receipt Number'**
  String get receiptNumber;

  /// No description provided for @remarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get remarks;

  /// No description provided for @chequeNo.
  ///
  /// In en, this message translates to:
  /// **'Cheque/DD No'**
  String get chequeNo;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @branch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branch;

  /// No description provided for @chequeDate.
  ///
  /// In en, this message translates to:
  /// **'Cheque Date'**
  String get chequeDate;

  /// No description provided for @voucherCode.
  ///
  /// In en, this message translates to:
  /// **'Voucher Code'**
  String get voucherCode;

  /// No description provided for @cardType.
  ///
  /// In en, this message translates to:
  /// **'Card Type'**
  String get cardType;

  /// No description provided for @pendingAmount.
  ///
  /// In en, this message translates to:
  /// **'Pending Amount'**
  String get pendingAmount;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccessful;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailed;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid Amount'**
  String get invalidAmount;

  /// No description provided for @emptyFields.
  ///
  /// In en, this message translates to:
  /// **'Empty Fields'**
  String get emptyFields;

  /// No description provided for @amountShouldNotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Amount should not be empty'**
  String get amountShouldNotBeEmpty;

  /// No description provided for @selectValidReceipt.
  ///
  /// In en, this message translates to:
  /// **'Select valid Receipt Number'**
  String get selectValidReceipt;

  /// No description provided for @fieldsShouldNotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Fields should not be empty'**
  String get fieldsShouldNotBeEmpty;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @invoiceHistory.
  ///
  /// In en, this message translates to:
  /// **'Invoice History'**
  String get invoiceHistory;

  /// No description provided for @pgTransactions.
  ///
  /// In en, this message translates to:
  /// **'PG Transactions'**
  String get pgTransactions;

  /// No description provided for @complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaints;

  /// No description provided for @openComplaints.
  ///
  /// In en, this message translates to:
  /// **'Open Complaints'**
  String get openComplaints;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'Create New'**
  String get createNew;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @subcategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get subcategory;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @assignTo.
  ///
  /// In en, this message translates to:
  /// **'Assign To'**
  String get assignTo;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @ticketNumber.
  ///
  /// In en, this message translates to:
  /// **'Ticket Number'**
  String get ticketNumber;

  /// No description provided for @complaintCreated.
  ///
  /// In en, this message translates to:
  /// **'Complaint Created'**
  String get complaintCreated;

  /// No description provided for @updateComplaint.
  ///
  /// In en, this message translates to:
  /// **'Update Complaint'**
  String get updateComplaint;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @complaintHistory.
  ///
  /// In en, this message translates to:
  /// **'Complaint History'**
  String get complaintHistory;

  /// No description provided for @totalComplaints.
  ///
  /// In en, this message translates to:
  /// **'Total Complaints'**
  String get totalComplaints;

  /// No description provided for @stbOperations.
  ///
  /// In en, this message translates to:
  /// **'STB Operations'**
  String get stbOperations;

  /// No description provided for @deactivateStb.
  ///
  /// In en, this message translates to:
  /// **'Deactivate STB'**
  String get deactivateStb;

  /// No description provided for @reactivateStb.
  ///
  /// In en, this message translates to:
  /// **'Reactivate STB'**
  String get reactivateStb;

  /// No description provided for @temporaryActivate.
  ///
  /// In en, this message translates to:
  /// **'Temporary Activate STB'**
  String get temporaryActivate;

  /// No description provided for @selectReason.
  ///
  /// In en, this message translates to:
  /// **'Select Reason'**
  String get selectReason;

  /// No description provided for @deactivationRemarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get deactivationRemarks;

  /// No description provided for @confirmDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to DEACTIVATE this STB?'**
  String get confirmDeactivate;

  /// No description provided for @confirmReactivate.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to REACTIVATE this STB?'**
  String get confirmReactivate;

  /// No description provided for @pairStb.
  ///
  /// In en, this message translates to:
  /// **'Pair STB'**
  String get pairStb;

  /// No description provided for @unpairStb.
  ///
  /// In en, this message translates to:
  /// **'Unpair STB'**
  String get unpairStb;

  /// No description provided for @serialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial Number'**
  String get serialNumber;

  /// No description provided for @replacement.
  ///
  /// In en, this message translates to:
  /// **'STB Replacement'**
  String get replacement;

  /// No description provided for @packageOperations.
  ///
  /// In en, this message translates to:
  /// **'Package Operations'**
  String get packageOperations;

  /// No description provided for @activatePackage.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activatePackage;

  /// No description provided for @deactivatePackage.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivatePackage;

  /// No description provided for @renewPackage.
  ///
  /// In en, this message translates to:
  /// **'Renew'**
  String get renewPackage;

  /// No description provided for @getBill.
  ///
  /// In en, this message translates to:
  /// **'Get Bill'**
  String get getBill;

  /// No description provided for @billSummary.
  ///
  /// In en, this message translates to:
  /// **'Bill Summary'**
  String get billSummary;

  /// No description provided for @lcoShare.
  ///
  /// In en, this message translates to:
  /// **'LCO Share'**
  String get lcoShare;

  /// No description provided for @msoShare.
  ///
  /// In en, this message translates to:
  /// **'MSO Share'**
  String get msoShare;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @confirmActivate.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to Activate packages?'**
  String get confirmActivate;

  /// No description provided for @confirmDeactivatePackage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to deactivate packages?'**
  String get confirmDeactivatePackage;

  /// No description provided for @confirmRenewal.
  ///
  /// In en, this message translates to:
  /// **'Confirm Renewal'**
  String get confirmRenewal;

  /// No description provided for @miniDayReport.
  ///
  /// In en, this message translates to:
  /// **'Mini Day Report'**
  String get miniDayReport;

  /// No description provided for @employeeCollection.
  ///
  /// In en, this message translates to:
  /// **'Employee Collection'**
  String get employeeCollection;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From Date'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To Date'**
  String get toDate;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @paymentMode.
  ///
  /// In en, this message translates to:
  /// **'Payment Mode'**
  String get paymentMode;

  /// No description provided for @customerCount.
  ///
  /// In en, this message translates to:
  /// **'Customer Count'**
  String get customerCount;

  /// No description provided for @customerSearch.
  ///
  /// In en, this message translates to:
  /// **'Customer Search'**
  String get customerSearch;

  /// No description provided for @customerNumber.
  ///
  /// In en, this message translates to:
  /// **'Customer#'**
  String get customerNumber;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get customerName;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobileNumber;

  /// No description provided for @stbNumber.
  ///
  /// In en, this message translates to:
  /// **'STB#'**
  String get stbNumber;

  /// No description provided for @lcoCustomerId.
  ///
  /// In en, this message translates to:
  /// **'LCO ID'**
  String get lcoCustomerId;

  /// No description provided for @cafNumber.
  ///
  /// In en, this message translates to:
  /// **'CAF#'**
  String get cafNumber;

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get noCustomersFound;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomer;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @customerType.
  ///
  /// In en, this message translates to:
  /// **'Customer Type'**
  String get customerType;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @idType.
  ///
  /// In en, this message translates to:
  /// **'ID Type'**
  String get idType;

  /// No description provided for @idNumber.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get idNumber;

  /// No description provided for @fatherName.
  ///
  /// In en, this message translates to:
  /// **'Father\'s Name'**
  String get fatherName;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessName;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @billingAddress.
  ///
  /// In en, this message translates to:
  /// **'Billing Address'**
  String get billingAddress;

  /// No description provided for @installationAddress.
  ///
  /// In en, this message translates to:
  /// **'Installation Address'**
  String get installationAddress;

  /// No description provided for @pinCode.
  ///
  /// In en, this message translates to:
  /// **'Pin Code'**
  String get pinCode;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @mandal.
  ///
  /// In en, this message translates to:
  /// **'Mandal'**
  String get mandal;

  /// No description provided for @sameAsBilling.
  ///
  /// In en, this message translates to:
  /// **'Same as Billing Address'**
  String get sameAsBilling;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @createCustomer.
  ///
  /// In en, this message translates to:
  /// **'Create Customer'**
  String get createCustomer;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @telugu.
  ///
  /// In en, this message translates to:
  /// **'తెలుగు'**
  String get telugu;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// No description provided for @developerTools.
  ///
  /// In en, this message translates to:
  /// **'Developer Tools'**
  String get developerTools;

  /// No description provided for @debugConsole.
  ///
  /// In en, this message translates to:
  /// **'Debug Console'**
  String get debugConsole;

  /// No description provided for @enableDebugLogging.
  ///
  /// In en, this message translates to:
  /// **'Enable Debug Logging'**
  String get enableDebugLogging;

  /// No description provided for @debugOn.
  ///
  /// In en, this message translates to:
  /// **'ON — logging all API calls'**
  String get debugOn;

  /// No description provided for @debugOff.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get debugOff;

  /// No description provided for @debugEnabled.
  ///
  /// In en, this message translates to:
  /// **'Debug logging enabled — all API calls will be captured'**
  String get debugEnabled;

  /// No description provided for @debugDisabled.
  ///
  /// In en, this message translates to:
  /// **'Debug logging disabled'**
  String get debugDisabled;

  /// No description provided for @walletTopUp.
  ///
  /// In en, this message translates to:
  /// **'Wallet Top-Up'**
  String get walletTopUp;

  /// No description provided for @customAmount.
  ///
  /// In en, this message translates to:
  /// **'Custom Amount'**
  String get customAmount;

  /// No description provided for @addToWallet.
  ///
  /// In en, this message translates to:
  /// **'Add to Wallet'**
  String get addToWallet;

  /// No description provided for @walletHistory.
  ///
  /// In en, this message translates to:
  /// **'Wallet History'**
  String get walletHistory;

  /// No description provided for @lcoPayment.
  ///
  /// In en, this message translates to:
  /// **'LCO Payment'**
  String get lcoPayment;

  /// No description provided for @lcoCode.
  ///
  /// In en, this message translates to:
  /// **'LCO Code'**
  String get lcoCode;

  /// No description provided for @paymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Payment Amount'**
  String get paymentAmount;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @bluetoothPrinter.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Printer'**
  String get bluetoothPrinter;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @scanForDevices.
  ///
  /// In en, this message translates to:
  /// **'Scan for Devices'**
  String get scanForDevices;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @tapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Tap to retry'**
  String get tapToRetry;

  /// No description provided for @quickAction.
  ///
  /// In en, this message translates to:
  /// **'Quick Action'**
  String get quickAction;

  /// No description provided for @enterStbNo.
  ///
  /// In en, this message translates to:
  /// **'Enter STB No...'**
  String get enterStbNo;

  /// No description provided for @enterVcNo.
  ///
  /// In en, this message translates to:
  /// **'Enter VC No...'**
  String get enterVcNo;

  /// No description provided for @enterMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter Mobile...'**
  String get enterMobile;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter Name...'**
  String get enterName;

  /// No description provided for @enterAccountNo.
  ///
  /// In en, this message translates to:
  /// **'Enter A/C No...'**
  String get enterAccountNo;

  /// No description provided for @pressEnterOrSearch.
  ///
  /// In en, this message translates to:
  /// **'Press Enter or click search'**
  String get pressEnterOrSearch;

  /// No description provided for @poweredByEzybill.
  ///
  /// In en, this message translates to:
  /// **'Powered by Ezybill Quick Actions'**
  String get poweredByEzybill;

  /// No description provided for @activePackagesLabel.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE PACKAGES'**
  String get activePackagesLabel;

  /// No description provided for @lastDeactivatedPackages.
  ///
  /// In en, this message translates to:
  /// **'LAST DEACTIVATED PACKAGES'**
  String get lastDeactivatedPackages;

  /// No description provided for @activated.
  ///
  /// In en, this message translates to:
  /// **'Activated'**
  String get activated;

  /// No description provided for @lco.
  ///
  /// In en, this message translates to:
  /// **'LCO'**
  String get lco;

  /// No description provided for @tempActivate.
  ///
  /// In en, this message translates to:
  /// **'Temp Activate'**
  String get tempActivate;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @describeAction.
  ///
  /// In en, this message translates to:
  /// **'Describe what you want to do...'**
  String get describeAction;

  /// No description provided for @exampleRecharge.
  ///
  /// In en, this message translates to:
  /// **'Recharge box CONAX123'**
  String get exampleRecharge;

  /// No description provided for @exampleDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate 108045...'**
  String get exampleDeactivate;

  /// No description provided for @exampleStatus.
  ///
  /// In en, this message translates to:
  /// **'Check status of 9177...'**
  String get exampleStatus;

  /// No description provided for @deviceRegistration.
  ///
  /// In en, this message translates to:
  /// **'Device Registration'**
  String get deviceRegistration;

  /// No description provided for @registerDevice.
  ///
  /// In en, this message translates to:
  /// **'Register your device with MSO'**
  String get registerDevice;

  /// No description provided for @msoKey.
  ///
  /// In en, this message translates to:
  /// **'MSO Key'**
  String get msoKey;

  /// No description provided for @enterMsoKey.
  ///
  /// In en, this message translates to:
  /// **'Enter MSO Key'**
  String get enterMsoKey;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful'**
  String get registrationSuccessful;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration Failed'**
  String get registrationFailed;

  /// No description provided for @deviceId.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get deviceId;

  /// No description provided for @enterValidDetails.
  ///
  /// In en, this message translates to:
  /// **'Please check and enter valid details'**
  String get enterValidDetails;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your Registration with this device is Successful. Press OK to Login.'**
  String get registrationSuccess;

  /// No description provided for @maxRegistrations.
  ///
  /// In en, this message translates to:
  /// **'Maximum registrations reached'**
  String get maxRegistrations;

  /// No description provided for @subscriptionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your app subscription expired, please renew'**
  String get subscriptionExpired;

  /// No description provided for @appDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'App does not exist'**
  String get appDoesNotExist;

  /// No description provided for @employeeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Employee does not exist'**
  String get employeeNotFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
