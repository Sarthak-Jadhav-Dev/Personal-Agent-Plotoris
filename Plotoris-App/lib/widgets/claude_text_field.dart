import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Claude-styled text input with focus glow animation.
class ClaudeTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final bool enabled;
  final FocusNode? focusNode;

  const ClaudeTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<ClaudeTextField> createState() => _ClaudeTextFieldState();
}

class _ClaudeTextFieldState extends State<ClaudeTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isFocused = false;
  bool _obscureVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      _glowController.forward();
    } else {
      _glowController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(widget.label, style: AppTheme.labelText),
        ),

        // Input field with glow
        _AnimatedGlowBuilder(
          listenable: _glowAnimation,
          builder: (context, child) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: AppTheme.accent
                            .withValues(alpha: 0.15 * _glowAnimation.value),
                        blurRadius: 12 * _glowAnimation.value,
                        spreadRadius: 1 * _glowAnimation.value,
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText && !_obscureVisible,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            enabled: widget.enabled,
            style: AppTheme.bodyLarge,
            cursorColor: AppTheme.accent,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: widget.prefixIcon,
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppTheme.textTertiary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscureVisible = !_obscureVisible);
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated builder helper for glow animation.
class _AnimatedGlowBuilder extends AnimatedWidget {
  final Widget? child;
  final Widget Function(BuildContext, Widget?) builder;

  const _AnimatedGlowBuilder({
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
