import 'package:http_parser/http_parser.dart';

MediaType? mediaTypeForPath(String path) {
  final name = path.split('/').last.toLowerCase();
  final ext = name.contains('.') ? name.split('.').last : '';
  return switch (ext) {
    'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
    'png' => MediaType('image', 'png'),
    'webp' => MediaType('image', 'webp'),
    'gif' => MediaType('image', 'gif'),
    'mp4' => MediaType('video', 'mp4'),
    'mov' => MediaType('video', 'quicktime'),
    'webm' => MediaType('video', 'webm'),
    '3gp' => MediaType('video', '3gpp'),
    'mp3' => MediaType('audio', 'mpeg'),
    'm4a' => MediaType('audio', 'mp4'),
    'aac' => MediaType('audio', 'aac'),
    'wav' => MediaType('audio', 'wav'),
    'ogg' => MediaType('audio', 'ogg'),
    'pdf' => MediaType('application', 'pdf'),
    'doc' => MediaType('application', 'msword'),
    'docx' => MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document'),
    'xls' => MediaType('application', 'vnd.ms-excel'),
    'xlsx' => MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
    'txt' => MediaType('text', 'plain'),
    'zip' => MediaType('application', 'zip'),
    _ => null,
  };
}
