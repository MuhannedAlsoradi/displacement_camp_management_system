import 'package:displacement_camp_management_system/views/screens/admin/add_camp_screen.dart';
import 'package:displacement_camp_management_system/views/screens/shared/add_familiy_screen.dart';
import 'package:displacement_camp_management_system/views/screens/shared/aid_distribution_screen.dart';
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
          curr is DashboardErrorState ||
          curr is AddCampSuccessState ||
          curr is AddDisplacedSuccessState,
      builder: (context, state) {
        final cubit = AppCubit.get(context);

        if (state is DashboardLoadingState) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (state is DashboardErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.statusCritical.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.wifi_off_rounded,
                      color: AppColors.statusCritical, size: 40),
                ),
                const SizedBox(height: 12),
                const Text('تعذّر تحميل البيانات',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(
                  state.error,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => cubit.getDashboardStats(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          );
        }

        final stats = cubit.dashboardStats;
        final activities = cubit.recentActivities;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => cubit.getDashboardStats(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── الرأس ─────────────────────────────────────
                _buildHeader(cubit.currentUsername ?? 'مسؤول النظام'),

                const SizedBox(height: 20),

                // ── البطاقات الرئيسية ─────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        title: 'عدد المخيمات',
                        value: '${stats['totalCamps'] ?? 0}',
                        badge: '${stats['campsPercent'] ?? '0 نشط'}',
                        icon: Icons.location_on_rounded,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        title: 'إجمالي النازحين',
                        value: '${stats['totalDisplaced'] ?? 0}',
                        badge: "${stats['occupancyPercent'] ?? '0'}% امتلاء",
                        icon: Icons.group_rounded,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _miniStatCard(
                        title: 'إجمالي العائلات',
                        value: '${stats['totalFamilies'] ?? 0}',
                        icon: Icons.family_restroom_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _miniStatCard(
                        title: 'مخيمات نشطة',
                        value: '${stats['activeCamps'] ?? 0}',
                        icon: Icons.location_city_rounded,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _blueCard('${stats['totalAid'] ?? 0} وحدة'),

                const SizedBox(height: 20),

                // ── إجراءات سريعة ─────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'إجراءات سريعة',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
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
                      'تسجيل عائلة',
                      Icons.group_add_rounded,
                      AppColors.secondary,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddFamilyScreen()),
                        );
                        cubit.getDashboardStats();
                      },
                    ),
                    _actionButton(
                      'إضافة مخيم',
                      Icons.add_location_alt_rounded,
                      AppColors.warning,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddCampScreen()),
                        );
                        cubit.getDashboardStats();
                      },
                    ),
                    _actionButton(
                      'توزيع مساعدات',
                      Icons.volunteer_activism_rounded,
                      AppColors.success,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AidDistributionScreen(),
                          )),
                    ),
                    _actionButton(
                      'التقارير',
                      Icons.bar_chart_rounded,
                      AppColors.primary,
                      onTap: () {
                        // الانتقال إلى تبويب التقارير في HomeLayout
                        // يمكن استخدام AppCubit.get(context).changeAdminIndex(3)
                        // حسب ترتيب التبويبات في HomeLayout
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── آخر النشاطات ──────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'آخر النشاطات',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    IconButton(
                      onPressed: () => cubit.getDashboardStats(),
                      icon: const Icon(Icons.refresh_rounded,
                          color: AppColors.primary, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

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

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Widgets ──────────────────────────────────────────────────

  Widget _buildHeader(String username) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أهلاً بك، $username',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now()),
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
                Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
          ),
          child: const CircleAvatar(
            backgroundColor: AppColors.primary100,
            radius: 20,
            child:
                Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
          ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
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
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.85),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.volunteer_activism_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('المساعدات الموزعة',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                aidValue,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white38, size: 16),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
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
          color: color.withOpacity(0.07),
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
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityItem(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
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
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textHint),
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
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, color: AppColors.textHint, size: 40),
            SizedBox(height: 8),
            Text(
              'لا توجد نشاطات حديثة',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'shipment':
        return Icons.local_shipping_rounded;
      case 'register':
        return Icons.person_add_rounded;
      case 'camp':
        return Icons.location_on_rounded;
      case 'aid':
        return Icons.volunteer_activism_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.inventory_2_rounded;
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
      case 'aid':
        return AppColors.success;
      default:
        return AppColors.textHint;
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — قريباً'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
