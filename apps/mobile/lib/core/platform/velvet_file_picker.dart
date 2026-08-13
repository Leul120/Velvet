import 'package:flutter/services.dart';

class VelvetFilePicker {
  static const _channel = MethodChannel('velvet/secure_picker');

  static Future<({String path, String name})?> pick({
    String mime = '*/*',
    List<String>? mimes,
  }) async {
    final result = await _channel.invokeMethod<dynamic>('pickFile', {
      'mime': mime,
      'mimes': ?mimes,
    });
    if (result is! Map) return null;
    final path = result['path']?.toString();
    final name = result['name']?.toString() ?? 'file';
    if (path == null || path.isEmpty) return null;
    return (path: path, name: name);
  }
}
