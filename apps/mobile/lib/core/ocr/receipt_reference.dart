import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Extracts the transaction/FT reference from a CBE receipt screenshot on-device.
class ReceiptReference {
  /// Best-effort OCR. Never throws — returns null on failure/timeout so the
  /// FT confirmation dialog can still open for manual entry.
  static Future<String?> fromImage(
    String path, {
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final text = await recognizer
          .processImage(InputImage.fromFilePath(path))
          .timeout(timeout);
      return fromText(text.text);
    } catch (_) {
      return null;
    } finally {
      await recognizer.close();
    }
  }

  /// CBE transaction IDs are exactly FT + ten alphanumeric characters.
  /// Handles varied OCR formatting (colons, dashes, dots, slashes, linebreaks,
  /// parentheses) and common OCR misreads (FI/F1).
  static String? fromText(String text) {
    if (text.trim().isEmpty) return null;

    // Pass 1: Standard FT match with flexible separators
    final pattern1 = RegExp(
      r'(?:^|[^A-Za-z0-9])F[\s:._\-]*T[\s:._\-\/#\(\)]*([A-Za-z0-9][\s:._\-\/#\(\)]*){10}(?:$|[^A-Za-z0-9])',
      caseSensitive: false,
    );
    final match1 = pattern1.firstMatch(text);
    if (match1 != null) {
      final normalized = match1.group(0)!.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
      final ftMatch = RegExp(r'FT[A-Z0-9]{10}').firstMatch(normalized);
      if (ftMatch != null) return ftMatch.group(0);
    }

    // Pass 2: Search after transaction/reference labels for OCR misreads (e.g. FI/F1/PT/ET)
    final labelPattern = RegExp(
      r'(?:Transaction|Txn|Reference|Ref|Receipt|FT)\s*(?:ID|No|Num|Number|Code|Ref)?[\s:._\-\/#]*([A-Za-z0-9]{10,14})',
      caseSensitive: false,
    );
    final labelMatches = labelPattern.allMatches(text);
    for (final m in labelMatches) {
      final rawVal = m.group(1)!.toUpperCase();
      if (rawVal.startsWith('FT') && rawVal.length >= 12) {
        return rawVal.substring(0, 12);
      }
      if (rawVal.length == 12 && RegExp(r'^(?:FI|F1|PT|ET|TT)[A-Z0-9]{10}$').hasMatch(rawVal)) {
        return 'FT${rawVal.substring(2)}';
      }
    }

    // Pass 3: Global text normalization pass
    final cleaned = text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final globalMatch = RegExp(r'FT[A-Z0-9]{10}').firstMatch(cleaned);
    if (globalMatch != null) {
      return globalMatch.group(0);
    }

    return null;
  }
}

