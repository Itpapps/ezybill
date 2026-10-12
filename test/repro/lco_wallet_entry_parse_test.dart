// Proves LcoWalletEntry reads the getLcoWalletReport row exactly as the server
// sends it (keys from LcoRestServices.php:8036 / native
// Report_EmpCollect_Fragment.java:291-304).
import 'package:ezybill/data/models/lco/lco_wallet_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> serverRow() => {
        'Deposit_Date': '2026-10-05 11:42:10',
        'business_name': 'ITP TEST LCO',
        'payment_mode': 'Online',
        'cheque_ddnumber': '',
        'bank': 'HDFC',
        'branch': 'MG Road',
        'instrument_date': '2026-10-05',
        'credit_amount': '5000.00',
        'debit_amount': '0.00',
        'transaction_no': 'TXN123456',
        'receipt_no': 'R-889',
        'Remarks': 'Wallet top-up',
        'Deposited_By': 'itptest',
        'deposite_amount': '5000.00',
      };

  test('maps every server column (strings, mixed case)', () {
    final e = LcoWalletEntry.fromJson(serverRow());
    expect(e.depositDate, '2026-10-05 11:42:10');
    expect(e.businessName, 'ITP TEST LCO');
    expect(e.paymentMode, 'Online');
    expect(e.chequeDdnumber, '');
    expect(e.bank, 'HDFC');
    expect(e.branch, 'MG Road');
    expect(e.instrumentDate, '2026-10-05');
    expect(e.creditAmount, 5000.0);
    expect(e.debitAmount, 0.0);
    expect(e.transactionNo, 'TXN123456');
    expect(e.receiptNo, 'R-889');
    expect(e.remarks, 'Wallet top-up');
    expect(e.depositedBy, 'itptest');
    expect(e.depositeAmount, 5000.0);
  });

  test('numeric / null columns do not throw (native getString tolerance)', () {
    final row = serverRow()
      ..['transaction_no'] = 123456
      ..['receipt_no'] = 889
      ..['credit_amount'] = 2500
      ..['debit_amount'] = null
      ..['bank'] = null;
    final e = LcoWalletEntry.fromJson(row);
    expect(e.transactionNo, '123456');
    expect(e.receiptNo, '889');
    expect(e.creditAmount, 2500.0);
    expect(e.debitAmount, 0.0);
    expect(e.bank, isNull);
  });

  test('old camelCase keys are no longer what we read', () {
    final e = LcoWalletEntry.fromJson({'creditAmount': '999', 'depositDate': 'x'});
    expect(e.creditAmount, 0.0);
    expect(e.depositDate, isNull);
  });
}
