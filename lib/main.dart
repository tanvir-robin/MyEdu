import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:myedu/constraints/app_constants.dart';
import 'package:myedu/controllers/auth_controller.dart';
import 'package:myedu/controllers/theme_controller.dart';
import 'package:myedu/firebase_options.dart';
import 'package:myedu/utils/theme.dart';
import 'package:myedu/views/dashboard_view.dart';
import 'package:myedu/views/sign_in_view.dart';
import 'package:myedu/views/sign_up_view.dart';
import 'package:myedu/views/splash_view.dart';

void main() async {
  // Ensure that plugin services are initialized so that Firebase can be used.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize theme controller
  Get.put(ThemeController());
  Get.put(AuthController());
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
              name: AppRoutes.dashboard,
              page: () => const DashboardView(),
              transition: Transition.fadeIn,
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ],
        );
      },
    );
  }
}
