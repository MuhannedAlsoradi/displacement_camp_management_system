import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:displacement_camp_management_system/shared/cubit/app_cubit.dart';
import 'package:displacement_camp_management_system/styles/colors.dart';
import 'package:flutter/material.dart';

class IdpAidRequestScreen extends StatefulWidget {
  const IdpAidRequestScreen({super.key});

  @override
  State<IdpAidRequestScreen> createState() => _IdpAidRequestScreenState();
}

class _IdpAidRequestScreenState extends State<IdpAidRequestScreen> {
  String? _selectedType;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _requestTypes = [
    {
      'type': 'غذاء',
      'label': 'سلة غذائية',
      'icon': Icons.fastfood_outlined,
      'iconColor': const Color(0xFF0F6E56),
      'iconBg': const Color(0xFFE1F5EE),
    },
    {
      'type': 'طبي',
      'label': 'مساعدة طبية',
      'icon': Icons.medical_services_outlined,
      'iconColor': const Color(0xFFA32D2D),
      'iconBg': const Color(0xFFFCEBEB),
    },
    {
      'type': 'مياه',
      'label': 'مياه',
      'icon': Icons.water_drop_outlined,
      'iconColor': const Color(0xFF185FA5),
      'iconBg': const Color(0xFFE6F1FB),
    },
    {
      'type': 'ملابس',
      'label': 'ملابس',
      'icon': Icons.checkroom_outlined,
      'iconColor': const Color(0xFF92400E),
      'iconBg': const Color(0xFFFFF7ED),
    },
    {
      'type': 'مأوى',
      'label': 'دعم مأوى',
      'icon': Icons.home_outlined,
      'iconColor': const Color(0xFF4355B9),
      'iconBg': const Color(0xFFEEF0FF),
    },
    {
      'type': 'نفسي',
      'label': 'دعم نفسي',
      'icon': Icons.psychology_outlined,
      'iconColor': const Color(0xFF633806),
      'iconBg': const Color(0xFFFAEEDA),
    },
  ];

  // ← نجيب الـ familyId مرة واحدة هنا ونحفظه
  late final String _familyId =
      AppCubit.get(context).currentFamily?['id'] ?? '';

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر نوع الطلب أولاً')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final family = AppCubit.get(context).currentFamily;
      await FirebaseFirestore.instance.collection('requests').add({
        'familyId': family?['id'] ?? '',
        'familyName': family?['familyName'] ?? '',
        'campName': family?['campName'] ?? '',
        'requestType': _selectedType,
        'notes': _notesController.text.trim(),
        'status': 'قيد المعالجة',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _notesController.clear();
        setState(() => _selectedType = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال طلبك بنجاح'),
            backgroundColor: Color(0xFF0F6E56),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ، حاول مرة أخرى'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── وصف الشاشة ───────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F1FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF185FA5), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'اختر نوع المساعدة التي تحتاجها وسيتم مراجعة طلبك من قِبل إدارة المخيم',
                      style: TextStyle(fontSize: 12, color: Color(0xFF185FA5)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── اختيار نوع الطلب ─────────────────────────
            const Text(
              'نوع الطلب',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.2,
              physics: const NeverScrollableScrollPhysics(),
              children: _requestTypes.map((item) {
                final isSelected = _selectedType == item['type'];
                return InkWell(
                  onTap: () =>
                      setState(() => _selectedType = item['type'] as String),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.08)
                          : AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: item['iconBg'] as Color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: item['iconColor'] as Color,
                            size: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle,
                              color: AppColors.primary, size: 16),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            // ── ملاحظات إضافية ────────────────────────────
            const Text(
              'ملاحظات إضافية (اختياري)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'أضف تفاصيل إضافية عن طلبك...',
                hintStyle:
                    const TextStyle(fontSize: 12, color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.backgroundCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.border, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.border, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.primary, width: 1),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── زر الإرسال ────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'إرسال الطلب',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 14),

            // ── طلباتي السابقة ────────────────────────────
            const Text(
              'طلباتي السابقة',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            // ← نمرر _familyId المحفوظ وليس من context مباشرة
            _PreviousRequestsSection(familyId: _familyId),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// StatefulWidget — الـ stream لا يتأثر بـ setState الأب
// ════════════════════════════════════════════════════════
class _PreviousRequestsSection extends StatefulWidget {
  final String familyId;
  const _PreviousRequestsSection({required this.familyId});

  @override
  State<_PreviousRequestsSection> createState() =>
      _PreviousRequestsSectionState();
}

class _PreviousRequestsSectionState extends State<_PreviousRequestsSection> {
  Color _statusColor(String status) {
    switch (status) {
      case 'قيد المعالجة':
        return const Color(0xFF92400E);
      case 'تمت الموافقة':
        return const Color(0xFF185FA5);
      case 'مكتمل':
        return const Color(0xFF27500A);
      case 'مرفوض':
        return const Color(0xFFA32D2D);
      default:
        return AppColors.textHint;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'قيد المعالجة':
        return const Color(0xFFFFF7ED);
      case 'تمت الموافقة':
        return const Color(0xFFE6F1FB);
      case 'مكتمل':
        return const Color(0xFFEAF3DE);
      case 'مرفوض':
        return const Color(0xFFFCEBEB);
      default:
        return AppColors.background;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'قيد المعالجة':
        return Icons.hourglass_empty_outlined;
      case 'تمت الموافقة':
        return Icons.thumb_up_alt_outlined;
      case 'مكتمل':
        return Icons.check_circle_outline;
      case 'مرفوض':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  // ← يُنشأ مرة واحدة فقط ولا يُعاد بناؤه أبداً
  // بدون orderBy في الـ query لتجنب الحاجة لـ composite index
  // الترتيب يصير محلياً بعد جلب البيانات
  late final Stream<QuerySnapshot> _stream = FirebaseFirestore.instance
      .collection('requests')
      .where('familyId', isEqualTo: widget.familyId)
      .limit(10)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    if (widget.familyId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final rawDocs = snapshot.data?.docs ?? [];

        // ترتيب محلي بالتاريخ تنازلياً (بدل orderBy في الـ query)
        final docs = [...rawDocs]..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime =
                (aData['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bTime =
                (bData['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            return bTime.compareTo(aTime);
          });

        if (docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: const Text(
              'لا توجد طلبات سابقة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            children: docs.asMap().entries.map((entry) {
              final i = entry.key;
              final data = entry.value.data() as Map<String, dynamic>;
              final isLast = i == docs.length - 1;
              final status = data['status'] as String? ?? '';
              final date = (data['createdAt'] as Timestamp?)?.toDate();
              final dateStr =
                  date != null ? '${date.day}/${date.month}/${date.year}' : '';

              return Column(
                children: [
                  ListTile(
                    dense: true,
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _statusBg(status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _statusIcon(status),
                        size: 16,
                        color: _statusColor(status),
                      ),
                    ),
                    title: Text(
                      data['requestType'] ?? '',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      dateStr,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textHint),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusBg(status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _statusColor(status),
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, thickness: 0.5, indent: 12),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
