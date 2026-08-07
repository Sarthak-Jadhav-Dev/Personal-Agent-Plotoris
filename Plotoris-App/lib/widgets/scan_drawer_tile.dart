import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/analysis_models.dart';

/// Expandable/collapsible drawer tile for a single analyzed email.
///
/// Shows:
/// - Priority color indicator (green/yellow/red dot)
/// - Summary text
/// - Category badge
/// - Expandable body with action, deadline, and details
class ScanDrawerTile extends StatefulWidget {
  final AnalyzedEmail email;
  final int index;

  const ScanDrawerTile({
    super.key,
    required this.email,
    required this.index,
  });

  @override
  State<ScanDrawerTile> createState() => _ScanDrawerTileState();
}

class _ScanDrawerTileState extends State<ScanDrawerTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  /// Maps priority (1-5) to a traffic-light color.
  Color _getPriorityColor() {
    switch (widget.email.priority) {
      case 5:
        return const Color(0xFFEF4444); // Urgent — red
      case 4:
        return const Color(0xFFF97316); // High — orange-red
      case 3:
        return const Color(0xFFEAB308); // Medium — yellow
      case 2:
        return const Color(0xFF22C55E); // Normal — green
      case 1:
        return const Color(0xFF6B7280); // Low — gray
      default:
        return const Color(0xFF22C55E);
    }
  }

  String _getPriorityLabel() {
    switch (widget.email.priority) {
      case 5:
        return 'URGENT';
      case 4:
        return 'HIGH';
      case 3:
        return 'MEDIUM';
      case 2:
        return 'NORMAL';
      case 1:
        return 'LOW';
      default:
        return 'NORMAL';
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.email.category.toLowerCase()) {
      case 'finance':
        return Icons.account_balance_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'social':
        return Icons.people_rounded;
      case 'promotions':
        return Icons.local_offer_rounded;
      case 'travel':
        return Icons.flight_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'government':
        return Icons.account_balance_rounded;
      case 'subscriptions':
        return Icons.subscriptions_rounded;
      case 'personal':
        return Icons.person_rounded;
      default:
        return Icons.mail_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: _isExpanded
            ? AppTheme.surface
            : AppTheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: _isExpanded
              ? priorityColor.withValues(alpha: 0.3)
              : AppTheme.border,
          width: _isExpanded ? 1.0 : 0.5,
        ),
        boxShadow: _isExpanded
            ? [
                BoxShadow(
                  color: priorityColor.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // ── Header (always visible) ────────────────────────
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Row(
                children: [
                  // Priority indicator dot
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: priorityColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Summary text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.email.summary,
                          style: AppTheme.bodyLarge.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: _isExpanded ? 3 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Category badge
                            _buildBadge(
                              icon: _getCategoryIcon(),
                              label: widget.email.category,
                              color: AppTheme.textTertiary,
                            ),
                            if (widget.email.actionRequired) ...[
                              const SizedBox(width: 8),
                              _buildBadge(
                                icon: Icons.bolt_rounded,
                                label: 'Action',
                                color: priorityColor,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Expand arrow
                  RotationTransition(
                    turns: _rotateAnimation,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textTertiary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded Body ──────────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                Divider(
                  color: AppTheme.border.withValues(alpha: 0.5),
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Priority row
                      _buildDetailRow(
                        icon: Icons.flag_rounded,
                        label: 'Priority',
                        value: _getPriorityLabel(),
                        valueColor: priorityColor,
                      ),

                      const SizedBox(height: 10),

                      // Category row
                      _buildDetailRow(
                        icon: _getCategoryIcon(),
                        label: 'Category',
                        value: widget.email.category[0].toUpperCase() +
                            widget.email.category.substring(1),
                      ),

                      // Deadline row
                      if (widget.email.deadlineLabel != null ||
                          widget.email.deadline != null) ...[
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          icon: Icons.event_rounded,
                          label: 'Deadline',
                          value: widget.email.deadlineLabel ??
                              widget.email.deadline ??
                              '',
                          valueColor: const Color(0xFFF97316),
                        ),
                      ],

                      // Action required
                      if (widget.email.actionRequired &&
                          widget.email.action != null) ...[
                        const SizedBox(height: 12),
                        _buildActionCard(priorityColor),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color.withValues(alpha: 0.7)),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              fontSize: 10,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textTertiary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textTertiary,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: valueColor ?? AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(Color priorityColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: priorityColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: priorityColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.bolt_rounded,
              size: 16,
              color: priorityColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Action Required',
                  style: AppTheme.bodySmall.copyWith(
                    color: priorityColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.email.action!,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
