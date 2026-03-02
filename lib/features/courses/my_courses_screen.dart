import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/enrollment_service.dart';
import '../../services/course_service.dart';
import '../../services/auth_service.dart';
import '../../models/enrollment_model.dart';
import '../../models/course_model.dart';
import '../../core/constants/colors.dart';
import '../../widgets/loading_indicator.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final EnrollmentService _enrollService;
  late final CourseService _courseService;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _enrollService = context.read<EnrollmentService>();
    _courseService = context.read<CourseService>();
    _userId = context.read<AuthService>().currentUser?.id ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (_userId.isEmpty) {
      return const Scaffold(body: Center(child: Text('Пользователь не авторизован')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои курсы'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'В процессе'),
            Tab(text: 'Завершенные'),
          ],
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
        ),
      ),
      body: StreamBuilder<List<Enrollment>>(
        stream: _enrollService.getUserEnrollmentsStream(_userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const LoadingIndicator();
          }
          final enrollments = snapshot.data ?? [];
          if (enrollments.isEmpty) {
            return const Center(child: Text('Вы ещё не записаны на курсы'));
          }
          final inProgress = enrollments.where((e) => e.status.name == 'in_progress').toList();
          final completed = enrollments.where((e) => e.status.name == 'completed').toList();
          return FutureBuilder<Map<String, Course?>>(
            future: _loadCourses(enrollments),
            builder: (context, courseSnap) {
              if (!courseSnap.hasData) {
                return const LoadingIndicator();
              }
              final courseMap = courseSnap.data!;
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildList(inProgress, courseMap),
                  _buildList(completed, courseMap),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 2),
    );
  }

  Future<Map<String, Course?>> _loadCourses(List<Enrollment> enrollments) async {
    final Map<String, Course?> map = {};
    for (var e in enrollments) {
      map[e.courseId] = await _courseService.getCourseById(e.courseId);
    }
    return map;
  }

  Widget _buildList(List<Enrollment> enrollments, Map<String, Course?> courseMap) {
    if (enrollments.isEmpty) {
      return const Center(child: Text('Нет курсов'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: enrollments.length,
      itemBuilder: (_, i) {
        final e = enrollments[i];
        final course = courseMap[e.courseId];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(course?.title ?? 'Загрузка...'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: e.progressPercent / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text('${e.progressPercent}% • Этап ${(e.progressPercent / 10).round()}/10'),
              ],
            ),
            onTap: () => context.push('/course/${e.courseId}'),
          ),
        );
      },
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