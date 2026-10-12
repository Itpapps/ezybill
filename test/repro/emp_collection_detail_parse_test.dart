// Proves EmpCollectionDetail reads empCustomerCollectionDetailsRest rows the
// way native does (Reports_Emp_Collection_List_Fragment.java:474-485), and
// that the server's empty-result dummy row (LcoRestServices.php:2789) is
// recognisable so the provider can drop it.
import 'package:ezybill/data/models/report/emp_collection_detail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps the server snake_case columns; amount is not 0', () {
    final d = EmpCollectionDetail.fromJson({
      'customer_id': '10452',
      'customer_name': 'RAVI KUMAR',
      'paid_amount': '350.00',
      'paid_on': '2026-10-06 10:15:00',
      'payment_mode': 'Cash',
      'payment_id': '88231',
      'account_number': 'AC-10452',
      'name': 'itptest',
    });
    expect(d.customerId, '10452');
    expect(d.customerName, 'RAVI KUMAR');
    expect(d.paidAmount, 350.0);
    expect(d.paidOn, '2026-10-06 10:15:00');
    expect(d.paymentMode, 'Cash');
    expect(d.paymentId, '88231');
  });

  test('numeric ids/amount from the server still parse', () {
    final d = EmpCollectionDetail.fromJson({
      'customer_id': 10452,
      'paid_amount': 350,
      'payment_id': 88231,
    });
    expect(d.customerId, '10452');
    expect(d.paidAmount, 350.0);
    expect(d.paymentId, '88231');
  });

  test('server dummy row has no customer_id, so it is filterable', () {
    final d = EmpCollectionDetail.fromJson({
      'customerName': '',
      'lcoCustomerId': '',
      'paymentDate': '',
      'paymentMode': '',
      'amount': '',
    });
    expect(d.customerId, isEmpty);
    expect(d.paidAmount, 0.0);
  });
}
