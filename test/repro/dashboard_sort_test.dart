// Proves the dashboard list sort (Name / Due date) orders rows the way the
// sort button promises, keeps server order for ties, and parks rows without
// a value at the end.
import 'package:ezybill/application/providers/dashboard_customer_list_provider.dart';
import 'package:ezybill/data/models/customer/customer_model.dart';
import 'package:flutter_test/flutter_test.dart';

CustomerModel row(String id, String name, String? due) => CustomerModel.fromJson({
      'customer_id': id,
      'customerName': name,
      'service_enddate': due,
    });

List<String> ids(List<CustomerModel> l) => [for (final c in l) c.customerId];

void main() {
  test('service_enddate is read from the dashboard row', () {
    expect(row('1', 'a', '2026-03-25 23:59:59').serviceEndDate,
        '2026-03-25 23:59:59');
  });

  test('Name: A→Z, case-insensitive, blank names last', () {
    final list = [
      row('1', 'ravi', null),
      row('2', '', null),
      row('3', 'Anil', null),
      row('4', 'kumar ', null),
    ];
    expect(ids(sortDashboardCustomers(list, DashboardSort.name)),
        ['3', '4', '1', '2']);
  });

  test('Due date: earliest first, missing/zero dates last, tie by name', () {
    final list = [
      row('1', 'Zed', '2026-04-10 23:59:59'),
      row('2', 'Bob', ''),
      row('3', 'Amy', '2026-03-25'),
      row('4', 'Cat', '0000-00-00 00:00:00'),
      row('5', 'Abe', '2026-04-10 23:59:59'),
      row('6', 'Dan', null),
    ];
    expect(ids(sortDashboardCustomers(list, DashboardSort.dueDate)),
        ['3', '5', '1', '2', '4', '6']);
  });

  test('ties keep the server order (stable) — e.g. fresh STBs, no names', () {
    final list = [for (var i = 0; i < 40; i++) row('$i', '', null)];
    for (final s in DashboardSort.values) {
      expect(ids(sortDashboardCustomers(list, s)), ids(list));
    }
  });
}
