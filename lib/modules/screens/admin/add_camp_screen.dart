import 'package:displacement_camp_management_system/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/cubit/app_cubit.dart';
import '../../../shared/cubit/app_states.dart';

class AddCampScreen extends StatefulWidget {
  const AddCampScreen({super.key});

  @override
  State<AddCampScreen> createState() => _AddCampScreenState();
}

class _AddCampScreenState extends State<AddCampScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();

  String _selectedStatus = 'متاح';

  final List<Map<String, dynamic>> _statusOptions = [
    {'label': 'متاح', 'color': AppColors.statusStable},
    {'label': 'ممتلئ تقريباً', 'color': AppColors.statusWarning},
    {'label': 'قيد الصيانة', 'color': AppColors.statusCritical},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    AppCubit.get(context).addCamp(
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      capacity: int.parse(_capacityController.text.trim()),
      status: _selectedStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is AddCampSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ تم إضافة المخيم بنجاح'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
          Navigator.pop(context);
        } else if (state is AddCampErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AddCampLoadingState;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A2E)),
            ),
            title: const Text(
              'إضافة مخيم جديد',
              style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────
                  _sectionHeader(),
                  const SizedBox(height: 20),

                  // ── اسم المخيم ──────────────────────────────────
                  _buildLabel('اسم المخيم', isRequired: true),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'مثال: مخيم الأمل',
                    icon: Icons.home_work_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'هذا الحقل مطلوب'
                        : null,
                  ),

                  const SizedBox(height: 14),

                  // ── الموقع ──────────────────────────────────────
                  _buildLabel('الموقع', isRequired: true),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _locationController,
                    hint: 'مثال: رفح، شارع البحر',
                    icon: Icons.location_on_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'هذا الحقل مطلوب'
                        : null,
                  ),

                  const SizedBox(height: 14),

                  // ── الطاقة الاستيعابية ──────────────────────────
                  _buildLabel('الطاقة الاستيعابية (عدد الأفراد)',
                      isRequired: true),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _capacityController,
                    hint: 'مثال: 500',
                    icon: Icons.people_outline,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'هذا الحقل مطلوب';
                      final n = int.tryParse(v);
                      if (n == null || n <= 0) return 'أدخل رقماً أكبر من صفر';
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── الحالة ──────────────────────────────────────
                  _buildLabel('حالة المخيم', isRequired: true),
                  const SizedBox(height: 10),
                  _buildStatusSelector(),

                  const SizedBox(height: 40),

                  // ── زر الحفظ ─────────────────────────────────────
                  _buildSubmitButton(isLoading: isLoading),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Widgets ──────────────────────────────────────────────────────────────

  Widget _sectionHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child:
              const Icon(Icons.home_work, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        const Text(
          'بيانات المخيم',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF424242),
          ),
        ),
        if (isRequired)
          const Text(' *', style: TextStyle(color: Colors.red, fontSize: 13)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Row(
      children: _statusOptions.map((option) {
        final label = option['label'] as String;
        final color = option['color'] as Color;
        final isSelected = _selectedStatus == label;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedStatus = label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade200,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? color : Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton({required bool isLoading}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : _submit,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
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
                    'حفظ المخيم',
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
}
