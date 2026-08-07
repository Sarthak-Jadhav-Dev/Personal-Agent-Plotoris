import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A glossy, gradient banner showing the user's name and greeting.
///
/// Inspired by hero banners on e-commerce platforms — features a
/// glass-like shimmer effect, gradient overlay, and subtle shadow.
class GlossyBanner extends StatelessWidget {
  final String userName;
  final String? email;
  final String greeting;
  final VoidCallback? onProfileTap;

  const GlossyBanner({
    super.key,
    required this.userName,
    this.email,
    required this.greeting,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Stack(
          children: [
            // Base gradient
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4A3728),
                    Color(0xFF3B2E23),
                    Color(0xFF2D2520),
                    Color(0xFF352A22),
                  ],
                  stops: [0.0, 0.35, 0.7, 1.0],
                ),
              ),
              child: const SizedBox.shrink(),
            ),

            // Glossy highlight (top-left shimmer)
            Positioned(
              top: -30,
              left: -20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accent.withValues(alpha: 0.15),
                      AppTheme.accent.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Glossy edge highlight (top border glow)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // Decorative accent circle (bottom right)
            Positioned(
              bottom: -20,
              right: -10,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.12),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Row(
                children: [
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.accent.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          userName,
                          style: AppTheme.headingMedium.copyWith(
                            fontSize: 22,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (email != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            email!,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textTertiary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Profile avatar
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.accentGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          userName.isNotEmpty
                              ? userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
}
