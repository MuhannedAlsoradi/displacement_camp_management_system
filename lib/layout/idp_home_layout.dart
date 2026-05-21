import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:displacement_camp_management_system/shared/cubit/app_cubit.dart';
import 'package:displacement_camp_management_system/styles/colors.dart';
import 'package:flutter/material.dart';

import '../modules/screens/idp/idp_aidrequest_screen.dart';
import '../modules/screens/idp/idp_dashboard_screen.dart';
import '../modules/screens/idp/idp_notifications_screen.dart';
import '../modules/screens/idp/idp_profile_screen.dart';

class IdpHomeLayout extends StatefulWidget {
  const IdpHomeLayout({super.key});

  @override
  State<IdpHomeLayout> createState() => _IdpHomeLayoutState();
}

class _IdpHomeLayoutState extends State<IdpHomeLayout> {
  int _currentIndex = 0;

  // شاشات النازح الأربع
  static const List<Widget> _screens = [
    IdpDashboardScreen(),
    IdpAidRequestScreen(),
    IdpNotificationsScreen(),
    IdpProfileScreen(),
  ];

  static const List<String> _titles = [
    'الرئيسية',
    'طلب مساعدة',
    'الإشعارات',
    'حسابي',
  ];

  // ── Stream لعدد الإشعارات الغير مقروءة ─────────────────
  Stream<int> _unreadStream() {
    final family = AppCubit.get(context).currentFamily;
    final familyId = family?['id'] ?? '';
    final campName = family?['campName'] ?? '';

    if (campName.isEmpty) return Stream.value(0);

    // إشعارات عامة للمخيم غير مقروءة
    final campUnread = FirebaseFirestore.instance
        .collection('notifications')
        .where('campName', isEqualTo: campName)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs
            .where((d) => (d.data()['familyId'] as String? ?? '').isEmpty)
            .length);

    // إشعارات خاصة بالأسرة غير مقروءة
    final familyUnread = familyId.isEmpty
        ? Stream.value(0)
        : FirebaseFirestore.instance
            .collection('notifications')
            .where('familyId', isEqualTo: familyId)
            .where('isRead', isEqualTo: false)
            .snapshots()
            .map((s) => s.docs.length);

    // نجمع الاثنين
    return campUnread.asyncMap((campCount) async {
      final familyCount = await familyUnread.first;
      return campCount + familyCount;
    });
  }

  // ── Mark all as read لما يفتح شاشة الإشعارات ───────────
  Future<void> _markAllNotificationsRead() async {
    final family = AppCubit.get(context).currentFamily;
    final familyId = family?['id'] ?? '';
    final campName = family?['campName'] ?? '';

    final col = FirebaseFirestore.instance.collection('notifications');
    final batch = FirebaseFirestore.instance.batch();

    // إشعارات المخيم العامة الغير مقروءة
    final campSnap = await col
        .where('campName', isEqualTo: campName)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in campSnap.docs) {
      final fid = (doc.data()['familyId'] as String? ?? '');
      if (fid.isEmpty) batch.update(doc.reference, {'isRead': true});
    }

    // إشعارات الأسرة الخاصة الغير مقروءة
    if (familyId.isNotEmpty) {
      final familySnap = await col
          .where('familyId', isEqualTo: familyId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in familySnap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
    }

    await batch.commit();
  }

  void _onTabTapped(int index) {
    // لما يضغط على الإشعارات — نعلّم الكل كمقروء
    if (index == 2) {
      _markAllNotificationsRead();
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _titles[_currentIndex],
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
        // زر الإشعارات يظهر فقط في شاشة الرئيسية
        actions: _currentIndex == 0
            ? [
                StreamBuilder<int>(
                  stream: _unreadStream(),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () => _onTabTapped(2),
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
                  },
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
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
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
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
  }

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'الرئيسية',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.add_circle_outline),
      activeIcon: Icon(Icons.add_circle),
      label: 'طلب مساعدة',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications_outlined),
      activeIcon: Icon(Icons.notifications),
      label: 'الإشعارات',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'حسابي',
    ),
  ];
}
