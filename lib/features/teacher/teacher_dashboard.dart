import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import '../../models/course_model.dart';
import '../../widgets/loading_indicator.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentProfile;
    if (user?.role.name != 'teacher') {
      return const Scaffold(body: Center(child: Text('Доступ запрещён')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Панель преподавателя')),
      body: FutureBuilder<List<Course>>(
        future: context.read<CourseService>().getAvailableCourses().first,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingIndicator();
          final courses = snapshot.data!;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(courses[i].title),
              subtitle: Text(courses[i].description),
              trailing: const Icon(Icons.edit),
              onTap: () {
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}