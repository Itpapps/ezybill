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
  ///
  /// Server: getCustomerParticularBoxDetailsRest_post (LcoRestServices.php:1812)
  /// reads `customerId`, `stockId` and `userType`; native sends all three
  /// (Customer_STB_Select_Fragment.java:1138-1140). `userType` decides which
  /// replacement reasons come back in `replacement_types`.
  Future<Map<String, dynamic>> getParticularBoxDetails({
    required String authtoken,
    required String customerId,
    required String stockId,
    String? userType,
  }) async {
    final response = await _dio.post(
      ApiConstants.particularBoxDetails,
      data: {
        'authtoken': authtoken,
        'customerId': customerId,
        'stockId': stockId,
        if (userType != null) 'userType': userType,
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

  /// Get deactivation reasons.
  ///
  /// Android sends `stockId` and `CustomerId` (exact key casing) with this
  /// call; the server uses stockId to trim due-dependent reasons and treats
  /// both as optional. They are sent only when the caller has them.
  Future<Map<String, dynamic>> getDeactivationReasons({
    required String authtoken,
    String? stockId,
    String? customerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.deactivationReasons,
      data: {
        'authtoken': authtoken,
        if (stockId != null && stockId.isNotEmpty) 'stockId': stockId,
        if (customerId != null && customerId.isNotEmpty)
          'CustomerId': customerId,
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
  /// Server: stb_replacement_post (LcoRestServices.php:8604)
  ///
  /// Field names are the server's own, exactly as native sends them
  /// (Box_Operations_Fragment.java:2311-2320) — including the server's
  /// `account_nmber` spelling. The old names (customer_id, old_stb_no,
  /// new_stb_no, new_vc_no) were never read, so the server saw an empty
  /// serial and always answered "Invalid Serialnumber".
  ///
  /// Exactly one of [replaceSerialNumber] / [replaceVcNumber] carries the new
  /// box; both are empty for a surrender.
  Future<Map<String, dynamic>> stbReplacement({
    required String authtoken,
    required String customerId,
    required String serialNumber,
    required String replacementTypeId,
    required String amount,
    required String receiptNumber,
    required String remarks,
    required String replaceSerialNumber,
    required String replaceVcNumber,
    required bool permanentSurrender,
    required bool unpair,
  }) async {
    final response = await _dio.post(
      ApiConstants.stbReplacement,
      data: {
        'authtoken': authtoken,
        'serial_number': serialNumber,
        'account_nmber': customerId,
        'replacement_type_id': replacementTypeId,
        'amount': amount,
        'receipt_number': receiptNumber,
        'remarks': remarks,
        'replace_serial_number': replaceSerialNumber,
        'replace_vc_number': replaceVcNumber,
        // Native: "1" / "0" (Box_Operations_Fragment.java:487-491).
        'is_permanent_surrender': permanentSurrender ? '1' : '0',
        // Native: "1" = unpair the box, "2" = keep it paired (:494-498).
        'pair_condition': unpair ? '1' : '2',
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
