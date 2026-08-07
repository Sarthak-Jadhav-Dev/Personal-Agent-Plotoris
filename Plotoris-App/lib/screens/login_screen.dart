import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/claude_button.dart';
import '../services/auth_service.dart';

/// Login screen with Google-only authentication.
///
/// Features:
/// - Plotoris branding / welcome message
/// - "Continue with Google" button
/// - Subtle entrance animations
/// - Error handling with animated snackbar
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Start entrance animation
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppTheme.error, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        margin: const EdgeInsets.all(AppTheme.spacingMd),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.surfaceGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Logo / Brand ──────────────────────────
                      _buildLogo(),
                      const SizedBox(height: AppTheme.spacing2xl),

                      // ── Welcome Text ──────────────────────────
                      _buildWelcomeText(),
                      const SizedBox(height: AppTheme.spacing2xl),

                      // ── Auth Card ─────────────────────────────
                      _buildAuthCard(),

                      const SizedBox(height: AppTheme.spacingLg),

                      // ── Footer ────────────────────────────────
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.accentGlow,
      ),
      child: const Center(
        child: Text(
          'P',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Welcome to Plotoris',
          style: AppTheme.headingLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Your personal AI-powered planner',
          style: AppTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border, width: 0.5),
        boxShadow: AppTheme.elevationMedium,
      ),
      child: Column(
        children: [
          Text(
            'Sign in to continue',
            style: AppTheme.headingSmall,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Use your Google account to securely access Plotoris',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // Divider
          Row(
            children: [
              const Expanded(
                child: Divider(color: AppTheme.border, thickness: 0.5),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                child: Text('GET STARTED', style: AppTheme.bodySmall),
              ),
              const Expanded(
                child: Divider(color: AppTheme.border, thickness: 0.5),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // Google Sign-In Button
          ClaudeButton.google(
            text: 'Continue with Google',
            isLoading: _isLoading,
            icon: _isLoading
                ? null
                : Image.network(
                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.g_mobiledata_rounded,
                      color: Color(0xFF4285F4),
                      size: 24,
                    ),
                  ),
            onPressed: _isLoading ? null : _handleGoogleSignIn,
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Or sign in with accent button
          ClaudeButton.primary(
            text: 'Sign in with Google',
            isLoading: false,
            icon: const Icon(Icons.login_rounded, color: Colors.white, size: 20),
            onPressed: _isLoading ? null : _handleGoogleSignIn,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'By continuing, you agree to our',
          style: AppTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // TODO: Open Terms of Service
              },
              child: Text(
                'Terms of Service',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.accent,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.accent,
                ),
              ),
            ),
            Text(' & ', style: AppTheme.bodySmall),
            GestureDetector(
              onTap: () {
                // TODO: Open Privacy Policy
              },
              child: Text(
                'Privacy Policy',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.accent,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.accent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
