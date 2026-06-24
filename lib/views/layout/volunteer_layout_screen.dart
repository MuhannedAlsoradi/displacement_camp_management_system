import 'package:displacement_camp_management_system/views/screens/shared/aid_distribution_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/styles/colors.dart';
import '../../controllers/cubit/app_cubit.dart';
import '../../controllers/cubit/app_states.dart';
import '../screens/shared/role_selection_screen.dart';
import '../screens/shared/shared_notification_screen.dart';
import '../screens/volunteer/volunteer_dashboard_screen.dart';
import '../screens/volunteer/volunteer_inquiry_screen.dart';
import '../widgets/connectivit_banner.dart';

class VolunteerLayoutScreen extends StatelessWidget {
  const VolunteerLayoutScreen({super.key});

  static final List<Widget> _screens = [
    const VolunteerDashboardScreen(),
    const AidDistributionScreen(showAppBar: false),
    const VolunteerInquiryScreen(),
    const SharedNotificationsScreen(showAppBar: false),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      buildWhen: (prev, curr) =>
          curr is ChangeCurrentIndexState ||
          curr is NotificationsSuccessState,
      builder: (context, state) {
        final cubit = AppCubit.get(context);

        return Scaffold(
          backgroundColor: AppColors.backgroundPage,
          appBar: _buildAppBar(context, cubit),
          body: Column(
            children: [
              // ← جديد: بانر حالة الاتصال يظهر فوق أي Tab
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ConnectivityBanner(),
              ),
              Expanded(child: _screens[cubit.currentIndex]),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(context, cubit),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, AppCubit cubit) {
    final titles = [
      'لوحة التحكم',
      // 'تسجيل عائلة',
      'إدارة المساعدات',
      'استفسار',
      'الإشعارات',
    ];

    return AppBar(
      backgroundColor: AppColors.backgroundCard,
      elevation: 0,
      title: Text(
        titles[cubit.currentIndex],
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        /// زر تسجيل الخروج
        IconButton(
          onPressed: () => _confirmLogout(context, cubit),
          icon: const Icon(Icons.logout, color: AppColors.danger, size: 22),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, AppCubit cubit) {
    final unread = cubit.unreadNotificationsCount;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: cubit.currentIndex,
        onTap: (index) {
          // عند الضغط على تبويب الإشعارات — علّم الكل كمقروء
          if (index == 3) {
            cubit.markAllNotificationsAsRead();
          }
          cubit.changeIndex(index);
        },
        backgroundColor: AppColors.backgroundCard,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism_outlined),
            activeIcon: Icon(Icons.volunteer_activism),
            label: 'المساعدات',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'استفسار',
          ),
          BottomNavigationBarItem(
            icon: _buildBadgedIcon(Icons.notifications_outlined, unread),
            activeIcon: _buildBadgedIcon(Icons.notifications, unread),
            label: 'الإشعارات',
          ),
        ],
      ),
    );
  }

  /// أيقونة مع badge العداد
  Widget _buildBadgedIcon(IconData iconData, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(iconData),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _confirmLogout(BuildContext context, AppCubit cubit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppColors.danger, size: 22),
            SizedBox(width: 10),
            Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await cubit.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const RoleSelectionScreen()), // اسم الشاشة عندك
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }
}
