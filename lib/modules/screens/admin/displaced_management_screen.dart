import 'package:displacement_camp_management_system/shared/cubit/app_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/cubit/app_states.dart';
import '../../../styles/colors.dart';

class DisplacedManagementScreen extends StatefulWidget {
  const DisplacedManagementScreen({super.key});

  @override
  State<DisplacedManagementScreen> createState() =>
      _DisplacedManagementScreenState();
}

class _DisplacedManagementScreenState extends State<DisplacedManagementScreen> {
  String _activeFilter = 'الكل';
  String _searchQuery = '';

  // ── قائمة المخيمات للفلتر "حسب المخيم" ────────────────────
  String? _selectedCamp;

  @override
  void initState() {
    super.initState();
    AppCubit.get(context).getFamilies();
  }

  // ══════════════════════════════════════════════════════════
  //  منطق الفلترة المحلي (بدون استدعاءات Firestore إضافية)
  // ══════════════════════════════════════════════════════════
  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> all) {
    List<Map<String, dynamic>> result = List.from(all);

    // 1. فلتر البحث النصي
    if (_searchQuery.isNotEmpty) {
      result = result.where((f) {
        return (f['representativeName'] ?? '')
                .toString()
                .contains(_searchQuery) ||
            (f['nationalId'] ?? '').toString().contains(_searchQuery) ||
            (f['familyName'] ?? '').toString().contains(_searchQuery);
      }).toList();
    }

    // 2. فلتر المخيم
    if (_activeFilter == 'حسب المخيم' && _selectedCamp != null) {
      result = result
          .where((f) => f['campName']?.toString() == _selectedCamp)
          .toList();
    }

    // 3. فلتر الحجم (تنازلي حسب عدد الأفراد)
    if (_activeFilter == 'حسب الحجم') {
      result.sort((a, b) => (b['membersCount'] as int? ?? 0)
          .compareTo(a['membersCount'] as int? ?? 0));
    }

    return result;
  }

  // جمع أسماء المخيمات الموجودة في القائمة
  List<String> _getCampNames(List<Map<String, dynamic>> families) {
    final names = families
        .map((f) => f['campName']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList();
    names.sort();
    return names;
  }

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      buildWhen: (p, c) =>
          c is DisplacedSuccessState ||
          c is DisplacedLoadingState ||
          c is DisplacedErrorState,
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
              // ── شريط البحث ───────────────────────────────
              _SearchBar(
                onChanged: (v) => setState(() => _searchQuery = v),
              ),

              const SizedBox(height: 12),

              // ── الفلاتر ──────────────────────────────────
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

              // ── عداد النتائج ─────────────────────────────
              _ResultsCounter(
                familyCount: filtered.length,
                totalPersons: totalPersons,
              ),

              const SizedBox(height: 8),

              // ── القائمة ──────────────────────────────────
              Expanded(
                child: _buildBody(state, filtered),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(AppStates state, List<Map<String, dynamic>> filtered) {
    if (state is DisplacedLoadingState) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is DisplacedErrorState) {
      return _ErrorView(
        error: state.error,
        onRetry: () => AppCubit.get(context).getFamilies(),
      );
    }

    if (filtered.isEmpty) {
      return const _EmptyView();
    }

    return ListView.builder(
      itemCount: filtered.length,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        final f = filtered[index];
        return _FamilyCard(
          nationalId: f['nationalId']?.toString() ?? '',
          familyName: f['familyName']?.toString() ?? '',
          representativeName: f['representativeName']?.toString() ?? '',
          campName: f['campName']?.toString() ?? 'غير محدد',
          originCity: f['originCity']?.toString() ?? '',
          membersCount: f['membersCount'] as int? ?? 1,
          needs: f['needs']?.toString() ?? '',
          status: f['status']?.toString() ?? '',
        );
      },
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
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textHint),
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
        // ── الثلاثة زراراير ──────────────────────────────
        Row(
          children: [
            _chip('الكل', Icons.grid_view_rounded),
            const SizedBox(width: 8),
            _chip('حسب المخيم', Icons.location_city_rounded),
            const SizedBox(width: 8),
            _chip('حسب الحجم', Icons.sort_rounded),
          ],
        ),

        // ── قائمة المخيمات (تظهر فقط عند اختيار "حسب المخيم") ──
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
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
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
//  بطاقة عائلة
// ══════════════════════════════════════════════════════════════
class _FamilyCard extends StatelessWidget {
  final String nationalId;
  final String familyName;
  final String representativeName;
  final String campName;
  final String originCity;
  final int membersCount;
  final String needs;
  final String status;

  const _FamilyCard({
    required this.nationalId,
    required this.familyName,
    required this.representativeName,
    required this.campName,
    required this.originCity,
    required this.membersCount,
    required this.needs,
    required this.status,
  });

  Color get _statusColor {
    switch (status) {
      case 'تم التسجيل':
        return AppColors.success;
      case 'قيد المراجعة':
        return Colors.orange;
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
            // ── أيقونة ────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.family_restroom_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            // ── المعلومات الرئيسية ─────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم العائلة + الحالة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        familyName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      _StatusBadge(label: status, color: _statusColor),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // الممثل
                  Text(
                    'ممثل العائلة: $representativeName',
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 6),

                  // الصف السفلي: مخيم | مدينة | أفراد
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

                  // الاحتياجات (إن وُجدت)
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

            const SizedBox(width: 8),

            // ── رقم الهوية (يمين) ─────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
              ),
              child: Text(
                nationalId,
                style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  Widgets مساعدة صغيرة
// ══════════════════════════════════════════════════════════════
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
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
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                const Icon(Icons.wifi_off_rounded, color: Colors.red, size: 40),
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
  const _EmptyView();

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
          const Text('جرّب تغيير الفلتر أو كلمة البحث',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
