import 'package:flutter/material.dart';
import 'package:med_train/core/utils/date_formatter.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../services/accreditation_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../models/accreditation_model.dart';
import '../../widgets/accreditation_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../core/constants/colors.dart';

class AccreditationScreen extends StatefulWidget {
  const AccreditationScreen({super.key});

  @override
  State<AccreditationScreen> createState() => _AccreditationScreenState();
}

class _AccreditationScreenState extends State<AccreditationScreen> {
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().currentUser?.id;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Ошибка авторизации')),
      );
    }

    final service = context.read<AccreditationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Аккредитация'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => _showUploadDialog(context, service, userId),
            tooltip: 'Загрузить документ',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: FutureBuilder<List<Accreditation>>(
        future: service.getUserAccreditations(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          final accreditations = snapshot.data ?? [];

          if (accreditations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_outlined,
                    size: 80,
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Нет данных об аккредитации',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Загрузите документы для начала процесса аккредитации',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showUploadDialog(context, service, userId),
                    icon: const Icon(Icons.upload),
                    label: const Text('Загрузить документ'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          final currentAccreditation = accreditations.firstWhere(
            (a) => a.status == AccreditationStatus.active || a.status == AccreditationStatus.pending,
            orElse: () => accreditations.first,
          );
          
          final previousAccreditations = accreditations
              .where((a) => a.id != currentAccreditation.id)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _getStatusColor(currentAccreditation.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(currentAccreditation.status),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(currentAccreditation.status),
                          color: _getStatusColor(currentAccreditation.status),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getStatusText(currentAccreditation.status),
                          style: TextStyle(
                            color: _getStatusColor(currentAccreditation.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (currentAccreditation.status == AccreditationStatus.pending) ...[
                      const Text(
                        'Ваш документ находится на проверке. Обычно это занимает 1-2 рабочих дня.',
                        style: TextStyle(fontSize: 14),
                      ),
                      if (currentAccreditation.uploadedAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Загружен: ${DateFormatter.formatWithTime(currentAccreditation.uploadedAt!)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ] else if (currentAccreditation.status == AccreditationStatus.active) ...[
                      const Text(
                        'Ваша аккредитация активна',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _calculateProgress(currentAccreditation),
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          currentAccreditation.isExpiring 
                              ? AppColors.warning 
                              : AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentAccreditation.isExpiring
                            ? 'Истекает через ${currentAccreditation.daysLeft} дней'
                            : 'Действует до ${DateFormatter.format(currentAccreditation.expiryDate)}',
                        style: TextStyle(
                          color: currentAccreditation.isExpiring 
                              ? AppColors.warning 
                              : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Text(
                'Текущая аккредитация',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              AccreditationCard(
                accreditation: currentAccreditation,
                onTap: () => _showDetails(context, currentAccreditation, service),
              ),

              if (previousAccreditations.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Предыдущие сертификаты',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ...previousAccreditations.map((a) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.card_membership, color: AppColors.primary),
                    ),
                    title: Text('№${a.registrationNumber}'),
                    subtitle: Text('до ${DateFormatter.format(a.expiryDate)}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showDetails(context, a, service),
                  ),
                )),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadDialog(context, service, userId),
        icon: const Icon(Icons.add),
        label: const Text('Добавить новый'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showUploadDialog(BuildContext context, AccreditationService service, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Загрузить документ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Поддерживаемые форматы: PDF, JPG, PNG',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              
              if (_selectedFile == null) ...[
                OutlinedButton.icon(
                  onPressed: _isUploading ? null : _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Выбрать файл'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fileName!,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Файл выбран',
                              style: TextStyle(color: AppColors.success, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedFile = null;
                            _fileName = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                onPressed: (_selectedFile == null || _isUploading) 
                    ? null 
                    : () async {
                        setState(() => _isUploading = true);
                        
                        final newAccreditationId = DateTime.now().millisecondsSinceEpoch.toString();
                        
                        final url = await service.uploadAccreditationDocument(
                          userId: userId,
                          accreditationId: newAccreditationId,
                          file: _selectedFile!,
                          documentName: _fileName!,
                        );
                        
                        setState(() => _isUploading = false);
                        
                        if (url != null && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Документ успешно загружен и отправлен на проверку'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          setState(() {});
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ошибка загрузки документа'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload),
                label: Text(_isUploading ? 'Загрузка...' : 'Загрузить'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  void _showDetails(BuildContext context, Accreditation acc, AccreditationService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getStatusIcon(acc.status),
              color: _getStatusColor(acc.status),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Детали аккредитации',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Статус:', _getStatusText(acc.status)),
              _buildDetailRow('Тип:', acc.type),
              _buildDetailRow('Номер:', acc.registrationNumber),
              _buildDetailRow('Дата выдачи:', DateFormatter.format(acc.issueDate)),
              _buildDetailRow('Действует до:', DateFormatter.format(acc.expiryDate)),
              _buildDetailRow('Осталось дней:', '${acc.daysLeft}'),
              
              if (acc.uploadedAt != null) ...[
                const Divider(),
                _buildDetailRow('Документ загружен:', DateFormatter.formatWithTime(acc.uploadedAt!)),
                _buildDetailRow('Статус проверки:', acc.isVerified ? 'Подтверждён' : 'Ожидает'),
              ],
              
              if (acc.fileUrl != null) ...[
                const Divider(),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                  },
                  icon: const Icon(Icons.download),
                  label: Text(acc.documentName ?? 'Скачать документ'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (acc.status == AccreditationStatus.pending && !acc.isVerified) ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showUploadDialog(context, service, acc.userId);
              },
              child: const Text('Загрузить новый'),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AccreditationStatus status) {
    switch (status) {
      case AccreditationStatus.active:
        return AppColors.success;
      case AccreditationStatus.expired:
        return AppColors.error;
      case AccreditationStatus.pending:
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(AccreditationStatus status) {
    switch (status) {
      case AccreditationStatus.active:
        return Icons.verified;
      case AccreditationStatus.expired:
        return Icons.error;
      case AccreditationStatus.pending:
        return Icons.pending;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(AccreditationStatus status) {
    switch (status) {
      case AccreditationStatus.active:
        return 'Активна';
      case AccreditationStatus.expired:
        return 'Просрочена';
      case AccreditationStatus.pending:
        return 'На проверке';
      default:
        return 'Неизвестно';
    }
  }

  double _calculateProgress(Accreditation acc) {
    final total = acc.expiryDate.difference(acc.issueDate).inDays;
    final passed = DateTime.now().difference(acc.issueDate).inDays;
    return (passed / total).clamp(0.0, 1.0);
  }
}