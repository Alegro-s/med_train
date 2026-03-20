// lib/services/notification_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final DarwinInitializationSettings initializationSettingsDarwin =
        const DarwinInitializationSettings();
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    
    await _localNotifications.initialize(settings: initializationSettings);
  }

  Stream<List<UserNotification>> getNotifications(String userId) {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((events) => events.map((e) => UserNotification.fromJson(e)).toList());
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('Ошибка отметки уведомления: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      print('Ошибка отметки всех уведомлений: $e');
    }
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type ?? 'info',
        'data': data,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      await showLocalNotification(title, message);
    } catch (e) {
      print('Ошибка создания уведомления: $e');
    }
  }

  Future<void> createBulkNotifications({
    required List<String> userIds,
    required String title,
    required String message,
    String? type,
  }) async {
    try {
      final notifications = userIds.map((userId) => {
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type ?? 'info',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      }).toList();
      
      await _supabase.from('notifications').insert(notifications);
    } catch (e) {
      print('Ошибка создания массовых уведомлений: $e');
    }
  }

  Future<void> sendAccreditationReminder({
    required String userId,
    required String accreditationId,
    required int daysLeft,
  }) async {
    String title;
    String message;
    
    if (daysLeft < 0) {
      title = 'Аккредитация просрочена';
      message = 'Срок вашей аккредитации истёк. Пожалуйста, обновите документы.';
    } else if (daysLeft == 0) {
      title = 'Аккредитация истекает сегодня';
      message = 'Срок вашей аккредитации истекает сегодня. Срочно примите меры.';
    } else {
      title = 'Напоминание об аккредитации';
      message = 'Срок вашей аккредитации истекает через $daysLeft дней. Пожалуйста, позаботьтесь о продлении.';
    }
    
    await createNotification(
      userId: userId,
      title: title,
      message: message,
      type: 'accreditation_reminder',
      data: {'accreditation_id': accreditationId, 'days_left': daysLeft},
    );
  }

  Future<void> sendDocumentVerificationNotification({
    required String userId,
    required String accreditationId,
    required bool isApproved,
    String? rejectionReason,
  }) async {
    if (isApproved) {
      await createNotification(
        userId: userId,
        title: 'Документ подтверждён',
        message: 'Ваш документ об аккредитации успешно проверен и подтверждён.',
        type: 'document_verified',
        data: {'accreditation_id': accreditationId},
      );
    } else {
      await createNotification(
        userId: userId,
        title: 'Документ отклонён',
        message: rejectionReason != null
            ? 'Ваш документ отклонён. Причина: $rejectionReason'
            : 'Ваш документ отклонён. Пожалуйста, загрузите корректный документ.',
        type: 'document_rejected',
        data: {'accreditation_id': accreditationId, 'reason': rejectionReason},
      );
    }
  }

  Future<void> showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'accreditation_channel',
          'Аккредитация',
          channelDescription: 'Уведомления об аккредитации',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );
    
    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails();
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );
    
    await _localNotifications.show(
      id: 0,
      title:title,
      body:body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      print('Ошибка удаления уведомления: $e');
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);
      
      return (response as List).length;
    } catch (e) {
      print('Ошибка получения количества уведомлений: $e');
      return 0;
    }
  }

  Future<void> sendSystemNotification({
    required String title,
    required String message,
    List<String>? roles,
  }) async {
    try {
      List<Map<String, dynamic>> response;
      
      if (roles != null && roles.isNotEmpty) {
        response = await _supabase
            .from('profiles')
            .select('id')
            .inFilter('role', roles);
      } else {
        response = await _supabase
            .from('profiles')
            .select('id');
      }
      
      final userIds = response.map((u) => u['id'] as String).toList();
      
      if (userIds.isNotEmpty) {
        await createBulkNotifications(
          userIds: userIds,
          title: title,
          message: message,
          type: 'system',
        );
      }
    } catch (e) {
      print('Ошибка отправки системного уведомления: $e');
    }
  }
}