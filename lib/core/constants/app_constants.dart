class AppConstants {
  AppConstants._();

  // SharedPreferences Keys
  static const String prefKeyToken = 'auth_token';
  static const String prefKeyJwtToken = 'jwt_token';
  static const String prefKeyDealerId = 'dealer_id';
  static const String prefKeyEmployeeId = 'employee_id';
  static const String prefKeyUserType = 'user_type';
  static const String prefKeyEmployeeName = 'employee_name';
  static const String prefKeyFirstName = 'first_name';
  static const String prefKeyLastName = 'last_name';
  static const String prefKeyEmail = 'email';
  static const String prefKeyPhone = 'phone';
  static const String prefKeyLcoCode = 'lco_code';
  static const String prefKeyBusinessName = 'business_name';
  static const String prefKeyParentType = 'employee_parent_type';
  static const String prefKeyParentId = 'employee_parent_id';
  static const String prefKeyIsLoggedIn = 'is_logged_in';
  static const String prefKeyLoginResponse = 'login_response_json';

  // App Info
  static const String appName = 'EzyBill';
  static const String appVersion = '1.0.0';
  static const String currencySymbol = '₹';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 60000; // 60 seconds — report APIs can be slow
}
