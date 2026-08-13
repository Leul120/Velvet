import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Extracts the transaction/FT reference from a CBE receipt screenshot on-device.
class ReceiptReference {
  static Future<String?> fromImage(String path) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final text = (await recognizer.processImage(
        InputImage.fromFilePath(path),
      )).text;
      return fromText(text);
    } finally {
      recognizer.close();
    }
  }

  /// CBE transaction IDs are exactly FT + ten alphanumeric characters.
  /// Do not use broad words such as "Transaction" as a fallback: receipt
  /// headings like "Transaction Completed" would otherwise become COMPLETED.
  static String? fromText(String text) {
    final ftCode = RegExp(
      r'\bF\s*T(?:[\s-]*[A-Z0-9]){10}\b',
      caseSensitive: false,
    ).firstMatch(text);
    if (ftCode == null) return null;
    final normalized = ftCode.group(0)!.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return RegExp(r'^FT[A-Z0-9]{10}$').hasMatch(normalized) ? normalized : null;
  }
}
