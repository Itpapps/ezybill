/// Model representing the BMS (Business Management System) SOAP registration
/// response. The server returns a semicolon-separated key=value string
/// (NOT JSON), which this class parses.
class BmsRegistrationResponse {
  final int statusCode;
  final String statusMessage;
  final String ipAddress; // REST API URL (ends with /wsController)
  final String employeeId;
  final int appThemeColor;
  final int appDashboard;
  final String appLogoPath;
  final int registrationRequired;
  final String version; // "V1" or "V2"

  const BmsRegistrationResponse({
    required this.statusCode,
    required this.statusMessage,
    required this.ipAddress,
    required this.employeeId,
    required this.appThemeColor,
    required this.appDashboard,
    required this.appLogoPath,
    required this.registrationRequired,
    required this.version,
  });

  /// Parse from a Map (extracted from structured XML tags).
  factory BmsRegistrationResponse.fromMap(Map<String, String> map) {
    return BmsRegistrationResponse(
      statusCode: int.tryParse(map['statusCode'] ?? '') ?? -1,
      statusMessage: map['statusMessage'] ?? '',
      ipAddress: map['ipAddress'] ?? '',
      employeeId: map['employeeId'] ?? '',
      appThemeColor: int.tryParse(map['appThemeColor'] ?? '') ?? 1,
      appDashboard: int.tryParse(map['appDashboard'] ?? '') ?? 0,
      appLogoPath: map['appLogoPath'] ?? '',
      registrationRequired:
          int.tryParse(map['registrationRequired'] ?? '') ?? 0,
      version: map['version'] ?? 'V1',
    );
  }

  /// Parse from semicolon-separated key=value string.
  ///
  /// Example:
  /// ```
  /// statusCode=0;statusMessage=Registered successfully;ipAddress=http://...;employeeId=3541;appThemeColor=1;appDashboard=0;appLogoPath=...
  /// ```
  factory BmsRegistrationResponse.fromSoapString(String response) {
    final map = <String, String>{};
    final pairs = response.split(';');

    for (final pair in pairs) {
      final trimmed = pair.trim();
      if (trimmed.isEmpty) continue;

      final eqIndex = trimmed.indexOf('=');
      if (eqIndex == -1) continue;

      final key = trimmed.substring(0, eqIndex).trim();
      final value = trimmed.substring(eqIndex + 1).trim();
      map[key] = value;
    }

    return BmsRegistrationResponse(
      statusCode: int.tryParse(map['statusCode'] ?? '') ?? -1,
      statusMessage: map['statusMessage'] ?? '',
      ipAddress: map['ipAddress'] ?? '',
      employeeId: map['employeeId'] ?? '',
      appThemeColor: int.tryParse(map['appThemeColor'] ?? '') ?? 1,
      appDashboard: int.tryParse(map['appDashboard'] ?? '') ?? 0,
      appLogoPath: map['appLogoPath'] ?? '',
      registrationRequired:
          int.tryParse(map['registrationRequired'] ?? '') ?? 0,
      version: map['version'] ?? 'V1',
    );
  }

  /// The REST API base URL — store ipAddress as-is from BMS.
  /// The interceptor handles URL construction for both live (wsController)
  /// and local (direct LcoRestServices) environments.
  String get restBaseUrl => ipAddress;

  /// Whether the registration/check was successful.
  bool get isSuccess => statusCode == 0;

  @override
  String toString() =>
      'BmsRegistrationResponse(statusCode: $statusCode, statusMessage: $statusMessage, '
      'ipAddress: $ipAddress, employeeId: $employeeId, '
      'appThemeColor: $appThemeColor, appDashboard: $appDashboard, '
      'version: $version)';
}
