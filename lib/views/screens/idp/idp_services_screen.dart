import 'package:displacement_camp_management_system/utils/styles/colors.dart';
import 'package:flutter/material.dart';

class IdpServicesScreen extends StatelessWidget {
  const IdpServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        title: const Text('الخدمات المتاحة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final service in _services) ...[
                _ServiceCard(service: service),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String availability;

  const _ServiceItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.availability,
  });
}

const List<_ServiceItem> _services = [
  _ServiceItem(
    title: 'مركز التسجيل',
    description: 'تسجيل العائلات الجديدة وتحديث بيانات الأسرة عبر المتطوعين.',
    icon: Icons.app_registration,
    color: AppColors.primary,
    availability: 'يومياً 8 ص - 4 م',
  ),
  _ServiceItem(
    title: 'نقطة توزيع المياه',
    description: 'تعبئة وتوزيع مياه الشرب النظيفة لجميع العائلات المسجلة.',
    icon: Icons.water_drop_outlined,
    color: AppColors.secondary,
    availability: 'يومياً 6 ص - 6 م',
  ),
  _ServiceItem(
    title: 'العيادة الصحية',
    description: 'فحص طبي أولي، إسعافات وصرف أدوية أساسية.',
    icon: Icons.medical_services_outlined,
    color: AppColors.danger,
    availability: 'يومياً 9 ص - 5 م',
  ),
  _ServiceItem(
    title: 'نقطة توزيع الغذاء',
    description: 'توزيع السلال الغذائية والمساعدات العينية بشكل دوري.',
    icon: Icons.restaurant_outlined,
    color: AppColors.warning,
    availability: 'حسب الجدول الأسبوعي',
  ),
  _ServiceItem(
    title: 'مركز الدعم النفسي والاجتماعي',
    description: 'جلسات دعم نفسي فردية وجماعية للكبار والأطفال.',
    icon: Icons.favorite_outline,
    color: AppColors.success,
    availability: 'السبت - الخميس',
  ),
  _ServiceItem(
    title: 'نقطة الأمن والسلامة',
    description: 'الإبلاغ عن أي حالة طارئة أو مشكلة أمنية داخل المخيم.',
    icon: Icons.shield_outlined,
    color: AppColors.secondaryDark,
    availability: 'متاح على مدار الساعة',
  ),
];

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final _ServiceItem service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: service.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(service.icon, color: service.color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 13, color: service.color),
                    const SizedBox(width: 4),
                    Text(
                      service.availability,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: service.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
