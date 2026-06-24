import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controllers/cubit/app_cubit.dart';
import '../../../controllers/cubit/app_states.dart';
import '../../../utils/styles/colors.dart';

class TentManagementScreen extends StatefulWidget {
  final Map<String, dynamic> camp;
  const TentManagementScreen({super.key, required this.camp});

  @override
  State<TentManagementScreen> createState() => _TentManagementScreenState();
}

class _TentManagementScreenState extends State<TentManagementScreen> {
  String _selectedFilter = 'الكل';
  final List<String> _filters = ['الكل', 'متاحة', 'غير متاحة'];

  @override
  void initState() {
    super.initState();
    AppCubit.get(context).getAvailableTents(widget.camp['id']);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listenWhen: (p, c) =>
          c is CampsErrorState ||
          c is TentActionSuccessState ||
          c is TentActionErrorState,
      listener: (context, state) {
        if (state is CampsErrorState) {
          _showSnack(state.error, AppColors.statusCritical);
        } else if (state is TentActionSuccessState) {
          _showSnack(state.message, AppColors.statusStable);
        } else if (state is TentActionErrorState) {
          _showSnack(state.error, AppColors.statusCritical);
        }
      },
      buildWhen: (p, c) =>
          c is CampsLoadingState ||
          c is CampsSuccessState ||
          c is CampsErrorState ||
          c is TentActionLoadingState,
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        final allTents = cubit.availableTents;

        final filtered = _selectedFilter == 'الكل'
            ? allTents
            : allTents
                .where((t) => t['status']?.toString() == _selectedFilter)
                .toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundPage,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundCard,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: AppColors.textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خيام: ${widget.camp['name'] ?? ''}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.camp['location'] ?? '',
                  style:
                      const TextStyle(color: AppColors.textHint, fontSize: 11),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: AppColors.primary, size: 22),
                onPressed: () => cubit.getAvailableTents(widget.camp['id']),
              ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, thickness: 1, color: AppColors.border),
            ),
          ),
          body: Column(
            children: [
              // ── ملخص المخيم ────────────────────────────────
              _buildCampSummary(),

              // ── الفلاتر ────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: _filters.map((f) {
                    final isSelected = _selectedFilter == f;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            f,
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
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── عداد ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} خيمة',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddTentDialog(context, cubit),
                      icon: const Icon(Icons.add,
                          size: 16, color: AppColors.primary),
                      label: const Text('إضافة خيمة',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
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
              ),
              const SizedBox(height: 8),

              // ── القائمة ────────────────────────────────────
              Expanded(
                child: state is CampsLoadingState
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary))
                    : filtered.isEmpty
                        ? _emptyState()
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) =>
                                _tentCard(filtered[index], cubit),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCampSummary() {
    final capacity = widget.camp['capacity'] as int? ?? 0;
    final current = widget.camp['current'] as int? ?? 0;
    final percent = capacity == 0 ? 0.0 : (current / capacity).clamp(0.0, 1.0);
    final status = widget.camp['status']?.toString() ?? '';

    Color statusColor;
    switch (status) {
      case 'متاح':
        statusColor = AppColors.statusStable;
        break;
      case 'ممتلئ تقريباً':
        statusColor = AppColors.statusWarning;
        break;
      default:
        statusColor = AppColors.statusCritical;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem('السعة الكلية', '$capacity', AppColors.primary),
              _summaryItem('المقيمون', '$current', AppColors.secondary),
              _summaryItem(
                  'المتاح', '${capacity - current}', AppColors.statusStable),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              color: percent > 0.9
                  ? AppColors.statusCritical
                  : percent > 0.7
                      ? AppColors.statusWarning
                      : AppColors.statusStable,
              backgroundColor: AppColors.border,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('نسبة الإشغال',
                  style: TextStyle(color: AppColors.textHint, fontSize: 10)),
              Text('${(percent * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _tentCard(Map<String, dynamic> tent, AppCubit cubit) {
    final status = tent['status']?.toString() ?? '';
    final isAvailable = status == 'متاحة';
    final statusColor =
        isAvailable ? AppColors.statusStable : AppColors.statusCritical;
    final tentId = tent['tentId']?.toString() ?? '';
    final capacity = tent['capacity'] as int? ?? 4;
    final assignedFamily = tent['assignedFamily']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── أيقونة ──────────────────────────
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.holiday_village_rounded,
                color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),

          // ── المعلومات ───────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'خيمة رقم: $tentId',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(status,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('السعة: $capacity أفراد',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                if (assignedFamily.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.people_rounded,
                          size: 12, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(assignedFamily,
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 11)),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── القائمة ─────────────────────────
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: AppColors.textHint, size: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) => _onTentAction(value, tent, cubit),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'toggle',
                child: Row(children: [
                  Icon(
                    isAvailable ? Icons.lock_outline : Icons.lock_open_rounded,
                    size: 18,
                    color: isAvailable
                        ? AppColors.statusWarning
                        : AppColors.statusStable,
                  ),
                  const SizedBox(width: 8),
                  Text(isAvailable ? 'تعيين كغير متاحة' : 'تعيين كمتاحة'),
                ]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline,
                      size: 18, color: AppColors.statusCritical),
                  SizedBox(width: 8),
                  Text('حذف',
                      style: TextStyle(color: AppColors.statusCritical)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onTentAction(String action, Map<String, dynamic> tent, AppCubit cubit) {
    if (action == 'toggle') {
      final currentStatus = tent['status']?.toString() ?? 'متاحة';
      final newStatus = currentStatus == 'متاحة' ? 'غير متاحة' : 'متاحة';
      cubit.updateTentStatus(
        campId: widget.camp['id'],
        tentDocId: tent['id'],
        newStatus: newStatus,
      );
    } else if (action == 'delete') {
      _confirmDeleteTent(tent, cubit);
    }
  }

  void _confirmDeleteTent(Map<String, dynamic> tent, AppCubit cubit) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.statusCritical, size: 22),
          SizedBox(width: 8),
          Text('تأكيد الحذف',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        content: Text(
          'هل تريد حذف خيمة رقم "${tent['tentId']}"؟',
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
              cubit.deleteTent(
                campId: widget.camp['id'],
                tentDocId: tent['id'],
              );
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAddTentDialog(BuildContext context, AppCubit cubit) {
    final tentIdController = TextEditingController();
    final capacityController = TextEditingController(text: '4');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إضافة خيمة جديدة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(
              controller: tentIdController,
              label: 'رقم الخيمة',
              hint: 'مثال: T001',
              icon: Icons.holiday_village_outlined,
            ),
            const SizedBox(height: 12),
            _dialogField(
              controller: capacityController,
              label: 'السعة (عدد الأفراد)',
              hint: '4',
              icon: Icons.people_outline,
              keyboardType: TextInputType.number,
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
              final tentId = tentIdController.text.trim();
              final capacity =
                  int.tryParse(capacityController.text.trim()) ?? 4;
              if (tentId.isEmpty) return;

              Navigator.pop(context);
              cubit.addTent(
                campId: widget.camp['id'],
                tentId: tentId,
                capacity: capacity,
              );
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.backgroundPage,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            child: Icon(Icons.holiday_village_outlined,
                color: AppColors.primary.withOpacity(0.4), size: 48),
          ),
          const SizedBox(height: 14),
          const Text('لا توجد خيام',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            _selectedFilter == 'الكل'
                ? 'لم يتم إضافة أي خيام لهذا المخيم بعد'
                : 'لا توجد خيام بحالة "$_selectedFilter"',
            style: const TextStyle(color: AppColors.textHint, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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