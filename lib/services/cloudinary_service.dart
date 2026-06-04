import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String cloudName = 'dzli32yut';
  static const String uploadPreset = 'gym_lead_master';

  //  PURANA METHOD (Profile Picture ke liye - XFile se)
  Future<String?> uploadImage(XFile imageFile) async {
    try {
      Uint8List bytes = await imageFile.readAsBytes();
      if (bytes.isEmpty) return null;

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request =
          http.MultipartRequest('POST', uri)
            ..fields['upload_preset'] = uploadPreset
            ..files.add(
              http.MultipartFile.fromBytes(
                'file',
                bytes,
                filename: imageFile.name,
              ),
            );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final RegExp urlRegExp = RegExp(r'"secure_url":"([^"]+)"');
        final match = urlRegExp.firstMatch(responseString);

        if (match != null) {
          return match.group(1)!;
        }
      }
      return null;
    } catch (e) {
      print("❌ Cloudinary Error: $e");
      return null;
    }
  }

  

  Future<String?> uploadBytes(
    Uint8List bytes, {
    String fileName = 'upload.jpg',
  }) async {
    try {
      if (bytes.isEmpty) return null;

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request =
          http.MultipartRequest('POST', uri)
            ..fields['upload_preset'] = uploadPreset
            ..files.add(
              http.MultipartFile.fromBytes('file', bytes, filename: fileName),
            );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final RegExp urlRegExp = RegExp(r'"secure_url":"([^"]+)"');
        final match = urlRegExp.firstMatch(responseString);

        if (match != null) {
          print("Cloudinary Bytes Upload Success: ${match.group(1)!}");
          return match.group(1)!;
        }
      }
      return null;
    } catch (e) {
      print("Cloudinary Bytes Error: $e");
      return null;
    }
  }
}
