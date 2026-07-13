import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile image using BYTES 
  Future<String?> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      debugPrint("STEP 1: Reading image bytes...");
      
      // Read bytes - works on Android, iOS, Web, Windows, macOS, Linux
      Uint8List bytes = await imageFile.readAsBytes();
      debugPrint("STEP 2: Bytes read successfully. Size: ${bytes.length} bytes");

      if (bytes.isEmpty) {
        debugPrint("ERROR: Image bytes are empty!");
        return null;
      }

      String fileName = 'profile_$userId.jpg';
      Reference ref = _storage.ref().child('users/$userId/$fileName');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploadedBy': userId},
      );

      debugPrint("STEP 3: Starting upload to Firebase Storage...");
      debugPrint("Path: users/$userId/$fileName");

      // Use putData for ALL platforms (NOT putFile)
      UploadTask uploadTask = ref.putData(bytes, metadata);

      // Add timeout - if upload doesn't complete in 60 seconds, fail
      TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint("ERROR: Upload timed out after 60 seconds!");
          throw TimeoutException('Image upload timed out');
        },
      );

      debugPrint("STEP 4: Upload complete. Getting download URL...");

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint("STEP 5: Download URL = $downloadUrl");

      return downloadUrl;
    } on TimeoutException {
      debugPrint("TIMEOUT: Image upload took too long");
      return null;
    } on FirebaseException catch (e) {
      debugPrint("FIREBASE ERROR: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      debugPrint("UNKNOWN ERROR: $e");
      return null;
    }
  }

  Future<void> deleteProfileImage(String userId) async {
    try {
      String fileName = 'profile_$userId.jpg';
      await _storage.ref().child('users/$userId/$fileName').delete();
      debugPrint("Image deleted successfully");
    } on FirebaseException catch (e) {
      debugPrint("DELETE ERROR: ${e.code} - ${e.message}");
    } catch (e) {
      debugPrint("DELETE ERROR: $e");
    }
  }
}