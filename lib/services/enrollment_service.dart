import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/enrollment_model.dart';

class EnrollmentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Enrollment>> getUserEnrollments(String userId) async {
    try {
      final response = await _supabase
          .from('enrollments')
          .select()
          .eq('user_id', userId)
          .order('enrolled_at', ascending: false);
      
      print('📦 Загружено записей: ${(response as List).length}');
      return (response).map((e) => Enrollment.fromJson(e)).toList();
    } catch (e) {
      print('❌ Ошибка загрузки записей: $e');
      return [];
    }
  }

  Stream<List<Enrollment>> getUserEnrollmentsStream(String userId) {
    return _supabase
        .from('enrollments')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('enrolled_at', ascending: false)
        .map((events) {
          print('🔄 Stream обновился: ${events.length} записей');
          return events.map((e) => Enrollment.fromJson(e)).toList();
        });
  }

  Future<bool> isEnrolled(String userId, String courseId) async {
    try {
      final response = await _supabase
          .from('enrollments')
          .select()
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      print('❌ Ошибка проверки записи: $e');
      return false;
    }
  }

  Future<void> enroll(String userId, String courseId) async {
    try {
      print('📝 Запись на курс: user=$userId, course=$courseId');
      
      await _supabase.from('enrollments').insert({
        'user_id': userId,
        'course_id': courseId,
        'status': 'in_progress',
        'progress_percent': 0,
        'enrolled_at': DateTime.now().toIso8601String(),
      });
      
      print('✅ Успешно записан!');
    } catch (e) {
      print('❌ Ошибка записи: $e');
      rethrow;
    }
  }

  Future<Enrollment?> getEnrollment(String userId, String courseId) async {
    try {
      final response = await _supabase
          .from('enrollments')
          .select()
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .maybeSingle();
      return response != null ? Enrollment.fromJson(response) : null;
    } catch (e) {
      print('❌ Ошибка получения записи: $e');
      return null;
    }
  }

  Future<void> updateProgress(String userId, String courseId, int progress) async {
    try {
      await _supabase
          .from('enrollments')
          .update({'progress_percent': progress})
          .eq('user_id', userId)
          .eq('course_id', courseId);
      print('✅ Прогресс обновлен: $progress%');
    } catch (e) {
      print('❌ Ошибка обновления прогресса: $e');
    }
  }
}