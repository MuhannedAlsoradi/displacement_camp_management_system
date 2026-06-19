import 'dart:io';
import 'package:displacement_camp_management_system/utils/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/cubit/app_cubit.dart';
import '../../../controllers/cubit/app_states.dart';

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

  // ─── الصورة المختارة ─────────────────────────────────────────
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // ─── الحالات الثلاث مع ألوانها من AppColors ─────────────────
  final List<Map<String, dynamic>> _statusOptions = [
    {
      'label': 'متاح',
      'color': AppColors.statusStable,
      'icon': Icons.check_circle_outline,
    },
    {
      'label': 'ممتلئ تقريباً',
      'color': AppColors.statusWarning,
      'icon': Icons.warning_amber_outlined,
    },
    {
      'label': 'قيد الصيانة',
      'color': AppColors.statusCritical,
      'icon': Icons.construction_outlined,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1200,
      );
      if (picked != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (_) {}
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'اختر مصدر الصورة',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _imageSourceButton(
                      icon: Icons.photo_library_outlined,
                      label: 'المعرض',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _imageSourceButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'الكاميرا',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                ],
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _selectedImage = null);
                  },
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.statusCritical, size: 18),
                  label: const Text(
                    'حذف الصورة',
                    style: TextStyle(color: AppColors.statusCritical),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    AppCubit.get(context).addCamp(
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      capacity: int.parse(_capacityController.text.trim()),
      status: _selectedStatus,
      imageFile: _selectedImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is AddCampSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('تم إضافة المخيم بنجاح'),
                ],
              ),
              backgroundColor: AppColors.statusStable,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.pop(context);
        } else if (state is AddCampErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.error)),
                ],
              ),
              backgroundColor: AppColors.statusCritical,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Color(0xFF1A1A2E), size: 20),
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
                  // ── Header Card ─────────────────────────────────
                  _buildHeaderCard(),
                  const SizedBox(height: 20),

                  // ── القسم الأول: بيانات المخيم ──────────────────
                  _sectionHeader('بيانات المخيم', Icons.home_work_outlined),
                  const SizedBox(height: 14),

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
                      if (v == null || v.trim().isEmpty) {
                        return 'هذا الحقل مطلوب';
                      }
                      final n = int.tryParse(v);
                      if (n == null || n <= 0) return 'أدخل رقماً أكبر من صفر';
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── القسم الثاني: صورة المخيم ────────────────────
                  _sectionHeader('صورة المخيم', Icons.image_outlined),
                  const SizedBox(height: 14),
                  _buildImagePicker(),

                  const SizedBox(height: 24),

                  // ── القسم الثالث: حالة المخيم ───────────────────
                  _sectionHeader('حالة المخيم', Icons.info_outline),
                  const SizedBox(height: 14),
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

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: _selectedImage != null ? 180 : 120,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedImage != null
                ? AppColors.primary
                : Colors.grey.shade300,
            width: _selectedImage != null ? 2 : 1.5,
            style: BorderStyle.solid,
          ),
          color: _selectedImage != null
              ? Colors.transparent
              : AppColors.primary.withOpacity(0.03),
        ),
        child: _selectedImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // زر التغيير
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'تغيير',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'اضغط لإضافة صورة للمخيم',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'اختياري — من المعرض أو الكاميرا',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.primary.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_home_work_outlined,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مخيم جديد',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'أدخل بيانات المخيم الأساسية',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
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
      textDirection: TextDirection.rtl,
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.statusCritical),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.statusCritical, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      children: _statusOptions.map((option) {
        final label = option['label'] as String;
        final color = option['color'] as Color;
        final icon = option['icon'] as IconData;
        final isSelected = _selectedStatus == label;

        return GestureDetector(
          onTap: () => setState(() => _selectedStatus = label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade200,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected ? color : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? color : Colors.grey.shade300,
                      width: 2,
                    ),
                    color: isSelected ? color : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 12)
                      : null,
                ),
              ],
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
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'جاري الحفظ...',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'حفظ المخيم',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
