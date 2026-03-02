import 'package:flutter/material.dart';
import 'package:med_train/core/utils/date_formatter.dart';
import 'package:provider/provider.dart';
import '../../services/accreditation_service.dart';
import '../../services/auth_service.dart';
import '../../models/accreditation_model.dart';
import '../../widgets/accreditation_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../core/constants/colors.dart';

class AccreditationScreen extends StatelessWidget {
  const AccreditationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().currentUser?.id;
    if (userId == null) return const Scaffold(body: Center(child: Text('Ошибка')));

    final service = context.read<AccreditationService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Аккредитация')),
      body: FutureBuilder<List<Accreditation>>(
        future: service.getUserAccreditations(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          final accreditations = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (accreditations.isNotEmpty) ...[
                const Text('Текущая аккредитация', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                AccreditationCard(
                  accreditation: accreditations.first,
                  onTap: () => _showDetails(context, accreditations.first),
                ),
                const SizedBox(height: 24),
                const Text('Предыдущие сертификаты', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                ...accreditations.skip(1).map((a) => ListTile(
                  leading: const Icon(Icons.card_membership),
                  title: Text('№${a.registrationNumber}'),
                  subtitle: Text('до ${DateFormatter.format(a.expiryDate)}'),
                  onTap: () => _showDetails(context, a),
                )),
              ] else
                const Center(child: Text('Нет данных об аккредитации')),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
        },
        icon: const Icon(Icons.add),
        label: const Text('Добавить новый'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showDetails(BuildContext context, Accreditation acc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Детали аккредитации'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Тип: ${acc.type}'),
            Text('Номер: ${acc.registrationNumber}'),
            Text('Дата выдачи: ${DateFormatter.format(acc.issueDate)}'),
            Text('Действует до: ${DateFormatter.format(acc.expiryDate)}'),
            if (acc.fileUrl != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('Скачать документ'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть')),
        ],
      ),
    );
  }
}