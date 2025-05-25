import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:myedu/controllers/auth_controller.dart';

class DashboardController extends GetxController {
  var profileImageUrl = ''.obs;
  var userName = 'Student Name'.obs;
  var userEmail = 'student@university.edu'.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    // Load user data from Firebase/local storage
    // This is where you'll implement the actual user data loading
  }

  Future<void> uploadProfileImage() async {
    try {
      isLoading.value = true;
      // Show attractive overlay loading
      EasyLoading.show(
        status: 'Uploading image...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false,
      );

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Upload to Firebase Storage
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        await storageRef.putFile(File(image.path));
        final String downloadUrl = await storageRef.getDownloadURL();

        profileImageUrl.value = downloadUrl;
        AuthController.instance.updateProfilePicture(downloadUrl);
        // Save to user profile in Firestore

        EasyLoading.showSuccess('Image uploaded successfully!');
      } else {
        EasyLoading.dismiss();
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error', 'Failed to upload image: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
