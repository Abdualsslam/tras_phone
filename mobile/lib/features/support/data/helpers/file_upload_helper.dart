/// File Upload Helper - Converts files to base64 format for API
library;

import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// File data for upload
class FileUploadData {
  final String base64;
  final String filename;
  final String mimeType;

  const FileUploadData({
    required this.base64,
    required this.filename,
    required this.mimeType,
  });

  Map<String, dynamic> toJson() => {
        'base64': 'data:$mimeType;base64,$base64',
        'filename': filename,
      };
}

/// Helper class for file upload operations
class FileUploadHelper {
  /// Convert XFile to base64
  static Future<FileUploadData> convertXFileToBase64(XFile file) async {
    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);
    final mimeType = file.mimeType ?? 'application/octet-stream';

    return FileUploadData(
      base64: base64String,
      filename: file.name,
      mimeType: mimeType,
    );
  }

  /// Convert file path to base64
  static Future<FileUploadData> convertFilePathToBase64(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $filePath');
    }

    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);
    final extension = filePath.split('.').last;
    final mimeType = _getMimeTypeFromExtension(extension);
    final filename = filePath.split('/').last;

    return FileUploadData(
      base64: base64String,
      filename: filename,
      mimeType: mimeType,
    );
  }

  /// Convert multiple XFiles to base64
  static Future<List<FileUploadData>> convertXFilesToBase64(
    List<XFile> files,
  ) async {
    final results = <FileUploadData>[];
    for (final file in files) {
      final data = await convertXFileToBase64(file);
      results.add(data);
    }
    return results;
  }

  /// Convert multiple file paths to base64
  static Future<List<FileUploadData>> convertFilePathsToBase64(
    List<String> filePaths,
  ) async {
    final results = <FileUploadData>[];
    for (final path in filePaths) {
      final data = await convertFilePathToBase64(path);
      results.add(data);
    }
    return results;
  }

  /// Get MIME type from file extension
  static String _getMimeTypeFromExtension(String extension) {
    final ext = extension.toLowerCase();
    switch (ext) {
      // Images
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      case 'bmp':
        return 'image/bmp';

      // Documents
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';

      // Text
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'html':
        return 'text/html';
      case 'xml':
        return 'text/xml';

      // Archives
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      case '7z':
        return 'application/x-7z-compressed';

      default:
        return 'application/octet-stream';
    }
  }
}
