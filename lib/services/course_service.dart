import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';

class CourseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<List<Course>> getAvailableCourses() {
    return _supabase
        .from('courses')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .map((events) => events.map((e) => Course.fromJson(e)).toList());
  }

  Future<Course?> getCourseById(String id) async {
    final response = await _supabase
        .from('courses')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response != null ? Course.fromJson(response) : null;
  }
}