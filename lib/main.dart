import 'package:flutter/material.dart';
import 'package:med_train/services/accreditation_service.dart';
import 'package:med_train/services/certificate_service.dart';
import 'package:med_train/services/course_service.dart';
import 'package:med_train/services/enrollment_service.dart';
import 'package:med_train/services/module_service.dart';
import 'package:med_train/services/test_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final NotificationService notificationService = NotificationService();
  await notificationService.initLocalNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => CourseService()),
        Provider(create: (_) => ModuleService()),
        Provider(create: (_) => TestService()),
        Provider(create: (_) => EnrollmentService()),
        Provider(create: (_) => AccreditationService()),
        Provider(create: (_) => NotificationService()),
        Provider(create: (_) => CertificateService()),
      ],
      child: const MyApp(),
    ),
  );
}