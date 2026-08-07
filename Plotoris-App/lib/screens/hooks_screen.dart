import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/hooks_service.dart';
import '../widgets/claude_button.dart';
import '../widgets/claude_text_field.dart';

/// Hooks management screen — view, create, and delete custom hooks.
///
/// Hooks are keyword triggers that the AI uses to prioritize
/// and flag specific emails during analysis.
class HooksScreen extends StatefulWidget {
  const HooksScreen({super.key});

  @override
  State<HooksScreen> createState() => _HooksScreenState();
}

class _HooksScreenState extends State<HooksScreen>
    with SingleTickerProviderStateMixin {
  final HooksService _hooksService = HooksService();

  List<Hook> _hooks = [];
  bool _isLoading = true;
  bool _isCreating = false;
  String? _error;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _loadHooks();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _loadHooks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final hooks = await _hooksService.getHooks();
      if (mounted) {
        setState(() {
          _hooks = hooks;
          _isLoading = false;
        });
        _entranceController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
        _entranceController.forward();
      }
    }
  }

  Future<void> _deleteHook(String hookName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text('Delete Hook', style: AppTheme.headingSmall),
        content: Text(
          'Delete "$hookName"? This cannot be undone.',
          style: AppTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTheme.buttonText
                  .copyWith(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.error.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
            child: Text(
              'Delete',
              style: AppTheme.buttonText.copyWith(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final updatedHooks = await _hooksService.deleteHook(hookName);
      if (mounted) {
        setState(() => _hooks = updatedHooks);
        _showSnackbar('Hook deleted', Icons.check_circle_rounded,
            AppTheme.success);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar(
          e.toString().replaceFirst('Exception: ', ''),
          Icons.error_outline_rounded,
          AppTheme.error,
        );
      }
    }
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXl),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin:
                          const EdgeInsets.only(bottom: AppTheme.spacingLg),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                    ),
                  ),

                  // Title
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: const Icon(
                          Icons.webhook_rounded,
                          color: AppTheme.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('New Hook', style: AppTheme.headingSmall),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Text(
                    'Hooks help the AI identify and prioritize specific emails.',
                    style: AppTheme.bodySmall,
                  ),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Hook Name
                  ClaudeTextField(
                    label: 'Hook Name',
                    hint: 'e.g. Job Interview',
                    controller: nameCtrl,
                    prefixIcon: const Icon(Icons.label_rounded,
                        color: AppTheme.textTertiary, size: 18),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),

                  const SizedBox(height: AppTheme.spacingMd),

                  // Hook Value (keyword)
                  ClaudeTextField(
                    label: 'Keyword / Trigger',
                    hint: 'e.g. interview, offer letter',
                    controller: valueCtrl,
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppTheme.textTertiary, size: 18),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),

                  const SizedBox(height: AppTheme.spacingMd),

                  // Hook Description
                  ClaudeTextField(
                    label: 'Description',
                    hint: 'e.g. Flag emails about job interviews',
                    controller: descCtrl,
                    prefixIcon: const Icon(Icons.description_rounded,
                        color: AppTheme.textTertiary, size: 18),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Create button
                  ClaudeButton.primary(
                    text: 'Create Hook',
                    isLoading: _isCreating,
                    icon: _isCreating
                        ? null
                        : const Icon(Icons.add_rounded,
                            color: Colors.white, size: 20),
                    onPressed: _isCreating
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;

                            setSheetState(() => _isCreating = true);
                            setState(() => _isCreating = true);

                            try {
                              final updatedHooks =
                                  await _hooksService.createHook(
                                name: nameCtrl.text.trim(),
                                value: valueCtrl.text.trim(),
                                description: descCtrl.text.trim(),
                              );

                              if (mounted) {
                                setState(() {
                                  _hooks = updatedHooks;
                                  _isCreating = false;
                                });
                                if (ctx.mounted) {
                                  Navigator.of(ctx).pop();
                                }
                                _showSnackbar(
                                  'Hook created!',
                                  Icons.check_circle_rounded,
                                  AppTheme.success,
                                );
                              }
                            } catch (e) {
                              setSheetState(() => _isCreating = false);
                              if (mounted) {
                                setState(() => _isCreating = false);
                                _showSnackbar(
                                  e
                                      .toString()
                                      .replaceFirst('Exception: ', ''),
                                  Icons.error_outline_rounded,
                                  AppTheme.error,
                                );
                              }
                            }
                          },
                  ),

                  const SizedBox(height: AppTheme.spacingMd),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackbar(String msg, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style:
                    AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
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
        duration: const Duration(seconds: 3),
      ),
    );
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
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // ── App Bar ──────────────────────────────
                      SliverAppBar(
                        floating: true,
                        backgroundColor:
                            AppTheme.background.withValues(alpha: 0.95),
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        title: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.webhook_rounded,
                                color: AppTheme.accent,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'My Hooks',
                              style:
                                  AppTheme.headingSmall.copyWith(fontSize: 17),
                            ),
                          ],
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: AppTheme.textTertiary,
                              size: 20,
                            ),
                            onPressed: _loadHooks,
                            tooltip: 'Refresh',
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),

                      // ── Content ──────────────────────────────
                      SliverPadding(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Info card
                            _buildInfoCard(),
                            const SizedBox(height: AppTheme.spacingMd),

                            // Error
                            if (_error != null) ...[
                              _buildErrorCard(),
                              const SizedBox(height: AppTheme.spacingMd),
                            ],

                            // Hook count header
                            Row(
                              children: [
                                Text('Active Hooks',
                                    style: AppTheme.headingSmall),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusFull),
                                  ),
                                  child: Text(
                                    '${_hooks.length}',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacingSm),

                            // Hooks list or empty state
                            if (_hooks.isEmpty)
                              _buildEmptyState()
                            else
                              ..._hooks.map((hook) => _buildHookCard(hook)),

                            const SizedBox(height: 80),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
      // FAB for creating new hook
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton(
              onPressed: _showCreateDialog,
              backgroundColor: AppTheme.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accent.withValues(alpha: 0.1),
            AppTheme.accent.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppTheme.accent.withValues(alpha: 0.7),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hooks are keyword triggers that help the AI identify and prioritize your important emails during scans.',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
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
          const Icon(Icons.error_outline_rounded,
              color: AppTheme.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: AppTheme.bodyMedium
                  .copyWith(color: AppTheme.textPrimary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHookCard(Hook hook) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hook icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Icon(
                Icons.webhook_rounded,
                color: AppTheme.accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),

            // Hook details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hook.name,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Keyword badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF60A5FA).withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_rounded,
                            size: 12, color: Color(0xFF60A5FA)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            hook.value,
                            style: AppTheme.bodySmall.copyWith(
                              color: const Color(0xFF60A5FA),
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hook.description,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Delete button
            GestureDetector(
              onTap: () => _deleteHook(hook.name),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.error.withValues(alpha: 0.7),
                  size: 16,
                ),
              ),
            ),
          ],
        ),
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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              Icons.webhook_rounded,
              color: AppTheme.textTertiary,
              size: 28,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'No hooks yet',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Tap + to create your first hook.\nHooks help the AI focus on what matters to you.',
            style: AppTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
