import 'package:displacement_camp_management_system/views/screens/admin/dashboard_admin_screen.dart';
import 'package:displacement_camp_management_system/views/screens/admin/reports_screen.dart';
import 'package:displacement_camp_management_system/controllers/cubit/app_cubit.dart';
import 'package:displacement_camp_management_system/views/screens/shared/role_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:displacement_camp_management_system/controllers/cubit/app_states.dart';

import '../../utils/enums/user_role.dart';
import '../screens/admin/camps_management_screen.dart';
import '../screens/admin/displaced_management_screen.dart';
import '../../utils/styles/colors.dart';
import '../screens/shared/login_screen.dart';
import '../screens/shared/shared_notification_screen.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  @override
  void initState() {
    super.initState();
    // ابدأ كل الـ Streams مرة واحدة عند فتح الـ HomeLayout
    // (تعمل حتى لو فُتح التطبيق بدون المرور بشاشة تسجيل الدخول)
    AppCubit.get(context).startAllListeners();
  }

  static const List<Widget> _screens = [
    DashboardAdminScreen(),
    CampsManagementScreen(),
    DisplacedManagementScreen(),
    ReportsScreen(),
  ];

  static const List<String> _titles = [
    'لوحة التحكم',
    'المخيمات',
    'النازحين',
    'التقارير',
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: 'لوحة التحكم',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.holiday_village_outlined),
      activeIcon: Icon(Icons.holiday_village),
      label: 'المخيمات',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people_outline),
      activeIcon: Icon(Icons.people),
      label: 'النازحين',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bar_chart_outlined),
      activeIcon: Icon(Icons.bar_chart_sharp),
      label: 'التقارير',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      buildWhen: (prev, curr) =>
          curr is ChangeCurrentIndexState || curr is NotificationsSuccessState,
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            actions: [
              _buildNotificationButton(context, cubit),
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.statusCritical),
                onPressed: () => _confirmLogout(context, cubit),
              ),
            ],
            automaticallyImplyLeading: false,
            title: Text(
              _titles[cubit.currentIndex],
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            backgroundColor: AppColors.backgroundCard,
            elevation: 0,
            scrolledUnderElevation: 0,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, thickness: 1, color: AppColors.border),
            ),
          ),
          body: IndexedStack(
            index: cubit.currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppColors.backgroundCard,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: cubit.currentIndex,
              onTap: (index) => cubit.changeIndex(index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.backgroundCard,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textHint,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              elevation: 0,
              items: _navItems,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationButton(BuildContext context, AppCubit cubit) {
    final count = cubit.unreadNotificationsCount;
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const SharedNotificationsScreen(showAppBar: true),
              ),
            );
            // بعد إغلاق شاشة الإشعارات نعلّم الكل كمقروء
            if (context.mounted) {
              AppCubit.get(context).markAllNotificationsAsRead();
            }
          },
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
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
                  fontSize: 9,
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
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.logout_rounded, color: AppColors.statusCritical, size: 22),
          const SizedBox(width: 8),
          const Text('تسجيل الخروج',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        content: const Text(
          'هل تريد تسجيل الخروج من حسابك؟',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCritical,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await cubit.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) =>
                          const RoleSelectionScreen()), // اسم الشاشة عندك
                  (route) => false,
                );
              }
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
