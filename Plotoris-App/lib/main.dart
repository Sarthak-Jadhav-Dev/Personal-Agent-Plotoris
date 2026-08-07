import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style to match our dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const PlotorisApp());
}

class PlotorisApp extends StatelessWidget {
  const PlotorisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plotoris',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainShell(),
      },
    );
  }
}

/// Splash screen that checks for existing auth session.
///
/// Shows a brief branded loading state, then navigates to
/// either the home screen (if logged in) or login screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Give the splash a moment to display
    await Future.delayed(const Duration(milliseconds: 1500));

    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
        isLoggedIn ? '/home' : '/login',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.surfaceGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusXl),
                      boxShadow: AppTheme.accentGlow,
                    ),
                    child: const Center(
                      child: Text(
                        'P',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  Text('Plotoris', style: AppTheme.headingLarge),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'AI-Powered Planning',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
