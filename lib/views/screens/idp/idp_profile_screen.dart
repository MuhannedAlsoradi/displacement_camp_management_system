import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:displacement_camp_management_system/utils/styles/colors.dart';
import 'package:flutter/material.dart';

import '../../../controllers/cubit/app_cubit.dart';

class IdpProfileScreen extends StatefulWidget {
  const IdpProfileScreen({super.key});

  @override
  State<IdpProfileScreen> createState() => _IdpProfileScreenState();
}

class _IdpProfileScreenState extends State<IdpProfileScreen> {
  late final String _familyId;
  late final Stream<int> _activeRequestsStream;

  @override
  void initState() {
    super.initState();
    _familyId = AppCubit.get(context).currentFamily?['id'] ?? '';
    _activeRequestsStream = _buildActiveRequestsStream();
  }

  // طلبات نشطة = قيد المعالجة أو تمت الموافقة
  Stream<int> _buildActiveRequestsStream() {
    if (_familyId.isEmpty) return Stream.value(0);

    return FirebaseFirestore.instance
        .collection('requests')
        .where('familyId', isEqualTo: _familyId)
        .snapshots()
        .map((snap) => snap.docs.where((doc) {
              final status = doc.data()['status'] as String? ?? '';
              return status == 'قيد المعالجة' || status == 'تمت الموافقة';
            }).length);
  }

  @override
  Widget build(BuildContext context) {
    final family = AppCubit.get(context).currentFamily;
    final createdAt = (family?['createdAt'] as Timestamp?)?.toDate();
    final days = createdAt != null
        ? DateTime.now().difference(createdAt).inDays.toString()
        : '0';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // ── بطاقة المعرّف ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.background,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 35),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            family?['representativeName'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on),
                              Text(
                                '${family?['campName'] ?? ''} - ${family?['tentId'] ?? ''}',
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.badge, size: 22),
                                const SizedBox(width: 3),
                                Text(
                                  'IDP-${family?['id'].toString().substring(0, 6).toUpperCase() ?? ''}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.warning200.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_outline, color: AppColors.warningDark),
                        Text(
                          'البيانات للقراءة فقط — التعديل عبر المتطوع',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── الإحصائيات الأربع ─────────────────────────
            StreamBuilder<int>(
              stream: _activeRequestsStream,
              builder: (context, snapshot) {
                final activeCount = snapshot.data ?? 0;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    _dataItem(
                      icon: Icons.people_outline,
                      iconColor: const Color(0xFF4355B9),
                      iconBg: const Color(0xFFEEF0FF),
                      value: family?['membersCount'].toString() ?? '0',
                      label: 'أفراد الأسرة',
                    ),
                    _dataItem(
                      icon: Icons.assignment_outlined,
                      iconColor: const Color(0xFF92400E),
                      iconBg: const Color(0xFFFFF7ED),
                      value: activeCount.toString(),
                      label: 'طلبات نشطة',
                    ),
                    _dataItem(
                      icon: Icons.home_outlined,
                      iconColor: const Color(0xFF0F6E56),
                      iconBg: const Color(0xFFE1F5EE),
                      value: family?['tentId'] ?? '',
                      label: 'رقم الخيمة',
                    ),
                    _dataItem(
                      icon: Icons.calendar_today_outlined,
                      iconColor: const Color(0xFF27500A),
                      iconBg: const Color(0xFFEAF3DE),
                      value: days,
                      label: 'يوم مسجّل',
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            // ── المعلومات الشخصية ─────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.person_outline),
                      SizedBox(width: 6),
                      Text('المعلومات الشخصية'),
                    ],
                  ),
                  const Divider(thickness: 0.3),
                  _dataItem2(
                    icon: Icons.badge_outlined,
                    label: 'رقم الهوية',
                    value: family?['nationalId'] ?? '',
                  ),
                  const Divider(thickness: 0.1, height: 1),
                  _dataItem2(
                    icon: Icons.phone_outlined,
                    label: 'الهاتف',
                    value: family?['phone'] ?? '',
                  ),
                  const Divider(thickness: 0.1, height: 1),
                  _dataItem2(
                    icon: Icons.location_on_outlined,
                    label: 'مكان النزوح',
                    value: family?['originCity'] ?? '',
                  ),
                  const Divider(thickness: 0.1, height: 1),
                  _dataItem2(
                    icon: Icons.calendar_month_outlined,
                    label: 'تاريخ النزوح',
                    value: () {
                      final ts = family?['displacementDate'] as Timestamp?;
                      if (ts == null) return '';
                      final d = ts.toDate();
                      return '${d.day}/${d.month}/${d.year}';
                    }(),
                  ),
                  const Divider(thickness: 0.1, height: 1),
                  _dataItem2(
                    icon: Icons.accessible_outlined,
                    label: 'احتياجات خاصة',
                    value: family?['needs'] ?? '',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _dataItem2({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _dataItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
