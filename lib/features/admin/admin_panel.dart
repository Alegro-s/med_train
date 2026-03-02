import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentProfile;
    if (user?.role.name != 'admin') {
      return const Scaffold(body: Center(child: Text('Доступ запрещён')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Администрирование')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Пользователи'),
            onTap: () {
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Курсы'),
            onTap: () {
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified),
            title: const Text('Аккредитации'),
            onTap: () {
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Отчёты'),
            onTap: () {
            },
          ),
        ],
      ),
    );
  }
}