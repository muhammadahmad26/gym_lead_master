import 'dart:typed_data';
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

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        
        final RegExp urlRegExp = RegExp(r'"secure_url":"([^"]+)"');
        final match = urlRegExp.firstMatch(responseString);
        
        if (match != null) {
          String imageUrl = match.group(1)!;
          print("✅ Cloudinary Upload Success: $imageUrl");
          return imageUrl;
        } else {
          print("❌ URL not found in response");
          return null;
        }
      } else {
        print("❌ Cloudinary Upload Failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Cloudinary Error: $e");
      return null;
    }
}
}