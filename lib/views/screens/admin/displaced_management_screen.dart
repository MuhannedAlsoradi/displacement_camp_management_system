import 'package:displacement_camp_management_system/controllers/cubit/app_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../controllers/cubit/app_states.dart';
import '../../../utils/styles/colors.dart';

class DisplacedManagementScreen extends StatefulWidget {
  const DisplacedManagementScreen({super.key});

  @override
  State<DisplacedManagementScreen> createState() =>
      _DisplacedManagementScreenState();
}

class _DisplacedManagementScreenState extends State<DisplacedManagementScreen> {
  String _activeFilter = 'الكل';
  String _searchQuery = '';
  String? _selectedCamp;

  @override
  void initState() {
    super.initState();
    AppCubit.get(context).getFamilies();
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> all) {
    List<Map<String, dynamic>> result = List.from(all);

    if (_searchQuery.isNotEmpty) {
      result = result.where((f) {
        return (f['representativeName'] ?? '')
                .toString()
                .contains(_searchQuery) ||
            (f['nationalId'] ?? '').toString().contains(_searchQuery) ||
            (f['familyName'] ?? '').toString().contains(_searchQuery);
      }).toList();
    }

    if (_activeFilter == 'حسب المخيم' && _selectedCamp != null) {
      result = result
          .where((f) => f['campName']?.toString() == _selectedCamp)
          .toList();
    }

    if (_activeFilter == 'حسب الحجم') {
      result.sort((a, b) => (b['membersCount'] as int? ?? 0)
          .compareTo(a['membersCount'] as int? ?? 0));
    }

    return result;
  }

  List<String> _getCampNames(List<Map<String, dynamic>> families) {
    final names = families
        .map((f) => f['campName']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList();
    names.sort();
    return names;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listenWhen: (p, c) =>
          c is DeleteFamilySuccessState ||
          c is DeleteFamilyErrorState ||
          c is TentActionSuccessState ||
          c is TentActionErrorState,
      listener: (context, state) {
        if (state is DeleteFamilySuccessState) {
          _showSnack('تم حذف العائلة بنجاح', AppColors.statusStable);
          AppCubit.get(context).getFamilies();
        } else if (state is DeleteFamilyErrorState) {
          _showSnack('فشل الحذف: ${state.error}', AppColors.statusCritical);
        } else if (state is TentActionSuccessState) {
          _showSnack(state.message, AppColors.statusStable);
        } else if (state is TentActionErrorState) {
          _showSnack(state.error, AppColors.statusCritical);
        }
      },
      buildWhen: (p, c) =>
          c is DisplacedSuccessState ||
          c is DisplacedLoadingState ||
          c is DisplacedErrorState ||
          c is DeleteFamilySuccessState,
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        final allFamilies = cubit.families;
        final filtered = _applyFilters(allFamilies);
        final campNames = _getCampNames(allFamilies);
        final totalPersons = filtered.fold<int>(
            0, (s, f) => s + (f['membersCount'] as int? ?? 1));

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── شريط البحث ────────────────────────────────
              _SearchBar(
                onChanged: (v) => setState(() => _searchQuery = v),
              ),

              const SizedBox(height: 12),

              // ── الفلاتر ───────────────────────────────────
              _FilterRow(
                active: _activeFilter,
                campNames: campNames,
                selectedCamp: _selectedCamp,
                onFilterChanged: (f) => setState(() {
                  _activeFilter = f;
                  if (f != 'حسب المخيم') _selectedCamp = null;
                }),
                onCampSelected: (c) => setState(() => _selectedCamp = c),
              ),

              const SizedBox(height: 10),

              // ── عداد النتائج ──────────────────────────────
              _ResultsCounter(
                familyCount: filtered.length,
                totalPersons: totalPersons,
              ),

              const SizedBox(height: 8),

              // ── القائمة ───────────────────────────────────
              Expanded(
                child: _buildBody(state, filtered, cubit),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
      AppStates state, List<Map<String, dynamic>> filtered, AppCubit cubit) {
    if (state is DisplacedLoadingState) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state is DisplacedErrorState) {
      return _ErrorView(
        error: state.error,
        onRetry: () => AppCubit.get(context).getFamilies(),
      );
    }

    if (filtered.isEmpty) {
      return _EmptyView(hasQuery: _searchQuery.isNotEmpty);
    }

    return ListView.builder(
      itemCount: filtered.length,
      physics: const BouncingScrollPhysics(),
      // padding: const EdgeInsets.only(bottom: 0),
      itemBuilder: (context, index) {
        final f = filtered[index];
        return _FamilyCard(
          familyData: f,
          onDelete: () => _confirmDelete(f, cubit),
          onDetails: () => _showFamilyDetails(f),
          onAssignTent: () => _assignTentDialog(f, cubit),
        );
      },
    );
  }

  void _confirmDelete(Map<String, dynamic> family, AppCubit cubit) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.statusCritical, size: 22),
            SizedBox(width: 8),
            Text('تأكيد الحذف',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'هل تريد حذف عائلة "${family['familyName']}"؟\nلا يمكن التراجع عن هذه العملية.',
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
              cubit.deleteFamily(
                family['id'],
                family['campId'] ?? '',
                family['membersCount'] as int? ?? 0,
                tentDocId: family['tentDocId']?.toString() ?? '',
              );
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _assignTentDialog(Map<String, dynamic> family, AppCubit cubit) async {
    final campId = family['campId']?.toString() ?? '';
    if (campId.isEmpty) {
      _showSnack('هذه العائلة غير مرتبطة بمخيم', AppColors.statusCritical);
      return;
    }

    await cubit.getAvailableTents(campId);
    final currentTentDocId = family['tentDocId']?.toString() ?? '';
    final allTents = cubit.availableTents;
    final selectableTents = allTents.where((t) {
      final status = t['status']?.toString() ?? '';
      return status == 'متاحة' || t['id'] == currentTentDocId;
    }).toList();

    if (!mounted) return;

    String? selectedTentDocId =
        currentTentDocId.isNotEmpty ? currentTentDocId : null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'تعيين خيمة: ${family['familyName'] ?? ''}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: selectableTents.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'لا توجد خيام متاحة بهذا المخيم حالياً',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: selectableTents.map((t) {
                      final tentDocId = t['id'] as String;
                      final tentLabel = t['tentId']?.toString() ?? '';
                      final isCurrent = tentDocId == currentTentDocId;
                      final isSelected = selectedTentDocId == tentDocId;
                      return GestureDetector(
                        onTap: () =>
                            setDialogState(() => selectedTentDocId = tentDocId),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.holiday_village_outlined,
                                  size: 18,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textHint),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'خيمة رقم: $tentLabel'
                                  '${isCurrent ? ' (الحالية)' : ''}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: AppColors.primary, size: 18),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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
              onPressed: selectedTentDocId == null
                  ? null
                  : () {
                      final chosen = selectableTents
                          .firstWhere((t) => t['id'] == selectedTentDocId);
                      Navigator.pop(context);
                      cubit.assignTentToFamily(
                        familyId: family['id'],
                        campId: campId,
                        familyName: family['familyName']?.toString() ?? '',
                        newTentDocId: selectedTentDocId!,
                        newTentId: chosen['tentId']?.toString() ?? '',
                        oldTentDocId: currentTentDocId,
                      );
                    },
              child: const Text('تعيين'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFamilyDetails(Map<String, dynamic> family) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.family_restroom_rounded,
                            color: AppColors.primary, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              family['familyName'] ?? '',
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary),
                            ),
                            Text(
                              family['representativeName'] ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 16),
                  _detailRow(Icons.badge_outlined, 'رقم الهوية',
                      family['nationalId']?.toString() ?? '-'),
                  _detailRow(Icons.people_rounded, 'عدد الأفراد',
                      '${family['membersCount'] ?? 1} أفراد'),
                  _detailRow(Icons.location_city_rounded, 'المخيم',
                      family['campName']?.toString() ?? 'غير محدد'),
                  if ((family['originCity'] ?? '').toString().isNotEmpty)
                    _detailRow(Icons.home_rounded, 'مدينة الأصل',
                        family['originCity'].toString()),
                  if ((family['needs'] ?? '').toString().isNotEmpty)
                    _detailRow(Icons.volunteer_activism_rounded, 'الاحتياجات',
                        family['needs'].toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 10, color: AppColors.textHint)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
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

// ══════════════════════════════════════════════════════════════
//  شريط البحث
// ══════════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: TextField(
        onChanged: onChanged,
        textDirection: TextDirection.rtl,
        decoration: const InputDecoration(
          prefixIcon:
              Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
          hintText: 'ابحث بالاسم، اسم العائلة، أو رقم الهوية',
          hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  صف الفلاتر
// ══════════════════════════════════════════════════════════════
class _FilterRow extends StatelessWidget {
  final String active;
  final List<String> campNames;
  final String? selectedCamp;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String?> onCampSelected;

  const _FilterRow({
    required this.active,
    required this.campNames,
    required this.selectedCamp,
    required this.onFilterChanged,
    required this.onCampSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _chip('الكل', Icons.grid_view_rounded),
            const SizedBox(width: 8),
            _chip('حسب المخيم', Icons.location_city_rounded),
            const SizedBox(width: 8),
            _chip('حسب الحجم', Icons.sort_rounded),
          ],
        ),
        if (active == 'حسب المخيم' && campNames.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: campNames.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final name = campNames[i];
                final isSelected = selectedCamp == name;
                return GestureDetector(
                  onTap: () => onCampSelected(isSelected ? null : name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _chip(String label, IconData icon) {
    final isSelected = active == label;
    return GestureDetector(
      onTap: () => onFilterChanged(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  عداد النتائج
// ══════════════════════════════════════════════════════════════
class _ResultsCounter extends StatelessWidget {
  final int familyCount;
  final int totalPersons;
  const _ResultsCounter(
      {required this.familyCount, required this.totalPersons});

  @override
  Widget build(BuildContext context) {
    return Row(
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
              '$familyCount عائلة مسجلة',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'إجمالي الأفراد: $totalPersons',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  بطاقة عائلة — مع زر الخيارات (تفاصيل + حذف)
// ══════════════════════════════════════════════════════════════
class _FamilyCard extends StatelessWidget {
  final Map<String, dynamic> familyData;
  final VoidCallback onDelete;
  final VoidCallback onDetails;
  final VoidCallback onAssignTent;

  const _FamilyCard({
    required this.familyData,
    required this.onDelete,
    required this.onDetails,
    required this.onAssignTent,
  });

  String get nationalId => familyData['nationalId']?.toString() ?? '';
  String get familyName => familyData['familyName']?.toString() ?? '';
  String get representativeName =>
      familyData['representativeName']?.toString() ?? '';
  String get campName => familyData['campName']?.toString() ?? 'غير محدد';
  String get originCity => familyData['originCity']?.toString() ?? '';
  int get membersCount => familyData['membersCount'] as int? ?? 1;
  String get needs => familyData['needs']?.toString() ?? '';
  String get status => familyData['status']?.toString() ?? '';

  Color get _statusColor {
    switch (status) {
      case 'تم التسجيل':
        return AppColors.statusStable;
      case 'قيد المراجعة':
        return AppColors.statusWarning;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── أيقونة ──────────────────────────────────────
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.family_restroom_rounded,
                  color: AppColors.primary, size: 22),
            ),

            const SizedBox(width: 12),

            // ── المعلومات ────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          familyName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _StatusBadge(label: status, color: _statusColor),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'ممثل العائلة: $representativeName',
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      _InfoChip(
                          icon: Icons.location_city_rounded, label: campName),
                      if (originCity.isNotEmpty)
                        _InfoChip(icon: Icons.home_rounded, label: originCity),
                      _InfoChip(
                          icon: Icons.people_rounded,
                          label: '$membersCount أفراد'),
                    ],
                  ),
                  if (needs.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.volunteer_activism_rounded,
                            size: 11, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            needs,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10.5, color: AppColors.textHint),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 6),

            // ── قائمة الخيارات ───────────────────────────────
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  color: AppColors.textHint, size: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'details') onDetails();
                if (value == 'assign_tent') onAssignTent();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'details',
                  child: Row(children: [
                    Icon(Icons.info_outline,
                        size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('عرض التفاصيل'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'assign_tent',
                  child: Row(children: [
                    Icon(Icons.holiday_village_outlined,
                        size: 18, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text('تعيين خيمة'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline,
                        size: 18, color: AppColors.statusCritical),
                    SizedBox(width: 8),
                    Text('حذف العائلة',
                        style: TextStyle(color: AppColors.statusCritical)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Widgets مساعدة
// ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.textHint),
        const SizedBox(width: 3),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  حالات الخطأ والفراغ
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
            child: const Icon(Icons.wifi_off_rounded,
                color: AppColors.statusCritical, size: 40),
          ),
          const SizedBox(height: 12),
          const Text('تعذّر تحميل البيانات',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(error,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
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

class _EmptyView extends StatelessWidget {
  final bool hasQuery;
  const _EmptyView({this.hasQuery = false});

  @override
  Widget build(BuildContext context) {
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
            child: const Icon(Icons.family_restroom_rounded,
                size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          const Text('لا توجد نتائج',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            hasQuery
                ? 'جرّب كلمة بحث مختلفة'
                : 'جرّب تغيير الفلتر أو كلمة البحث',
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
