import 'package:flutter/material.dart';

import '../styles/colors.dart';

class CampsManagementScreen extends StatelessWidget {
  CampsManagementScreen({super.key});

  final List<Map<String, dynamic>> camps = [
    {
      'name': 'مخيم جباليا',
      'location': 'شمال غزة',
      'capacity': 50000,
      'current': 35000,
      'status': 'متاح',
      'image': 'images/camps/image1.png',
    },
    {
      'name': 'مخيم الشاطي',
      'location': 'غرب غزة',
      'capacity': 40000,
      'current': 38000,
      'status': 'ممتلئ تقريبا',
      'image': 'images/camps/image2.png',
    },
    {
      'name': 'مخيم البريج',
      'location': 'وسط القطاع',
      'capacity': 25000,
      'current': 13000,
      'status': 'متاح',
      'image': 'images/camps/image3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // البحث
          TextField(
            decoration: InputDecoration(
              hintText: 'بحث عن مخيم...',
              hintStyle: const TextStyle(color: AppColors.textHint),
              prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.backgroundCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              filterChip('الكل', true),
              filterChip('مفتوح', false),
              filterChip('ممتلئ', false),
              filterChip('قيد الصيانة', false),
            ],
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: camps.length,
              itemBuilder: (context, index) => campCard(camps[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget filterChip(String text, bool selected) {
    return Chip(
      label: Text(text),
      backgroundColor: selected ? AppColors.primary : AppColors.backgroundCard,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  Widget campCard(Map<String, dynamic> camp) {
    double percent = camp['current'] / camp['capacity'];

    // استخدام ألوان حالة المخيم من AppColors
    Color statusColor = camp['status'] == 'متاح'
        ? AppColors.statusStable
        : AppColors.statusCritical;

    // لون شريط التقدم بناءً على نسبة الامتلاء
    Color progressColor = percent > 0.9
        ? AppColors.statusCritical
        : percent > 0.7
            ? AppColors.statusWarning
            : AppColors.statusStable;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.backgroundCard,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.asset(
                  camp['image'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        camp['status'],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      camp['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white),
                        Text(
                          camp['location'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'السعة الإجمالية',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${camp['capacity']}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'المقيمون حالياً',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${camp['current']}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'نسبة الإشغال',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(percent * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: progressColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 10,
                color: progressColor,
                backgroundColor: AppColors.border,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
