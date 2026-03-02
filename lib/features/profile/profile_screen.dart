import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/certificate_service.dart';
import '../../models/certificate_model.dart';
import '../../widgets/loading_indicator.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentProfile;
    final userId = auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                child: Text(user?.firstName?[0] ?? '?'),
              ),
            ),
            const SizedBox(height: 16),
            Text('ФИО: ${user?.fullName ?? ''}', style: const TextStyle(fontSize: 18)),
            Text('Email: ${auth.currentUser?.email ?? ''}'),
            Text('Организация: ${user?.organization ?? 'не указано'}'),
            const SizedBox(height: 24),
            const Text('Мои сертификаты', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: FutureBuilder<List<Certificate>>(
                future: context.read<CertificateService>().getUserCertificates(userId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingIndicator();
                  }
                  final certs = snapshot.data ?? [];
                  if (certs.isEmpty) {
                    return const Center(child: Text('Нет сертификатов'));
                  }
                  return ListView.builder(
                    itemCount: certs.length,
                    itemBuilder: (_, i) {
                      final c = certs[i];
                      return ListTile(
                        leading: const Icon(Icons.card_membership),
                        title: Text('Сертификат №${c.registrationNumber}'),
                        subtitle: Text('Выдан: ${c.issueDate.toLocal()}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}