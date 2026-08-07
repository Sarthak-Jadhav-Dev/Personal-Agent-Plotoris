import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'hooks_screen.dart';

/// Main shell that hosts the bottom navigation bar and switches
/// between the Dashboard (Home) and Hooks screens.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HooksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.background,
          border: Border(
            top: BorderSide(
              color: AppTheme.border.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: AppTheme.background,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.accent,
            unselectedItemColor: AppTheme.textTertiary,
            selectedLabelStyle: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1.6,
            ),
            unselectedLabelStyle: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.6,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(
                    _currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
                    size: 24,
                  ),
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(
                    _currentIndex == 1 ? Icons.webhook_rounded : Icons.webhook_outlined,
                    size: 24,
                  ),
                ),
                label: 'Hooks',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
