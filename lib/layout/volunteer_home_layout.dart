import 'package:displacement_camp_management_system/shared/cubit/app_cubit.dart';
import 'package:displacement_camp_management_system/shared/cubit/app_states.dart';
import 'package:displacement_camp_management_system/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../modules/screens/volunteer/volunteer_screens_placeholder.dart';

class VolunteerHomeLayout extends StatefulWidget {
  const VolunteerHomeLayout({super.key});

  @override
  State<VolunteerHomeLayout> createState() => _VolunteerHomeLayoutState();
}

class _VolunteerHomeLayoutState extends State<VolunteerHomeLayout> {
  @override
  void initState() {
    super.initState();
    // المتطوع يحتاج فقط بيانات العائلات والمساعدات
    AppCubit.get(context).startVolunteerListeners();
  }

  static const List<Widget> _screens = [
    VolunteerDashboardScreen(),
    VolunteerFamiliesScreen(),
    VolunteerAidScreen(),
    VolunteerProfileScreen(),
  ];

  static const List<String> _titles = [
    'الرئيسية',
    'العائلات',
    'توزيع المساعدات',
    'حسابي',
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'الرئيسية',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people_outline),
      activeIcon: Icon(Icons.people),
      label: 'العائلات',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.volunteer_activism_outlined),
      activeIcon: Icon(Icons.volunteer_activism),
      label: 'المساعدات',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'حسابي',
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
            actions: [
              // زر المزامنة — مهم للمتطوع لأنه يعمل أوفلاين
              BlocBuilder<AppCubit, AppStates>(
                buildWhen: (_, curr) =>
                    curr is SyncLoadingState ||
                    curr is SyncSuccessState ||
                    curr is SyncErrorState,
                builder: (context, syncState) {
                  if (syncState is SyncLoadingState) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  return IconButton(
                    icon: const Icon(Icons.sync),
                    tooltip: 'مزامنة البيانات',
                    onPressed: () => cubit.syncPendingData(),
                  );
                },
              ),
            ],
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
