import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

/// Home screen — placeholder landing page after successful login.
///
/// Shows user greeting, basic navigation, and logout functionality.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _loadUserData();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userData = await _authService.getUserData();
    if (mounted) {
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
      _entranceController.forward();
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text('Sign Out', style: AppTheme.headingSmall),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTheme.buttonText.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.accent.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
            child: Text(
              'Sign Out',
              style: AppTheme.buttonText.copyWith(color: AppTheme.accent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.surfaceGradient),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accent,
                    strokeWidth: 2.5,
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: CustomScrollView(
                    slivers: [
                      // ── App Bar ────────────────────────────
                      SliverAppBar(
                        floating: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        title: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: AppTheme.accentGradient,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSm),
                              ),
                              child: const Center(
                                child: Text(
                                  'P',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('Plotoris', style: AppTheme.headingSmall),
                          ],
                        ),
                        actions: [
                          // User avatar
                          GestureDetector(
                            onTap: _handleLogout,
                            child: Container(
                              margin: const EdgeInsets.only(right: 16),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceElevated,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.border,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  (_userData?['fullname'] as String?)
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      'U',
                                  style: AppTheme.buttonText.copyWith(
                                    color: AppTheme.accent,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── Content ────────────────────────────
                      SliverPadding(
                        padding: const EdgeInsets.all(AppTheme.spacingLg),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Greeting
                            Text(
                              '${_getGreeting()},',
                              style: AppTheme.bodyMedium.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userData?['fullname'] ?? 'User',
                              style: AppTheme.headingLarge,
                            ),
                            const SizedBox(height: AppTheme.spacingXl),

                            // Quick actions card
                            _buildQuickActionsCard(),

                            const SizedBox(height: AppTheme.spacingMd),

                            // Status card
                            _buildStatusCard(),

                            const SizedBox(height: AppTheme.spacingXl),

                            // Recent activity header
                            Text('Recent Activity',
                                style: AppTheme.headingSmall),
                            const SizedBox(height: AppTheme.spacingMd),

                            // Empty state
                            _buildEmptyState(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          _buildActionTile(
            icon: Icons.auto_awesome_rounded,
            label: 'AI Plan',
            color: AppTheme.accent,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          _buildActionTile(
            icon: Icons.email_rounded,
            label: 'Mails',
            color: const Color(0xFF60A5FA),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          _buildActionTile(
            icon: Icons.schedule_rounded,
            label: 'Schedule',
            color: const Color(0xFF34D399),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          _buildActionTile(
            icon: Icons.settings_rounded,
            label: 'Settings',
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accent.withValues(alpha: 0.15),
            AppTheme.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All systems operational',
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Connected to ${_userData?['email'] ?? 'your account'}',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacing2xl,
        horizontal: AppTheme.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            color: AppTheme.textTertiary,
            size: 48,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'No recent activity',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Your scheduled tasks and AI analysis will appear here',
            style: AppTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
