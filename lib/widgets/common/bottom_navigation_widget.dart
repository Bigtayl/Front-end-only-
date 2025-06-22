import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Reusable bottom navigation bar widget
class BesinovaBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  const BesinovaBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.midnightBlue,
      selectedItemColor: AppColors.tropicalLime,
      unselectedItemColor: Colors.grey[400],
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
    );
  }
}
