import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../controllers/cubit/app_cubit.dart';
import '../../../../controllers/cubit/app_states.dart';
import '../../../../utils/styles/colors.dart';

class AidDistributionScreen extends StatefulWidget {
  /// true: تظهر AppBar خاصة فيها (لما تُفتح Standalone عبر Navigator.push)
  /// false: بدون AppBar (لما تكون Tab جوه VolunteerLayoutScreen)
  final bool showAppBar;

  const AidDistributionScreen({super.key, this.showAppBar = true});

  @override
  State<AidDistributionScreen> createState() => _AidDistributionScreenState();
}

class _AidDistributionScreenState extends State<AidDistributionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  final List<String> _aidTypes = [
    'غذاء',
    'ماء',
    'دواء',
    'ملابس',
    'بطانيات',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    AppCubit.get(context).getFamilies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabBarView = TabBarView(
      controller: _tabController,
      children: [
        _DistributeTab(aidTypes: _aidTypes),
        _HistoryTab(
            searchQuery: _searchQuery,
            onSearchChanged: (v) => setState(() => _searchQuery = v)),
      ],
    );

    final tabBar = TabBar(
      controller: _tabController,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textHint,
      indicatorColor: AppColors.primary,
      indicatorWeight: 3,
      tabs: const [
        Tab(text: 'توزيع جديد'),
        Tab(text: 'سجل التوزيع'),
      ],
    );

    if (!widget.showAppBar) {
      // بدون AppBar — فقط TabBar + المحتوى (لما تكون Tab جوه VolunteerLayoutScreen)
      return Scaffold(
        backgroundColor: AppColors.backgroundPage,
        body: Column(
          children: [
            Container(
              color: AppColors.backgroundCard,
              child: tabBar,
            ),
            Expanded(child: tabBarView),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: AppColors.textPrimary, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'توزيع المساعدات',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: tabBar,
      ),
      body: tabBarView,
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  تبويب التوزيع الجديد
// ══════════════════════════════════════════════════════════════
class _DistributeTab extends StatefulWidget {
  final List<String> aidTypes;
  const _DistributeTab({required this.aidTypes});

  @override
  State<_DistributeTab> createState() => _DistributeTabState();
}

class _DistributeTabState extends State<_DistributeTab> {
  Map<String, dynamic>? _selectedFamily;
  String? _selectedAidType;
  int _quantity = 1;
  String _familySearch = '';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listenWhen: (p, c) =>
          c is AddDisplacedSuccessState || c is AddDisplacedErrorState,
      listener: (context, state) {
        if (state is AddDisplacedSuccessState) {
          setState(() {
            _selectedFamily = null;
            _selectedAidType = null;
            _quantity = 1;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم تسجيل توزيع المساعدة بنجاح ✓'),
            backgroundColor: AppColors.statusStable,
            behavior: SnackBarBehavior.floating,
          ));
        } else if (state is AddDisplacedErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error),
            backgroundColor: AppColors.statusCritical,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        final allFamilies = cubit.families;
        final filtered = _familySearch.isEmpty
            ? allFamilies
            : allFamilies.where((f) {
                return (f['familyName'] ?? '')
                        .toString()
                        .contains(_familySearch) ||
                    (f['representativeName'] ?? '')
                        .toString()
                        .contains(_familySearch);
              }).toList();

        final isLoading = state is AddDisplacedLoadingState;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── اختيار الأسرة ────────────────────────────
              const _SectionLabel(
                  icon: Icons.family_restroom_rounded,
                  text: 'اختر الأسرة المستفيدة'),
              const SizedBox(height: 8),

              // شريط بحث الأسر
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border.withOpacity(0.5)),
                ),
                child: TextField(
                  textDirection: TextDirection.rtl,
                  onChanged: (v) => setState(() => _familySearch = v),
                  decoration: const InputDecoration(
                    hintText: 'ابحث عن أسرة...',
                    hintStyle:
                        TextStyle(color: AppColors.textHint, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppColors.textHint, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // قائمة الأسر
              if (allFamilies.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.border.withOpacity(0.4)),
                  ),
                  child: const Center(
                    child: Text('لا توجد أسر مسجلة',
                        style:
                            TextStyle(color: AppColors.textHint, fontSize: 13)),
                  ),
                )
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.border.withOpacity(0.4)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final family = filtered[index];
                      final isSelected = _selectedFamily?['id'] == family['id'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFamily = family),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.15)
                                      : AppColors.backgroundPage,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.family_restroom_rounded,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textHint,
                                    size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      family['familyName'] ?? '',
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 13,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${family['campName'] ?? ''} • ${family['membersCount'] ?? 0} أفراد',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textHint),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded,
                                    color: AppColors.primary, size: 18),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),

              // ── نوع المساعدة ─────────────────────────────
              const _SectionLabel(
                  icon: Icons.volunteer_activism_rounded, text: 'نوع المساعدة'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.aidTypes.map((type) {
                  final isSelected = _selectedAidType == type;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAidType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _aidIcon(type),
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            type,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // ── الكمية ──────────────────────────────────
              const _SectionLabel(
                  icon: Icons.production_quantity_limits_rounded,
                  text: 'الكمية'),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      color: AppColors.primary,
                      disabledColor: AppColors.textHint,
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _quantity++),
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── ملخص التوزيع ─────────────────────────────
              if (_selectedFamily != null && _selectedAidType != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      _summaryRow(
                          'الأسرة', _selectedFamily!['familyName'] ?? ''),
                      _summaryRow('المخيم', _selectedFamily!['campName'] ?? ''),
                      _summaryRow('نوع المساعدة', _selectedAidType!),
                      _summaryRow('الكمية', '$_quantity وحدة'),
                    ],
                  ),
                ),

              // ── زر التوزيع ───────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        (_selectedFamily != null && _selectedAidType != null)
                            ? AppColors.primary
                            : AppColors.textHint,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: (_selectedFamily != null &&
                          _selectedAidType != null &&
                          !isLoading)
                      ? () => _distribute(cubit)
                      : null,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.volunteer_activism_rounded, size: 20),
                            SizedBox(width: 10),
                            Text('تسجيل التوزيع',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // تحذير المنع المسبق
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.warning, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'يتحقق النظام تلقائياً من منع تكرار التوزيع لنفس الأسرة في نفس اليوم.',
                        style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 11,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _distribute(AppCubit cubit) {
    if (_selectedFamily == null || _selectedAidType == null) return;
    cubit.distributeAid(
      familyId: _selectedFamily!['id'],
      familyName: _selectedFamily!['familyName'] ?? '',
      campName: _selectedFamily!['campName'] ?? '',
      aidType: _selectedAidType!,
      quantity: _quantity,
    );
  }

  IconData _aidIcon(String type) {
    switch (type) {
      case 'غذاء':
        return Icons.fastfood_rounded;
      case 'ماء':
        return Icons.water_drop_rounded;
      case 'دواء':
        return Icons.medical_services_rounded;
      case 'ملابس':
        return Icons.checkroom_rounded;
      case 'بطانيات':
        return Icons.bed_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }
}

// ══════════════════════════════════════════════════════════════
//  تبويب السجل
// ══════════════════════════════════════════════════════════════
class _HistoryTab extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const _HistoryTab({required this.searchQuery, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        final allAid = cubit.aidDistributions;
        final filtered = searchQuery.isEmpty
            ? allAid
            : allAid.where((a) {
                return (a['familyName'] ?? '')
                        .toString()
                        .contains(searchQuery) ||
                    (a['aidType'] ?? '').toString().contains(searchQuery);
              }).toList();

        return Column(
          children: [
            // البحث
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border.withOpacity(0.5)),
                ),
                child: TextField(
                  textDirection: TextDirection.rtl,
                  onChanged: onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'ابحث في سجل التوزيع...',
                    hintStyle:
                        TextStyle(color: AppColors.textHint, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppColors.textHint, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // العداد
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('${filtered.length} سجل',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_rounded,
                              color: AppColors.textHint, size: 48),
                          SizedBox(height: 12),
                          Text('لا توجد سجلات توزيع',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final record = filtered[index];
                        return _aidRecord(record);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _aidRecord(Map<String, dynamic> record) {
    final aidType = record['aidType']?.toString() ?? '';
    final familyName = record['familyName']?.toString() ?? '';
    final campName = record['campName']?.toString() ?? '';
    final quantity = record['quantity'] as int? ?? 0;
    final distributedBy = record['distributedBy']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.volunteer_activism_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(familyName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text('$aidType • $quantity وحدة',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 11, color: AppColors.textHint),
                    const SizedBox(width: 2),
                    Text(campName,
                        style: const TextStyle(
                            color: AppColors.textHint, fontSize: 11)),
                    if (distributedBy.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.person_outline,
                          size: 11, color: AppColors.textHint),
                      const SizedBox(width: 2),
                      Text(distributedBy,
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 11)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.statusStable.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$quantity',
                style: const TextStyle(
                    color: AppColors.statusStable,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Widget مساعد
// ──────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SectionLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      ],
    );
  }
}
