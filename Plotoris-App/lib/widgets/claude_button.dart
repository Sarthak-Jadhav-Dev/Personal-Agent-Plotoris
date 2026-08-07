import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Claude-styled button with micro-animations.
///
/// Variants:
/// - [ClaudeButton.primary] — filled accent background
/// - [ClaudeButton.outlined] — transparent with accent border
/// - [ClaudeButton.google] — white background with Google branding
class ClaudeButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final _ClaudeButtonVariant _variant;
  final Widget? icon;

  const ClaudeButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : _variant = _ClaudeButtonVariant.primary;

  const ClaudeButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : _variant = _ClaudeButtonVariant.outlined;

  const ClaudeButton.google({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : _variant = _ClaudeButtonVariant.google;

  @override
  State<ClaudeButton> createState() => _ClaudeButtonState();
}

enum _ClaudeButtonVariant { primary, outlined, google }

class _ClaudeButtonState extends State<ClaudeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animController.forward();
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(TapUpDetails _) {
    _animController.reverse();
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    _animController.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onPressed == null || widget.isLoading;

    return _AnimatedScaleBuilder(
      listenable: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: disabled ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: _buildDecoration(disabled),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget._variant == _ClaudeButtonVariant.google
                          ? AppTheme.textTertiary
                          : Colors.white,
                    ),
                  ),
                )
              else ...[
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 12),
                ],
                Text(
                  widget.text,
                  style: _buildTextStyle(disabled),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(bool disabled) {
    switch (widget._variant) {
      case _ClaudeButtonVariant.primary:
        return BoxDecoration(
          gradient: disabled ? null : AppTheme.accentGradient,
          color: disabled ? AppTheme.surfaceElevated : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: disabled
              ? null
              : _isPressed
                  ? null
                  : AppTheme.accentGlow,
        );
      case _ClaudeButtonVariant.outlined:
        return BoxDecoration(
          color: _isPressed
              ? AppTheme.surfaceElevated
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: disabled ? AppTheme.border : AppTheme.accent,
            width: 1.5,
          ),
        );
      case _ClaudeButtonVariant.google:
        return BoxDecoration(
          color: _isPressed
              ? const Color(0xFFF1F1F1)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: _isPressed ? null : AppTheme.elevationLow,
        );
    }
  }

  TextStyle _buildTextStyle(bool disabled) {
    switch (widget._variant) {
      case _ClaudeButtonVariant.primary:
        return AppTheme.buttonText.copyWith(
          color: disabled ? AppTheme.textTertiary : Colors.white,
        );
      case _ClaudeButtonVariant.outlined:
        return AppTheme.buttonText.copyWith(
          color: disabled ? AppTheme.textTertiary : AppTheme.accent,
        );
      case _ClaudeButtonVariant.google:
        return AppTheme.buttonText.copyWith(
          color: disabled
              ? AppTheme.textTertiary
              : const Color(0xFF3C4043),
        );
    }
  }
}

/// Animated builder helper for scale animations.
class _AnimatedScaleBuilder extends AnimatedWidget {
  final Widget? child;
  final Widget Function(BuildContext, Widget?) builder;

  const _AnimatedScaleBuilder({
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
