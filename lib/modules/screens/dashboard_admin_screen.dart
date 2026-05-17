import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../styles/colors.dart';
import '../../shared/cubit/app_cubit.dart';
import '../../shared/cubit/app_states.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  @override
  void initState() {
    super.initState();
    // جلب كل البيانات عند فتح الشاشة
    AppCubit.get(context).getDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      buildWhen: (prev, curr) =>
          curr is DashboardLoadingState ||
          curr is DashboardSuccessState ||
          curr is DashboardErrorState,
      builder: (context, state) {
        final cubit = AppCubit.get(context);

        // ─── Loading: مؤشر واحد فقط لكل الصفحة ───
        if (state is DashboardLoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final stats = cubit.dashboardStats;
        final activities = cubit.recentActivities;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Header
              _buildHeader(cubit.currentUsername ?? 'مسؤول النظام'),

              const SizedBox(height: 20),

              /// 🔹 Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      "عدد المخيمات",
                      '${stats['totalCamps'] ?? 0}',
                      "${stats['campsPercent'] ?? '+0%'}",
                      Icons.location_on,
                      AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      "إجمالي النازحين",
                      '${stats['totalDisplaced'] ?? 0}',
                      "${stats['displacedPercent'] ?? '+0%'}",
                      Icons.group,
                      AppColors.secondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// 🔹 Blue Card — المساعدات الموزعة
              _blueCard('${stats['totalAid'] ?? 0} وحدة'),

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
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(
                      "إضافة مستفيد",
                      Icons.add,
                      AppColors.secondary,
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔹 Stats Row — عائلات + مخيمات نشطة
              Row(
                children: [
                  Expanded(
                    child: _miniStatCard(
                      "إجمالي العائلات",
                      '${stats['totalFamilies'] ?? 0}',
                      Icons.family_restroom,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _miniStatCard(
                      "مخيمات نشطة",
                      '${stats['activeCamps'] ?? 0}',
                      Icons.location_city,
                      AppColors.success,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔹 Activities
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "آخر النشاطات",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => cubit.getDashboardStats(),
                    icon: const Icon(Icons.refresh, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (activities.isEmpty)
                _emptyActivities()
              else
                ...activities.map(
                  (activity) => _activityItem(
                    activity['title'] ?? '',
                    activity['subtitle'] ?? '',
                    _getActivityIcon(activity['type'] ?? ''),
                    _getActivityColor(activity['type'] ?? ''),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ─── Widgets ──────────────────────────────────────────────

  Widget _buildHeader(String username) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "أهلاً بك، $username",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'ar').format(DateTime.now()),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {},
          child: const CircleAvatar(
            backgroundColor: AppColors.primary100,
            child: Icon(Icons.person, color: AppColors.primary),
          ),
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

  Widget _blueCard(String aidValue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.volunteer_activism, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "المساعدات الموزعة",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                aidValue,
                style: const TextStyle(
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

  Widget _miniStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    String text,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Widget _activityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
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

  Widget _emptyActivities() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, color: AppColors.textHint, size: 40),
            SizedBox(height: 8),
            Text(
              'لا توجد نشاطات حديثة',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'shipment':
        return Icons.local_shipping;
      case 'register':
        return Icons.person_add;
      case 'camp':
        return Icons.location_on;
      case 'aid':
        return Icons.volunteer_activism;
      case 'warning':
        return Icons.warning_amber;
      default:
        return Icons.inventory;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'shipment':
        return AppColors.primary;
      case 'register':
        return AppColors.secondary;
      case 'camp':
        return AppColors.warning;
      case 'warning':
        return AppColors.statusCritical;
      default:
        return AppColors.success;
    }
  }
}
