import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/styles/colors.dart';
import '../../../controllers/cubit/app_cubit.dart';
import '../../../controllers/cubit/app_states.dart';

class VolunteerInquiryScreen extends StatefulWidget {
  const VolunteerInquiryScreen({super.key});

  @override
  State<VolunteerInquiryScreen> createState() =>
      _VolunteerInquiryScreenState();
}

class _VolunteerInquiryScreenState extends State<VolunteerInquiryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    AppCubit.get(context).getFamilies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        title: const Text(
          'استفسار عن العائلات',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          /// شريط البحث
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم أو رقم الهوية أو المخيم...',
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textHint, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppColors.textHint, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.backgroundCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
          ),

          /// القائمة
          Expanded(
            child: BlocBuilder<AppCubit, AppStates>(
              builder: (context, state) {
                final cubit = AppCubit.get(context);

                if (state is DisplacedLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = cubit.families.where((f) {
                  final name =
                      (f['familyName'] ?? '').toString().toLowerCase();
                  final rep = (f['representativeName'] ?? '')
                      .toString()
                      .toLowerCase();
                  final id =
                      (f['nationalId'] ?? '').toString().toLowerCase();
                  final camp =
                      (f['campName'] ?? '').toString().toLowerCase();
                  final q = _searchQuery.toLowerCase();
                  return name.contains(q) ||
                      rep.contains(q) ||
                      id.contains(q) ||
                      camp.contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return _emptyState();
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _familyCard(filtered[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _familyCard(Map<String, dynamic> family) {
    return GestureDetector(
      onTap: () => _showFamilyDetails(family),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.secondary50,
              radius: 22,
              child: Text(
                (family['familyName'] ?? 'أ').toString().substring(0, 1),
                style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    family['familyName'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ممثل: ${family['representativeName'] ?? ''}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _badge(
                        family['campName'] ?? 'غير محدد',
                        Icons.location_on,
                        AppColors.warning,
                      ),
                      const SizedBox(width: 6),
                      _badge(
                        '${family['membersCount'] ?? 0} فرد',
                        Icons.group,
                        AppColors.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }

  void _showFamilyDetails(Map<String, dynamic> family) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.secondary50,
                  radius: 28,
                  child: Text(
                    (family['familyName'] ?? 'أ')
                        .toString()
                        .substring(0, 1),
                    style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      family['familyName'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      family['status'] ?? 'تم التسجيل',
                      style: const TextStyle(
                          color: AppColors.success, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),

            /// التفاصيل
            _detailRow('ممثل العائلة',
                family['representativeName'] ?? '', Icons.person),
            _detailRow(
                'رقم الهوية', family['nationalId'] ?? '', Icons.badge),
            _detailRow('عدد الأفراد',
                '${family['membersCount'] ?? 0} فرد', Icons.group),
            _detailRow(
                'المخيم', family['campName'] ?? '', Icons.location_on),
            _detailRow('المدينة الأصلية',
                family['originCity'] ?? '', Icons.location_city),
            if ((family['needs'] ?? '').isNotEmpty)
              _detailRow(
                  'الاحتياجات', family['needs'], Icons.medical_services),
            if ((family['tentId'] ?? '').isNotEmpty)
              _detailRow('الخيمة', 'خيمة ${family['tentId']}',
                  Icons.house),

            const SizedBox(height: 16),

            /// زر تحديث الاحتياجات
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showUpdateNeedsDialog(family);
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('تحديث الاحتياجات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateNeedsDialog(Map<String, dynamic> family) {
    final needsController =
        TextEditingController(text: family['needs'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تحديث الاحتياجات',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextFormField(
          controller: needsController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'أدخل احتياجات الأسرة...',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          BlocConsumer<AppCubit, AppStates>(
            listener: (context, state) {
              if (state is DisplacedSuccessState) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث الاحتياجات بنجاح'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            builder: (context, state) {
              return ElevatedButton(
                onPressed: () {
                  AppCubit.get(context).updateFamily(
                    family['id'],
                    {'needs': needsController.text.trim()},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('حفظ'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off,
              color: AppColors.textHint, size: 48),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isEmpty
                ? 'لا توجد عائلات مسجلة'
                : 'لا توجد نتائج للبحث',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
