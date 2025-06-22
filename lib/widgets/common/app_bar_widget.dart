import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/user_provider.dart';

/// Reusable app bar widget with notification badge and profile avatar
class BesinovaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showNotifications;
  final bool showProfile;

  const BesinovaAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showNotifications = true,
    this.showProfile = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.deepFern.withValues(alpha: 0.95),
      elevation: 0,
      centerTitle: true,
      title: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [AppColors.tropicalLime, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: 1.2,
          ),
        ),
      ),
      actions: [
        if (showNotifications) _buildNotificationButton(context),
        if (showProfile) _buildProfileAvatar(context),
        ...?actions,
      ],
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bildirimler yakında eklenecek!'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                if (userProvider.notificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        userProvider.notificationCount >
                                AppConstants.maxNotificationCount
                            ? AppConstants.maxNotificationDisplay
                            : userProvider.notificationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          margin: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: AppColors.tropicalLime,
            radius: 20,
            child: Text(
              userProvider.avatar,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
