import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myedu/components/custom_button.dart';
import 'package:myedu/components/custom_dropdown.dart';
import 'package:myedu/components/custom_text_field.dart';
import 'package:myedu/constraints/app_constants.dart';
import 'package:myedu/controllers/auth_controller.dart';
import 'package:myedu/controllers/theme_controller.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure AuthController is initialized
    // if (!Get.isRegistered<AuthController>()) {
    //   Get.put(AuthController());
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        actions: [
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
      body: SafeArea(
        child: GetBuilder<AuthController>(
          init: AuthController(),
          builder: (controller) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(controller),
                      const SizedBox(height: AppConstants.largeSpacing),
                      _buildSignUpForm(controller),
                      const SizedBox(height: AppConstants.largeSpacing),
                      _buildSignInLink(controller),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(AuthController controller) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_add,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.mediumSpacing),
        Text(
          'Join ${AppConstants.appName}',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Text(
          'Create your university account',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignUpForm(AuthController controller) {
    return Card(
      elevation: AppConstants.mediumElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largeSpacing),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Personal Information',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.largeSpacing),

              // Name Field
              CustomTextField(
                controller: controller.nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.nameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.mediumSpacing),

              // Email Field
              CustomTextField(
                controller: controller.emailController,
                label: 'Email',
                hint: 'Enter your email address',
                isEmail: true,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppConstants.mediumSpacing),

              // Faculty Dropdown
              CustomDropdown(
                label: 'Faculty',
                value: controller.selectedFaculty,
                items: AppConstants.faculties,
                onChanged: (value) {
                  setState(() {
                    controller.selectedFaculty = value;
                  });
                },
                prefixIcon: Icons.school_outlined,
                hint: 'Select your faculty',
              ),
              const SizedBox(height: AppConstants.mediumSpacing),

              // ID Field
              CustomTextField(
                controller: controller.idController,
                label: 'Student ID',
                hint: 'Enter your student ID',
                prefixIcon: Icons.badge_outlined,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.idRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.mediumSpacing),

              // Registration Field
              CustomTextField(
                controller: controller.regiController,
                label: 'Registration Number',
                hint: 'Enter your registration number',
                prefixIcon: Icons.assignment_outlined,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.regiRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.mediumSpacing),

              // Phone Field
              CustomTextField(
                controller: controller.phoneController,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                isPhone: true,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.phoneRequired;
                  }
                  if (!GetUtils.isPhoneNumber(value)) {
                    return AppConstants.phoneInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.mediumSpacing),

              // Password Field
              CustomTextField(
                controller: controller.passwordController,
                label: 'Password',
                hint: 'Create a strong password',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.passwordRequired;
                  }
                  if (value.length < 6) {
                    return AppConstants.passwordMinLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.mediumSpacing),

              // Confirm Password Field
              CustomTextField(
                controller: controller.confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Re-enter your password',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != controller.passwordController.text) {
                    return AppConstants.passwordMismatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.largeSpacing),

              // Sign Up Button
              GetBuilder<AuthController>(
                builder: (controller) {
                  return CustomButton(
                    text: 'Create Account',
                    onPressed: controller.signUpHandler,
                    isLoading: controller.isLoading,
                    icon: Icons.person_add,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInLink(AuthController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
