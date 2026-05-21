import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../styles/colors.dart';
import '../../../shared/cubit/app_cubit.dart';
import '../../../shared/cubit/app_states.dart';

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
    'قيد الصيانة'
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      buildWhen: (prev, curr) =>
          curr is CampsLoadingState ||
          curr is CampsSuccessState ||
          curr is CampsErrorState,
      builder: (context, state) {
        final cubit = AppCubit.get(context);

        if (state is CampsLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CampsErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(state.error,
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => cubit.getCamps(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        _applyFilter(cubit.camps);

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            children: [
              // ─── البحث ────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border.withOpacity(0.5)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'بحث عن مخيم...',
                    hintStyle:
                        TextStyle(color: AppColors.textHint, fontSize: 13),
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.textHint),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close,
                                color: AppColors.textHint),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                    filled: true,
                    fillColor: AppColors.backgroundCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

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
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: Chip(
                        label: Text(filter),
                        backgroundColor: isSelected
                            ? AppColors.primary
                            : AppColors.backgroundCard,
                        labelStyle: TextStyle(
                          color:
                              isSelected ? Colors.white : AppColors.textPrimary,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // ─── عدد النتائج ──────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'النتائج: ${_filteredCamps.length} مخيم',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ─── القائمة ──────────────────────────────────
              Expanded(
                child: _filteredCamps.isEmpty
                    ? _emptyState()
                    : ListView.builder(
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

  // ─── Widgets ────────────────────────────────────────────

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off_outlined,
              color: AppColors.textHint, size: 48),
          const SizedBox(height: 12),
          const Text(
            'لا توجد مخيمات',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
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

  Widget _campCard(Map<String, dynamic> camp, AppCubit cubit) {
    final int capacity = camp['capacity'] ?? 1;
    final int current = camp['current'] ?? 0;
    final double percent = (current / capacity).clamp(0.0, 1.0);

    final Color statusColor = camp['status'] == 'متاح'
        ? AppColors.statusStable
        : AppColors.statusCritical;

    final Color progressColor = percent > 0.9
        ? AppColors.statusCritical
        : percent > 0.7
            ? AppColors.statusWarning
            : AppColors.statusStable;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.backgroundCard,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: _buildCampImage(camp['image']),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.5, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
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
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        camp['status'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              // زر الخيارات
              Positioned(
                top: 8,
                left: 8,
                child: PopupMenuButton<String>(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: Icon(Icons.more_vert, color: Colors.white, size: 18),
                  ),
                  onSelected: (value) => _onCampAction(value, camp, cubit),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('تعديل'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('حذف', style: TextStyle(color: Colors.red)),
                      ]),
                    ),
                  ],
                ),
              ),

              // اسم وموقع المخيم
              Positioned(
                bottom: 10,
                right: 10,
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
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white, size: 16),
                        Text(
                          camp['location'] ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ─── إحصائيات ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
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
                ],
              ),
            ),
          ),

          // ─── شريط الإشغال ────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'نسبة الإشغال',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(percent * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: progressColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 10,
                color: progressColor,
                backgroundColor: AppColors.border,
              ),
            ),
          ),
          const SizedBox(height: 12),
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
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  Widget _buildCampImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return _imagePlaceholder();
    }
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }
    return Image.asset(
      imagePath,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: AppColors.surfaceSecondary,
      child: const Icon(Icons.image_not_supported_outlined,
          color: AppColors.textHint, size: 48),
    );
  }

  // ─── Actions ────────────────────────────────────────────

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
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف ${camp['name']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              cubit.deleteCamp(camp['id']);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
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
          title: Text('تعديل ${camp['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('الحالة:',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              ...statusOptions.map(
                (s) => RadioListTile<String>(
                  title: Text(s),
                  value: s,
                  groupValue: selectedStatus,
                  onChanged: (v) => setDialogState(() => selectedStatus = v!),
                  activeColor: AppColors.primary,
                  dense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                Navigator.pop(context);
                cubit.updateCamp(camp['id'], {'status': selectedStatus});
              },
              child: const Text('حفظ', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return '$number';
  }
}
