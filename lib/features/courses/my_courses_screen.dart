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
  final Map<String, Course?> _courseCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _enrollService = context.read<EnrollmentService>();
    _courseService = context.read<CourseService>();
  }

  Future<void> _loadCourse(String courseId) async {
    if (!_courseCache.containsKey(courseId)) {
      final course = await _courseService.getCourseById(courseId);
      if (mounted) {
        setState(() {
          _courseCache[courseId] = course;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().currentUser?.id;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Пользователь не авторизован')),
      );
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
        stream: _enrollService.getUserEnrollmentsStream(userId),
        builder: (context, snapshot) {
          print('📊 Stream state: ${snapshot.connectionState}');
          print('📊 Has data: ${snapshot.hasData}');
          print('📊 Data: ${snapshot.data}');
          print('📊 Error: ${snapshot.error}');
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Ошибка: ${snapshot.error}'),
                ],
              ),
            );
          }

          final enrollments = snapshot.data ?? [];
          
          if (enrollments.isEmpty) {
            return const Center(
              child: Text('Вы ещё не записаны на курсы'),
            );
          }

          // Загружаем курсы
          for (var e in enrollments) {
            _loadCourse(e.courseId);
          }

          final inProgress = enrollments.where((e) => e.status == EnrollmentStatus.inProgress).toList();
          final completed = enrollments.where((e) => e.status == EnrollmentStatus.completed).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(inProgress, 'В процессе'),
              _buildList(completed, 'Завершено'),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 2),
    );
  }

  Widget _buildList(List<Enrollment> enrollments, String emptyMessage) {
    if (enrollments.isEmpty) {
      return Center(child: Text('Нет курсов'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: enrollments.length,
      itemBuilder: (_, i) {
        final e = enrollments[i];
        final course = _courseCache[e.courseId];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              course?.title ?? 'Загрузка...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: e.progressPercent / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text('${e.progressPercent}% завершено'),
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