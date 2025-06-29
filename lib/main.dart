import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:myedu/constraints/app_constants.dart';
import 'package:myedu/controllers/auth_controller.dart';
import 'package:myedu/controllers/notification_controller.dart';
import 'package:myedu/controllers/theme_controller.dart';
import 'package:myedu/firebase_options.dart';
import 'package:myedu/services/push_notification_service.dart';
import 'package:myedu/utils/theme.dart';
import 'package:myedu/views/dashboard_view.dart';
import 'package:myedu/views/notification_history_view.dart';
import 'package:myedu/views/otp_verification_view.dart';
import 'package:myedu/views/sign_in_view.dart';
import 'package:myedu/views/sign_up_view.dart';
import 'package:myedu/views/splash_view.dart';
import 'package:myedu/views/notice_screen.dart';

void main() async {
  // Ensure that plugin services are initialized so that Firebase can be used.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize controllers
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(NotificationController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          builder: EasyLoading.init(),
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          initialRoute: AppRoutes.splash,
          getPages: [
            GetPage(
              name: AppRoutes.splash,
              page: () => const SplashView(),
              transition: Transition.fadeIn,
              transitionDuration: const Duration(milliseconds: 300),
            ),
            GetPage(
              name: AppRoutes.signIn,
              page: () => const SignInView(),
              transition: Transition.rightToLeft,
              transitionDuration: const Duration(milliseconds: 300),
            ),
            GetPage(
              name: AppRoutes.signUp,
              page: () => const SignUpView(),
              transition: Transition.rightToLeft,
              transitionDuration: const Duration(milliseconds: 300),
            ),
            GetPage(
              name: AppRoutes.otpVerification,
              page:
                  () => OtpVerificationView(
                    email: Get.arguments['email'],
                    name: Get.arguments['name'],
                    faculty: Get.arguments['faculty'],
                    id: Get.arguments['id'],
                    regi: Get.arguments['regi'],
                    phone: Get.arguments['phone'],
                    password: Get.arguments['password'],
                  ),
              transition: Transition.rightToLeft,
              transitionDuration: const Duration(milliseconds: 300),
            ),
            GetPage(
              name: AppRoutes.dashboard,
              page: () => const DashboardView(),
              transition: Transition.fadeIn,
              transitionDuration: const Duration(milliseconds: 300),
            ),
            GetPage(
              name: '/notices',
              page: () => NoticeScreen(),
              transition: Transition.rightToLeft,
              transitionDuration: const Duration(milliseconds: 300),
            ),
            GetPage(
              name: '/notifications',
              page: () => const NotificationHistoryView(),
              transition: Transition.rightToLeft,
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ],
        );
      },
    );
  }
}
