import 'package:ezybill/core/utils/result.dart';

/// Abstract interface for employee data operations.
abstract class EmployeeRepository {
  /// Get LCO employee list for a dealer.
  Future<Result<Map<String, dynamic>>> getLcoEmployeeList({
    required int dealerId,
  });

  /// Get service employee list for a dealer.
  Future<Result<Map<String, dynamic>>> getServiceEmployeeList({
    required int dealerId,
  });
}
