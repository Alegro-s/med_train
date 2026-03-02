import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/enrollment_model.dart';

class EnrollmentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> isEnrolled(String userId, String courseId) async {
    final response = await _supabase
        .from('enrollments')
        .select()
        .eq('user_id', userId)
        .eq('course_id', courseId)
        .maybeSingle();
    return response != null;
  }

  Future<void> enroll(String userId, String courseId) async {
    await _supabase.from('enrollments').insert({
      'user_id': userId,
      'course_id': courseId,
      'status': 'in_progress',
      'progress_percent': 0,
    });
  }

  Future<List<Enrollment>> getUserEnrollments(String userId) async {
    final response = await _supabase
        .from('enrollments')
        .select()
        .eq('user_id', userId);
    return (response as List).map((e) => Enrollment.fromJson(e)).toList();
  }

  Stream<List<Enrollment>> getUserEnrollmentsStream(String userId) {
    return _supabase
        .from('enrollments')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((events) => events.map((e) => Enrollment.fromJson(e)).toList());
  }
}