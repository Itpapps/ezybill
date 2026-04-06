import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/models/customer/customer_search_response.dart';

/// Abstract interface for customer data operations.
abstract class CustomerRepository {
  /// Get customer count matching search criteria.
  Future<Result<Map<String, dynamic>>> getCustomerDetailsCount({
    String? customerNumber,
    String? customerName,
    String? mobileNumber,
    String? boxNumber,
    String? lcoCustomerId,
  });

  /// Search customers with pagination.
  Future<Result<CustomerSearchResponse>> searchCustomers({
    String? customerNumber,
    String? customerName,
    String? mobileNumber,
    String? boxNumber,
    String? lcoCustomerId,
    String? cafNumber,
    int startValue = 0,
    int endValue = 20,
  });

  /// Check if a customer already exists by mobile number.
  Future<Result<Map<String, dynamic>>> checkExistingCustomer({
    required String mobileNumber,
  });

  /// Save a new customer.
  Future<Result<Map<String, dynamic>>> saveCustomer({
    required Map<String, dynamic> customerData,
  });

  /// Edit an existing customer.
  Future<Result<Map<String, dynamic>>> editCustomer({
    required Map<String, dynamic> customerData,
  });

  /// Update customer GPS location.
  Future<Result<Map<String, dynamic>>> updateCustomerLocation({
    required String customerId,
    required double latitude,
    required double longitude,
  });
}
