import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/accreditation_service.dart';
import '../../core/constants/colors.dart';
import 'accreditation_management_screen.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  Map<String, int> _stats = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await context.read<AccreditationService>().getAccreditationStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentProfile;
    
    if (user?.role.name != 'admin') {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: AppColors.error),
              SizedBox(height: 16),
              Text(
                'Доступ запрещён',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('У вас нет прав администратора'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель администратора'),
        backgroundColor: AppColors.darkHeader,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
            tooltip: 'Обновить статистику',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.darkHeader, AppColors.background],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Здравствуйте, ${user?.fullName}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Управляйте аккредитациями, пользователями и курсами',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            if (!_isLoadingStats) ...[
              const Text(
                'Статистика аккредитаций',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    'Активные',
                    _stats['active']?.toString() ?? '0',
                    Icons.verified,
                    AppColors.success,
                  ),
                  _buildStatCard(
                    'На проверке',
                    _stats['pending']?.toString() ?? '0',
                    Icons.pending,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Истекают',
                    _stats['expiring']?.toString() ?? '0',
                    Icons.warning,
                    AppColors.warning,
                  ),
                  _buildStatCard(
                    'Просрочены',
                    _stats['expired']?.toString() ?? '0',
                    Icons.error,
                    AppColors.error,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            
            const Text(
              'Управление',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildMenuItem(
              icon: Icons.verified,
              title: 'Аккредитации',
              subtitle: 'Проверка документов и отслеживание сроков',
              color: Colors.green,
              badge: _stats['pending'] ?? 0,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccreditationManagementScreen(),
                ),
              ),
            ),
            
            const Divider(height: 24),
            
            _buildMenuItem(
              icon: Icons.people,
              title: 'Пользователи',
              subtitle: 'Управление сотрудниками и их ролями',
              color: Colors.blue,
              onTap: () {
                // Навигация к управлению пользователями
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Раздел в разработке'),
                  ),
                );
              },
            ),
            
            const Divider(height: 24),
            
            _buildMenuItem(
              icon: Icons.book,
              title: 'Курсы',
              subtitle: 'Управление учебными материалами',
              color: Colors.purple,
              onTap: () {
                // Навигация к управлению курсами
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Раздел в разработке'),
                  ),
                );
              },
            ),
            
            const Divider(height: 24),
            
            _buildMenuItem(
              icon: Icons.bar_chart,
              title: 'Отчёты',
              subtitle: 'Статистика и аналитика',
              color: Colors.orange,
              onTap: () {
                // Навигация к отчётам
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Раздел в разработке'),
                  ),
                );
              },
            ),
            
            const Divider(height: 24),
            
            _buildMenuItem(
              icon: Icons.settings,
              title: 'Настройки системы',
              subtitle: 'Общие настройки платформы',
              color: Colors.grey,
              onTap: () {
                // Навигация к настройкам
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Раздел в разработке'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    int badge = 0,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (badge > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}