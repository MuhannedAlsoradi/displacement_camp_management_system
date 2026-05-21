import 'package:displacement_camp_management_system/modules/screens/admin/dashboard_admin_screen.dart';
import 'package:displacement_camp_management_system/modules/screens/notification_screen.dart';
import 'package:displacement_camp_management_system/modules/screens/admin/reports_screen.dart';
import 'package:displacement_camp_management_system/shared/cubit/app_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:displacement_camp_management_system/shared/cubit/app_states.dart';

import '../modules/screens/admin/camps_management_Screen.dart';
import '../modules/screens/admin/displaced_management_screen.dart';
import '../styles/colors.dart';

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
      buildWhen: (prev, curr) => curr is ChangeCurrentIndexState,
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationScreen(),
                    ),
                  );
                },
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
}
