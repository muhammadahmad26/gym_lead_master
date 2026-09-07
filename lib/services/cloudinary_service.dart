import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String cloudName = 'dzli32yut';
  static const String uploadPreset = 'gym_lead_master';

  /// Upload Image to Cloudinary and return the URL
  Future<String?> uploadImage(XFile imageFile) async {
    try {
      Uint8List bytes = await imageFile.readAsBytes();
      if (bytes.isEmpty) return null;

      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: imageFile.name),
        );

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = utf8.decode(responseData);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(responseString);
        final String? imageUrl = data['secure_url'] as String?;

        if (imageUrl != null) {
          debugPrint("Cloudinary Upload Success: $imageUrl");
          return imageUrl;
        } else {
          debugPrint("URL not found in response: $responseString");
          return null;
        }
      } else {
        debugPrint(
          "Cloudinary Upload Failed: ${response.statusCode} — $responseString",
        );
        return null;
      }
    } catch (e) {
      debugPrint("Cloudinary Error: $e");
      return null;
    }
}
}