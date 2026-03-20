import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/accreditation_service.dart';
import '../../services/notification_service.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/date_formatter.dart';

class AccreditationManagementScreen extends StatefulWidget {
  const AccreditationManagementScreen({super.key});

  @override
  State<AccreditationManagementScreen> createState() => 
      _AccreditationManagementScreenState();
}

class _AccreditationManagementScreenState extends State<AccreditationManagementScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all'; 
  
  @override
  Widget build(BuildContext context) {
    final accreditationService = context.read<AccreditationService>();
    final notificationService = context.read<NotificationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление аккредитациями'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Поиск по ФИО или должности...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Все', 'all'),
                      _buildFilterChip('На проверке', 'pending'),
                      _buildFilterChip('Истекает скоро', 'expiring'),
                      _buildFilterChip('Просрочено', 'expired'),
                      _buildFilterChip('Активные', 'active'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: accreditationService.getAllAccreditationsWithUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var accreditations = snapshot.data!;
          
          if (_searchQuery.isNotEmpty) {
            accreditations = accreditations.where((acc) {
              final profile = acc['profiles'] as Map<String, dynamic>;
              final fullName = '${profile['last_name']} ${profile['first_name']} ${profile['middle_name'] ?? ''}'.toLowerCase();
              final position = (profile['position'] ?? '').toLowerCase();
              final query = _searchQuery.toLowerCase();
              return fullName.contains(query) || position.contains(query);
            }).toList();
          }
          
          if (_filterStatus != 'all') {
            accreditations = accreditations.where((acc) {
              final status = acc['status'] as String;
              final daysLeft = DateTime.parse(acc['expiry_date'])
                  .difference(DateTime.now()).inDays;
                  
              switch (_filterStatus) {
                case 'pending':
                  return status == 'pending';
                case 'expiring':
                  return daysLeft < 30 && daysLeft >= 0;
                case 'expired':
                  return daysLeft < 0;
                case 'active':
                  return status == 'active' && daysLeft >= 30;
                default:
                  return true;
              }
            }).toList();
          }

          if (accreditations.isEmpty) {
            return const Center(
              child: Text('Нет данных для отображения'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accreditations.length,
            itemBuilder: (context, index) {
              final acc = accreditations[index];
              final profile = acc['profiles'] as Map<String, dynamic>;
              final expiryDate = DateTime.parse(acc['expiry_date']);
              final daysLeft = expiryDate.difference(DateTime.now()).inDays;
              final status = acc['status'] as String;
              final isPending = status == 'pending';
              final isExpiring = daysLeft < 30 && daysLeft >= 0;
              final isExpired = daysLeft < 0;

              Color statusColor = AppColors.success;
              String statusText = 'Активна';
              
              if (isPending) {
                statusColor = Colors.orange;
                statusText = 'На проверке';
              } else if (isExpired) {
                statusColor = AppColors.error;
                statusText = 'Просрочена';
              } else if (isExpiring) {
                statusColor = AppColors.warning;
                statusText = 'Истекает через $daysLeft дн.';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(
                      isPending ? Icons.pending : 
                      isExpired ? Icons.error : 
                      isExpiring ? Icons.warning : Icons.verified,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${profile['last_name']} ${profile['first_name']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile['position'] ?? 'Должность не указана'),
                      if (profile['department'] != null)
                        Text(profile['department']),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Тип', acc['type']),
                          _buildInfoRow('Номер', acc['registration_number']),
                          _buildInfoRow('Дата выдачи', 
                              DateFormatter.format(DateTime.parse(acc['issue_date']))),
                          _buildInfoRow('Действует до', 
                              DateFormatter.format(expiryDate)),
                          
                          if (acc['file_url'] != null) ...[
                            const Divider(),
                            const Text(
                              'Документ:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    acc['document_name'] ?? 'Документ',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.download),
                                  onPressed: () {
                                  },
                                ),
                                if (isPending) ...[
                                  IconButton(
                                    icon: const Icon(Icons.check, color: AppColors.success),
                                    onPressed: () async {
                                      await accreditationService.verifyAccreditation(acc['id']);
                                      setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Аккредитация подтверждена'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: AppColors.error),
                                    onPressed: () {
                                      _showRejectDialog(context, acc['id']);
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ],
                          
                          const Divider(),
                          
                          if (isExpiring || isExpired)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await notificationService.createNotification(
                                    userId: acc['user_id'],
                                    title: 'Напоминание об аккредитации',
                                    message: isExpired
                                        ? 'Срок вашей аккредитации истёк. Пожалуйста, обновите документы.'
                                        : 'Срок вашей аккредитации истекает через $daysLeft дней. Пожалуйста, позаботьтесь о продлении.',
                                  );
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Напоминание отправлено'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.notifications_active),
                                label: const Text('Напомнить'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.warning,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _filterStatus == value,
        onSelected: (selected) {
          setState(() {
            _filterStatus = value;
          });
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String accreditationId) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отклонить аккредитацию'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Укажите причину отклонения:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Причина...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final service = context.read<AccreditationService>();
              await service.rejectAccreditation(
                accreditationId,
                reason: reasonController.text,
              );
              
              if (context.mounted) {
                Navigator.pop(context);
                setState(() {});
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Аккредитация отклонена'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Отклонить'),
          ),
        ],
      ),
    );
  }
}