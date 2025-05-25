import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myedu/constraints/app_constants.dart';
import 'package:myedu/models/user_model.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final idController = TextEditingController();
  final regiController = TextEditingController();
  final phoneController = TextEditingController();

  String? selectedFaculty;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Normal variables instead of Rx
  User? _firebaseUser;
  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticating = false; // Add this flag

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _firebaseUser != null;

  @override
  void onInit() {
    super.onInit();
    //  _initAuthListener();
  }

  void _initAuthListener() {
    _auth.authStateChanges().listen((User? user) async {
      _firebaseUser = user;

      // Ensure navigation only occurs when not authenticating
      if (!_isAuthenticating) {
        await _setInitialScreen(user);
      }

      update();
    });
  }

  Future<void> updateProfilePicture(String imageUrl) async {
    if (_firebaseUser == null) return;

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_firebaseUser!.uid)
          .update({'profileImageUrl': imageUrl});

      // Update local user model
      if (_user != null) {
        _user!.profileImageUrl = imageUrl;
        update(); // Update UI
      }
    } catch (e) {
      print('Error updating profile picture: $e');
    }
  }

  Future<void> loadUserData() async {
    _firebaseUser = _auth.currentUser;
    if (_firebaseUser != null) {
      await _loadUserData(_firebaseUser!.uid);
    } else {
      _user = null; // Reset user if not logged in
    }
    update(); // Update UI
  }

  Future<void> _setInitialScreen(User? user) async {
    if (user == null) {
      // Navigate to sign-in screen only if not authenticating
      if (!_isAuthenticating) {
        Get.offAllNamed(AppRoutes.signIn);
      }
    } else {
      await _loadUserData(user.uid);
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(uid)
              .get();

      if (doc.exists) {
        _user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        update(); // Update UI
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Sign Up with Email and Password
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String faculty,
    required String id,
    required String regi,
    required String phone,
  }) async {
    try {
      _isLoading = true;
      _isAuthenticating = true; // Set flag before auth operation
      update();

      // Create user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user model
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        faculty: faculty,
        id: id,
        regi: regi,
        phone: phone,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user data to Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .set(newUser.toMap());

      _isAuthenticating = false; // Reset flag after successful sign-up
      _isLoading = false;
      update();
      return true; // Explicitly return true on success
    } catch (e) {
      _isAuthenticating = false; // Reset flag in case of error
      _isLoading = false;
      update();
      rethrow; // Rethrow the exception to propagate the error
    }
  }

  // Sign In with Email and Password
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _isLoading = true;
      _isAuthenticating = true; // Set flag before auth operation
      update();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _loadUserData(userCredential.user!.uid);

      Get.snackbar(
        'Success',
        AppConstants.signInSuccess,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      String message = _getFirebaseErrorMessage(e.code);
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        AppConstants.generalError,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    } finally {
      _isLoading = false;
      _isAuthenticating = false; // Clear flag after auth operation
      update();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      update(); // Update UI

      await _auth.signOut();
      _user = null;
      update(); // Update UI

      Get.snackbar(
        'Success',
        AppConstants.signOutSuccess,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        AppConstants.generalError,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      _isLoading = false;
      update(); // Update UI
    }
  }

  // Get Firebase error message
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Signing in with Email and Password is not enabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  void signUpHandler() async {
    if (formKey.currentState?.validate() ?? false) {
      if (selectedFaculty == null) {
        Get.snackbar(
          'Error',
          AppConstants.facultyRequired,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }

      try {
        bool success = await signUp(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          faculty: selectedFaculty!,
          id: idController.text.trim(),
          regi: regiController.text.trim(),
          phone: phoneController.text.trim(),
        );

        if (success) {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'AuthController not found. Please restart the app.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    }
  }
}
