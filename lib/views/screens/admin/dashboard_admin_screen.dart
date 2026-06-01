import 'package:displacement_camp_management_system/views/screens/admin/add_camp_screen.dart';
import 'package:displacement_camp_management_system/views/screens/admin/add_familiy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../utils/styles/colors.dart';
import '../../../controllers/cubit/app_cubit.dart';
import '../../../controllers/cubit/app_states.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  @override
  void initState() {
    super.initState();
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

        // ─── Loading ───────────────────────────────────────────
        if (state is DashboardLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        // ─── Error ─────────────────────────────────────────────
        if (state is DashboardErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  'حدث خطأ:\n${state.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => cubit.getDashboardStats(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        // ─── Success ───────────────────────────────────────────
        final stats = cubit.dashboardStats;
        final activities = cubit.recentActivities;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              _buildHeader(cubit.currentUsername ?? 'مسؤول النظام'),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: "عدد المخيمات",
                      value: '${stats['totalCamps'] ?? 0}',
                      badge: '${stats['campsPercent'] ?? '0 نشط'}',
                      icon: Icons.location_on,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      title: "إجمالي النازحين",
                      value: '${stats['totalDisplaced'] ?? 0}',
                      badge: "${stats['occupancyPercent'] ?? '0'}% امتلاء",
                      icon: Icons.group,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              /// بطاقتان: العائلات + المخيمات النشطة
              Row(
                children: [
                  Expanded(
                    child: _miniStatCard(
                      title: "إجمالي العائلات",
                      // ← هذا عدد العائلات (documents)
                      value: '${stats['totalFamilies'] ?? 0}',
                      icon: Icons.family_restroom,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _miniStatCard(
                      title: "مخيمات نشطة",
                      value: '${stats['activeCamps'] ?? 0}',
                      icon: Icons.location_city,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// البطاقة الزرقاء — المساعدات الموزعة
              _blueCard('${stats['totalAid'] ?? 0} وحدة'),

              const SizedBox(height: 12),

              /// إجراءات سريعة — GridView 2×2
              const Text(
                "إجراءات سريعة",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _actionButton(
                    "تسجيل عائلة",
                    Icons.group_add,
                    AppColors.secondary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddFamilyScreen(),
                        ),
                      );
                    },
                  ),
                  _actionButton(
                    "شحنة جديدة",
                    Icons.local_shipping,
                    AppColors.primary,
                    onTap: () {},
                  ),
                  _actionButton(
                    "إضافة مخيم",
                    Icons.add_location_alt,
                    AppColors.warning,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddCampScreen(),
                          ));
                    },
                  ),
                  _actionButton(
                    "توزيع مساعدات",
                    Icons.volunteer_activism,
                    AppColors.success,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// آخر النشاطات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "آخر النشاطات",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

              const SizedBox(height: 12),
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
        const CircleAvatar(
          backgroundColor: AppColors.primary100,
          child: Icon(Icons.person, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String badge,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // badge — نشاط أو نسبة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style:
                      const TextStyle(color: AppColors.success, fontSize: 11),
                ),
              ),
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
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

  Widget _miniStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
                    color: AppColors.textSecondary, fontSize: 11),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
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
          const Icon(Icons.arrow_forward_ios,
              size: 16, color: AppColors.textHint),
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
