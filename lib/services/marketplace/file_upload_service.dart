// lib/services/file_upload_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;

class FileUploadService {
  static const String uploadUrl = "https://api.metazone.app/upload";

  // -------------------------------------------------------
  // رفع ملف واحد (صور – AR Model – ملفات إضافية)
  // -------------------------------------------------------
  static Future<String> uploadFile(File file) async {
    final req = http.MultipartRequest("POST", Uri.parse(uploadUrl));

    req.files.add(
      await http.MultipartFile.fromPath("file", file.path),
    );

    final res = await req.send();

    if (res.statusCode != 200) throw Exception("Upload failed");

    final body = await res.stream.bytesToString();
    return body;  // بيرجع رابط الملف
  }

  // -------------------------------------------------------
  // رفع مجموعة ملفات دفعة واحدة
  // -------------------------------------------------------
  static Future<List<String>> uploadMultiple(List<File> files) async {
    List<String> urls = [];

    for (final file in files) {
      final link = await uploadFile(file);
      urls.add(link);
    }
    return urls;
  }
}
