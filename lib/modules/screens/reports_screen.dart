import 'package:flutter/material.dart';

import '../../styles/colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Toggle (شهري / أسبوعي)
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _toggleItem('شهري', true),
                  _toggleItem('أسبوعي', false),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔹 نظرة عامة
            const Text(
              'نظرة عامة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: 'السلال الغذائية',
                    value: '450',
                    percent: '+5%',
                    iconColor: AppColors.warning,
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    title: 'إجمالي الأسر',
                    value: '1,250',
                    percent: '+12%',
                    iconColor: AppColors.secondary,
                    isPrimary: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔹 توزيع المساعدات
            _distributionCard(),

            const SizedBox(height: 20),

            /// 🔹 النشاط الأخير
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'النشاط الأخير',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'عرض الكل',
                  style: TextStyle(color: AppColors.secondary),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _activityItem(
              title: 'اكتمل توزيع السلال - مخيم أ',
              subtitle: 'منذ ساعتين',
              icon: Icons.check,
              color: AppColors.success,
            ),
            _activityItem(
              title: 'تسجيل عائلات جديدة',
              subtitle: 'أمس، 4:30 م',
              icon: Icons.person_add,
              color: AppColors.secondary,
            ),
            _activityItem(
              title: 'بلاغ نقص مياه - قطاع 4',
              subtitle: '20 يونيو، 10:00 ص',
              icon: Icons.warning_amber,
              color: AppColors.warning,
            ),

            const SizedBox(height: 30),

            /// 🔹 زر PDF
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {},
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('تصدير التقرير PDF', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Icon(Icons.download),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Toggle Item
  Widget _toggleItem(String text, bool selected) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.backgroundCard : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: selected ? AppColors.secondary : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 🔹 Stat Card
  Widget _statCard({
    required String title,
    required String value,
    required String percent,
    required Color iconColor,
    required bool isPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.secondary50 : AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border:
            isPrimary ? Border.all(color: AppColors.secondary, width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.inventory, color: iconColor),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$percent هذا الشهر',
            style: const TextStyle(color: AppColors.success),
          ),
        ],
      ),
    );
  }

  /// 🔹 Distribution Card
  Widget _distributionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'توزيع المساعدات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              '100%',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Center(
            child: Text(
              'مكتمل',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 20),
          _progressItem('غذاء', 0.45, AppColors.primary),
          _progressItem('دواء', 0.30, AppColors.secondary),
          _progressItem('إيواء', 0.25, AppColors.warning),
        ],
      ),
    );
  }

  Widget _progressItem(String title, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
              color: color,
              backgroundColor: AppColors.border,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  /// 🔹 Activity Item
  Widget _activityItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textHint,
          ),
        ],
      ),
    );
  }
}
