// Proves the STB replacement request now carries the server's field names
// (LcoRestServices.php stb_replacement_post / native
// Box_Operations_Fragment.java:2311-2320) and that the replacement switch,
// reasons and mandatory flags are parsed like native
// (Customer_STB_Select_Fragment.java:1172-1209).
import 'package:dio/dio.dart';
import 'package:ezybill/application/providers/stb_provider.dart';
import 'package:ezybill/core/network/dio_client.dart';
import 'package:ezybill/data/datasources/remote/stb_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturingDio extends DioClient {
  String? path;
  Map<String, dynamic>? body;
  Map<String, dynamic> reply = {'status_code': 0};

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
  group('replacement request body', () {
    late _CapturingDio dio;
    late StbRemoteDatasource ds;
    setUp(() {
      dio = _CapturingDio();
      ds = StbRemoteDatasource(dio: dio);
    });

    Future<void> send({
      String newSerial = '',
      String newVc = '',
      bool surrender = false,
      bool unpair = false,
    }) =>
        ds.stbReplacement(
          authtoken: 't',
          customerId: '1413',
          serialNumber: 'OLD123',
          replacementTypeId: '1',
          amount: '',
          receiptNumber: 'R-9',
          remarks: 'faulty',
          replaceSerialNumber: newSerial,
          replaceVcNumber: newVc,
          permanentSurrender: surrender,
          unpair: unpair,
        );

    test('uses the server keys, never the old ones', () async {
      await send(newSerial: 'NEW456');
      expect(dio.path, '/stb_replacement');
      expect(dio.body, containsPair('serial_number', 'OLD123'));
      expect(dio.body, containsPair('account_nmber', '1413'));
      expect(dio.body, containsPair('replacement_type_id', '1'));
      expect(dio.body, containsPair('amount', ''));
      expect(dio.body, containsPair('receipt_number', 'R-9'));
      expect(dio.body, containsPair('remarks', 'faulty'));
      expect(dio.body, containsPair('replace_serial_number', 'NEW456'));
      expect(dio.body, containsPair('replace_vc_number', ''));
      for (final old in ['customer_id', 'old_stb_no', 'new_stb_no', 'new_vc_no']) {
        expect(dio.body!.containsKey(old), isFalse, reason: old);
      }
    });

    test('flags use native values: surrender 1/0, pair_condition 1=unpair 2=keep',
        () async {
      await send(surrender: true, unpair: true);
      expect(dio.body, containsPair('is_permanent_surrender', '1'));
      expect(dio.body, containsPair('pair_condition', '1'));
      await send();
      expect(dio.body, containsPair('is_permanent_surrender', '0'));
      expect(dio.body, containsPair('pair_condition', '2'));
    });

    test('box details call sends userType like native', () async {
      await ds.getParticularBoxDetails(
        authtoken: 't',
        customerId: '1413',
        stockId: '77',
        userType: 'RESELLER',
      );
      expect(dio.body, containsPair('customerId', '1413'));
      expect(dio.body, containsPair('stockId', '77'));
      expect(dio.body, containsPair('userType', 'RESELLER'));
    });
  });

  group('parseReplacementOptions', () {
    test('enabled, reasons de-duplicated, flags read (strings or ints)', () {
      final o = parseReplacementOptions({
        'status_code': 0,
        'show_replacement': '1',
        'replacement_types': [
          {'replacement_type_id': '1', 'replacement_type': 'DEFECTIVE'},
          {'replacement_type_id': '4', 'replacement_type': 'SURRENDER'},
          {'replacement_type_id': '1', 'replacement_type': 'DEFECTIVE'},
        ],
        'stb_replacement_form_validations': {
          'amount_mandatory': 1,
          'receipt_number_mandatory': '0',
        },
      });
      expect(o.enabled, isTrue);
      expect([for (final t in o.types) t.id], ['1', '4']);
      expect(o.types[1].isSurrender, isTrue);
      expect(o.types[0].isSurrender, isFalse);
      expect(o.amountMandatory, isTrue);
      expect(o.receiptMandatory, isFalse);
    });

    test('switch off or failed reply => not enabled', () {
      expect(
        parseReplacementOptions({'status_code': 0, 'show_replacement': 0})
            .enabled,
        isFalse,
      );
      expect(
        parseReplacementOptions({'status_code': 1, 'show_replacement': 1})
            .enabled,
        isFalse,
      );
    });
  });
}
