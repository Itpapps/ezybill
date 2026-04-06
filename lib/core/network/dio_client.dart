import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../services/debug_log_service.dart';
import 'api_exception.dart';
import 'payload_encryption.dart';

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
/// Server wraps all responses as `{payload: "...", hash: "..."}`.
/// We decode via the `hash` field for efficiency.
class _ResponseDecryptionInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
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

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add JWT token to header if available
    if (_client.jwtToken != null && _client.jwtToken!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${_client.jwtToken}';
    }

    // Handle custom base URL
    final customBaseUrl = options.extra['customBaseUrl'] as String?;
    if (customBaseUrl != null) {
      options.baseUrl = customBaseUrl;
      options.extra.remove('customBaseUrl');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _client.onAuthFailure?.call();
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
    handler.next(err);
  }
}
