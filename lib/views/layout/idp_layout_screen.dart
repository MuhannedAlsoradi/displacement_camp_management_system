import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:displacement_camp_management_system/controllers/cubit/app_cubit.dart';
import 'package:displacement_camp_management_system/controllers/cubit/app_states.dart';
import 'package:displacement_camp_management_system/utils/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/idp/idp_aidrequest_screen.dart';
import '../screens/idp/idp_dashboard_screen.dart';
import '../screens/idp/idp_profile_screen.dart';
import '../screens/shared/role_selection_screen.dart';
import '../screens/shared/shared_notification_screen.dart';

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
    SharedNotificationsScreen(),
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
    final cubit = AppCubit.get(context);

    return BlocConsumer<AppCubit, AppStates>(
      listenWhen: (prev, curr) => curr is NotificationsSuccessState,
      listener: (context, state) {
        // إعادة البناء لتحديث الـ badge عند وصول إشعارات جديدة
        setState(() {});
      },
      buildWhen: (prev, curr) => false, // نُعيد البناء فقط عبر setState
      builder: (context, _) => Scaffold(
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
                IconButton(
                  onPressed: () => _confirmLogout(context, cubit),
                  icon: const Icon(Icons.logout,
                      color: AppColors.danger, size: 22),
                ),
              ]
            : [
                IconButton(
                  onPressed: () => _confirmLogout(context, cubit),
                  icon: const Icon(Icons.logout,
                      color: AppColors.danger, size: 22),
                ),
              ],
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
          items: _buildNavItems(),
        ),
      ),
    ),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    final unread = AppCubit.get(context).unreadNotificationsCount;
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'الرئيسية',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.add_circle_outline),
        activeIcon: Icon(Icons.add_circle),
        label: 'طلب مساعدة',
      ),
      BottomNavigationBarItem(
        icon: _buildBadgedIcon(Icons.notifications_outlined, unread),
        activeIcon: _buildBadgedIcon(Icons.notifications, unread),
        label: 'الإشعارات',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'حسابي',
      ),
    ];
  }

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
                      builder: (_) => const RoleSelectionScreen()), // اسم الشاشة عندك
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
