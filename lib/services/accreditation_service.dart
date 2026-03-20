import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/accreditation_model.dart';

class AccreditationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String bucketName = 'accreditation_docs';
  Future<List<Accreditation>> getUserAccreditations(String userId) async {
    try {
      final response = await _supabase
          .from('accreditations')
          .select()
          .eq('user_id', userId)
          .order('issue_date', ascending: false);
      
      return (response as List).map((e) => Accreditation.fromJson(e)).toList();
    } catch (e) {
      print('Ошибка получения аккредитаций пользователя: $e');
      return [];
    }
  }

  Future<Accreditation?> getCurrentAccreditation(String userId) async {
    try {
      final response = await _supabase
          .from('accreditations')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .maybeSingle();
      
      return response != null ? Accreditation.fromJson(response) : null;
    } catch (e) {
      print('Ошибка получения текущей аккредитации: $e');
      return null;
    }
  }

  Future<void> addAccreditation(Map<String, dynamic> data) async {
    try {
      await _supabase.from('accreditations').insert(data);
    } catch (e) {
      print('Ошибка добавления аккредитации: $e');
      rethrow;
    }
  }

  Future<String?> uploadAccreditationDocument({
    required String userId,
    required String accreditationId,
    required File file,
    required String documentName,
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
      
      await _supabase
          .from('accreditations')
          .update({
            'file_url': publicUrl,
            'document_name': documentName,
            'uploaded_at': DateTime.now().toIso8601String(),
            'status': 'pending',
            'is_verified': false,
          })
          .eq('id', accreditationId);
      
      return publicUrl;
    } catch (e) {
      print('Ошибка загрузки документа: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllAccreditationsWithUsers() async {
    try {
      final response = await _supabase
          .from('accreditations')
          .select('''
            *,
            profiles:user_id (
              id,
              last_name,
              first_name,
              middle_name,
              position,
              department,
              organization,
              role
            )
          ''')
          .order('expiry_date', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Ошибка получения всех аккредитаций: $e');
      return [];
    }
  }

  Future<void> verifyAccreditation(String accreditationId) async {
    try {
      await _supabase
          .from('accreditations')
          .update({
            'is_verified': true,
            'status': 'active',
          })
          .eq('id', accreditationId);
    } catch (e) {
      print('Ошибка подтверждения аккредитации: $e');
      rethrow;
    }
  }

  Future<void> rejectAccreditation(String accreditationId, {String? reason}) async {
    try {
      await _supabase
          .from('accreditations')
          .update({
            'status': 'rejected',
            'is_verified': false,
          })
          .eq('id', accreditationId);
      
      if (reason != null && reason.isNotEmpty) {
        print('Причина отклонения: $reason');
      }
    } catch (e) {
      print('Ошибка отклонения аккредитации: $e');
      rethrow;
    }
  }

  Future<void> deleteDocument(String fileName) async {
    try {
      await _supabase.storage.from(bucketName).remove([fileName]);
    } catch (e) {
      print('Ошибка удаления документа: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPendingAccreditations() async {
    try {
      final response = await _supabase
          .from('accreditations')
          .select('''
            *,
            profiles:user_id (
              last_name,
              first_name,
              middle_name,
              position,
              department
            )
          ''')
          .eq('status', 'pending')
          .order('uploaded_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Ошибка получения аккредитаций на проверке: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getExpiringAccreditations() async {
    try {
      final now = DateTime.now();
      final thirtyDaysLater = now.add(const Duration(days: 30));
      
      final response = await _supabase
          .from('accreditations')
          .select('''
            *,
            profiles:user_id (
              last_name,
              first_name,
              middle_name,
              position,
              department
            )
          ''')
          .eq('status', 'active')
          .gte('expiry_date', now.toIso8601String())
          .lte('expiry_date', thirtyDaysLater.toIso8601String())
          .order('expiry_date', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Ошибка получения истекающих аккредитаций: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getExpiredAccreditations() async {
    try {
      final now = DateTime.now();
      
      final response = await _supabase
          .from('accreditations')
          .select('''
            *,
            profiles:user_id (
              last_name,
              first_name,
              middle_name,
              position,
              department
            )
          ''')
          .eq('status', 'active')
          .lt('expiry_date', now.toIso8601String())
          .order('expiry_date', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Ошибка получения просроченных аккредитаций: $e');
      return [];
    }
  }

  Future<void> updateAccreditationStatus(String accreditationId, String status) async {
    try {
      await _supabase
          .from('accreditations')
          .update({'status': status})
          .eq('id', accreditationId);
    } catch (e) {
      print('Ошибка обновления статуса: $e');
    }
  }

  Future<Map<String, int>> getAccreditationStats() async {
    try {
      final now = DateTime.now();
      final thirtyDaysLater = now.add(const Duration(days: 30));
      
      final response = await _supabase
          .from('accreditations')
          .select('status, expiry_date');
      
      final List<dynamic> accreditations = response;
      
      int active = 0;
      int pending = 0;
      int expiring = 0;
      int expired = 0;
      
      for (var acc in accreditations) {
        final status = acc['status'] as String? ?? '';
        final expiryDateStr = acc['expiry_date'] as String?;
        
        if (status == 'pending') {
          pending++;
        } else if (status == 'active') {
          active++;
          
          if (expiryDateStr != null) {
            try {
              final expiryDate = DateTime.parse(expiryDateStr);
              if (expiryDate.isBefore(now)) {
                expired++;
                active--; 
              } else if (expiryDate.isBefore(thirtyDaysLater)) {
                expiring++;
              }
            } catch (e) {
            }
          }
        }
      }
      
      return {
        'active': active,
        'pending': pending,
        'expiring': expiring,
        'expired': expired,
      };
    } catch (e) {
      print('Ошибка получения статистики: $e');
      return {'active': 0, 'pending': 0, 'expiring': 0, 'expired': 0};
    }
  }
}