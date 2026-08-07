import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/analysis_service.dart';
import '../models/analysis_models.dart';
import '../widgets/glossy_banner.dart';
import '../widgets/scan_drawer_tile.dart';
import '../widgets/claude_button.dart';

/// Dashboard — the main screen after login.
///
/// Features:
/// - Glossy user banner with greeting
/// - Scan trigger button
/// - AI analysis results as expandable drawer tiles
/// - Priority-coded indicators (red/yellow/green)
/// - Overall summary card
/// - Stats overview
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final AnalysisService _analysisService = AnalysisService();

  Map<String, dynamic>? _userData;
  bool _isLoadingUser = true;
  bool _isScanning = false;
  ScanResult? _scanResult;
  String? _scanError;

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
        _isLoadingUser = false;
      });
      _entranceController.forward();
    }
  }

  Future<void> _runScan() async {
    setState(() {
      _isScanning = true;
      _scanError = null;
    });

    try {
      final result = await _analysisService.analyseEmails(maxEmails: 15);
      if (mounted) {
        setState(() {
          _scanResult = result;
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _scanError = e.toString().replaceFirst('Exception: ', '');
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
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
              style:
                  AppTheme.buttonText.copyWith(color: AppTheme.textSecondary),
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
          child: _isLoadingUser
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accent,
                    strokeWidth: 2.5,
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // ── App Bar ────────────────────────────────
                      _buildAppBar(),

                      // ── Content ────────────────────────────────
                      SliverPadding(
                        padding: const EdgeInsets.only(
                          top: AppTheme.spacingMd,
                          bottom: AppTheme.spacingXl,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Glossy Banner
                            GlossyBanner(
                              userName:
                                  _userData?['fullname'] ?? 'User',
                              email: _userData?['email'],
                              greeting: _getGreeting(),
                              onProfileTap: _handleLogout,
                            ),

                            const SizedBox(height: AppTheme.spacingLg),

                            // Quick Stats (if scan exists)
                            if (_scanResult != null) ...[
                              _buildStatsRow(),
                              const SizedBox(height: AppTheme.spacingMd),
                            ],

                            // Scan Button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingMd,
                              ),
                              child: ClaudeButton.primary(
                                text: _scanResult == null
                                    ? 'Scan My Inbox'
                                    : 'Rescan Inbox',
                                isLoading: _isScanning,
                                icon: _isScanning
                                    ? null
                                    : const Icon(
                                        Icons.radar_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                onPressed:
                                    _isScanning ? null : _runScan,
                              ),
                            ),

                            const SizedBox(height: AppTheme.spacingLg),

                            // Error state
                            if (_scanError != null)
                              _buildErrorCard(),

                            // Scan results
                            if (_scanResult != null &&
                                _scanResult!.latestScan != null) ...[
                              // Overall summary
                              if (_scanResult!
                                  .latestScan!.overallSummary.isNotEmpty)
                                _buildOverallSummary(),

                              const SizedBox(height: AppTheme.spacingMd),

                              // Section header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingMd,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Email Analysis',
                                      style: AppTheme.headingSmall,
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accent
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(
                                                AppTheme.radiusFull),
                                      ),
                                      child: Text(
                                        '${_scanResult!.latestScan!.emails.length}',
                                        style:
                                            AppTheme.bodySmall.copyWith(
                                          color: AppTheme.accent,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: AppTheme.spacingSm),

                              // Email tiles
                              ..._buildEmailTiles(),

                              // Matched hooks
                              if (_scanResult!
                                  .latestScan!.matchedHooks.isNotEmpty) ...[
                                const SizedBox(
                                    height: AppTheme.spacingLg),
                                _buildMatchedHooksSection(),
                              ],

                              // Manual review
                              if (_scanResult!
                                  .latestScan!.manualReview.isNotEmpty) ...[
                                const SizedBox(
                                    height: AppTheme.spacingLg),
                                _buildManualReviewSection(),
                              ],
                            ],

                            // Empty state (no scan yet)
                            if (_scanResult == null &&
                                _scanError == null &&
                                !_isScanning)
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

  // ── App Bar ─────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.background.withValues(alpha: 0.95),
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'P',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Plotoris',
            style: AppTheme.headingSmall.copyWith(fontSize: 17),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.logout_rounded,
            color: AppTheme.textTertiary,
            size: 20,
          ),
          onPressed: _handleLogout,
          tooltip: 'Sign out',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Stats Row ───────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    final scan = _scanResult!;
    final analysis = scan.latestScan;

    final actionCount = analysis?.emails
            .where((e) => e.actionRequired)
            .length ??
        0;
    final urgentCount =
        analysis?.emails.where((e) => e.priority >= 4).length ?? 0;

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: Row(
        children: [
          _buildStatCard(
            label: 'Total',
            value: '${scan.totalEmails}',
            icon: Icons.email_rounded,
            color: const Color(0xFF60A5FA),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          _buildStatCard(
            label: 'Safe',
            value: '${scan.safeEmails}',
            icon: Icons.verified_user_rounded,
            color: const Color(0xFF22C55E),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          _buildStatCard(
            label: 'Action',
            value: '$actionCount',
            icon: Icons.bolt_rounded,
            color: const Color(0xFFF97316),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          _buildStatCard(
            label: 'Urgent',
            value: '$urgentCount',
            icon: Icons.priority_high_rounded,
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacingSm + 4,
          horizontal: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTheme.headingSmall.copyWith(
                fontSize: 18,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // ── Overall Summary ─────────────────────────────────────────────────

  Widget _buildOverallSummary() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.accent.withValues(alpha: 0.1),
              AppTheme.accent.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: AppTheme.accent.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Summary',
                    style: AppTheme.labelText.copyWith(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _scanResult!.latestScan!.overallSummary,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Email Tiles ─────────────────────────────────────────────────────

  List<Widget> _buildEmailTiles() {
    final emails = _scanResult!.latestScan!.emails;

    // Sort by priority descending so urgent ones are first
    final sorted = List<AnalyzedEmail>.from(emails)
      ..sort((a, b) => b.priority.compareTo(a.priority));

    return sorted.asMap().entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
        ),
        child: ScanDrawerTile(
          email: entry.value,
          index: entry.key,
        ),
      );
    }).toList();
  }

  // ── Matched Hooks ───────────────────────────────────────────────────

  Widget _buildMatchedHooksSection() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Matched Hooks', style: AppTheme.headingSmall),
          const SizedBox(height: AppTheme.spacingSm),
          ..._scanResult!.latestScan!.matchedHooks.map((hook) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(
                  color: AppTheme.border,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.webhook_rounded,
                    size: 16,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hook.hookName,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hook.reason,
                          style: AppTheme.bodySmall.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Manual Review ───────────────────────────────────────────────────

  Widget _buildManualReviewSection() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: const Color(0xFF3D3020),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: const Color(0xFFEAB308).withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.visibility_rounded,
                  size: 16,
                  color: Color(0xFFEAB308),
                ),
                const SizedBox(width: 8),
                Text(
                  'Manual Review Needed',
                  style: AppTheme.labelText.copyWith(
                    color: const Color(0xFFEAB308),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._scanResult!.latestScan!.manualReview.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: AppTheme.bodySmall.copyWith(
                        color: const Color(0xFFEAB308),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Error Card ──────────────────────────────────────────────────────

  Widget _buildErrorCard() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.errorSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: AppTheme.error.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppTheme.error,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _scanError!,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: Container(
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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(
                Icons.radar_rounded,
                color: AppTheme.textTertiary,
                size: 28,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'No scans yet',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              'Tap "Scan My Inbox" to analyze your emails\nwith AI-powered insights',
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
