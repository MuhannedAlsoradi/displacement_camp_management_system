import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../utils/styles/colors.dart';
import '../../../controllers/cubit/app_cubit.dart';
import '../../../controllers/cubit/app_states.dart';
import 'add_camp_screen.dart';
import 'tent_management_screen.dart';

class CampsManagementScreen extends StatefulWidget {
  const CampsManagementScreen({super.key});

  @override
  State<CampsManagementScreen> createState() => _CampsManagementScreenState();
}

class _CampsManagementScreenState extends State<CampsManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'الكل';
  List<Map<String, dynamic>> _filteredCamps = [];

  final List<String> _filters = [
    'الكل',
    'متاح',
    'ممتلئ تقريباً',
    'قيد الصيانة',
  ];

  @override
  void initState() {
    super.initState();
    AppCubit.get(context).getCamps();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter(List<Map<String, dynamic>> camps) {
    final query = _searchController.text.trim().toLowerCase();

    _filteredCamps = camps.where((camp) {
      final matchSearch = query.isEmpty ||
          camp['name'].toString().toLowerCase().contains(query) ||
          camp['location'].toString().toLowerCase().contains(query);

      final matchFilter = _selectedFilter == 'الكل' ||
          camp['status'].toString() == _selectedFilter;

      return matchSearch && matchFilter;
    }).toList();
  }

  // ─── لون الحالة (الثلاث حالات) ───────────────────────────────
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'متاح':
        return AppColors.statusStable;
      case 'ممتلئ تقريباً':
        return AppColors.statusWarning;
      case 'قيد الصيانة':
        return AppColors.statusCritical;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listenWhen: (p, c) =>
          c is DeleteCampSuccessState ||
          c is DeleteCampErrorState ||
          c is UpdateCampSuccessState,
      listener: (context, state) {
        if (state is DeleteCampSuccessState) {
          _showSnack('تم حذف المخيم بنجاح', AppColors.statusStable);
        } else if (state is DeleteCampErrorState) {
          _showSnack('فشل الحذف: ${state.error}', AppColors.statusCritical);
        } else if (state is UpdateCampSuccessState) {
          _showSnack('تم تحديث المخيم بنجاح', AppColors.statusStable);
        }
      },
      buildWhen: (prev, curr) =>
          curr is CampsLoadingState ||
          curr is CampsSuccessState ||
          curr is CampsErrorState ||
          curr is DeleteCampSuccessState ||
          curr is UpdateCampSuccessState,
      builder: (context, state) {
        final cubit = AppCubit.get(context);

        if (state is CampsLoadingState) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is CampsErrorState) {
          return _ErrorView(
            error: state.error,
            onRetry: () => cubit.getCamps(),
          );
        }

        _applyFilter(cubit.camps);

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            children: [
              // ─── شريط البحث ──────────────────────────────
              _buildSearchBar(),

              const SizedBox(height: 10),

              // ─── الفلاتر ──────────────────────────────────
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    final filterColor = filter == 'الكل'
                        ? AppColors.primary
                        : _getStatusColor(filter);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? filterColor
                              : AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? filterColor : AppColors.border,
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // ─── عداد النتائج ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_filteredCamps.length} مخيم',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // زر إضافة مخيم
                  TextButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddCampScreen(),
                        ),
                      );
                      cubit.getCamps();
                    },
                    icon: const Icon(Icons.add,
                        size: 16, color: AppColors.primary),
                    label: const Text(
                      'إضافة مخيم',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      backgroundColor: AppColors.primary.withOpacity(0.07),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ─── القائمة ──────────────────────────────────
              Expanded(
                child: _filteredCamps.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        // padding: const EdgeInsets.only(bottom: 20),
                        itemCount: _filteredCamps.length,
                        itemBuilder: (context, index) =>
                            _campCard(_filteredCamps[index], cubit),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── شريط البحث ──────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: TextField(
        controller: _searchController,
        textDirection: TextDirection.rtl,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'ابحث باسم المخيم أو الموقع...',
          hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textHint, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textHint, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          filled: true,
          fillColor: AppColors.backgroundCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ─── بطاقة المخيم ────────────────────────────────────────────
  Widget _campCard(Map<String, dynamic> camp, AppCubit cubit) {
    final int capacity = camp['capacity'] ?? 1;
    final int current = camp['current'] ?? 0;
    final double percent = (current / capacity).clamp(0.0, 1.0);
    final String status = camp['status']?.toString() ?? '';

    final Color statusColor = _getStatusColor(status);
    final Color progressColor = percent > 0.9
        ? AppColors.statusCritical
        : percent > 0.7
            ? AppColors.statusWarning
            : AppColors.statusStable;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.backgroundCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─── الجزء العلوي (صورة + معلومات فوقها) ──────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                child: _buildCampImage(camp['image']),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.75),
                      ],
                      stops: const [0.4, 0.65, 1.0],
                    ),
                  ),
                ),
              ),

              // شارة الحالة (أعلى يمين)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

              // قائمة الخيارات (أعلى يسار)
              Positioned(
                top: 8,
                left: 8,
                child: PopupMenuButton<String>(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black38,
                    radius: 16,
                    child: Icon(Icons.more_vert, color: Colors.white, size: 18),
                  ),
                  onSelected: (value) => _onCampAction(value, camp, cubit),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined,
                            size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('تعديل الحالة'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline,
                            size: 18, color: AppColors.statusCritical),
                        const SizedBox(width: 8),
                        Text('حذف المخيم',
                            style: TextStyle(color: AppColors.statusCritical)),
                      ]),
                    ),
                  ],
                ),
              ),

              // اسم وموقع المخيم (أسفل)
              Positioned(
                bottom: 10,
                right: 12,
                left: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      camp['name'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          camp['location'] ?? '',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ─── إحصائيات ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('السعة الإجمالية', _formatNumber(capacity)),
                  Container(width: 1, height: 30, color: AppColors.border),
                  _statItem('المقيمون حالياً', _formatNumber(current)),
                  Container(width: 1, height: 30, color: AppColors.border),
                  _statItem('المتاح', _formatNumber(capacity - current)),
                ],
              ),
            ),
          ),

          // ─── شريط الإشغال ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'نسبة الإشغال',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(percent * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    color: progressColor,
                    backgroundColor: AppColors.border,
                  ),
                ),
              ],
            ),
          ),

          // ─── زر إدارة الخيام ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TentManagementScreen(camp: camp),
                    ),
                  );
                },
                icon: const Icon(Icons.holiday_village_rounded,
                    size: 18, color: AppColors.primary),
                label: const Text(
                  'إدارة الخيام',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCampImage(String? imagePath) {
    // لا توجد صورة
    if (imagePath == null || imagePath.isEmpty) {
      return _imagePlaceholder();
    }

    // رابط HTTPS كامل (مثل الصور الجديدة من Firebase Storage)
    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: 150,
          color: AppColors.primary.withOpacity(0.05),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => _imagePlaceholder(),
      );
    }

    // مسار داخل Firebase Storage (مثل "images/camps/image2.png")
    // نحوّله لرابط HTTPS عبر FutureBuilder
    return FutureBuilder<String>(
      future: FirebaseStorage.instance.ref(imagePath).getDownloadURL(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 150,
            color: AppColors.primary.withOpacity(0.05),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _imagePlaceholder();
        }
        return CachedNetworkImage(
          imageUrl: snapshot.data!,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _imagePlaceholder(),
        );
      },
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.holiday_village_outlined,
              color: AppColors.primary.withOpacity(0.4), size: 40),
          const SizedBox(height: 4),
          Text(
            'لا توجد صورة',
            style: TextStyle(
                color: AppColors.primary.withOpacity(0.4), fontSize: 11),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.location_off_outlined,
                color: AppColors.primary.withOpacity(0.4), size: 48),
          ),
          const SizedBox(height: 14),
          const Text(
            'لا توجد مخيمات',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _searchController.text.isNotEmpty
                ? 'جرب بحثاً مختلفاً'
                : 'لم يتم إضافة أي مخيمات بعد',
            style: const TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─── Actions ──────────────────────────────────────────────────

  void _onCampAction(String action, Map<String, dynamic> camp, AppCubit cubit) {
    if (action == 'delete') {
      _confirmDelete(camp, cubit);
    } else if (action == 'edit') {
      _showEditDialog(camp, cubit);
    }
  }

  void _confirmDelete(Map<String, dynamic> camp, AppCubit cubit) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.statusCritical, size: 22),
            const SizedBox(width: 8),
            const Text('تأكيد الحذف',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'هل تريد حذف مخيم "${camp['name']}"؟\nلا يمكن التراجع عن هذه العملية.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
            onPressed: () {
              Navigator.pop(context);
              cubit.deleteCamp(camp['id']);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> camp, AppCubit cubit) {
    final statusOptions = ['متاح', 'ممتلئ تقريباً', 'قيد الصيانة'];
    String selectedStatus = camp['status'] ?? 'متاح';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'تعديل: ${camp['name']}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('اختر حالة المخيم:',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 10),
              ...statusOptions.map(
                (s) {
                  final color = _getStatusColor(s);
                  final isSelected = selectedStatus == s;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedStatus = s),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? color : Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            s,
                            style: TextStyle(
                              color: isSelected ? color : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(context);
                cubit.updateCamp(camp['id'], {'status': selectedStatus});
              },
              child: const Text('حفظ التغييرات'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return '$number';
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  حالة الخطأ
// ══════════════════════════════════════════════════════════════
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.statusCritical.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.wifi_off_rounded,
                color: AppColors.statusCritical, size: 40),
          ),
          const SizedBox(height: 12),
          const Text('تعذّر تحميل المخيمات',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 15)),
          const SizedBox(height: 4),
          Text(error,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
