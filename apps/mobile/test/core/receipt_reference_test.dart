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

  test('extracts FT code with colons, dots, slashes, or symbols', () {
    expect(ReceiptReference.fromText('Txn ID: FT:26217SSG8W'), 'FT26217SSG8W');
    expect(ReceiptReference.fromText('Ref: FT.26217.SSG8W'), 'FT26217SSG8W');
    expect(ReceiptReference.fromText('Ref No: FT/26217/SSG8W'), 'FT26217SSG8W');
    expect(ReceiptReference.fromText('Trans. Ref: (FT26217SSG8W)'), 'FT26217SSG8W');
    expect(ReceiptReference.fromText('F.T. 26217SSG8W'), 'FT26217SSG8W');
    expect(ReceiptReference.fromText('FT 26217 SSG8 W'), 'FT26217SSG8W');
    expect(ReceiptReference.fromText('Transaction ID:\nFT26217SSG8W'), 'FT26217SSG8W');
    expect(ReceiptReference.fromText('ID:FT26217SSG8W'), 'FT26217SSG8W');
  });

  test('handles OCR misread of FT as FI or F1 after transaction label', () {
    expect(ReceiptReference.fromText('Transaction ID: FI26217SSG8W'), 'FT26217SSG8W');
    expect(ReceiptReference.fromText('Txn Ref: F126217SSG8W'), 'FT26217SSG8W');
  });
}

