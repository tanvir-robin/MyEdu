import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myedu/components/custom_button.dart';
import 'package:myedu/components/custom_text_field.dart';
import 'package:myedu/constraints/app_constants.dart';
import 'package:myedu/controllers/auth_controller.dart';
import 'package:myedu/controllers/theme_controller.dart';
import 'package:myedu/views/sign_up_view.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.mediumSpacing),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppConstants.extraLargeSpacing * 2),
                  _buildSignInForm(),
                  const SizedBox(height: AppConstants.largeSpacing),
                  _buildSignUpLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 48),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            GetBuilder<ThemeController>(
              builder: (controller) {
                return IconButton(
                  icon: Icon(
                    controller.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                  onPressed: controller.toggleTheme,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppConstants.mediumSpacing),
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.school,
            size: 60,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.mediumSpacing),
        Text(
          'Welcome Back!',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Text(
          'Sign in to your university account',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignInForm() {
    return Card(
      elevation: AppConstants.mediumElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largeSpacing),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sign In',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.largeSpacing),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email address',
                isEmail: true,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppConstants.mediumSpacing),
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.passwordRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.largeSpacing),
              GetBuilder<AuthController>(
                builder: (controller) {
                  return CustomButton(
                    text: 'Sign In',
                    onPressed: _signIn,
                    isLoading: controller.isLoading,
                    icon: Icons.login,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => Get.to(() => SignUpView()),
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      bool success = await _authController.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (success) {
        Get.offAllNamed(AppRoutes.dashboard);
      }
    }
  }
}
