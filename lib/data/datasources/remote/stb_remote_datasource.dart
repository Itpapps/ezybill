import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

class StbRemoteDatasource {
  final DioClient _dio;

  StbRemoteDatasource({required DioClient dio}) : _dio = dio;

  /// Get customer box/STB details
  Future<Map<String, dynamic>> getCustomerBoxDetails({
    required String authtoken,
    required String customerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.customerBoxDetails,
      data: {
        'authtoken': authtoken,
        'customerId': customerId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get particular box details
  Future<Map<String, dynamic>> getParticularBoxDetails({
    required String authtoken,
    required String customerId,
    required String stockId,
  }) async {
    final response = await _dio.post(
      ApiConstants.particularBoxDetails,
      data: {
        'authtoken': authtoken,
        'customerId': customerId,
        'stockId': stockId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Deactivate a box/STB
  /// Server: deactivateBoxRest_post (LcoRestServices.php)
  ///
  /// Key names are the server's, verified against its validator:
  /// `customerId`, `reasonId` and `resellerId` are all `isRequired` and are
  /// read in that exact camelCase form. They used to go out as `customer_id`,
  /// `reason_id` and `reseller_id`, which the server ignores — every deactivate
  /// was rejected with status_code 1 before it reached the model. Android
  /// (Box_Operations_Fragment.DeactiveBoxRest) sends the same camelCase keys.
  /// `dealer_id` is not read by the server (dealer comes from the token) but
  /// Android sends it, so it is kept.
  Future<Map<String, dynamic>> deactivateBox({
    required String authtoken,
    required String customerId,
    required String reasonId,
    String? serialNumber,
    String? vcNumber,
    String? boxNumber,
    String? macAddress,
    String? stockId,
    String? deviceId,
    String? backEndSetupId,
    String? remarks,
    int? dealerId,
    int? resellerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.deactivateBox,
      data: {
        'authtoken': authtoken,
        'customerId': customerId,
        'reasonId': reasonId,
        'from_mobileapp': '1',
        if (serialNumber != null) 'serialNumber': serialNumber,
        if (vcNumber != null) 'vcNumber': vcNumber,
        if (boxNumber != null) 'boxNumber': boxNumber,
        if (macAddress != null) 'macAddress': macAddress,
        if (stockId != null) 'stockId': stockId,
        if (deviceId != null) 'deviceId': deviceId,
        if (backEndSetupId != null) 'backEndSetupId': backEndSetupId,
        if (remarks != null) 'remarks': remarks,
        if (dealerId != null) 'dealer_id': dealerId,
        if (resellerId != null) 'resellerId': resellerId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Reactivate a box/STB
  /// Requires reinitialize: '1' per spec.
  /// Per Android spec: sends serialNumber, boxNumber, macAddress, stockId,
  /// deviceId, backEndSetupId. Does NOT send vcNumber, customer_id, dealer_id,
  /// reseller_id, reasonId, remarks, or from_mobileapp.
  Future<Map<String, dynamic>> reactivateBox({
    required String authtoken,
    String? serialNumber,
    String? boxNumber,
    String? macAddress,
    String? stockId,
    String? deviceId,
    String? backEndSetupId,
  }) async {
    final response = await _dio.post(
      ApiConstants.reactivateBox,
      data: {
        'authtoken': authtoken,
        'reinitialize': '1',
        if (serialNumber != null) 'serialNumber': serialNumber,
        if (boxNumber != null) 'boxNumber': boxNumber,
        if (macAddress != null) 'macAddress': macAddress,
        if (stockId != null) 'stockId': stockId,
        if (deviceId != null) 'deviceId': deviceId,
        if (backEndSetupId != null) 'backEndSetupId': backEndSetupId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get deactivation reasons
  Future<Map<String, dynamic>> getDeactivationReasons({
    required String authtoken,
  }) async {
    final response = await _dio.post(
      ApiConstants.deactivationReasons,
      data: {
        'authtoken': authtoken,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Temporary activation
  /// Per Android spec: only customerId and stockId are meaningful params.
  Future<Map<String, dynamic>> temporaryActivation({
    required String authtoken,
    required String customerId,
    required String stockId,
  }) async {
    final response = await _dio.post(
      ApiConstants.temporaryActivation,
      data: {
        'authtoken': authtoken,
        'customerId': customerId,
        'stockId': stockId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Validate box info (for pairing)
  Future<Map<String, dynamic>> validateBoxInfo({
    required String authtoken,
    required String boxNumber,
  }) async {
    final response = await _dio.post(
      ApiConstants.validateBoxInfo,
      data: {
        'authtoken': authtoken,
        'boxNumber': boxNumber,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// STB Pair
  /// Server: stbPairRest_post (LcoRestServices.php)
  ///
  /// The server reads exactly two keys — `serialNumber` and `vcNumber` — and
  /// derives stock_id / backend_setup_id from the serial; everything else
  /// comes from the token. Android (StbPairUnpair.GetStbPairRest, and the V1
  /// SOAP StbPairInfo) sends the same two keys. These used to go out as
  /// `stb_no` / `vc_no`, which the server never reads: because it only
  /// validates keys that are present, the request passed validation with an
  /// empty serial and then failed inside the pair library.
  ///
  /// [customerId] is kept on the signature so the provider is untouched, but
  /// it is not sent — the server does not read it and Android never sends it.
  Future<Map<String, dynamic>> stbPair({
    required String authtoken,
    required String customerId,
    required String stbNo,
    required String vcNo,
  }) async {
    final response = await _dio.post(
      ApiConstants.stbPair,
      data: {
        'authtoken': authtoken,
        'serialNumber': stbNo,
        'vcNumber': vcNo,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// STB Unpair
  /// Server: stbUnpairRest_post (LcoRestServices.php)
  ///
  /// Reads only `serialNumber`. Same history as [stbPair]: was `stb_no`.
  Future<Map<String, dynamic>> stbUnpair({
    required String authtoken,
    required String customerId,
    required String stbNo,
  }) async {
    final response = await _dio.post(
      ApiConstants.stbUnpair,
      data: {
        'authtoken': authtoken,
        'serialNumber': stbNo,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// STB Replacement
  Future<Map<String, dynamic>> stbReplacement({
    required String authtoken,
    required String customerId,
    required String oldStbNo,
    required String newStbNo,
    required String newVcNo,
  }) async {
    final response = await _dio.post(
      ApiConstants.stbReplacement,
      data: {
        'authtoken': authtoken,
        'customer_id': customerId,
        'old_stb_no': oldStbNo,
        'new_stb_no': newStbNo,
        'new_vc_no': newVcNo,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
