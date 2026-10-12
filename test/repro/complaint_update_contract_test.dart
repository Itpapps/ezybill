// Proves "Update complaint" now sends the five fields closeComplaintRest
// requires (LcoRestServices.php:6934; native
// ComplaintHistory_Other_Fragment.java:1601-1605) and that the status list
// is read from complaintStatuses[].value (captured reply in
// screen_docs/14_comprehensive_api_request_response.md:1260-1267).
import 'package:dio/dio.dart';
import 'package:ezybill/core/constants/api_constants.dart';
import 'package:ezybill/core/network/dio_client.dart';
import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/datasources/remote/complaint_remote_datasource.dart';
import 'package:ezybill/data/repositories/complaint_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturingDio extends DioClient {
  String? path;
  Map<String, dynamic>? body;
  Map<String, dynamic> reply = {'status_code': 0, 'status_msg': 'Success'};

  @override
  Future<Response<T>> post<T>(
    String path, {
    Map<String, dynamic>? data,
    String? customBaseUrl,
    Options? options,
  }) async {
    this.path = path;
    body = data;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: reply as T,
    );
  }
}

void main() {
  late _CapturingDio dio;
  late ComplaintRepositoryImpl repo;
  setUp(() {
    dio = _CapturingDio();
    repo = ComplaintRepositoryImpl(ComplaintRemoteDatasource(dio: dio));
  });

  test('update sends the five required fields under the server names',
      () async {
    await repo.closeComplaint(
      complaintId: '123',
      ticketNumber: 'TKT001',
      comment: 'fixed.Complaint Status Change From Flutter app',
      status: 'RESOLVED',
      assignedEmp: '-1',
    );
    expect(dio.path, '/closeComplaintRest');
    expect(dio.body, containsPair('complaintId', '123'));
    expect(dio.body, containsPair('ticketNumber', 'TKT001'));
    expect(dio.body,
        containsPair('comment', 'fixed.Complaint Status Change From Flutter app'));
    expect(dio.body, containsPair('status', 'RESOLVED'));
    expect(dio.body, containsPair('assignedemp', '-1'));
    expect(dio.body!.containsKey('remarks'), isFalse);
    // V2: exactly native's five fields — no authtoken in the payload.
    expect(ApiConstants.isWsController, isFalse);
    expect(dio.body!.keys.toSet(),
        {'complaintId', 'ticketNumber', 'comment', 'status', 'assignedemp'});
    // Optional closer ids only when chosen.
    expect(dio.body!.containsKey('closer_ticket_type_id'), isFalse);
    expect(dio.body!.containsKey('closer_reason_id'), isFalse);
  });

  test('closer ids go out when chosen', () async {
    await repo.closeComplaint(
      complaintId: '123',
      ticketNumber: 'TKT001',
      comment: 'c',
      status: 'RESOLVED',
      assignedEmp: '45',
      closerTicketTypeId: '7',
      closerReasonId: '9',
    );
    expect(dio.body, containsPair('closer_ticket_type_id', '7'));
    expect(dio.body, containsPair('closer_reason_id', '9'));
  });

  test('status list comes from complaintStatuses (real captured shape)',
      () async {
    dio.reply = {
      'status_code': 0,
      'status_msg': 'Success',
      'complaintStatuses': [
        {'value': 'ASSIGNED'},
        {'value': 'INPROCESS'},
        {'value': 'ONHOLD'},
        {'value': 'RESOLVED'},
        {'value': 'CLOSED'},
        {'value': 'REOPEN'},
      ],
      'ticket_closer_categories': [],
    };
    final result = await repo.getComplaintTypes();
    expect(result, isA<Success<List<Map<String, dynamic>>>>());
    final list = (result as Success<List<Map<String, dynamic>>>).data;
    expect([for (final s in list) s['value']],
        ['ASSIGNED', 'INPROCESS', 'ONHOLD', 'RESOLVED', 'CLOSED', 'REOPEN']);
  });
}
