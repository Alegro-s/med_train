import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import '../../services/enrollment_service.dart';
import '../../services/accreditation_service.dart';
import '../../services/notification_service.dart';
import '../../models/course_model.dart';
import '../../models/enrollment_model.dart';
import '../../models/accreditation_model.dart';
import '../../widgets/course_card.dart';
import '../../widgets/accreditation_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../core/constants/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CourseService _courseService;
  late final EnrollmentService _enrollmentService;
  late final AccreditationService _accredService;
  late final NotificationService _notifyService;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _courseService = context.read<CourseService>();
    _enrollmentService = context.read<EnrollmentService>();
    _accredService = context.read<AccreditationService>();
    _notifyService = context.read<NotificationService>();
    _loadUnreadCount();
  }

  void _loadUnreadCount() {
    final userId = context.read<AuthService>().currentUser?.id;
    if (userId == null) return;
    
    _notifyService.getUnreadCount(userId).then((count) {
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentProfile;
    final userId = auth.currentUser?.id;
    final isAdmin = user?.role.name == 'admin';
    
    print('HomeScreen: user=${user?.fullName}, role=${user?.role.name}, isAdmin=$isAdmin');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Здравствуйте, ${user?.firstName ?? ''}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => context.push('/admin'),
              tooltip: 'Админ-панель',
            ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
                tooltip: 'Уведомления',
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
            tooltip: 'Профиль',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          _loadUnreadCount();
        },
        child: ListView(
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Мои курсы',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (userId != null)
              StreamBuilder<List<Enrollment>>(
                stream: _enrollmentService.getUserEnrollmentsStream(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: LoadingIndicator(),
                    );
                  }
                  
                  final enrollments = snapshot.data ?? [];
                  if (enrollments.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 48,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Вы ещё не записаны на курсы',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => context.push('/available'),
                            child: const Text('Посмотреть доступные курсы'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: enrollments.length,
                      itemBuilder: (_, i) {
                        final e = enrollments[i];
                        return FutureBuilder<Course?>(
                          future: _courseService.getCourseById(e.courseId),
                          builder: (_, snap) {
                            if (!snap.hasData) {
                              return const SizedBox(
                                width: 280,
                                child: Card(
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: SizedBox(
                                width: 280,
                                child: CourseCard(
                                  course: snap.data!,
                                  onTap: () => context.push('/course/${e.courseId}'),
                                  progress: e.progressPercent / 100,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Аккредитация',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (userId != null)
              FutureBuilder<Accreditation?>(
                future: _accredService.getCurrentAccreditation(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: LoadingIndicator(),
                    );
                  }
                  
                  if (snapshot.hasData && snapshot.data != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AccreditationCard(
                        accreditation: snapshot.data!,
                        onTap: () => context.push('/accreditation'),
                      ),
                    );
                  }
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Нет данных об аккредитации',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Загрузите документы для начала процесса',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.upload_file),
                          onPressed: () => context.push('/accreditation'),
                          tooltip: 'Загрузить документ',
                        ),
                      ],
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Быстрый доступ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildQuickAccessCard(
                    icon: Icons.menu_book_outlined,
                    title: 'Доступные курсы',
                    color: Colors.blue,
                    onTap: () => context.push('/available'),
                  ),
                  _buildQuickAccessCard(
                    icon: Icons.school_outlined,
                    title: 'Мои курсы',
                    color: Colors.green,
                    onTap: () => context.push('/my-courses'),
                  ),
                  _buildQuickAccessCard(
                    icon: Icons.verified_outlined,
                    title: 'Аккредитация',
                    color: Colors.purple,
                    onTap: () => context.push('/accreditation'),
                  ),
                  if (isAdmin)
                    _buildQuickAccessCard(
                      icon: Icons.admin_panel_settings,
                      title: 'Админ-панель',
                      color: Colors.orange,
                      onTap: () => context.push('/admin'),
                    )
                  else
                    _buildQuickAccessCard(
                      icon: Icons.person_outline,
                      title: 'Профиль',
                      color: Colors.teal,
                      onTap: () => context.push('/profile'),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 0),
    );
  }
  
  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Главная',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          label: 'Доступные',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          label: 'Мои курсы',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Настройки',
        ),
        if (isAdmin)
          const BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Админ',
          ),
      ],
    );
  }
}