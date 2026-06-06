import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vetted_club_mobile/core/config/app_check_bootstrap.dart';

/// Thrown when a profile photo fails to upload to Firebase Storage.
class PhotoUploadException implements Exception {
  PhotoUploadException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class PhotoStorageService {
  PhotoStorageService._();

  static final PhotoStorageService instance = PhotoStorageService._();

  static const _uploadTimeout = Duration(seconds: 90);

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
      throw PhotoUploadException('You must be signed in to upload photos.');
    }

    if (useAppCheckDebugProviders) {
      await primeAppCheckToken();
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw PhotoUploadException('Selected image is empty. Try another photo.');
    }

    final extension = _extensionFor(file.path);
    final objectPath =
        'profile-photos/$uid/${DateTime.now().millisecondsSinceEpoch}.$extension';
    final bucket = FirebaseStorage.instance.bucket;
    final ref = FirebaseStorage.instance.ref(objectPath);

    if (kDebugMode) {
      debugPrint(
        'Storage upload: gs://$bucket/$objectPath (${bytes.length} bytes)',
      );
    }

    final metadata = SettableMetadata(
      contentType: _contentTypeFor(file.path),
    );

    try {
      final task = ref.putData(bytes, metadata);
      task.snapshotEvents.listen((event) {
        if (!kDebugMode) return;
        final total = event.totalBytes;
        final sent = event.bytesTransferred;
        if (total > 0) {
          final pct = (100 * sent / total).round();
          debugPrint('Storage upload progress: $pct% ($sent/$total)');
        }
      });

      await task.timeout(
        _uploadTimeout,
        onTimeout: () {
          task.cancel();
          throw PhotoUploadException(
            'Upload timed out. Check your connection and try again.',
            code: 'timeout',
          );
        },
      );

      final url = await ref.getDownloadURL();
      if (kDebugMode) {
        debugPrint('Storage upload done: $url');
      }
      return url;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          'Storage upload failed: code=${e.code} message=${e.message} '
          'plugin=${e.plugin}',
        );
      }
      throw PhotoUploadException(
        _messageForFirebaseException(e),
        code: e.code,
      );
    } on PhotoUploadException {
      rethrow;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Storage upload unexpected error: $e\n$st');
      }
      throw PhotoUploadException('Upload failed. Please try again.');
    }
  }

  String _messageForFirebaseException(FirebaseException e) {
    return switch (e.code) {
      'unauthorized' || 'permission-denied' => _permissionMessage(e),
      'unauthenticated' => 'Session expired. Sign in again and retry.',
      'object-not-found' =>
        'Storage bucket not found. Enable Firebase Storage in the console.',
      'canceled' => 'Upload was cancelled.',
      'retry-limit-exceeded' =>
        'Upload failed after several retries. Check your connection.',
      _ => e.message?.isNotEmpty == true
          ? 'Upload failed: ${e.message}'
          : 'Upload failed (${e.code}).',
    };
  }

  String _permissionMessage(FirebaseException e) {
    final msg = (e.message ?? '').toLowerCase();
    if (msg.contains('app check') || msg.contains('app-check')) {
      return 'App Check blocked the upload. Register your debug token in '
          'Firebase Console → App Check → Manage debug tokens, then restart the app.';
    }
    return 'Storage permission denied. Deploy storage.rules and ensure you are signed in.';
  }

  String _extensionFor(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return 'jpg';
    final ext = path.substring(dot + 1).toLowerCase();
    if (ext == 'jpeg' || ext == 'heic' || ext == 'heif') return 'jpg';
    return ext;
  }

  String _contentTypeFor(String path) {
    return switch (_extensionFor(path)) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}
