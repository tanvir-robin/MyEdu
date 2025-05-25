import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myedu/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find<ProfileController>();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  File? _selectedImage;
  String? _profileImageUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Getters
  File? get selectedImage => _selectedImage;
  String? get profileImageUrl => _profileImageUrl;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;

  @override
  void onInit() {
    super.onInit();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    if (_authController.user == null) return;

    try {
      final doc =
          await _firestore
              .collection('users')
              .doc(_authController.user!.uid)
              .get();

      if (doc.exists && doc.data()!.containsKey('profileImageUrl')) {
        _profileImageUrl = doc.data()!['profileImageUrl'] as String?;
        update();
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        update();

        // Upload the image automatically
        await uploadProfileImage();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> uploadProfileImage() async {
    if (_selectedImage == null || _authController.user == null) return;

    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      update();

      // Create a reference to the location where we'll store the file
      final storageRef = _storage
          .ref()
          .child('profile_images')
          .child('${_authController.user!.uid}.jpg');

      // Start upload task
      final uploadTask = storageRef.putFile(_selectedImage!);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        update();
      });

      // Wait for upload to complete
      await uploadTask.whenComplete(() {});

      // Get the download URL
      final downloadUrl = await storageRef.getDownloadURL();
      _profileImageUrl = downloadUrl;

      // Update user document with the profile image URL
      await _firestore
          .collection('users')
          .doc(_authController.user!.uid)
          .update({'profileImageUrl': downloadUrl});

      _isUploading = false;
      update();

      Get.snackbar(
        'Success',
        'Profile image uploaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      _isUploading = false;
      update();

      Get.snackbar(
        'Error',
        'Failed to upload profile image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
