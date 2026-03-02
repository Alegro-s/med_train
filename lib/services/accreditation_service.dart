import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/accreditation_model.dart';

class AccreditationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Accreditation>> getUserAccreditations(String userId) async {
    final response = await _supabase
        .from('accreditations')
        .select()
        .eq('user_id', userId)
        .order('issue_date', ascending: false);
    return (response as List).map((e) => Accreditation.fromJson(e)).toList();
  }

  Future<Accreditation?> getCurrentAccreditation(String userId) async {
    final response = await _supabase
        .from('accreditations')
        .select()
        .eq('user_id', userId)
        .eq('status', 'active')
        .maybeSingle();
    return response != null ? Accreditation.fromJson(response) : null;
  }

  Future<void> addAccreditation(Map<String, dynamic> data) async {
    await _supabase.from('accreditations').insert(data);
  }
}