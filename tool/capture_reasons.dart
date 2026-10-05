// TEMPORARY read-only capture script (investigation). Run:
//   dart run tool/capture_reasons.dart <base> <user> <pass> [customerId]
// Calls the REAL backend exactly like the app's DioClient does (same
// PayloadEncryption, same {payload,hash} envelope, Bearer JWT) and prints the
// decrypted responses for validateLogin and getDeactiveReasonsRest with and
// without stockId/CustomerId. No app code is touched.
import 'dart:convert';
import 'dart:io';

import 'package:ezybill/core/network/payload_encryption.dart';

Future<Map<String, dynamic>> post(
  String url,
  Map<String, dynamic> fields, {
  String? jwt,
}) async {
  final client = HttpClient();
  final req = await client.postUrl(Uri.parse(url));
  req.headers.contentType =
      ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8');
  if (jwt != null) req.headers.set('Authorization', 'Bearer $jwt');
  final enc = PayloadEncryption.encryptPayload(fields);
  req.write(enc.entries
      .map((e) => '${Uri.encodeQueryComponent(e.key)}='
          '${Uri.encodeQueryComponent(e.value)}')
      .join('&'));
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  client.close();
  stdout.writeln('  -> HTTP ${res.statusCode}, ${body.length} bytes');
  dynamic parsed;
  try {
    parsed = jsonDecode(body);
  } catch (_) {
    stdout.writeln('  raw (first 300): ${body.substring(0, body.length > 300 ? 300 : body.length)}');
    return {};
  }
  if (parsed is Map<String, dynamic> &&
      parsed.containsKey('payload') &&
      parsed.containsKey('hash')) {
    return PayloadEncryption.decryptResponse(parsed) ?? {'_undecryptable': body};
  }
  return parsed is Map<String, dynamic> ? parsed : {'_raw': parsed};
}

Future<void> main(List<String> args) async {
  if (args.length < 3) {
    stderr.writeln('usage: base user pass [customerId]');
    exit(2);
  }
  final base = args[0]; // e.g. http://192.168.1.143/v2_release_aakshya/index.php/LcoRestServices
  final user = args[1];
  final pass = args[2];
  final customerId = args.length > 3 ? args[3] : null;

  stdout.writeln('== validateLogin ==');
  final login = await post('$base/validateLogin', {
    'UserName': user,
    'PassWord': pass,
    'imei': '',
  });
  final jwt = login['token']?.toString() ?? '';
  stdout.writeln('  status_code=${login['status_code']} status_msg=${login['status_msg']}');
  stdout.writeln('  enable_box_wise_payment=${login['enable_box_wise_payment']} '
      '(type ${login['enable_box_wise_payment']?.runtimeType}) '
      'users_type=${login['users_type']} employeeId=${login['employeeId']} '
      'dealerId=${login['dealerId']} token.len=${jwt.length}');
  stdout.writeln('  login keys: ${login.keys.toList()}');
  if (jwt.isEmpty) exit(1);

  stdout.writeln('\n== getDeactiveReasonsRest {authtoken} (Flutter before R2) ==');
  final r1 = await post('$base/getDeactiveReasonsRest', {'authtoken': jwt}, jwt: jwt);
  stdout.writeln('  status_code=${r1['status_code']} status_msg=${r1['status_msg']}');
  stdout.writeln('  reasonList=${jsonEncode(r1['reasonList'])}');

  String? stockId;
  if (customerId != null) {
    stdout.writeln('\n== getCustomerBoxDetailsRest {customerId=$customerId} ==');
    final box = await post('$base/getCustomerBoxDetailsRest',
        {'authtoken': jwt, 'customerId': customerId}, jwt: jwt);
    stdout.writeln('  status_code=${box['status_code']} status_msg=${box['status_msg']}');
    final list = box['customerBoxList'];
    if (list is List && list.isNotEmpty) {
      stockId = (list.first as Map)['stock_id']?.toString();
      stdout.writeln('  first box: ${jsonEncode(list.first)}');
    }
  }

  stdout.writeln('\n== getDeactiveReasonsRest {authtoken, stockId=${stockId ?? "0"}, CustomerId=${customerId ?? "0"}} (Android / Flutter after R2) ==');
  final r2 = await post('$base/getDeactiveReasonsRest', {
    'authtoken': jwt,
    'stockId': stockId ?? '0',
    'CustomerId': customerId ?? '0',
  }, jwt: jwt);
  stdout.writeln('  status_code=${r2['status_code']} status_msg=${r2['status_msg']}');
  stdout.writeln('  reasonList=${jsonEncode(r2['reasonList'])}');

  stdout.writeln('\n== Android client filter simulation ==');
  final ebwp = int.tryParse('${login['enable_box_wise_payment']}') ?? 0;
  for (final entry in [
    ['no ids', r1],
    ['with ids', r2],
  ]) {
    final list = (entry[1] as Map)['reasonList'];
    if (list is! List) continue;
    final kept = list.where((r) {
      final id = int.tryParse('${(r as Map)['reasonId']}') ?? 0;
      final g = int.tryParse('${r['global_reason']}') ?? 0;
      return ebwp == 1 || !(id == 21 || id == 17 || g == 1);
    }).map((r) => '${(r as Map)['reasonId']}:${r['reasonName']}(g=${r['global_reason']})').toList();
    stdout.writeln('  ${entry[0]}: total=${list.length} shown=${kept.length} -> $kept');
  }
}
