import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/courses/available_courses_screen.dart';
import '../../features/courses/my_courses_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/courses/course_detail_screen.dart';
import '../../features/courses/module_screen.dart';
import '../../features/courses/test_screen.dart';
import '../../features/accreditation/accreditation_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/teacher/teacher_dashboard.dart';
import '../../features/admin/admin_panel.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final isLoggedIn = authService.currentUser != null;
      final isLoginRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/available', builder: (_, __) => const AvailableCoursesScreen()),
      GoRoute(path: '/my-courses', builder: (_, __) => const MyCoursesScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),

      GoRoute(
        path: '/course/:id',
        builder: (_, state) => CourseDetailScreen(
          courseId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/module/:moduleId',
        builder: (_, state) => ModuleScreen(
          moduleId: state.pathParameters['moduleId']!,
        ),
      ),
      GoRoute(
        path: '/test/:testId',
        builder: (_, state) => TestScreen(
          testId: state.pathParameters['testId']!,
        ),
      ),

      GoRoute(path: '/accreditation', builder: (_, __) => const AccreditationScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/teacher', builder: (_, __) => const TeacherDashboard()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminPanel()),
    ],
  );
}