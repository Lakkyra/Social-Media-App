import 'dart:typed_data';
import 'dart:convert';
import 'dart:io' show File;
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';

Future<String> uploadToCloudinary({
  required String folder,
  PlatformFile? platformFile,
  Uint8List? webBytes,
}) async {
  // Validate input
  if (!kIsWeb && platformFile == null) {
    print("No file provided for mobile.");
    return '';
  }
  if (kIsWeb && webBytes == null) {
    print("No file bytes provided for web.");
    return '';
  }

  // Cloudinary configuration
  final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  if (cloudName.isEmpty) {
    print("Cloudinary cloud name not found in .env");
    return '';
  }

  final uri = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
  );
  final request = http.MultipartRequest('POST', uri);

  late Uint8List fileBytes;
  late String fileName;

  if (kIsWeb) {
    fileBytes = webBytes!;
    fileName = 'uploaded_image'; // Default name
  } else {
    fileBytes =
        platformFile!.bytes ?? await File(platformFile.path!).readAsBytes();
    fileName = platformFile.name;
  }

  final multipartFile = http.MultipartFile.fromBytes(
    'file',
    fileBytes,
    filename: fileName,
  );

  request.files.add(multipartFile);
  request.fields['upload_preset'] = "preset_for_uploads";
  request.fields['folder'] =
      folder; // Optional: specify a folder for organization

  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final jsonResponse = jsonDecode(responseBody);

    if (response.statusCode == 200 && jsonResponse['secure_url'] != null) {
      print("Image uploaded: ${jsonResponse['secure_url']}");
      return jsonResponse['secure_url'];
    } else {
      print("Upload failed: ${jsonResponse['error'] ?? 'Unknown error'}");
      return '';
    }
  } catch (e) {
    print("Upload error: $e");
    return '';
  }
}

Future<bool> deleteFromCloudinary(String imageUrl) async {
  final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  final apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  final apiSecret = dotenv.env['CLOUDINARY_SECRET_KEY'] ?? '';

  if (cloudName.isEmpty || apiKey.isEmpty || apiSecret.isEmpty) {
    print("Cloudinary credentials are missing.");
    return false;
  }

  try {
    // Extract public ID
    Uri uri = Uri.parse(imageUrl);
    List<String> segments = List<String>.from(uri.pathSegments);

    // Remove version (e.g., "v1717171717")
    segments.removeWhere(
      (segment) =>
          segment.startsWith('v') && int.tryParse(segment.substring(1)) != null,
    );

    final uploadIndex = segments.indexOf('upload');
    if (uploadIndex == -1 || uploadIndex + 1 >= segments.length) {
      print("Invalid image URL format.");
      return false;
    }

    final filePath = segments.sublist(uploadIndex + 1).join('/');
    final publicId = filePath.replaceAll(RegExp(r'\.\w+$'), '');

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final toSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
    final signature = sha1.convert(utf8.encode(toSign)).toString();

    final uriToPost = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/destroy',
    );

    final response = await http.post(
      uriToPost,
      body: {
        'public_id': publicId,
        'timestamp': timestamp.toString(),
        'api_key': apiKey,
        'signature': signature,
      },
    );

    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200 && responseBody['result'] == 'ok') {
      print("Image deleted successfully.");
      return true;
    } else {
      print("Delete failed: ${responseBody['result']}");
      return false;
    }
  } catch (e) {
    print("Error deleting image: $e");
    return false;
  }
}
