import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/module_model.dart';
import '../models/material_model.dart';

class ModuleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CourseModule>> getModulesForCourse(String courseId) async {
    final response = await _supabase
        .from('course_modules')
        .select()
        .eq('course_id', courseId)
        .order('order_index');
    return (response as List).map((e) => CourseModule.fromJson(e)).toList();
  }

  Future<List<Material>> getMaterialsForModule(String moduleId) async {
    final response = await _supabase
        .from('materials')
        .select()
        .eq('module_id', moduleId)
        .order('order_index');
    return (response as List).map((e) => Material.fromJson(e)).toList();
  }
  Future<CourseModule?> getModule(String moduleId) async {
    try {
      final response = await _supabase
          .from('course_modules')
          .select()
          .eq('id', moduleId)
          .maybeSingle();
      return response != null ? CourseModule.fromJson(response) : null;
    } catch (e) {
      print('❌ Ошибка получения модуля: $e');
      return null;
    }
  }
}