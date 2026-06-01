import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/styles/colors.dart';
import '../../../controllers/cubit/app_cubit.dart';
import '../../../controllers/cubit/app_states.dart';

class VolunteerAidManagementScreen extends StatefulWidget {
  const VolunteerAidManagementScreen({super.key});

  @override
  State<VolunteerAidManagementScreen> createState() =>
      _VolunteerAidManagementScreenState();
}

class _VolunteerAidManagementScreenState
    extends State<VolunteerAidManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    AppCubit.get(context).getFamilies();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          'إدارة المساعدات',
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'توزيع مساعدة'),
            Tab(text: 'سجل التوزيع'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDistributeTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  // ─── تبويب توزيع المساعدات ──────────────────────────────

  Widget _buildDistributeTab() {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        final cubit = AppCubit.get(context);

        if (state is DisplacedLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        final filtered = cubit.families.where((f) {
          final name = (f['familyName'] ?? '').toString().toLowerCase();
          final rep =
              (f['representativeName'] ?? '').toString().toLowerCase();
          final q = _searchQuery.toLowerCase();
          return name.contains(q) || rep.contains(q);
        }).toList();

        return Column(
          children: [
            /// شريط البحث
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'ابحث عن عائلة...',
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

            /// قائمة العائلات
            Expanded(
              child: filtered.isEmpty
                  ? _emptyState('لا توجد عائلات مطابقة للبحث')
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final family = filtered[index];
                        return _familyCard(family);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _familyCard(Map<String, dynamic> family) {
    return Container(
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
            child: Text(
              (family['familyName'] ?? 'أ').toString().substring(0, 1),
              style: const TextStyle(
                  color: AppColors.secondary, fontWeight: FontWeight.bold),
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
                  ),
                ),
                Text(
                  '${family['campName'] ?? ''} — ${family['membersCount'] ?? 0} فرد',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showDistributeDialog(family),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('توزيع', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showDistributeDialog(Map<String, dynamic> family) {
    final quantityController = TextEditingController(text: '1');
    String selectedType = 'غذاء';
    final aidTypes = ['غذاء', 'دواء', 'ملابس', 'مياه', 'أدوات'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.backgroundCard,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.volunteer_activism,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'توزيع مساعدة\n${family['familyName']}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// نوع المساعدة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    items: aidTypes.map((type) {
                      return DropdownMenuItem(
                          value: type, child: Text(type));
                    }).toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedType = v!),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              /// الكمية
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'الكمية',
                  prefixIcon: const Icon(Icons.production_quantity_limits,
                      color: AppColors.primary, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            BlocConsumer<AppCubit, AppStates>(
              listener: (context, state) {
                if (state is AddDisplacedSuccessState) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تسجيل توزيع المساعدة بنجاح'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is AddDisplacedLoadingState;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final qty =
                              int.tryParse(quantityController.text) ?? 1;
                          AppCubit.get(context).distributeAid(
                            familyId: family['id'],
                            familyName: family['familyName'] ?? '',
                            campName: family['campName'] ?? '',
                            aidType: selectedType,
                            quantity: qty,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('تأكيد التوزيع'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── تبويب سجل التوزيع ────────────────────────────────────

  Widget _buildHistoryTab() {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        final distributions = cubit.aidDistributions;

        if (distributions.isEmpty) {
          return _emptyState('لا يوجد سجل توزيع حتى الآن');
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: distributions.length,
          itemBuilder: (context, index) {
            final dist = distributions[index];
            return _distributionCard(dist);
          },
        );
      },
    );
  }

  Widget _distributionCard(Map<String, dynamic> dist) {
    final aidTypeColors = {
      'غذاء': AppColors.success,
      'دواء': AppColors.danger,
      'ملابس': AppColors.secondary,
      'مياه': AppColors.primary,
      'أدوات': AppColors.warning,
    };
    final color =
        aidTypeColors[dist['aidType']] ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(_getAidIcon(dist['aidType'] ?? ''),
                color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dist['familyName'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${dist['aidType'] ?? ''} — ${dist['quantity'] ?? 0} وحدة',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              dist['aidType'] ?? '',
              style: TextStyle(color: color, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAidIcon(String type) {
    switch (type) {
      case 'غذاء':
        return Icons.fastfood;
      case 'دواء':
        return Icons.medical_services;
      case 'ملابس':
        return Icons.checkroom;
      case 'مياه':
        return Icons.water_drop;
      case 'أدوات':
        return Icons.handyman;
      default:
        return Icons.volunteer_activism;
    }
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined,
              color: AppColors.textHint, size: 48),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
