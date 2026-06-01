import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/styles/colors.dart';
import '../../../controllers/cubit/app_cubit.dart';
import '../../../controllers/cubit/app_states.dart';

class VolunteerRegisterFamilyScreen extends StatefulWidget {
  const VolunteerRegisterFamilyScreen({super.key});

  @override
  State<VolunteerRegisterFamilyScreen> createState() =>
      _VolunteerRegisterFamilyScreenState();
}

class _VolunteerRegisterFamilyScreenState
    extends State<VolunteerRegisterFamilyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _familyNameController = TextEditingController();
  final _representativeController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _membersCountController = TextEditingController();
  final _originCityController = TextEditingController();
  final _needsController = TextEditingController();

  String? _selectedCampId;
  String? _selectedCampName;
  String? _selectedTentId;
  String? _selectedTentDocId;

  @override
  void initState() {
    super.initState();
    AppCubit.get(context).getCamps();
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    _representativeController.dispose();
    _nationalIdController.dispose();
    _membersCountController.dispose();
    _originCityController.dispose();
    _needsController.dispose();
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
          'تسجيل عائلة نازحة',
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
      body: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is AddDisplacedSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تسجيل العائلة بنجاح'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          }
          if (state is AddDisplacedErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ: ${state.error}'),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = AppCubit.get(context);
          final isLoading = state is AddDisplacedLoadingState;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// معلومات العائلة
                  _sectionTitle('معلومات العائلة', Icons.family_restroom,
                      AppColors.secondary),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _familyNameController,
                    label: 'اسم العائلة',
                    icon: Icons.people,
                    validator: (v) =>
                        v!.isEmpty ? 'الرجاء إدخال اسم العائلة' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _representativeController,
                    label: 'اسم ممثل العائلة',
                    icon: Icons.person,
                    validator: (v) =>
                        v!.isEmpty ? 'الرجاء إدخال اسم الممثل' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _nationalIdController,
                    label: 'رقم الهوية الوطنية',
                    icon: Icons.badge,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v!.isEmpty ? 'الرجاء إدخال رقم الهوية' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _membersCountController,
                    label: 'عدد أفراد الأسرة',
                    icon: Icons.group,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'الرجاء إدخال عدد الأفراد';
                      if (int.tryParse(v) == null) return 'أدخل رقماً صحيحاً';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _originCityController,
                    label: 'المدينة الأصلية',
                    icon: Icons.location_on,
                    validator: (v) =>
                        v!.isEmpty ? 'الرجاء إدخال المدينة الأصلية' : null,
                  ),

                  const SizedBox(height: 20),

                  /// اختيار المخيم
                  _sectionTitle(
                      'تعيين المخيم', Icons.location_city, AppColors.warning),
                  const SizedBox(height: 12),
                  _buildCampDropdown(cubit),

                  /// اختيار الخيمة
                  if (_selectedCampId != null) ...[
                    const SizedBox(height: 12),
                    _buildTentDropdown(cubit),
                  ],

                  const SizedBox(height: 20),

                  /// الاحتياجات
                  _sectionTitle(
                      'الاحتياجات', Icons.medical_services, AppColors.danger),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _needsController,
                    label: 'احتياجات الأسرة (اختياري)',
                    icon: Icons.note,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),

                  /// زر الحفظ
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'تسجيل العائلة',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCampId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار المخيم'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    AppCubit.get(context).addFamily(
      familyName: _familyNameController.text.trim(),
      representativeName: _representativeController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      membersCount: int.parse(_membersCountController.text.trim()),
      campId: _selectedCampId!,
      campName: _selectedCampName!,
      originCity: _originCityController.text.trim(),
      tentId: _selectedTentId ?? '',
      tentDocId: _selectedTentDocId ?? '',
      needs: _needsController.text.trim(),
    );
  }

  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildCampDropdown(AppCubit cubit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCampId,
          isExpanded: true,
          hint: const Text('اختر المخيم',
              style: TextStyle(color: AppColors.textHint)),
          items: cubit.camps.map((camp) {
            return DropdownMenuItem<String>(
              value: camp['id'],
              child: Text(camp['name'] ?? ''),
            );
          }).toList(),
          onChanged: (value) {
            final camp = cubit.camps.firstWhere((c) => c['id'] == value);
            setState(() {
              _selectedCampId = value;
              _selectedCampName = camp['name'];
              _selectedTentId = null;
              _selectedTentDocId = null;
            });
            cubit.getAvailableTents(value!);
          },
        ),
      ),
    );
  }

  Widget _buildTentDropdown(AppCubit cubit) {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTentDocId,
              isExpanded: true,
              hint: const Text('اختر الخيمة (اختياري)',
                  style: TextStyle(color: AppColors.textHint)),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('بدون خيمة'),
                ),
                ...cubit.availableTents.map((tent) {
                  return DropdownMenuItem<String>(
                    value: tent['id'],
                    child: Text('خيمة ${tent['tentId'] ?? tent['id']}'),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTentDocId = value;
                  if (value != null) {
                    final tent = cubit.availableTents
                        .firstWhere((t) => t['id'] == value);
                    _selectedTentId = tent['tentId']?.toString() ?? value;
                  } else {
                    _selectedTentId = null;
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }
}
