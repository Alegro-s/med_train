import 'package:flutter/material.dart' hide Material, MaterialType;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/module_service.dart';
import '../../services/test_service.dart';
import '../../models/material_model.dart';
import '../../models/test_model.dart';
import '../../widgets/loading_indicator.dart';

class ModuleScreen extends StatefulWidget {
  final String moduleId;
  const ModuleScreen({super.key, required this.moduleId});

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  late final ModuleService _moduleService;
  late final TestService _testService;

  @override
  void initState() {
    super.initState();
    _moduleService = context.read<ModuleService>();
    _testService = context.read<TestService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Модуль')),
      body: FutureBuilder<List<Material>>(
        future: _moduleService.getMaterialsForModule(widget.moduleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          final materials = snapshot.data ?? [];
          return ListView.builder(
            itemCount: materials.length,
            itemBuilder: (_, i) {
              final m = materials[i];
              IconData icon;
              if (m.type == MaterialType.lecture) icon = Icons.description;
              else if (m.type == MaterialType.video) icon = Icons.play_circle;
              else if (m.type == MaterialType.file) icon = Icons.attach_file;
              else icon = Icons.quiz;
              return ListTile(
                leading: Icon(icon),
                title: Text(m.title),
                onTap: () async {
                  if (m.type == MaterialType.test) {
                    final test = await _testService.getTestForModule(widget.moduleId);
                    if (test != null) {
                      context.push('/test/${test.id}');
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(m.title),
                        content: Text(m.content ?? 'Нет содержимого'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
                        ],
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}