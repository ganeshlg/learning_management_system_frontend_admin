import 'dart:typed_data';

abstract class FileUploadRepository {
  Future<String> uploadBytes(Uint8List bytes, String fileName, {String? folder});
  Future<void> deleteFile(String url);
}
