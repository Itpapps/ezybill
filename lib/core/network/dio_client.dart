import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../services/debug_log_service.dart';
import 'api_exception.dart';
import 'payload_encryption.dart';
import 'soap_helper.dart';

class DioClient {
  late final Dio _dio;
  String? _jwtToken;
  String? _authToken;

  // Callback for when auth fails - triggers logout
  VoidCallback? onAuthFailure;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.restBase,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeout),
        contentType: 'application/x-www-form-urlencoded',
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.addAll([
      _DebugLogRequestInterceptor(),
      _PayloadEncryptionInterceptor(),
      _AuthInterceptor(this),
      _ResponseDecryptionInterceptor(),
      _DebugLogResponseInterceptor(),
      if (kDebugMode) _LoggingInterceptor(),
    ]);
  }

  void setTokens({String? jwtToken, String? authToken}) {
    _jwtToken = jwtToken;
    _authToken = authToken;
  }

  String? get jwtToken => _jwtToken;
  String? get authToken => _authToken;

  Future<Response<T>> post<T>(
    String path, {
    Map<String, dynamic>? data,
    String? customBaseUrl,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data ?? <String, dynamic>{},
        options: customBaseUrl != null
            ? (options ?? Options()).copyWith(
                extra: {'customBaseUrl': customBaseUrl},
              )
            : options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: 'Connection timed out');
      case DioExceptionType.connectionError:
        return NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          onAuthFailure?.call();
          return UnauthorizedException();
        }
        return ServerException(
          message: e.response?.statusMessage ?? 'Server error',
        );
      default:
        return ApiException(
          message: e.message ?? 'Unknown error occurred',
        );
    }
  }
}

/// Captures the original request data BEFORE encryption for debug logging.
class _DebugLogRequestInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final debugLog = DebugLogService();
    if (debugLog.enabled) {
      // Store original data and start time in extras
      final data = options.data;
      final mapData =
          data is Map<String, dynamic> ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      options.extra['_debug_original_data'] = mapData;
      options.extra['_debug_start_time'] =
          DateTime.now().millisecondsSinceEpoch;
    }
    handler.next(options);
  }
}

/// Encrypts all POST request payloads using the server's Encryption_lib scheme.
///
/// The server decrypts payloads in its constructor for ALL endpoints:
///   `$this->payload = $this->encryption_lib->checkPayload($this->post());`
///
/// So every POST must send `{payload: ..., hash: ...}` instead of raw fields.
class _PayloadEncryptionInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method == 'POST') {
      final data = options.data;
      final mapData = data is Map<String, dynamic> ? data : <String, dynamic>{};

      // LIVE: customerRestservices expects plain form data (no encryption).
      // LOCAL: LcoRestServices requires encrypted {payload, hash} format.
      if (ApiConstants.isWsController) {
        debugPrint('[ENC-v2] LIVE mode — skipping encryption for ${options.path}');
      } else {
        debugPrint('[ENC-v2] Encrypting ${mapData.length} fields for ${options.path}');
        final encrypted = PayloadEncryption.encryptPayload(mapData);
        debugPrint('[ENC-v2] Result: payload=${encrypted['payload']?.length ?? 0}chars, hash=${encrypted['hash']?.length ?? 0}chars');

        // Store encrypted preview for debug log
        final debugLog = DebugLogService();
        if (debugLog.enabled) {
          final payloadStr = encrypted['payload']?.toString() ?? '';
          final hashStr = encrypted['hash']?.toString() ?? '';
          options.extra['_debug_encrypted_preview'] =
              'payload=${payloadStr.length > 50 ? payloadStr.substring(0, 50) : payloadStr}... hash=${hashStr.length > 20 ? hashStr.substring(0, 20) : hashStr}...';
        }

        options.data = encrypted;
      }
    }
    handler.next(options);
  }
}

/// Captures decrypted response data for debug logging.
class _DebugLogResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final debugLog = DebugLogService();
    if (debugLog.enabled) {
      final startTime =
          response.requestOptions.extra['_debug_start_time'] as int?;
      final durationMs = startTime != null
          ? DateTime.now().millisecondsSinceEpoch - startTime
          : 0;

      final originalData = response.requestOptions.extra['_debug_original_data']
          as Map<String, dynamic>?;
      final encryptedPreview =
          response.requestOptions.extra['_debug_encrypted_preview'] as String?;

      final responseData = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{'_raw': response.data?.toString() ?? ''};

      debugLog.log(DebugLogEntry(
        timestamp: DateTime.now(),
        method: response.requestOptions.method,
        endpoint: response.requestOptions.path,
        requestData: originalData ?? {},
        encryptedPayload: encryptedPreview,
        httpStatus: response.statusCode,
        responseData: responseData,
        durationMs: durationMs,
      ));
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final debugLog = DebugLogService();
    if (debugLog.enabled) {
      final startTime =
          err.requestOptions.extra['_debug_start_time'] as int?;
      final durationMs = startTime != null
          ? DateTime.now().millisecondsSinceEpoch - startTime
          : 0;

      final originalData = err.requestOptions.extra['_debug_original_data']
          as Map<String, dynamic>?;
      final encryptedPreview =
          err.requestOptions.extra['_debug_encrypted_preview'] as String?;

      debugLog.log(DebugLogEntry(
        timestamp: DateTime.now(),
        method: err.requestOptions.method,
        endpoint: err.requestOptions.path,
        requestData: originalData ?? {},
        encryptedPayload: encryptedPreview,
        httpStatus: err.response?.statusCode,
        durationMs: durationMs,
        error: '${err.type}: ${err.message}',
      ));
    }
    handler.next(err);
  }
}

/// Decrypts server responses that are encrypted via `sendResponse -> app_data_encryption`.
/// Server wraps all responses as `{payload: "...", hash: "..."}` .
/// We decode via the `hash` field for efficiency.
///
/// Also handles SOAP XML responses (live mode) by parsing them to Map.
class _ResponseDecryptionInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final soapMethod = response.requestOptions.extra['_soap_method'] as String?;

    // ── SOAP XML response (live mode) ──
    if (soapMethod != null && response.data is String) {
      final xml = response.data as String;
      debugPrint('[SOAP-RESP] Parsing response for $soapMethod (${xml.length} chars)');

      final parsed = SoapHelper.parseResponse(xml);
      if (parsed != null) {
        debugPrint('[SOAP-RESP] Parsed keys: ${parsed.keys.toList()}');
        response.data = parsed;
      } else {
        debugPrint('[SOAP-RESP] FAILED to parse SOAP response, passing raw string');
        debugPrint('[SOAP-RESP] XML (first 500): ${xml.substring(0, xml.length > 500 ? 500 : xml.length)}');
        // Try to extract error message from SOAP fault
        final faultMatch = RegExp(r'<faultstring[^>]*>(.*?)</faultstring>', dotAll: true).firstMatch(xml);
        if (faultMatch != null) {
          response.data = <String, dynamic>{
            'status_code': 1,
            'status_msg': faultMatch.group(1) ?? 'SOAP Fault',
          };
        } else {
          // Ensure response.data is always a Map so cast in datasources won't crash
          response.data = <String, dynamic>{
            'status_code': 1,
            'status_msg': 'Unexpected response format from server',
          };
        }
      }
      handler.next(response);
      return;
    }

    // ── Regular JSON response (local mode or customerRestservices) ──
    final data = response.data;
    debugPrint('[DECRYPT] Response type: ${data.runtimeType} for ${response.requestOptions.uri}');
    if (data is Map<String, dynamic>) {
      debugPrint('[DECRYPT] Keys: ${data.keys.toList()}');
      if (data.containsKey('hash') && data.containsKey('payload')) {
        debugPrint('[DECRYPT] Found hash+payload, decrypting...');
        final decrypted = PayloadEncryption.decryptResponse(data);
        if (decrypted != null) {
          debugPrint('[DECRYPT] Success! Decrypted keys: ${decrypted.keys.toList()}');
          debugPrint('[DECRYPT] Decrypted data: $decrypted');
          response.data = decrypted;
        } else {
          debugPrint('[DECRYPT] FAILED - decryptResponse returned null');
        }
      } else {
        debugPrint('[DECRYPT] No hash/payload - passing through as-is: $data');
      }
    } else if (data is String) {
      debugPrint('[DECRYPT] Response is String (first 200 chars): ${data.substring(0, data.length > 200 ? 200 : data.length)}');
    }
    handler.next(response);
  }
}

/// Handles JWT Bearer token injection and custom base URL routing.
class _AuthInterceptor extends Interceptor {
  final DioClient _client;

  _AuthInterceptor(this._client);

  /// Methods available in customerRestservices on the live server.
  /// Derived from configg.properties entries with /customerRestservices/ prefix.
  /// These use REST; all others route through wsController SOAP.
  static const _customerRestMethods = <String>{
    // From configg.properties: /customerRestservices/ endpoints (V1 unencrypted REST)
    'getaccesscontroll',
    'getComplaintsubCategory',
    'getLcoEmployeeList',
    'getReceiptRanges',
    'updateCustomerLocation',
    'getExpiryServicesDateWiseCount',
    'extendCustomerServices',
    'getbilldetails',
    'getlcowallet',
    // Retrofit endpoints (also customerRestservices)
    'getComplaintList',
    'gettotalcomplaintslist',
    'getdashboardlist',
    // PG transactions — V1 uses customerRestservices, not wsController SOAP
    'pgTransactionLogs',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Always resolve base URL dynamically (may change after BMS registration)
    final customBaseUrl = options.extra['customBaseUrl'] as String?;
    if (customBaseUrl != null) {
      options.baseUrl = customBaseUrl;
      options.extra.remove('customBaseUrl');
    } else if (ApiConstants.isWsController) {
      // ══ LIVE MODE: Hybrid routing ══
      // Some methods exist in customerRestservices (REST), others only in wsController (SOAP).
      // Route accordingly based on the known REST method list from configg.properties.
      final rawPath = options.path; // e.g. /dashBoardDetailsRest
      var methodName = rawPath.startsWith('/') ? rawPath.substring(1) : rawPath;
      // Strip "Rest" suffix for both REST and SOAP
      if (methodName.endsWith('Rest')) {
        methodName = methodName.substring(0, methodName.length - 'Rest'.length);
      }

      if (_customerRestMethods.contains(methodName)) {
        // ── REST path: method exists in customerRestservices ──
        options.baseUrl = ApiConstants.restBase;
        options.path = '/$methodName';
        debugPrint('[LIVE-REST] $methodName → customerRestservices');
      } else {
        // ── SOAP path: method only exists in wsController ──
        final data = options.data;
        final mapData = data is Map<String, dynamic>
            ? data
            : <String, dynamic>{};

        final soapXml = SoapHelper.buildEnvelope(methodName, mapData);

        debugPrint('[SOAP] Wrapping $methodName with ${mapData.length} params');

        options.baseUrl = ApiConstants.baseUrl; // .../index.php/wsController
        options.path = '';
        options.data = soapXml;
        options.contentType = 'text/xml; charset=utf-8';
        options.responseType = ResponseType.plain; // receive XML as string
        options.headers['SOAPAction'] = '/$methodName';

        // Flag for response parser
        options.extra['_soap_method'] = methodName;
      }
    } else {
      // ══ LOCAL MODE: Direct REST to LcoRestServices ══
      options.baseUrl = ApiConstants.restBase;
    }

    // Add JWT token to header if available
    if (_client.jwtToken != null && _client.jwtToken!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${_client.jwtToken}';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _client.onAuthFailure?.call();
    }

    // For SOAP requests that get HTTP errors (e.g., 500 SOAP fault),
    // try to parse the fault and return it as a resolved response
    // so the app gets a proper error message instead of a raw exception.
    final soapMethod = err.requestOptions.extra['_soap_method'] as String?;
    if (soapMethod != null && err.response != null) {
      final body = err.response?.data;
      if (body is String && body.contains('faultstring')) {
        final faultMatch = RegExp(
          r'<faultstring[^>]*>(.*?)</faultstring>',
          dotAll: true,
        ).firstMatch(body);
        final message = faultMatch?.group(1) ?? 'SOAP error';
        debugPrint('[SOAP-ERR] $soapMethod fault: $message');
        // Resolve as a "success" response with error status
        handler.resolve(Response(
          requestOptions: err.requestOptions,
          statusCode: 200,
          data: <String, dynamic>{
            'status_code': 1,
            'status_msg': message,
          },
        ));
        return;
      }
    }

    handler.next(err);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('-> ${options.method} ${options.uri}');
    if (options.data != null) {
      final data = options.data;
      if (data is Map) {
        final payload = data['payload']?.toString() ?? '';
        final hash = data['hash']?.toString() ?? '';
        debugPrint(
            '  Encrypted: payload=${payload.length}chars, hash=${hash.length}chars');
      } else {
        debugPrint('  Body: $data');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('<- ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('x ${err.type} ${err.message}');
    if (err.response != null) {
      debugPrint('[ERROR] Status: ${err.response?.statusCode}');
      debugPrint('[ERROR] Response body: ${err.response?.data}');
    }
    handler.next(err);
  }
}
