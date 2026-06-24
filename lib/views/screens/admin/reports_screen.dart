import 'package:displacement_camp_management_system/controllers/cubit/app_cubit.dart';
import 'package:displacement_camp_management_system/controllers/cubit/app_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/pdf_report_service.dart';
import '../../../utils/styles/colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      buildWhen: (p, c) =>
          c is DashboardSuccessState ||
          c is DashboardLoadingState ||
          c is CampsSuccessState ||
          c is DisplacedSuccessState,
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        final stats = cubit.dashboardStats;
        final camps = cubit.camps;
        final families = cubit.families;
        final activities = cubit.recentActivities;
        final aidList = cubit.aidDistributions;

        // ── حساب إحصائيات المساعدات من البيانات الحقيقية ────────
        final Map<String, int> aidByType = {};
        for (final d in aidList) {
          final type = d['aidType']?.toString() ?? 'أخرى';
          aidByType[type] =
              (aidByType[type] ?? 0) + (d['quantity'] as int? ?? 0);
        }
        final totalAidQty = aidByType.values.fold(0, (a, b) => a + b);

        // ── نسبة الإشغال لكل مخيم ────────────────────────────────
        final campStats = camps.map((c) {
          final cap = (c['capacity'] as int? ?? 1);
          final cur = (c['current'] as int? ?? 0);
          return {
            'name': c['name'] ?? '',
            'percent': (cur / cap).clamp(0.0, 1.0),
            'current': cur,
            'capacity': cap,
            'status': c['status'] ?? '',
          };
        }).toList();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ══ 1. بطاقات الإحصائيات الأربع ═══════════════════
              _SectionTitle(title: 'ملخص عام', trailing: _liveIndicator()),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.25,
                children: [
                  _StatCard(
                    label: 'إجمالي المخيمات',
                    value: '${stats['totalCamps'] ?? 0}',
                    sub: '${stats['activeCamps'] ?? 0} نشط',
                    icon: Icons.holiday_village_rounded,
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    label: 'الأسر المسجلة',
                    value: '${stats['totalFamilies'] ?? 0}',
                    sub: '${stats['totalDisplaced'] ?? 0} فرد',
                    icon: Icons.family_restroom_rounded,
                    color: AppColors.secondary,
                  ),
                  _StatCard(
                    label: 'نسبة الإشغال',
                    value: '${stats['occupancyPercent'] ?? 0}%',
                    sub: 'من إجمالي السعة',
                    icon: Icons.bar_chart_rounded,
                    color: _occupancyColor(
                        int.tryParse('${stats['occupancyPercent'] ?? 0}') ?? 0),
                  ),
                  _StatCard(
                    label: 'المساعدات',
                    value: '$totalAidQty',
                    sub: '${aidList.length} سجل توزيع',
                    icon: Icons.volunteer_activism_rounded,
                    color: AppColors.warning,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ══ 2. إشغال المخيمات ══════════════════════════════
              const _SectionTitle(title: 'إشغال المخيمات'),
              const SizedBox(height: 10),

              if (campStats.isEmpty)
                const _EmptyCard(message: 'لا توجد مخيمات مسجلة')
              else
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.border.withOpacity(0.4)),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: campStats.map((c) {
                      return _CampOccupancyRow(
                        name: c['name'] as String,
                        percent: c['percent'] as double,
                        current: c['current'] as int,
                        capacity: c['capacity'] as int,
                        status: c['status'] as String,
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 22),

              // ══ 3. توزيع المساعدات حسب النوع ═══════════════════
              const _SectionTitle(title: 'توزيع المساعدات'),
              const SizedBox(height: 10),

              if (aidByType.isEmpty)
                const _EmptyCard(message: 'لا توجد سجلات مساعدات')
              else
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.border.withOpacity(0.4)),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      // رسم بياني بسيط بالألوان
                      _AidDonutSummary(
                          aidByType: aidByType, total: totalAidQty),
                      const SizedBox(height: 14),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 12),
                      // أشرطة لكل نوع
                      ...() {
                        final colors = [
                          AppColors.primary,
                          AppColors.secondary,
                          AppColors.warning,
                          AppColors.success,
                          AppColors.statusCritical,
                        ];
                        int idx = 0;
                        return aidByType.entries.map((e) {
                          final pct =
                              totalAidQty == 0 ? 0.0 : e.value / totalAidQty;
                          final color = colors[idx % colors.length];
                          idx++;
                          return _AidProgressRow(
                            label: e.key,
                            qty: e.value,
                            pct: pct,
                            color: color,
                            total: totalAidQty,
                          );
                        }).toList();
                      }(),
                    ],
                  ),
                ),

              const SizedBox(height: 22),

              // ══ 4. توزيع الأسر حسب المخيم ══════════════════════
              const _SectionTitle(title: 'الأسر حسب المخيم'),
              const SizedBox(height: 10),

              if (families.isEmpty)
                const _EmptyCard(message: 'لا توجد أسر مسجلة')
              else ...[
                () {
                  final Map<String, int> byCamp = {};
                  for (final f in families) {
                    final cn = f['campName']?.toString() ?? 'غير محدد';
                    byCamp[cn] = (byCamp[cn] ?? 0) + 1;
                  }
                  final colors = [
                    AppColors.primary,
                    AppColors.secondary,
                    AppColors.warning,
                    AppColors.success,
                  ];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColors.border.withOpacity(0.4)),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children:
                          byCamp.entries.toList().asMap().entries.map((e) {
                        final idx = e.key;
                        final entry = e.value;
                        final pct = families.isEmpty
                            ? 0.0
                            : entry.value / families.length;
                        return _AidProgressRow(
                          label: entry.key,
                          qty: entry.value,
                          pct: pct,
                          color: colors[idx % colors.length],
                          total: families.length,
                          unit: 'أسرة',
                        );
                      }).toList(),
                    ),
                  );
                }(),
              ],

              const SizedBox(height: 22),

              // ══ 5. النشاط الأخير ════════════════════════════════
              _SectionTitle(
                title: 'النشاط الأخير',
                trailing: Text(
                  '${activities.length} حدث',
                  style:
                      const TextStyle(color: AppColors.secondary, fontSize: 12),
                ),
              ),
              const SizedBox(height: 10),

              if (activities.isEmpty)
                const _EmptyCard(message: 'لا توجد نشاطات مسجلة')
              else
                Column(
                  children: activities
                      .take(7)
                      .map((a) => _ActivityItem(
                            title: a['title'] ?? '',
                            subtitle: a['subtitle'] ?? '',
                            type: a['type'] ?? 'default',
                          ))
                      .toList(),
                ),

              const SizedBox(height: 22),

              // ══ 6. زر تصدير ════════════════════════════════════
              _ExportButton(
                onTap: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text('جاري إنشاء التقرير...'),
                        ],
                      ),
                      backgroundColor: AppColors.primary,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  try {
                    await PdfReportService.generateAndShare(
                      stats: cubit.dashboardStats,
                      camps: cubit.camps,
                      families: cubit.families,
                      aidDistributions: cubit.aidDistributions,
                      activities: cubit.recentActivities,
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('خطأ في إنشاء التقرير: $e'),
                          backgroundColor: AppColors.statusCritical,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Color _occupancyColor(int pct) {
    if (pct >= 90) return AppColors.statusCritical;
    if (pct >= 70) return AppColors.statusWarning;
    return AppColors.statusStable;
  }

  Widget _liveIndicator() {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
              color: AppColors.success, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        const Text('مباشر',
            style: TextStyle(
                fontSize: 11,
                color: AppColors.success,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  _SectionTitle
// ══════════════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  _StatCard
// ══════════════════════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 1),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          Text(sub,
              style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  _CampOccupancyRow
// ══════════════════════════════════════════════════════════════
class _CampOccupancyRow extends StatelessWidget {
  final String name, status;
  final double percent;
  final int current, capacity;
  const _CampOccupancyRow({
    required this.name,
    required this.percent,
    required this.current,
    required this.capacity,
    required this.status,
  });

  Color get _barColor {
    if (percent >= 0.9) return AppColors.statusCritical;
    if (percent >= 0.7) return AppColors.statusWarning;
    return AppColors.statusStable;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ),
              Text(
                '${(percent * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _barColor),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              color: _barColor,
              backgroundColor: AppColors.border,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$current من $capacity فرد',
                  style:
                      const TextStyle(fontSize: 10, color: AppColors.textHint)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: status == 'متاح'
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.statusWarning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: status == 'متاح'
                            ? AppColors.success
                            : AppColors.statusWarning)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  _AidDonutSummary — ملخص دائري بسيط بدون library خارجية
// ══════════════════════════════════════════════════════════════
class _AidDonutSummary extends StatelessWidget {
  final Map<String, int> aidByType;
  final int total;
  const _AidDonutSummary({required this.aidByType, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 10,
                color: AppColors.border,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$total',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const Text('وحدة',
                    style: TextStyle(fontSize: 10, color: AppColors.textHint)),
              ],
            ),
          ],
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: aidByType.entries.take(4).map((e) {
            final pct = total == 0 ? 0 : (e.value * 100 ~/ total);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('${e.key}  $pct%',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  _AidProgressRow
// ══════════════════════════════════════════════════════════════
class _AidProgressRow extends StatelessWidget {
  final String label, unit;
  final int qty, total;
  final double pct;
  final Color color;
  const _AidProgressRow({
    required this.label,
    required this.qty,
    required this.pct,
    required this.color,
    required this.total,
    this.unit = 'وحدة',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 7),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              Text('$qty $unit  •  ${(pct * 100).toStringAsFixed(0)}%',
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.textHint)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              color: color,
              backgroundColor: AppColors.border,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  _ActivityItem
// ══════════════════════════════════════════════════════════════
class _ActivityItem extends StatelessWidget {
  final String title, subtitle, type;
  const _ActivityItem(
      {required this.title, required this.subtitle, required this.type});

  IconData get _icon {
    switch (type) {
      case 'register':
        return Icons.person_add_rounded;
      case 'camp':
        return Icons.holiday_village_rounded;
      case 'aid':
        return Icons.volunteer_activism_rounded;
      case 'shipment':
        return Icons.local_shipping_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  Color get _color {
    switch (type) {
      case 'register':
        return AppColors.secondary;
      case 'camp':
        return AppColors.warning;
      case 'aid':
        return AppColors.success;
      case 'shipment':
        return AppColors.primary;
      case 'warning':
        return AppColors.statusCritical;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textHint)),
              ],
            ),
          ),
          Icon(Icons.circle, size: 7, color: _color.withOpacity(0.5)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  _EmptyCard
// ══════════════════════════════════════════════════════════════
class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: Text(message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  _ExportButton
// ══════════════════════════════════════════════════════════════
class _ExportButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ExportButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      onPressed: onTap,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf_rounded, size: 20),
          SizedBox(width: 10),
          Text('تصدير التقرير PDF', style: TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
