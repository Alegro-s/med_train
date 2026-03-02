import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/module_service.dart';
import '../../services/test_service.dart';
import '../../services/enrollment_service.dart';
import '../../services/auth_service.dart';
import '../../models/material_model.dart' as model;
import '../../widgets/loading_indicator.dart';
import '../../core/constants/colors.dart';

class ModuleScreen extends StatefulWidget {
  final String moduleId;
  const ModuleScreen({super.key, required this.moduleId});

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  late final ModuleService _moduleService;
  late final TestService _testService;
  late final EnrollmentService _enrollmentService;

  @override
  void initState() {
    super.initState();
    _moduleService = context.read<ModuleService>();
    _testService = context.read<TestService>();
    _enrollmentService = context.read<EnrollmentService>();
  }

  Future<void> _updateProgress(String courseId) async {
    final userId = context.read<AuthService>().currentUser?.id;
    if (userId == null) return;
    
    final enrollment = await _enrollmentService.getEnrollment(userId, courseId);
    if (enrollment != null) {
      int newProgress = enrollment.progressPercent + 10;
      if (newProgress > 100) newProgress = 100;
      
      await _enrollmentService.updateProgress(userId, courseId, newProgress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Модуль'),
      ),
      body: FutureBuilder<List<model.Material>>(
        future: _moduleService.getMaterialsForModule(widget.moduleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('В модуле нет материалов'));
          }
          
          final materials = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: materials.length,
            itemBuilder: (_, i) {
              final m = materials[i];
              
              IconData icon;
              Color color = AppColors.textSecondary;
              
              switch (m.type) {
                case model.MaterialType.lecture:
                  icon = Icons.description;
                  color = Colors.blue;
                  break;
                case model.MaterialType.video:
                  icon = Icons.play_circle;
                  color = Colors.red;
                  break;
                case model.MaterialType.file:
                  icon = Icons.attach_file;
                  color = Colors.orange;
                  break;
                case model.MaterialType.test:
                  icon = Icons.quiz;
                  color = Colors.green;
                  break;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.1), 
                    child: Icon(icon, color: color),
                  ),
                  title: Text(m.title),
                  subtitle: Text(_getTypeName(m.type)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    if (m.type == model.MaterialType.test) {
                      final test = await _testService.getTestForModule(widget.moduleId);
                      if (test != null) {
                        final module = await _moduleService.getModule(widget.moduleId);
                        
                        if (!mounted) return; // Проверка mounted
                        
                        final result = await Navigator.pushNamed(
                          context,
                          '/test/${test.id}/${widget.moduleId}/${module?.courseId ?? ''}',
                        );
                        
                        if (result == true && mounted) {
                          await _updateProgress(module?.courseId ?? '');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Модуль пройден! +10% прогресса')),
                            );
                          }
                        }
                      }
                    } else {
                      if (mounted) {
                        _showMaterialDialog(m);
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getTypeName(model.MaterialType type) {
    switch (type) {
      case model.MaterialType.lecture:
        return 'Лекция';
      case model.MaterialType.video:
        return 'Видео';
      case model.MaterialType.file:
        return 'Документ';
      case model.MaterialType.test:
        return 'Тест';
    }
  }

  void _showMaterialDialog(model.Material material) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(material.title),
        content: SingleChildScrollView(
          child: Text(material.content ?? 'Нет содержимого'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}