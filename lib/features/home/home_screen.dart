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
  late final NotificationService _notifService;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _courseService = context.read<CourseService>();
    _enrollmentService = context.read<EnrollmentService>();
    _accredService = context.read<AccreditationService>();
    _notifService = context.read<NotificationService>();
    _loadUnreadCount();
  }

  void _loadUnreadCount() {
    final userId = context.read<AuthService>().currentUser?.id;
    if (userId == null) return;
    _notifService.getNotifications(userId).listen((list) {
      if (mounted) {
        setState(() {
          _unreadCount = list.where((n) => !n.isRead).length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentProfile;
    final userId = auth.currentUser?.id;
    return Scaffold(
      appBar: AppBar(
        title: Text('Здравствуйте, ${user?.firstName ?? ''}'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
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
        ],
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Мои курсы', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          if (userId != null)
            StreamBuilder<List<Enrollment>>(
              stream: _enrollmentService.getUserEnrollmentsStream(userId),
              builder: (context, snapshot) {
                print('🏠 Home stream: ${snapshot.connectionState}, data: ${snapshot.data}');
                
                if (!snapshot.hasData) {
                  return const LoadingIndicator();
                }
                
                final enrollments = snapshot.data!;
                
                if (enrollments.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Вы ещё не записаны на курсы'),
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
                          if (!snap.hasData) return const SizedBox();
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Аккредитация', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          if (userId != null)
            FutureBuilder<Accreditation?>(
              future: _accredService.getCurrentAccreditation(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return AccreditationCard(
                    accreditation: snapshot.data!,
                    onTap: () => context.push('/accreditation'),
                  );
                }
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Нет данных об аккредитации'),
                );
              },
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 0),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, int currentIndex) {
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
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Доступные'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Мои'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
      ],
    );
  }
}