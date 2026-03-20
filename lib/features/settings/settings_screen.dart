import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../core/constants/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final profile = auth.currentProfile;
    final isAdmin = profile?.role.name == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                profile?.firstName?[0] ?? '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(profile?.fullName ?? ''),
            subtitle: Text(profile?.organization ?? 'Не указано'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/profile'),
          ),
          const Divider(),
          
          if (isAdmin) ...[
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.admin_panel_settings, color: AppColors.primary),
              ),
              title: const Text('Админ-панель'),
              subtitle: const Text('Управление пользователями и аккредитациями'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/admin'),
            ),
            const Divider(),
          ],
          
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Тёмная тема'),
            value: _darkMode,
            onChanged: (val) {
              setState(() => _darkMode = val);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Политика конфиденциальности'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Выйти', style: TextStyle(color: AppColors.error)),
            onTap: () {
              auth.signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 3),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, int currentIndex) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final isAdmin = auth.currentProfile?.role.name == 'admin';
    
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/available');
            break;
          case 2:
            context.go('/my-courses');
            break;
          case 3:
            context.go('/settings');
            break;
          case 4:
            context.go('/admin');
            break;
        }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Главная'),
        const BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Доступные'),
        const BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'Мои'),
        const BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Настройки'),
        if (isAdmin)
          const BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Админ',
          ),
      ],
    );
  }
}