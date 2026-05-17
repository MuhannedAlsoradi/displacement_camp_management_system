import 'package:displacement_camp_management_system/shared/cubit/app_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/cubit/app_states.dart';
import '../../styles/colors.dart';

class DisplacedManagementScreen extends StatefulWidget {
  const DisplacedManagementScreen({super.key});

  @override
  State<DisplacedManagementScreen> createState() =>
      _DisplacedManagementScreenState();
}

class _DisplacedManagementScreenState extends State<DisplacedManagementScreen> {
  @override
  void initState() {
    super.initState();
    // استدعاء جلب البيانات تلقائياً عند فتح الشاشة
    AppCubit.get(context).getDisplacedPersons();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// حقل البحث بعد تفعيله وإزالة const
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (value) {
                // تفعيل البحث عند الكتابة
                AppCubit.get(context).getDisplacedPersons(searchQuery: value);
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: AppColors.textHint),
                hintText: 'ابحث بالاسم أو رقم الهوية',
                hintStyle: TextStyle(color: AppColors.textHint),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              filterChoiceChip('الكل', true),
              filterChoiceChip('حسب المخيم', false),
              filterChoiceChip('حسب العمر', false),
            ],
          ),
          const SizedBox(height: 8),

          /// العداد الديناميكي لمعرفة عدد النتائج الحقيقية
          BlocBuilder<AppCubit, AppStates>(
            builder: (context, state) {
              final count = AppCubit.get(context).displacedPersons.length;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "عرض الكل",
                    style: TextStyle(color: AppColors.secondary, fontSize: 12),
                  ),
                  Text(
                    "النتائج: $count شخص",
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),

          /// الإصلاح الجوهري: الـ Expanded يغلف الـ BlocBuilder بالكامل من الخارج
          Expanded(
            child: BlocBuilder<AppCubit, AppStates>(
              buildWhen: (p, c) =>
                  c is DisplacedSuccessState ||
                  c is DisplacedLoadingState ||
                  c is DisplacedErrorState, // تم إضافة حالة الخطأ هنا لمعرفتها
              builder: (context, state) {
                if (state is DisplacedLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DisplacedErrorState) {
                  return Center(
                    child: Text(
                      'حدث خطأ أثناء جلب البيانات:\n${state.error}', // تأكد من اسم المتغير في الـ State لديك
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final persons = AppCubit.get(context).displacedPersons;

                // التعامل مع حالة القائمة الفارغة
                if (persons.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد بيانات لعرضها',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: persons.length,
                  itemBuilder: (context, index) {
                    final p = persons[index];
                    return personItem(
                      p['nationalId']?.toString() ?? '',
                      p['name']?.toString() ?? '',
                      p['campName']?.toString() ?? 'غير محدد',
                      p['status']?.toString() ?? '',
                      AppColors.statusStable,
                    );
                  },
                  physics: const BouncingScrollPhysics(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget filterChoiceChip(String text, bool selected) {
    return ChoiceChip(
      label: Text(text),
      selected: selected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
      ),
      onSelected: (_) {},
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget personItem(
    String id,
    String name,
    String camp,
    String status,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
              ),
              Positioned(
                bottom: 0,
                right:
                    0, // تم تعديلها لليمين لتناسب الانحناء العربي للملف الشخصي
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.statusStable,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          /// 2. المنتصف: بيانات الشخص (تبدأ من اليمين إلى اليسار)
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // جعل المحاذاة تبدأ من اليمين
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 13,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      camp,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          /// 3. اليسار: رقم الهوية وزر الخيارات (المزيد)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  id,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.more_horiz, color: AppColors.textHint),
            ],
          ),
        ],
      ),
    );
  }
}
