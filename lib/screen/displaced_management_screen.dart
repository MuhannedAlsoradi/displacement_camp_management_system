import 'package:flutter/material.dart';

import '../styles/colors.dart';

class DisplacedManagementScreen extends StatelessWidget {
  const DisplacedManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              decoration: InputDecoration(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "عرض الكل",
                style: TextStyle(color: AppColors.secondary, fontSize: 12),
              ),
              Text(
                "النتائج: 14 شخص",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                personItem(
                  "#4992831",
                  "منى العلي",
                  "مخيم السلام",
                  "تم التسجيل",
                  AppColors.statusStable,
                ),
              ],
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
          /// ID + Menu
          Column(
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
              const Icon(Icons.more_horiz, color: AppColors.textHint),
            ],
          ),

          const SizedBox(width: 10),

          /// Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      camp,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppColors.textHint,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          /// Avatar + Status Dot
          Stack(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
              ),
              Positioned(
                bottom: 0,
                left: 0,
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
        ],
      ),
    );
  }
}
