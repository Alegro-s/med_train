import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/course_service.dart';
import '../../services/auth_service.dart';
import '../../services/enrollment_service.dart';
import '../../models/course_model.dart';
import '../../core/constants/colors.dart';
import '../../widgets/loading_indicator.dart';

class AvailableCoursesScreen extends StatelessWidget {
  const AvailableCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courseService = context.read<CourseService>();
    final enrollService = context.read<EnrollmentService>();
    final userId = context.read<AuthService>().currentUser?.id ?? '';

    if (userId.isEmpty) {
      return const Scaffold(body: Center(child: Text('Пользователь не авторизован')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Доступные курсы'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Course>>(
        future: courseService.getAvailableCourses().first,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator();
          }
          final courses = snapshot.data!;
          if (courses.isEmpty) {
            return const Center(child: Text('Нет доступных курсов'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (_, i) {
              final course = courses[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(course.description ?? ''),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${course.durationHours} ч', style: const TextStyle(color: AppColors.textSecondary)),
                          const Spacer(),
                          FutureBuilder<bool>(
                            future: enrollService.isEnrolled(userId, course.id),
                            builder: (context, snap) {
                              if (snap.connectionState == ConnectionState.waiting) {
                                return const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              }
                              if (snap.data == true) {
                                return const Text('Вы записаны', style: TextStyle(color: AppColors.success));
                              }
                              return ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await enrollService.enroll(userId, course.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Вы записаны на курс'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                      context.go('/home');
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Ошибка: $e'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(120, 36),
                                ),
                                child: const Text('Записаться'),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 1),
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