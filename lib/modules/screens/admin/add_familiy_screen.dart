import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:displacement_camp_management_system/shared/cubit/app_cubit.dart';
import 'package:displacement_camp_management_system/shared/cubit/app_states.dart';

class AddFamilyScreen extends StatefulWidget {
  const AddFamilyScreen({super.key});

  @override
  State<AddFamilyScreen> createState() => _AddFamilyScreenState();
}

class _AddFamilyScreenState extends State<AddFamilyScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _familyNameController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _representativeNameController =
      TextEditingController();
  final TextEditingController _tentIdController = TextEditingController();

  // Origin city — قائمة مدن قطاع غزة
  String? _selectedOriginCity;
  final List<String> _palestinianCities = [
    'غزة',
    'جباليا',
    'بيت لاهيا',
    'بيت حانون',
    'رفح',
    'خان يونس',
    'دير البلح',
    'النصيرات',
    'البريج',
    'المغازي',
    'الزوايدة',
    'المنصورة',
    'خزاعة',
    'عبسان الكبيرة',
    'عبسان الصغيرة',
    'بني سهيلا',
    'القرارة',
    'الفاهوم',
    'الزهراء',
    'الشجاعية',
    'التفاح',
    'الدرج',
    'الرمال',
    'البلد',
    'الصبرة',
    'الشيخ رضوان',
    'بيت حانون (حي)',
    'حي الأمل',
    'حي السلام',
    'حي النصر',
  ];

  int _membersCount = 1;

  // Camp selection — مصدره AppCubit.camps
  String? _selectedCampId;
  String? _selectedCampName;

  // Tent selection — تُجلب من Firestore بعد اختيار المخيم
  String? _selectedTentDocId; // document ID في Firestore
  String? _selectedTentLabel; // للعرض: "خيمة 5"

  // Needs multi-select chips
  final List<String> _allNeeds = [
    'غذاء',
    'دواء',
    'مياه',
    'ملابس',
    'مأوى',
    'بطانيات',
    'حفاضات',
    'حليب أطفال',
    'كراسي متحركة',
    'نظارات طبية',
    'أدوية مزمنة',
    'دعم نفسي',
  ];
  final Set<String> _selectedNeeds = {};

  @override
  void initState() {
    super.initState();
    // جلب المخيمات عبر الـ Cubit إذا لم تكن محملة بعد
    final cubit = AppCubit.get(context);
    if (cubit.camps.isEmpty) {
      cubit.getCamps();
    }
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    _nationalIdController.dispose();
    _representativeNameController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  //  Submit
  // ─────────────────────────────────────────────────────────────
  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCampId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار المخيم'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    AppCubit.get(context).addFamily(
      familyName: _familyNameController.text.trim(),
      representativeName: _representativeNameController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      membersCount: _membersCount,
      campId: _selectedCampId!,
      campName: _selectedCampName!,
      originCity: _selectedOriginCity ?? '',
      tentId: _selectedTentLabel ?? '',
      tentDocId: _selectedTentDocId ?? '',
      needs: _selectedNeeds.join('، '),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is AddDisplacedSuccessState) {
          // تحديث قائمة العائلات في الصفحة السابقة
          AppCubit.get(context).getFamilies();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ تم تسجيل العائلة بنجاح'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
          Navigator.pop(context);
        } else if (state is AddDisplacedErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        final isSubmitting = state is AddDisplacedLoadingState;
        final campsLoading = state is CampsLoadingState;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A2E)),
            ),
            title: const Text(
              'تسجيل عائلة',
              style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── معلومات العائلة ──────────────────────────
                    _sectionHeader('معلومات العائلة', Icons.group),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _familyNameController,
                      label: 'اسم العائلة',
                      hint: 'مثال: عائلة حمدان',
                      icon: Icons.family_restroom,
                      isRequired: true,
                    ),
                    _buildTextField(
                      controller: _representativeNameController,
                      label: 'اسم ممثل العائلة',
                      hint: 'مثال: نضال فارس حمدان',
                      icon: Icons.person,
                      isRequired: true,
                    ),
                    _buildMembersCounter(),
                    _buildTextField(
                      controller: _nationalIdController,
                      label: 'رقم الهوية الوطنية',
                      hint: 'مثال: 409378189',
                      icon: Icons.badge,
                      isRequired: true,
                      maxLength: 9,
                    ),
                    _buildCityPicker(),
                    const SizedBox(height: 20),

                    // ── معلومات المخيم ───────────────────────────
                    _sectionHeader('معلومات المخيم', Icons.home_work),
                    const SizedBox(height: 12),
                    _buildCampPicker(cubit: cubit, campsLoading: campsLoading),
                    _buildTentPicker(cubit: cubit, state: state),
                    const SizedBox(height: 20),

                    // ── الاحتياجات ───────────────────────────────
                    _sectionHeader('الاحتياجات', Icons.volunteer_activism),
                    const SizedBox(height: 12),
                    _buildNeedsSelector(),
                    const SizedBox(height: 32),

                    // ── زر الحفظ ─────────────────────────────────
                    _buildSubmitButton(
                        isSubmitting: isSubmitting, context: context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  City Picker — قائمة مدن قطاع غزة
  // ─────────────────────────────────────────────────────────────
  Widget _buildCityPicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مدينة الأصل',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _showCityBottomSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_city,
                      color: Color(0xFF1565C0), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedOriginCity ?? 'اختر المدينة',
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedOriginCity != null
                            ? const Color(0xFF1A1A2E)
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  if (_selectedOriginCity != null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedOriginCity = null),
                      child: Icon(Icons.close,
                          color: Colors.grey.shade400, size: 18),
                    )
                  else
                    Icon(Icons.keyboard_arrow_down,
                        color: Colors.grey.shade400, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCityBottomSheet() {
    final TextEditingController searchCtrl = TextEditingController();
    List<String> filtered = List.from(_palestinianCities);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'اختر المدينة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              // Search
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: searchCtrl,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مدينة...',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFF1565C0), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setModalState(() {
                      filtered = _palestinianCities
                          .where((c) => c.contains(val.trim()))
                          .toList();
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('لا توجد نتائج',
                            style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: Colors.grey.shade100),
                        itemBuilder: (_, i) {
                          final city = filtered[i];
                          final isSelected = _selectedOriginCity == city;
                          return ListTile(
                            onTap: () {
                              setState(() => _selectedOriginCity = city);
                              Navigator.pop(context);
                            },
                            leading: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF1565C0)
                                    : const Color(0xFF1565C0).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.place,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1565C0),
                                size: 16,
                              ),
                            ),
                            title: Text(
                              city,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFF1565C0)
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle,
                                    color: Color(0xFF1565C0), size: 20)
                                : null,
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Camp Picker — يقرأ من cubit.camps
  // ─────────────────────────────────────────────────────────────
  Widget _buildCampPicker({
    required AppCubit cubit,
    required bool campsLoading,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'اسم المخيم',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242),
                ),
              ),
              Text(' *', style: TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap:
                campsLoading ? null : () => _showCampBottomSheet(cubit.camps),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      color: Color(0xFF1565C0), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: campsLoading
                        ? const Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('جاري تحميل المخيمات...',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13)),
                            ],
                          )
                        : Text(
                            _selectedCampName ?? 'اختر المخيم',
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedCampName != null
                                  ? const Color(0xFF1A1A2E)
                                  : Colors.grey.shade400,
                            ),
                          ),
                  ),
                  Icon(Icons.keyboard_arrow_down,
                      color: Colors.grey.shade400, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCampBottomSheet(List<Map<String, dynamic>> camps) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'اختر المخيم',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: camps.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('لا توجد مخيمات متاحة',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: camps.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade100),
                      itemBuilder: (_, i) {
                        final camp = camps[i];
                        final isSelected = _selectedCampId == camp['id'];
                        final int current = camp['current'] ?? 0;
                        final int capacity = camp['capacity'] ?? 0;
                        final bool isFull = capacity > 0 && current >= capacity;

                        return ListTile(
                          onTap: isFull
                              ? null
                              : () {
                                  setState(() {
                                    _selectedCampId = camp['id'];
                                    _selectedCampName = camp['name'];
                                    // إعادة ضبط الخيمة عند تغيير المخيم
                                    _selectedTentDocId = null;
                                    _selectedTentLabel = null;
                                  });
                                  // جلب الخيام الفارغة للمخيم المختار
                                  AppCubit.get(context)
                                      .getAvailableTents(camp['id']);
                                  Navigator.pop(context);
                                },
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1565C0)
                                  : isFull
                                      ? Colors.grey.shade200
                                      : const Color(0xFF1565C0)
                                          .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.home_work,
                              color: isSelected
                                  ? Colors.white
                                  : isFull
                                      ? Colors.grey
                                      : const Color(0xFF1565C0),
                              size: 18,
                            ),
                          ),
                          title: Text(
                            camp['name'] ?? '',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isFull
                                  ? Colors.grey
                                  : isSelected
                                      ? const Color(0xFF1565C0)
                                      : const Color(0xFF1A1A2E),
                            ),
                          ),
                          subtitle: capacity > 0
                              ? Text(
                                  '$current / $capacity فرد${isFull ? ' — ممتلئ' : ''}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isFull ? Colors.red : Colors.grey,
                                  ),
                                )
                              : null,
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: Color(0xFF1565C0), size: 20)
                              : null,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Needs Chips
  // ─────────────────────────────────────────────────────────────
  Widget _buildNeedsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اضغط على الاحتياجات لتحديدها',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allNeeds.map((need) {
            final selected = _selectedNeeds.contains(need);
            return GestureDetector(
              onTap: () => setState(() {
                selected
                    ? _selectedNeeds.remove(need)
                    : _selectedNeeds.add(need);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF1565C0) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF1565C0)
                        : Colors.grey.shade300,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF1565C0).withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selected) ...[
                      const Icon(Icons.check, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      need,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            selected ? Colors.white : const Color(0xFF424242),
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedNeeds.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'تم اختيار ${_selectedNeeds.length} احتياج',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Shared Widgets
  // ─────────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1565C0), size: 18),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }

  Widget _buildMembersCounter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'عدد أفراد العائلة',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242),
                ),
              ),
              Text(' *', style: TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.people, color: Color(0xFF1565C0), size: 20),
                const SizedBox(width: 12),
                _counterButton(
                  icon: Icons.remove,
                  onTap: () {
                    if (_membersCount > 1) setState(() => _membersCount--);
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_membersCount',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                ),
                _counterButton(
                  icon: Icons.add,
                  onTap: () => setState(() => _membersCount++),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _counterButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required String hint,
      required IconData icon,
      TextInputType keyboardType = TextInputType.text,
      bool isRequired = false,
      int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242))),
              if (isRequired)
                const Text(' *',
                    style: TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLength: maxLength,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: hint,
              counterText: '',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: Icon(icon, color: const Color(0xFF1565C0), size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red)),
            ),
            validator: isRequired
                ? (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton({
    required bool isSubmitting,
    required BuildContext context,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : () => _submit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF1565C0).withOpacity(0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'حفظ بيانات العائلة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Tent Picker — مخصص لعرض واختيار الخيام بناءً على الـ cubit
  // ─────────────────────────────────────────────────────────────
  Widget _buildTentPicker({
    required AppCubit cubit,
    required AppStates state,
  }) {
    final bool isCampSelected = _selectedCampId != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تخصيص خيمة عائلية',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: !isCampSelected
                ? null
                : () => _showTentBottomSheet(cubit.availableTents),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: isCampSelected ? Colors.white : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.gite_outlined,
                    color:
                        isCampSelected ? const Color(0xFF1565C0) : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      !isCampSelected
                          ? 'الرجاء اختيار المخيم أولاً لعرض الخيام المتاحة'
                          : (_selectedTentLabel ??
                              'اختر خيمة للعائلة (اختياري)'),
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedTentLabel != null
                            ? const Color(0xFF1A1A2E)
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  if (_selectedTentLabel != null)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTentDocId = null;
                          _selectedTentLabel = null;
                        });
                      },
                      child: Icon(Icons.close,
                          color: Colors.grey.shade400, size: 18),
                    )
                  else
                    Icon(Icons.keyboard_arrow_down,
                        color: Colors.grey.shade400, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTentBottomSheet(List<Map<String, dynamic>> tents) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'الخيام الشاغرة والمتاحة حالياً',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: tents.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'لا توجد خيام متاحة في هذا المخيم حالياً، سيتم الحفظ بدون خيمة.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: tents.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade100),
                      itemBuilder: (_, i) {
                        final tent = tents[i];
                        final isSelected = _selectedTentDocId == tent['id'];
                        // قراءة حقل الاسم أو الرقم الخاص بالخيمة من قاعدة البيانات
                        final String tentName = tent['name'] ??
                            tent['tentNumber'] ??
                            'خيمة غير معنونة';

                        return ListTile(
                          onTap: () {
                            setState(() {
                              _selectedTentDocId = tent['id'];
                              _selectedTentLabel = tentName;
                            });
                            Navigator.pop(context);
                          },
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1565C0)
                                  : const Color(0xFF1565C0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.gite,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1565C0),
                              size: 18,
                            ),
                          ),
                          title: Text(
                            tentName,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF1565C0)
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: Color(0xFF1565C0), size: 20)
                              : null,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
