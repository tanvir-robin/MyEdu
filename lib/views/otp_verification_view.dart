import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myedu/components/custom_button.dart';
import 'package:myedu/components/custom_text_field.dart';
import 'package:myedu/constraints/app_constants.dart';
import 'package:myedu/controllers/auth_controller.dart';
import 'package:myedu/controllers/theme_controller.dart';

class OtpVerificationView extends StatefulWidget {
  final String email;
  final String name;
  final String faculty;
  final String id;
  final String regi;
  final String phone;
  final String password;

  const OtpVerificationView({
    super.key,
    required this.email,
    required this.name,
    required this.faculty,
    required this.id,
    required this.regi,
    required this.phone,
    required this.password,
  });

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isResending = false;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startResendTimer();
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

  void _startResendTimer() {
    _resendCountdown = 60;
    _canResend = false;
    setState(() {});

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _resendCountdown--;
      });
      return _resendCountdown > 0;
    }).then((_) {
      setState(() {
        _canResend = true;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
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
                      _buildHeader(),
                      const SizedBox(height: AppConstants.largeSpacing),
                      _buildOtpForm(controller),
                      const SizedBox(height: AppConstants.largeSpacing),
                      _buildResendSection(controller),
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

  Widget _buildHeader() {
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
            Icons.email_outlined,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.mediumSpacing),
        Text(
          'Verify Your Email',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Text(
          'We\'ve sent a verification code to',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Text(
          widget.email,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.mediumSpacing),
        Container(
          padding: const EdgeInsets.all(AppConstants.mediumSpacing),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: AppConstants.smallSpacing),
              Expanded(
                child: Text(
                  'Enter the 6-digit code sent to your email to verify your account.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpForm(AuthController controller) {
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
                'Enter Verification Code',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.largeSpacing),

              // OTP Input Field
              CustomTextField(
                controller: _otpController,
                label: 'OTP Code',
                hint: 'Enter 6-digit code',
                prefixIcon: Icons.security_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP code';
                  }
                  if (value.length != 6) {
                    return 'OTP code must be 6 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.largeSpacing),

              // Verify Button
              GetBuilder<AuthController>(
                builder: (controller) {
                  return CustomButton(
                    text: 'Verify & Create Account',
                    onPressed: () => _verifyOtp(controller),
                    isLoading: controller.isLoading,
                    icon: Icons.verified_outlined,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResendSection(AuthController controller) {
    return Column(
      children: [
        Text(
          'Didn\'t receive the code?',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        if (_canResend)
          TextButton(
            onPressed: _isResending ? null : () => _resendOtp(controller),
            child:
                _isResending
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text(
                      'Resend Code',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          )
        else
          Text(
            'Resend code in $_resendCountdown seconds',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        const SizedBox(height: AppConstants.largeSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Wrong email? ',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Go Back',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _verifyOtp(AuthController controller) async {
    if (_formKey.currentState!.validate()) {
      final otp = _otpController.text.trim();

      // Verify OTP with the controller
      final success = await controller.verifyOtpAndSignUp(
        otp: otp,
        name: widget.name,
        email: widget.email,
        password: widget.password,
        faculty: widget.faculty,
        id: widget.id,
        regi: widget.regi,
        phone: widget.phone,
      );

      if (success) {
        Get.offAllNamed(AppRoutes.dashboard);
      }
    }
  }

  void _resendOtp(AuthController controller) async {
    setState(() {
      _isResending = true;
    });

    try {
      await controller.sendOtpEmail(widget.email);
      _startResendTimer();

      Get.snackbar(
        'Success',
        'OTP code resent successfully!',
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
        'Failed to resend OTP. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }
}
