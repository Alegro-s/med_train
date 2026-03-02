import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/test_model.dart';
import '../models/test_question_model.dart';
import '../models/test_answer_model.dart';
import '../models/test_result_model.dart';

class TestService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Test?> getTestForModule(String moduleId) async {
    try {
      final response = await _supabase
          .from('tests')
          .select()
          .eq('module_id', moduleId)
          .maybeSingle();
      return response != null ? Test.fromJson(response) : null;
    } catch (e) {
      print('Error getting test for module: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionsWithAnswers(String testId) async {
    try {
      final response = await _supabase
          .from('test_questions')
          .select('*, test_answers(*)')
          .eq('test_id', testId)
          .order('order_index');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting questions: $e');
      return [];
    }
  }

  Future<void> saveTestResult(TestResult result) async {
    try {
      await _supabase.from('test_results').insert(result.toJson());
    } catch (e) {
      print('Error saving test result: $e');
    }
  }
}