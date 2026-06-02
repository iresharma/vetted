import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class PhotoStorageService {
  PhotoStorageService._();

  static final PhotoStorageService instance = PhotoStorageService._();

  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickFromGallery() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 88,
    );
  }

  Future<String> uploadProfilePhoto(XFile file) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('Must be signed in to upload photos.');
    }

    final extension = _extensionFor(file.path);
    final objectPath =
        'profile-photos/$uid/${DateTime.now().millisecondsSinceEpoch}.$extension';
    final ref = FirebaseStorage.instance.ref(objectPath);

    final metadata = SettableMetadata(
      contentType: _contentTypeFor(file.path),
    );

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      await ref.putData(bytes, metadata);
    } else {
      await ref.putFile(File(file.path), metadata);
    }

    return ref.getDownloadURL();
  }

  String _extensionFor(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return 'jpg';
    final ext = path.substring(dot + 1).toLowerCase();
    return ext == 'jpeg' ? 'jpg' : ext;
  }

  String _contentTypeFor(String path) {
    return switch (_extensionFor(path)) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };
  }
}
