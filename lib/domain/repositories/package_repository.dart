import 'package:ezybill/core/utils/result.dart';

/// Abstract interface for package/service data operations.
abstract class PackageRepository {
  /// Get customer's assigned packages for a given STB.
  Future<Result<Map<String, dynamic>>> getCustomerPackages({
    required String customerId,
    required String stbNo,
  });

  /// Get unassigned/available packages for a given STB.
  Future<Result<Map<String, dynamic>>> getUnassignedPackages({
    required String customerId,
    required String stbNo,
  });

  /// Get bill details before activation.
  Future<Result<Map<String, dynamic>>> getBillDetails({
    required String customerId,
    required String serialNumber,
    required String packageId,
    required String dealerId,
    required String employeeId,
  });

  /// Activate a service/package on a box.
  Future<Result<Map<String, dynamic>>> activateService({
    required String customerId,
    required String customerDeviceId,
    required String productId,
    required String stockId,
    required String dealerId,
    required String resellerId,
    required String loginEmployeeId,
  });

  /// Deactivate a service/package on a box.
  /// CRITICAL: serviceId is comma-separated customer_service_ids, NOT product_ids.
  Future<Result<Map<String, dynamic>>> deactivateService({
    required String customerId,
    required String serviceId,
    required String reasonId,
    required String remarks,
    required String dealerId,
    required String resellerId,
    required String loginEmployeeId,
    String? stockId,
  });

  /// Extend a service for additional months.
  Future<Result<Map<String, dynamic>>> extendService({
    required String customerId,
    required String stbNo,
    required String packageId,
    required String months,
  });

  /// Get CAS packages.
  Future<Result<Map<String, dynamic>>> getCasPackages();

  /// Get channel list for a package.
  Future<Result<Map<String, dynamic>>> getChannelList({
    required String packageId,
  });

  /// Renew services for a customer.
  /// CRITICAL: Sends both customer_service_id and product_ids separately.
  Future<Result<Map<String, dynamic>>> renewServices({
    required String customerId,
    required String dealerId,
    required String customerServiceIds,
    required String productIds,
  });

  /// Get renewable services list for a customer.
  Future<Result<Map<String, dynamic>>> getRenewServices({
    required String customerId,
    required String dealerId,
  });
}
