import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';
import '../../models/notification_model.dart';
import '../../widgets/loading_indicator.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().currentUser?.id;
    if (userId == null) return const Scaffold(body: Center(child: Text('Ошибка')));

    final service = context.read<NotificationService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              await service.markAllAsRead(userId);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<UserNotification>>(
        stream: service.getNotifications(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingIndicator();
          final notifications = snapshot.data!;
          if (notifications.isEmpty) {
            return const Center(child: Text('Нет уведомлений'));
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (_, i) {
              final n = notifications[i];
              return ListTile(
                leading: Icon(n.isRead ? Icons.mark_email_read : Icons.markunread),
                title: Text(n.title),
                subtitle: Text(n.message),
                trailing: Text(n.createdAt.toLocal().toString().split(' ')[0]),
                onTap: () => service.markAsRead(n.id),
              );
            },
          );
        },
      ),
    );
  }
}