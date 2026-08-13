import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_mobile/core/ocr/receipt_reference.dart';

void main() {
  test('extracts the CBE FT code rather than the transaction status', () {
    const receipt = '''
Transaction Completed Successfully!
Transaction ID: FT26217SSG8W. Reason: MB Transfer
''';

    expect(ReceiptReference.fromText(receipt), 'FT26217SSG8W');
  });

  test('does not treat COMPLETED as a transaction reference', () {
    expect(ReceiptReference.fromText('Transaction Completed Successfully'), isNull);
  });
}
