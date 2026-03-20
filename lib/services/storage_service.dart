import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String bucketName = 'accreditation_docs';

  Future<String?> uploadAccreditationDocument({
    required String userId,
    required String accreditationId,
    required File file,
  }) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = 'accreditations/$userId/$accreditationId.$fileExt';
      
      await _supabase.storage.from(bucketName).upload(
        fileName,
        file,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );
      
      final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('Ошибка загрузки документа: $e');
      return null;
    }
  }

  Future<void> deleteDocument(String fileName) async {
    try {
      await _supabase.storage.from(bucketName).remove([fileName]);
    } catch (e) {
      print('Ошибка удаления документа: $e');
    }
  }
}