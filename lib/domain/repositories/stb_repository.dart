import 'package:ezybill/core/utils/result.dart';

/// Abstract interface for STB (Set-Top Box) data operations.
abstract class StbRepository {
  /// Get all box/STB details for a customer.
  Future<Result<Map<String, dynamic>>> getCustomerBoxDetails({
    required String customerId,
  });

  /// Get details for a particular box.
  Future<Result<Map<String, dynamic>>> getParticularBoxDetails({
    required String customerId,
    required String stockId,
  });

  /// Deactivate a box/STB.
  Future<Result<Map<String, dynamic>>> deactivateBox({
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
  });

  /// Reactivate a box/STB.
  Future<Result<Map<String, dynamic>>> reactivateBox({
    String? serialNumber,
    String? boxNumber,
    String? macAddress,
    String? stockId,
    String? deviceId,
    String? backEndSetupId,
  });

  /// Get deactivation reasons.
  Future<Result<Map<String, dynamic>>> getDeactivationReasons();

  /// Temporary activation of a box.
  Future<Result<Map<String, dynamic>>> temporaryActivation({
    required String customerId,
    required String stockId,
  });

  /// Validate box info for pairing.
  Future<Result<Map<String, dynamic>>> validateBoxInfo({
    required String boxNumber,
  });

  /// Pair an STB.
  Future<Result<Map<String, dynamic>>> stbPair({
    required String customerId,
    required String stbNo,
    required String vcNo,
  });

  /// Unpair an STB.
  Future<Result<Map<String, dynamic>>> stbUnpair({
    required String customerId,
    required String stbNo,
  });

  /// Replace an STB with a new one.
  Future<Result<Map<String, dynamic>>> stbReplacement({
    required String customerId,
    required String oldStbNo,
    required String newStbNo,
    required String newVcNo,
  });
}
