import 'package:displacement_camp_management_system/shared/cubit/app_cubit.dart';
import 'package:displacement_camp_management_system/styles/colors.dart';
import 'package:flutter/material.dart';

class IdpDashboardScreen extends StatelessWidget {
  const IdpDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final family = AppCubit.get(context).currentFamily;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── بانر الترحيب ──────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'مرحباً بك،',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.backgroundCard,
                        ),
                      ),
                      Text(
                        family?['representativeName'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${family?['campName'] ?? ''} — ${family?['tentId'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'الحالة: ${family?['status'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.home_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── الخدمات السريعة ───────────────────────────
            const Text(
              'الخدمات السريعة',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _serviceItem(
                  icon: Icons.volunteer_activism_outlined,
                  label: 'طلب مساعدة',
                  iconColor: const Color(0xFF4355B9),
                  iconBg: const Color(0xFFEEF0FF),
                  onTap: () => _navigateToTab(context, 1),
                ),
                _serviceItem(
                  icon: Icons.medical_services_outlined,
                  label: 'خدمة طبية',
                  iconColor: const Color(0xFFA32D2D),
                  iconBg: const Color(0xFFFCEBEB),
                  onTap: () {},
                ),
                _serviceItem(
                  icon: Icons.apartment_outlined,
                  label: 'خدمات المخيم',
                  iconColor: const Color(0xFF0F6E56),
                  iconBg: const Color(0xFFE1F5EE),
                  onTap: () {},
                ),
                _serviceItem(
                  icon: Icons.menu_book_outlined,
                  label: 'محتوى تعليمي',
                  iconColor: const Color(0xFF92400E),
                  iconBg: const Color(0xFFFFF7ED),
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── آخر المساعدات الموزّعة على الأسرة ──────────
            const Text(
              'آخر المساعدات',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            _AidHistorySection(familyId: family?['id'] ?? ''),

            const SizedBox(height: 14),

            // ── محتوى توعوي ───────────────────────────────
            const Text(
              'محتوى توعوي',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            _educationalItem(
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFF185FA5),
              iconBg: const Color(0xFFE6F1FB),
              title: 'حقوقك كنازح',
              subtitle: 'تعرف على حقوقك الإنسانية',
            ),
            const SizedBox(height: 8),
            _educationalItem(
              icon: Icons.favorite_border,
              iconColor: const Color(0xFF0F6E56),
              iconBg: const Color(0xFFE1F5EE),
              title: 'الصحة العامة',
              subtitle: 'نصائح صحية في المخيم',
            ),
            const SizedBox(height: 8),
            _educationalItem(
              icon: Icons.school_outlined,
              iconColor: const Color(0xFF4355B9),
              iconBg: const Color(0xFFEEF0FF),
              title: 'التعليم والتدريب',
              subtitle: 'فرص تعليمية متاحة',
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    AppCubit.get(context).changeIndex(index);
  }

  Widget _serviceItem({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _educationalItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textHint,
            size: 18,
          ),
        ],
      ),
    );
  }
}

// ── Widget منفصل لآخر المساعدات ──────────────────────────
class _AidHistorySection extends StatelessWidget {
  final String familyId;
  const _AidHistorySection({required this.familyId});

  @override
  Widget build(BuildContext context) {
    final allAid = AppCubit.get(context).aidDistributions;
    final familyAid =
        allAid.where((a) => a['familyId'] == familyId).take(3).toList();

    if (familyAid.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: const Text(
          'لا توجد مساعدات موزّعة بعد',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: familyAid.asMap().entries.map((entry) {
          final i = entry.key;
          final aid = entry.value;
          final isLast = i == familyAid.length - 1;
          final date = (aid['createdAt'] as dynamic)?.toDate();
          final dateStr =
              date != null ? '${date.day}/${date.month}/${date.year}' : '';
          return Column(
            children: [
              ListTile(
                dense: true,
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F5EE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.volunteer_activism_outlined,
                    size: 16,
                    color: Color(0xFF0F6E56),
                  ),
                ),
                title: Text(
                  aid['resourceType'] ?? aid['type'] ?? 'مساعدة',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3DE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'مكتمل',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF27500A),
                    ),
                  ),
                ),
              ),
              if (!isLast) const Divider(height: 1, thickness: 0.5, indent: 12),
            ],
          );
        }).toList(),
      ),
    );
  }
}
