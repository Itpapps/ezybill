// Proves: (1) a customer's complaints are requested with `altCustomerId`, the
// key getCustomerComplaintListRest reads (native
// Complaint_Operations_Fragment.java:504); (2) the server's blank "No records
// found." placeholder row is not shown; (3) the update screen's employees come
// from getServiceEmployeeList (native GetServiceemployeelistRest), and
// "No Services Employees." (status 1) is what triggers the own-id rule.
import 'package:dio/dio.dart';
import 'package:ezybill/application/providers/complaint_provider.dart';
import 'package:ezybill/core/network/dio_client.dart';
import 'package:ezybill/data/datasources/remote/complaint_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ScriptedDio extends DioClient {
  final calls = <(String, Map<String, dynamic>?)>[];
  final Map<String, Map<String, dynamic>> replies;
  _ScriptedDio(this.replies);

  @override
  Future<Response<T>> post<T>(
    String path, {
    Map<String, dynamic>? data,
    String? customBaseUrl,
    Options? options,
  }) async {
    calls.add((path, data));
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: (replies[path] ?? {'status_code': 1}) as T,
    );
  }
}

ProviderContainer _containerWith(_ScriptedDio dio) => ProviderContainer(
      overrides: [
        complaintRemoteDatasourceProvider
            .overrideWithValue(ComplaintRemoteDatasource(dio: dio)),
      ],
    );

void main() {
  test('customer list goes out as altCustomerId and only shows real rows',
      () async {
    final dio = _ScriptedDio({
      '/getCustomerComplaintListRest': {
        'status_code': 0,
        'customerComplaintList': [
          // Exactly the columns native reads from this list
          // (Complaint_Operations_Fragment.java:540-575) — no `description`.
          {
            'customer_id': '1413',
            'account_number': '13528363',
            'customer_name': 'shiva',
            'group_name': 'G1',
            'simple_complaint_id': '501',
            'tkt_number': 'TKT501',
            'complaint': 'No signal',
            'date': '2026-10-11 10:20:00',
            'status': 'ASSIGNED',
            'assigned_employee_id': 45,
            'assigned_name': 'Ravi',
          },
        ],
      },
    });
    final c = _containerWith(dio);
    addTearDown(c.dispose);

    await c.read(complaintProvider.notifier).loadComplaints(customerId: '1413');

    final (path, body) = dio.calls.single;
    expect(path, '/getCustomerComplaintListRest');
    expect(body, containsPair('altCustomerId', '1413'));
    expect(body!.containsKey('customerId'), isFalse);
    final list = c.read(complaintProvider).complaints;
    expect([for (final x in list) x.complaintId], ['501']);
    expect(list.single.ticketNumber, 'TKT501');
  });

  test('"No records found." placeholder row is dropped', () async {
    final dio = _ScriptedDio({
      '/getCustomerComplaintListRest': {
        'status_code': 1,
        'status_msg': 'No records found.',
        'customerComplaintList': [
          {
            'customerId': '',
            'customNumber': '',
            'customerName': '',
            'group': '',
            'complaintId': '',
            'ticketNumber': '',
            'complaint': '',
            'complaintTime': '',
            'status': '',
          },
        ],
      },
    });
    final c = _containerWith(dio);
    addTearDown(c.dispose);
    await c.read(complaintProvider.notifier).loadComplaints(customerId: '1413');
    expect(c.read(complaintProvider).complaints, isEmpty);
  });

  test('reload keeps the customer context', () async {
    final dio = _ScriptedDio({});
    final c = _containerWith(dio);
    addTearDown(c.dispose);
    final n = c.read(complaintProvider.notifier);
    await n.loadComplaints(customerId: '1413');
    await n.reloadComplaints();
    expect([for (final call in dio.calls) call.$1],
        ['/getCustomerComplaintListRest', '/getCustomerComplaintListRest']);
  });

  test('service employees come from getServiceEmployeeList', () async {
    final dio = _ScriptedDio({
      '/getServiceEmployeeList': {
        'status_code': 0,
        'getServiceEmployeeList': [
          {'employee_id': '45', 'first_name': 'Ravi'},
          {'employee_id': '46', 'first_name': 'Kiran'},
        ],
      },
    });
    final c = _containerWith(dio);
    addTearDown(c.dispose);
    await c.read(complaintProvider.notifier).loadServiceEmployees(7);
    expect(dio.calls.single.$1, '/getServiceEmployeeList');
    expect(dio.calls.single.$2, containsPair('dealer_id', 7));
    final s = c.read(complaintProvider);
    expect([for (final e in s.serviceEmployees) e['employee_id']], ['45', '46']);
  });

  // Native's real request for this dealer (logcat `updatecomp`, 2026-10-12):
  // {ticketNumber=26000061, complaintId=91, …, assignedemp=-1, status=ASSIGNED}
  // even though getServiceEmployeeList said "No Services Employees." —
  // Flutter's own-id value (98) was what the server rejected.
  test('nothing picked => assignedemp -1, even with "No Services Employees."',
      () async {
    final dio = _ScriptedDio({
      '/getServiceEmployeeList': {
        'status_code': 1,
        'status_msg': 'No Services Employees.',
        'getServiceEmployeeList': [],
      },
      '/closeComplaintRest': {'status_code': 0, 'status_msg': 'Success'},
    });
    final c = _containerWith(dio);
    addTearDown(c.dispose);
    final n = c.read(complaintProvider.notifier);
    await n.loadServiceEmployees(7);
    expect(c.read(complaintProvider).serviceEmployees, isEmpty);

    final ok = await n.closeComplaint(
      complaintId: '91',
      ticketNumber: '26000061',
      comment: 'hh',
      status: 'ASSIGNED',
    );
    expect(ok, isTrue);
    final body = dio.calls.last.$2!;
    expect(body, containsPair('assignedemp', '-1'));
    expect(body, containsPair('comment',
        'hh.Complaint Status Change From Flutter app'));
  });

  test('a picked service employee is sent as-is', () async {
    final dio = _ScriptedDio({
      '/closeComplaintRest': {'status_code': 0, 'status_msg': 'Success'},
    });
    final c = _containerWith(dio);
    addTearDown(c.dispose);
    await c.read(complaintProvider.notifier).closeComplaint(
          complaintId: '91',
          ticketNumber: '26000061',
          comment: 'hh',
          status: 'INPROCESS',
          assignedEmployeeId: '45',
        );
    expect(dio.calls.last.$2, containsPair('assignedemp', '45'));
  });
}
