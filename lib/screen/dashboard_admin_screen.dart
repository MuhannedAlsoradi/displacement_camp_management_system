import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../styles/colors.dart';

class DashboardAdminScreen extends StatelessWidget {
  const DashboardAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Header
            _buildHeader(),

            const SizedBox(height: 20),

            /// 🔹 Stats Cards
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "عدد المخيمات",
                    "12",
                    "+12%",
                    Icons.location_on,
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    "إجمالي النازحين",
                    "1,240",
                    "+5%",
                    Icons.group,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 🔹 Blue Card
            _blueCard(),

            const SizedBox(height: 20),

            /// 🔹 Quick Actions
            const Text(
              "إجراءات سريعة",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    "شحنة جديدة",
                    Icons.local_shipping,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionButton(
                    "إضافة مستفيد",
                    Icons.add,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔹 Chart Placeholder
            _chartCard(),

            const SizedBox(height: 20),

            /// 🔹 Activities
            const Text(
              "آخر النشاطات",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _activityItem(
              "وصول شحنة أغذية",
              "مخيم السلام - منذ 2 ساعة",
              Icons.inventory,
            ),
            _activityItem(
              "تسجيل عائلة جديدة",
              "مخيم الأمل - منذ 5 ساعات",
              Icons.person_add,
            ),
          ],
        ));
  }

  /// ================= Widgets =================

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const Text(
              "أهلاً بك، مسؤول النظام",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'ar').format(DateTime.now()),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        const CircleAvatar(
          backgroundColor: AppColors.primary100,
          child: Icon(Icons.person),
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    String percent,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(percent, style: const TextStyle(color: AppColors.success)),
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _blueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.volunteer_activism, color: Colors.white),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "المساعدات الموزعة",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 6),
              Text(
                "4,000 وحدة",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _chartCard() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          "هنا الرسم البياني",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _activityItem(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.secondary50,
            child: Icon(icon, color: AppColors.secondary),
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
