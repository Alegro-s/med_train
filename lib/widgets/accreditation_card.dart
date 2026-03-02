import 'package:flutter/material.dart';
import '../models/accreditation_model.dart';
import '../core/constants/colors.dart';
import '../core/utils/date_formatter.dart';

class AccreditationCard extends StatelessWidget {
  final Accreditation accreditation;
  final VoidCallback onTap;

  const AccreditationCard({super.key, required this.accreditation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final daysLeft = DateFormatter.daysLeft(accreditation.expiryDate);
    final isExpiring = daysLeft < 30 && daysLeft >= 0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.verified, color: AppColors.primary),
        title: Text('Аккредитация №${accreditation.registrationNumber}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Действует до: ${DateFormatter.format(accreditation.expiryDate)}'),
            if (isExpiring) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Осталось $daysLeft дн.',
                  style: const TextStyle(color: AppColors.warning, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}