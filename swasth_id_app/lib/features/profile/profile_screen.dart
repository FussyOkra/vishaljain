import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swasth_id_app/core/constants/app_colors.dart';
import 'package:swasth_id_app/features/auth/login_screen.dart';
import 'package:swasth_id_app/widgets/glass_container.dart';
import 'package:swasth_id_app/widgets/gradient_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
       Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 120),
        child: Column(
          children: [
            // Profile Header
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryColor,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Swasth User',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                Text(
                  '+91 9876543210',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "HID-123456",
                    style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Settings Sections
            GlassContainer(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  _buildSectionHeader("Account"),
                  _buildListTile(Icons.person_outline, "Personal Details", onTap: () {}),
                  _buildListTile(Icons.health_and_safety_outlined, "Health ID Card", onTap: () {}),
                  Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                  _buildSectionHeader("App Settings"),
                  _buildListTile(Icons.notifications_outlined, "Notifications", onTap: () {}),
                  _buildListTile(Icons.language, "Language", onTap: () {}),
                  Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                  _buildSectionHeader("Support"),
                  _buildListTile(Icons.help_outline, "Help & Center", onTap: () {}),
                  _buildListTile(Icons.logout, "Logout", onTap: () => _logout(context), isDestructive: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Version 1.0.0",
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, {required VoidCallback onTap, bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
