import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controllers/cubit/app_cubit.dart';
import '../../../controllers/cubit/app_states.dart';
import '../../../utils/styles/colors.dart';
import '../../widgets/connectivit_banner.dart';

class ResourceManagementScreen extends StatefulWidget {
  const ResourceManagementScreen({super.key});

  @override
  State<ResourceManagementScreen> createState() =>
      _ResourceManagementScreenState();
}

class _ResourceManagementScreenState extends State<ResourceManagementScreen> {
  @override
  void initState() {
    super.initState();
    AppCubit.get(context).listenToResources();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listenWhen: (p, c) =>
          c is ResourceActionSuccessState || c is ResourceActionErrorState,
      listener: (context, state) {
        if (state is ResourceActionSuccessState) {
          _showSnack(state.message, AppColors.statusStable);
        } else if (state is ResourceActionErrorState) {
          _showSnack(state.error, AppColors.statusCritical);
        }
      },
      buildWhen: (p, c) =>
          c is ResourcesSuccessState ||
          c is ResourcesErrorState ||
          c is ResourceActionLoadingState,
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        final resources = cubit.resources;

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
            title: const Text(
              'إدارة المساعدات والموارد',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            centerTitle: true,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, thickness: 1, color: AppColors.border),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddResourceDialog(context, cubit),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('نوع مساعدة جديد',
                style: TextStyle(color: Colors.white)),
          ),
          body: Column(children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ConnectivityBanner(),
            ),
            Expanded(
              child: resources.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                      itemCount: resources.length,
                      itemBuilder: (context, index) =>
                          _resourceCard(resources[index], cubit),
                    ),
            ),
          ]),
        );
      },
    );
  }

  Widget _resourceCard(Map<String, dynamic> resource, AppCubit cubit) {
    final aidType = resource['aidType']?.toString() ?? '';
    final quantity = resource['quantityAvailable'] as int? ?? 0;
    final unit = resource['unit']?.toString() ?? '';
    final isLow = quantity < 10;
    final meta = _aidTypeMeta(aidType);

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
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: meta.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(meta.icon, color: meta.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(aidType,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      '$quantity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isLow
                            ? AppColors.statusCritical
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (unit.isNotEmpty)
                      Text(unit,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    if (isLow)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.statusCritical.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('مخزون منخفض',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.statusCritical,
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: AppColors.textHint, size: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'edit') _showEditQuantityDialog(resource, cubit);
              if (value == 'delete') _confirmDeleteResource(resource, cubit);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('تعديل الكمية'),
                ]),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline,
                      size: 18, color: AppColors.statusCritical),
                  const SizedBox(width: 8),
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

  void _showAddResourceDialog(BuildContext context, AppCubit cubit) {
    String? selectedType;
    final quantityController = TextEditingController();
    final unitController = TextEditingController();

    final types = [
      {'type': 'غذاء', 'icon': Icons.fastfood_outlined},
      {'type': 'طبي', 'icon': Icons.medical_services_outlined},
      {'type': 'مياه', 'icon': Icons.water_drop_outlined},
      {'type': 'ملابس', 'icon': Icons.checkroom_outlined},
      {'type': 'مأوى', 'icon': Icons.home_outlined},
      {'type': 'نفسي', 'icon': Icons.psychology_outlined},
    ];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('إضافة نوع مساعدة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('نوع المساعدة:',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: types.map((t) {
                    final isSel = selectedType == t['type'];
                    return GestureDetector(
                      onTap: () => setDialogState(
                          () => selectedType = t['type'] as String),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.backgroundPage,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  isSel ? AppColors.primary : AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(t['icon'] as IconData,
                                size: 16,
                                color: isSel
                                    ? AppColors.primary
                                    : AppColors.textHint),
                            const SizedBox(width: 6),
                            Text(t['type'] as String,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSel
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSel
                                        ? AppColors.primary
                                        : AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'الكمية المتاحة',
                    prefixIcon: const Icon(Icons.inventory_2_outlined,
                        color: AppColors.primary, size: 20),
                    filled: true,
                    fillColor: AppColors.backgroundPage,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: unitController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'الوحدة (اختياري، مثال: كرتونة)',
                    prefixIcon: const Icon(Icons.straighten_outlined,
                        color: AppColors.primary, size: 20),
                    filled: true,
                    fillColor: AppColors.backgroundPage,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                  ),
                ),
              ],
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
              onPressed: () {
                final qty = int.tryParse(quantityController.text.trim());
                if (selectedType == null || qty == null) return;
                Navigator.pop(context);
                cubit.addResource(
                  aidType: selectedType!,
                  quantityAvailable: qty,
                  unit: unitController.text.trim(),
                );
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditQuantityDialog(Map<String, dynamic> resource, AppCubit cubit) {
    final controller =
        TextEditingController(text: '${resource['quantityAvailable'] ?? 0}');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('تعديل كمية: ${resource['aidType']}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            labelText: 'الكمية المتاحة',
            filled: true,
            fillColor: AppColors.backgroundPage,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
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
            onPressed: () {
              final qty = int.tryParse(controller.text.trim());
              if (qty == null) return;
              Navigator.pop(context);
              cubit.updateResourceQuantity(
                  resourceId: resource['id'], newQuantity: qty);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteResource(Map<String, dynamic> resource, AppCubit cubit) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.statusCritical, size: 22),
          const SizedBox(width: 8),
          const Text('تأكيد الحذف',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        content: Text('هل تريد حذف نوع المساعدة "${resource['aidType']}"؟',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
              cubit.deleteResource(resource['id']);
            },
            child: const Text('حذف'),
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
            child: Icon(Icons.inventory_2_outlined,
                color: AppColors.primary.withOpacity(0.4), size: 48),
          ),
          const SizedBox(height: 14),
          const Text('لا توجد أنواع مساعدات معرّفة',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('أضف أول نوع مساعدة من الزر بالأسفل',
              style: TextStyle(color: AppColors.textHint, fontSize: 13)),
        ],
      ),
    );
  }

  _AidTypeMeta _aidTypeMeta(String type) {
    switch (type) {
      case 'غذاء':
        return _AidTypeMeta(Icons.fastfood_outlined, const Color(0xFF0F6E56));
      case 'طبي':
        return _AidTypeMeta(
            Icons.medical_services_outlined, const Color(0xFFA32D2D));
      case 'مياه':
        return _AidTypeMeta(Icons.water_drop_outlined, const Color(0xFF185FA5));
      case 'ملابس':
        return _AidTypeMeta(Icons.checkroom_outlined, const Color(0xFF92400E));
      case 'مأوى':
        return _AidTypeMeta(Icons.home_outlined, const Color(0xFF4355B9));
      case 'نفسي':
        return _AidTypeMeta(Icons.psychology_outlined, const Color(0xFF633806));
      default:
        return _AidTypeMeta(Icons.category_outlined, AppColors.textHint);
    }
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

class _AidTypeMeta {
  final IconData icon;
  final Color color;
  _AidTypeMeta(this.icon, this.color);
}
