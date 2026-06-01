import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/styles/colors.dart';
import '../../controllers/cubit/app_cubit.dart';
import '../../controllers/cubit/app_states.dart';
import '../screens/shared_notification_screen.dart';
import '../screens/volunteer/volunteer_aid_management_screen.dart';
import '../screens/volunteer/volunteer_dashboard_screen.dart';
import '../screens/volunteer/volunteer_inquiry_screen.dart';
import '../screens/volunteer/volunteer_register_family_screen.dart';

class VolunteerLayoutScreen extends StatelessWidget {
  const VolunteerLayoutScreen({super.key});

  static final List<Widget> _screens = [
    const VolunteerDashboardScreen(),
    const VolunteerRegisterFamilyScreen(),
    const VolunteerAidManagementScreen(),
    const VolunteerInquiryScreen(),
    const SharedNotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      buildWhen: (prev, curr) => curr is ChangeCurrentIndexState,
      builder: (context, state) {
        final cubit = AppCubit.get(context);

        return Scaffold(
          backgroundColor: AppColors.backgroundPage,
          appBar: _buildAppBar(context, cubit),
          body: _screens[cubit.currentIndex],
          bottomNavigationBar: _buildBottomNav(cubit),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, AppCubit cubit) {
    final titles = [
      'لوحة التحكم',
      'تسجيل عائلة',
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

  Widget _buildBottomNav(AppCubit cubit) {
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
        onTap: cubit.changeIndex,
        backgroundColor: AppColors.backgroundCard,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_add_outlined),
            activeIcon: Icon(Icons.group_add),
            label: 'تسجيل',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism_outlined),
            activeIcon: Icon(Icons.volunteer_activism),
            label: 'المساعدات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'استفسار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'الإشعارات',
          ),
        ],
      ),
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
            onPressed: () {
              Navigator.pop(ctx);
              cubit.logout();
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
