import 'package:displacement_camp_management_system/utils/styles/colors.dart';
import 'package:flutter/material.dart';

class IdpAwarenessScreen extends StatelessWidget {
  const IdpAwarenessScreen({super.key, this.categoryFilter});

  /// لو محددة، بتعرض بس عناصر هاي الفئة. لو null بتعرض كل المحتوى.
  final String? categoryFilter;

  @override
  Widget build(BuildContext context) {
    final content = categoryFilter == null
        ? _awarenessContent
        : _awarenessContent
            .where((item) => item.category == categoryFilter)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        title: Text(categoryFilter ?? 'التوعية والتعليم'),
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
              if (content.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'لا يوجد محتوى متاح حالياً في هذه الفئة',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  ),
                )
              else
                for (final item in content) ...[
                  _AwarenessCard(item: item),
                  const SizedBox(height: 10),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AwarenessItem {
  final String category;
  final Color color;
  final IconData icon;
  final String title;
  final String body;

  const _AwarenessItem({
    required this.category,
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
  });
}

const List<_AwarenessItem> _awarenessContent = [
  _AwarenessItem(
    category: 'صحة',
    color: AppColors.danger,
    icon: Icons.health_and_safety_outlined,
    title: 'الوقاية من الأمراض المعدية',
    body:
        'اغسل يديك بالماء والصابون بانتظام، خاصة قبل الأكل وبعد استخدام الحمام. '
        'حافظ على نظافة مكان إقامتك، وتجنب مشاركة أدوات الطعام الشخصية مع الآخرين. '
        'في حال ظهور أعراض مثل الحمى أو الإسهال، توجه فوراً إلى العيادة الصحية داخل المخيم.',
  ),
  _AwarenessItem(
    category: 'سلامة',
    color: AppColors.warning,
    icon: Icons.local_fire_department_outlined,
    title: 'إرشادات السلامة من الحرائق',
    body:
        'تجنب استخدام مصادر الإضاءة أو التدفئة المكشوفة داخل الخيام قدر الإمكان. '
        'احتفظ بمسافة آمنة بين أي مصدر للنار والمواد القابلة للاشتعال. '
        'في حال نشوب حريق، أبلغ نقطة الأمن فوراً وابتعد عن المكان بهدوء دون تدافع.',
  ),
  _AwarenessItem(
    category: 'حقوق',
    color: AppColors.secondary,
    icon: Icons.gavel_outlined,
    title: 'حقوق النازحين الأساسية',
    body:
        'لكل فرد نازح الحق في الحصول على المأوى والغذاء والماء والرعاية الصحية دون تمييز. '
        'يحق لك تقديم شكوى أو طلب مساعدة عبر المتطوعين أو إدارة المخيم في أي وقت. '
        'بياناتك الشخصية محمية ولا تُستخدم إلا لأغراض تقديم الخدمة.',
  ),
  _AwarenessItem(
    category: 'سلامة',
    color: AppColors.warning,
    icon: Icons.report_outlined,
    title: 'الإبلاغ عن العنف أو الاستغلال',
    body:
        'إذا تعرضت أنت أو أحد أفراد عائلتك لأي شكل من أشكال العنف أو الاستغلال، '
        'توجه فوراً إلى نقطة الأمن والسلامة أو أي متطوع موثوق داخل المخيم. '
        'جميع البلاغات تُعامل بسرية تامة لحماية المُبلّغ.',
  ),
  _AwarenessItem(
    category: 'نفسي اجتماعي',
    color: AppColors.success,
    icon: Icons.psychology_outlined,
    title: 'الدعم النفسي للأطفال في أوقات الأزمات',
    body: 'حافظ على روتين يومي ثابت قدر الإمكان لمنح الطفل شعوراً بالأمان. '
        'استمع لمخاوف طفلك دون تهوين مشاعره، وامنحه مساحة للتعبير باللعب أو الرسم. '
        'عند ملاحظة قلق شديد أو انعزال متواصل، يمكن التوجه لمركز الدعم النفسي والاجتماعي.',
  ),
  _AwarenessItem(
    category: 'صحة',
    color: AppColors.danger,
    icon: Icons.water_drop_outlined,
    title: 'الاستخدام الآمن لمياه الشرب',
    body: 'احرص على تخزين مياه الشرب في أوعية نظيفة ومغطاة لتجنب التلوث. '
        'لا تستخدم نفس الوعاء لتخزين الماء وأغراض التنظيف. '
        'في حال الشك بنظافة المياه، يفضل غليها قبل الاستخدام للشرب.',
  ),
  _AwarenessItem(
    category: 'تعليم',
    color: AppColors.secondary,
    icon: Icons.school_outlined,
    title: 'فرص التعليم والتدريب داخل المخيم',
    body:
        'تتوفر حلقات تعليمية غير رسمية للأطفال لمتابعة المهارات الأساسية في القراءة والكتابة والحساب. '
        'كما تُنظَّم دورات تدريبية قصيرة للشباب في مهارات حرفية وحياتية تساعد على التكيف وتحسين فرص العمل مستقبلاً. '
        'للاستفسار عن مواعيد الحلقات والدورات، يمكن التوجه إلى مركز التسجيل أو سؤال أي متطوع.',
  ),
];

class _AwarenessCard extends StatelessWidget {
  const _AwarenessCard({required this.item});

  final _AwarenessItem item;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(item.icon, color: item.color, size: 19),
          ),
          title: Text(
            item.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.category,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: item.color,
                ),
              ),
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                item.body,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
