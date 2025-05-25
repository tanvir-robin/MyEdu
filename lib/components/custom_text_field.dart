import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myedu/constraints/app_constants.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool isPassword;
  final bool isEmail;
  final bool isPhone;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool enabled;
  final VoidCallback? onTap;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.isEmail = false,
    this.isPhone = false,
    this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.normalAnimation,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType:
              widget.keyboardType ??
              (widget.isEmail
                  ? TextInputType.emailAddress
                  : widget.isPhone
                  ? TextInputType.phone
                  : TextInputType.text),
          inputFormatters: widget.inputFormatters,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          validator:
              widget.validator ??
              (widget.isEmail ? _emailValidator : _defaultValidator),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon:
                widget.prefixIcon != null
                    ? Icon(
                      widget.prefixIcon,
                      color: Theme.of(context).primaryColor,
                    )
                    : null,
            suffixIcon:
                widget.isPassword
                    ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                    : null,
          ),
        ),
      ),
    );
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.emailRequired;
    }
    if (!GetUtils.isEmail(value)) {
      return AppConstants.emailInvalid;
    }
    return null;
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '${widget.label} is required';
    }
    return null;
  }
}
