import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:displacement_camp_management_system/shared/cubit/app_cubit.dart';
import 'package:displacement_camp_management_system/styles/colors.dart';
import 'package:flutter/material.dart';

class IdpNotificationsScreen extends StatefulWidget {
  const IdpNotificationsScreen({super.key});

  @override
  State<IdpNotificationsScreen> createState() => _IdpNotificationsScreenState();
}

class _IdpNotificationsScreenState extends State<IdpNotificationsScreen> {
  late final String _familyId;
  late final String _campName;

  // streamين منفصلين — عام للمخيم + خاص بالأسرة
  late final Stream<List<Map<String, dynamic>>> _mergedStream;

  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    _familyId = AppCubit.get(context).currentFamily?['id'] ?? '';
    _campName = AppCubit.get(context).currentFamily?['campName'] ?? '';
    _mergedStream = _buildMergedStream();
  }

  // ══════════════════════════════════════════════════════════
  // دمج streamين: إشعارات المخيم العامة + الخاصة بالأسرة
  // ══════════════════════════════════════════════════════════
  Stream<List<Map<String, dynamic>>> _buildMergedStream() {
    // ── Query 1: كل إشعارات المخيم (بدون فلتر familyId في الـ query)
    // نفلتر محلياً لتجنب الحاجة لـ composite index
    final campStream = FirebaseFirestore.instance
        .collection('notifications')
        .where('campName', isEqualTo: _campName)
        .limit(30)
        .snapshots();

    // ── Query 2: إشعارات خاصة بالأسرة فقط (familyId + index موجود)
    final familyStream = _familyId.isEmpty
        ? Stream<QuerySnapshot>.empty()
        : FirebaseFirestore.instance
            .collection('notifications')
            .where('familyId', isEqualTo: _familyId)
            .limit(15)
            .snapshots();

    return StreamZip([campStream, familyStream]).map((snapshots) {
      final docs = <Map<String, dynamic>>[];

      // من campStream (index 0) — نأخذ فقط العامة
      if (snapshots.isNotEmpty) {
        for (final doc in snapshots[0].docs) {
          final data = doc.data() as Map<String, dynamic>;
          final fid = data['familyId'] as String? ?? '';
          if (fid.isEmpty) {
            data['_docId'] = doc.id;
            docs.add(data);
          }
        }
      }

      // من familyStream (index 1) — كلها خاصة بالأسرة
      if (snapshots.length > 1) {
        for (final doc in snapshots[1].docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['_docId'] = doc.id;
          docs.add(data);
        }
      }

      // إزالة المكررات
      final seen = <String>{};
      docs.retainWhere((d) => seen.add(d['_docId'] as String));

      // ترتيب بالتاريخ تنازلياً محلياً
      docs.sort((a, b) {
        final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
        final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
        return bTime.compareTo(aTime);
      });

      return docs;
    });
  }

  // ══════════════════════════════════════════════════════════
  // Seed — يضيف بيانات تجريبية لـ Firestore
  // ══════════════════════════════════════════════════════════
  Future<void> _seedNotifications() async {
    if (_campName.isEmpty) return;
    setState(() => _isSeeding = true);

    final col = FirebaseFirestore.instance.collection('notifications');
    final batch = FirebaseFirestore.instance.batch();

    final now = DateTime.now();

    // إشعارات عامة للمخيم
    final campNotifs = [
      {
        'type': 'camp',
        'title': 'إعلان من إدارة المخيم',
        'message': 'سيتم توزيع المساعدات الغذائية غداً الساعة 9 صباحاً',
        'campName': _campName,
        'familyId': '',
        'isRead': false,
        'createdAt':
            Timestamp.fromDate(now.subtract(const Duration(minutes: 10))),
      },
      {
        'type': 'aid',
        'title': 'توزيع مساعدات طبية',
        'message': 'يرجى التوجه إلى العيادة لاستلام الأدوية المخصصة لأسرتك',
        'campName': _campName,
        'familyId': '',
        'isRead': false,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
      },
      {
        'type': 'camp',
        'title': 'تنبيه أمني',
        'message':
            'يُرجى الالتزام بساعات الدوام وعدم مغادرة المخيم بعد الساعة 10 مساءً',
        'campName': _campName,
        'familyId': '',
        'isRead': true,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 5))),
      },
      {
        'type': 'medical',
        'title': 'حملة تطعيم',
        'message': 'ستنطلق حملة التطعيم ضد الإنفلونزا الأسبوع القادم للجميع',
        'campName': _campName,
        'familyId': '',
        'isRead': true,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
      },
    ];

    // إشعارات خاصة بهذه الأسرة
    final familyNotifs = _familyId.isEmpty
        ? <Map<String, dynamic>>[]
        : [
            {
              'type': 'request',
              'title': 'تحديث حالة طلبك',
              'message': 'تمت الموافقة على طلب المساعدة الغذائية الخاص بك',
              'campName': _campName,
              'familyId': _familyId,
              'isRead': false,
              'createdAt':
                  Timestamp.fromDate(now.subtract(const Duration(minutes: 30))),
            },
            {
              'type': 'medical',
              'title': 'موعد طبي مجدول',
              'message': 'لديك موعد في العيادة غداً الساعة 11 صباحاً',
              'campName': _campName,
              'familyId': _familyId,
              'isRead': false,
              'createdAt':
                  Timestamp.fromDate(now.subtract(const Duration(hours: 3))),
            },
            {
              'type': 'aid',
              'title': 'استلام مساعدة',
              'message':
                  'تم تخصيص سلة غذائية لأسرتك، يرجى الاستلام من نقطة التوزيع',
              'campName': _campName,
              'familyId': _familyId,
              'isRead': true,
              'createdAt':
                  Timestamp.fromDate(now.subtract(const Duration(days: 2))),
            },
          ];

    for (final n in [...campNotifs, ...familyNotifs]) {
      batch.set(col.doc(), n);
    }

    await batch.commit();
    if (mounted) setState(() => _isSeeding = false);
  }

  // ══════════════════════════════════════════════════════════
  // UI
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _mergedStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data ?? [];

        if (docs.isEmpty) {
          return _emptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          physics: const BouncingScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _notificationItem(docs[index]);
          },
        );
      },
    );
  }

  Widget _notificationItem(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? 'general';
    final isRead = data['isRead'] as bool? ?? false;
    final date = (data['createdAt'] as Timestamp?)?.toDate();
    final timeAgo = _timeAgo(date);
    final config = _notifConfig(type);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRead
            ? AppColors.backgroundCard
            : (config['bg'] as Color).withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isRead ? AppColors.border : config['bg'] as Color,
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة النوع
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: config['bg'] as Color,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              config['icon'] as IconData,
              color: config['color'] as Color,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data['title'] as String? ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    // بادج "خاص" إذا كان للأسرة
                    if ((data['familyId'] as String? ?? '').isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF0FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'خاص',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4355B9),
                          ),
                        ),
                      ),
                  ],
                ),
                if ((data['message'] as String? ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      data['message'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          // نقطة "غير مقروء"
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4, right: 2),
              decoration: const BoxDecoration(
                color: Color(0xFF4355B9),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Helpers
  // ══════════════════════════════════════════════════════════
  Map<String, dynamic> _notifConfig(String type) {
    switch (type) {
      case 'aid':
        return {
          'icon': Icons.volunteer_activism_outlined,
          'color': const Color(0xFF0F6E56),
          'bg': const Color(0xFFE1F5EE),
        };
      case 'medical':
        return {
          'icon': Icons.medical_services_outlined,
          'color': const Color(0xFFA32D2D),
          'bg': const Color(0xFFFCEBEB),
        };
      case 'request':
        return {
          'icon': Icons.assignment_turned_in_outlined,
          'color': const Color(0xFF92400E),
          'bg': const Color(0xFFFFF7ED),
        };
      case 'camp':
        return {
          'icon': Icons.campaign_outlined,
          'color': const Color(0xFF185FA5),
          'bg': const Color(0xFFE6F1FB),
        };
      default:
        return {
          'icon': Icons.notifications_outlined,
          'color': const Color(0xFF4355B9),
          'bg': const Color(0xFFEEF0FF),
        };
    }
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 32,
              color: Color(0xFF4355B9),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'ستظهر هنا إشعارات المخيم والمساعدات',
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// StreamZip — يدمج streamين ببعض، يبعث بمجرد توفر أي منهما
// ══════════════════════════════════════════════════════════
class StreamZip<T> extends Stream<List<T>> {
  final List<Stream<T>> streams;
  StreamZip(this.streams);

  @override
  StreamSubscription<List<T>> listen(
    void Function(List<T>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final latest = List<T?>.filled(streams.length, null);
    final subscriptions = <StreamSubscription<T>>[];
    late final StreamController<List<T>> controller;

    controller = StreamController<List<T>>(
      onCancel: () {
        for (final s in subscriptions) {
          s.cancel();
        }
      },
    );

    for (var i = 0; i < streams.length; i++) {
      final index = i;
      subscriptions.add(
        streams[index].listen(
          (value) {
            latest[index] = value;
            // نبعث بمجرد وصول أي stream — الباقي يبقى null ونتعامل معه
            final result = <T>[];
            for (final v in latest) {
              if (v != null) result.add(v);
            }
            controller.add(result);
          },
          onError: controller.addError,
        ),
      );
    }

    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
