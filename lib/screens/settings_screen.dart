import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/friends_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/user_avatar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return _buildProfileSection(context, auth);
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Appearance'),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle dark theme'),
                  secondary: Icon(
                    themeProvider.themeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: AppTheme.primaryColor,
                  ),
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Account'),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline, color: AppTheme.primaryColor),
                      title: Text(auth.isLoggedIn ? 'Signed in' : 'Not signed in'),
                      subtitle: Text(
                        auth.username ??
                            (auth.isLoggedIn
                                ? 'Offline mode - progress is local only'
                                : 'Sign in to sync your progress'),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onTap: () {
                        if (!auth.isLoggedIn) {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }
                      },
                    ),
                    if (auth.isLoggedIn)
                      ListTile(
                        leading: const Icon(Icons.logout, color: AppTheme.wrongRed),
                        title: const Text('Log out'),
                        subtitle: const Text('Stop syncing with the server'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onTap: () => _showLogoutDialog(context, auth),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Progress'),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.delete_sweep, color: AppTheme.wrongRed),
              title: const Text('Reset Progress'),
              subtitle: const Text('Delete all saved scores'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onTap: () => _showResetDialog(context),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Admin'),
          const SizedBox(height: 8),
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              if (!auth.isAdmin) return const SizedBox.shrink();
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.admin_panel_settings,
                      color: AppTheme.accentColor),
                  title: const Text('Admin Panel'),
                  subtitle: const Text('Manage users, units, stories and courses'),
                  trailing: const Icon(Icons.chevron_right),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onTap: () => Navigator.pushNamed(context, '/admin'),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'About'),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
              title: const Text('About'),
              subtitle: const Text('Learn more about this app'),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'French Vocabulary Master v1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, AuthProvider auth) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: auth.isLoggedIn ? () => _changePhoto(context, auth) : null,
              child: Stack(
                children: [
                  UserAvatar(
                    base64Photo: auth.profilePhoto,
                    username: auth.username ?? '?',
                    size: 80,
                    showOnlineIndicator: false,
                  ),
                  if (auth.isLoggedIn)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              auth.username ?? 'Guest',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (auth.profilePhoto != null && auth.isLoggedIn) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _removePhoto(context, auth),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Remove photo'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.wrongRed,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _changePhoto(BuildContext context, AuthProvider auth) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final base64Str = base64Encode(bytes);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Uploading photo...'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    await auth.updatePhoto(base64Str);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo updated'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removePhoto(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove photo?'),
        content: const Text('Your profile photo will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.removePhoto();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Photo removed'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Remove', style: TextStyle(color: AppTheme.wrongRed)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out?'),
        content: const Text('You will no longer sync your progress with the server.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              context.read<FriendsProvider>().reset();
              Navigator.pop(ctx);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Log out', style: TextStyle(color: AppTheme.wrongRed)),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Progress'),
        content: const Text(
          'This will delete all your saved scores. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProgressProvider>().resetProgress();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Progress has been reset'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Reset', style: TextStyle(color: AppTheme.wrongRed)),
          ),
        ],
      ),
    );
  }
}
