import 'package:flutter/material.dart';
import 'package:myedu/constraints/app_constants.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = AppConstants.buttonHeight,
    this.icon,
    this.borderRadius = AppConstants.mediumRadius,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:
          widget.onPressed != null && !widget.isLoading ? _onTapDown : null,
      onTapUp: widget.onPressed != null && !widget.isLoading ? _onTapUp : null,
      onTapCancel:
          widget.onPressed != null && !widget.isLoading ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              child:
                  widget.isOutlined
                      ? OutlinedButton(
                        onPressed: widget.isLoading ? null : widget.onPressed,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color:
                                widget.backgroundColor ??
                                Theme.of(context).primaryColor,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              widget.borderRadius,
                            ),
                          ),
                        ),
                        child: _buildButtonContent(),
                      )
                      : ElevatedButton(
                        onPressed: widget.isLoading ? null : widget.onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              widget.backgroundColor ??
                              Theme.of(context).primaryColor,
                          foregroundColor: widget.textColor ?? Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              widget.borderRadius,
                            ),
                          ),
                          elevation: 2,
                        ),
                        child: _buildButtonContent(),
                      ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.isOutlined
                ? (widget.backgroundColor ?? Theme.of(context).primaryColor)
                : (widget.textColor ?? Colors.white),
          ),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            size: 20,
            color:
                widget.isOutlined
                    ? (widget.backgroundColor ?? Theme.of(context).primaryColor)
                    : (widget.textColor ?? Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  widget.isOutlined
                      ? (widget.backgroundColor ??
                          Theme.of(context).primaryColor)
                      : (widget.textColor ?? Colors.white),
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color:
            widget.isOutlined
                ? (widget.backgroundColor ?? Theme.of(context).primaryColor)
                : (widget.textColor ?? Colors.white),
      ),
    );
  }
}
