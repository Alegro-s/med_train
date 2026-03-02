import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/certificate_model.dart';

class CertificateService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Certificate>> getUserCertificates(String userId) async {
    final response = await _supabase
        .from('certificates')
        .select()
        .eq('user_id', userId)
        .order('issue_date', ascending: false);
    return (response as List).map((e) => Certificate.fromJson(e)).toList();
  }

  Future<Certificate?> getCertificateForCourse(String userId, String courseId) async {
    final response = await _supabase
        .from('certificates')
        .select()
        .eq('user_id', userId)
        .eq('course_id', courseId)
        .maybeSingle();
    return response != null ? Certificate.fromJson(response) : null;
  }
}