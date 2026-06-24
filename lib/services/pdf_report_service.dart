import 'package:intl/intl.dart' show DateFormat;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// خدمة توليد وتصدير تقرير PDF لنظام إدارة مخيمات النازحين
class PdfReportService {
  // ── ألوان تتوافق مع AppColors ─────────────────────────────────
  static const _primary = PdfColor.fromInt(0xFF1565C0);
  static const _secondary = PdfColor.fromInt(0xFF00897B);
  static const _warning = PdfColor.fromInt(0xFFF57C00);
  static const _critical = PdfColor.fromInt(0xFFD32F2F);
  static const _success = PdfColor.fromInt(0xFF388E3C);
  static const _bgLight = PdfColor.fromInt(0xFFF5F7FA);
  static const _border = PdfColor.fromInt(0xFFE0E0E0);
  static const _textPrimary = PdfColor.fromInt(0xFF1A1A2E);
  static const _textSecondary = PdfColor.fromInt(0xFF616161);
  static const _textHint = PdfColor.fromInt(0xFF9E9E9E);

  /// ─── الدالة الرئيسية: توليد وعرض/تصدير PDF ───────────────────
  static Future<void> generateAndShare({
    required Map<String, dynamic> stats,
    required List<Map<String, dynamic>> camps,
    required List<Map<String, dynamic>> families,
    required List<Map<String, dynamic>> aidDistributions,
    required List<Map<String, dynamic>> activities,
  }) async {
    // ── تحميل خط Cairo من Google Fonts مباشرة (يدعم العربية تماماً) ──
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicFontBold = await PdfGoogleFonts.cairoBold();

    final pdf = pw.Document();

    // ── احسب الإحصائيات المشتقة ────────────────────────────────
    final Map<String, int> aidByType = {};
    for (final d in aidDistributions) {
      final type = d['aidType']?.toString() ?? 'أخرى';
      aidByType[type] = (aidByType[type] ?? 0) + (d['quantity'] as int? ?? 0);
    }
    final totalAidQty = aidByType.values.fold(0, (a, b) => a + b);

    final Map<String, int> familiesByCamp = {};
    for (final f in families) {
      final cn = f['campName']?.toString() ?? 'غير محدد';
      familiesByCamp[cn] = (familiesByCamp[cn] ?? 0) + 1;
    }

    final now = DateFormat('yyyy/MM/dd  HH:mm').format(DateTime.now());

    final baseStyle = pw.TextStyle(font: arabicFont, fontFallback: const []);
    final boldStyle = pw.TextStyle(
      font: arabicFontBold,
      fontFallback: const [],
      fontWeight: pw.FontWeight.bold,
    );

    // ════════════════════════════════════════════════════════════
    //  الصفحة الأولى — الغلاف + الملخص العام
    // ════════════════════════════════════════════════════════════
    pdf.addPage(
      pw.Page(
        pageTheme: _pageTheme(),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _buildHeader(
              title: 'تقرير نظام إدارة مخيمات النازحين',
              subtitle: 'تاريخ الإصدار: $now',
              baseStyle: baseStyle,
              boldStyle: boldStyle,
            ),
            pw.SizedBox(height: 24),
            _sectionTitle('ملخص عام', boldStyle),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                _statCard(
                  label: 'إجمالي المخيمات',
                  value: '${stats['totalCamps'] ?? 0}',
                  sub: '${stats['activeCamps'] ?? 0} نشط',
                  color: _primary,
                  baseStyle: baseStyle,
                  boldStyle: boldStyle,
                ),
                pw.SizedBox(width: 10),
                _statCard(
                  label: 'الأسر المسجلة',
                  value: '${stats['totalFamilies'] ?? 0}',
                  sub: '${stats['totalDisplaced'] ?? 0} فرد',
                  color: _secondary,
                  baseStyle: baseStyle,
                  boldStyle: boldStyle,
                ),
                pw.SizedBox(width: 10),
                _statCard(
                  label: 'نسبة الإشغال',
                  value: '${stats['occupancyPercent'] ?? 0}%',
                  sub: 'من إجمالي السعة',
                  color: _warning,
                  baseStyle: baseStyle,
                  boldStyle: boldStyle,
                ),
                pw.SizedBox(width: 10),
                _statCard(
                  label: 'المساعدات',
                  value: '$totalAidQty',
                  sub: '${aidDistributions.length} سجل',
                  color: _success,
                  baseStyle: baseStyle,
                  boldStyle: boldStyle,
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            _sectionTitle('إشغال المخيمات', boldStyle),
            pw.SizedBox(height: 8),
            _campsTable(camps, baseStyle, boldStyle),
          ],
        ),
      ),
    );

    // ════════════════════════════════════════════════════════════
    //  الصفحة الثانية — المساعدات + الأسر + النشاط الأخير
    // ════════════════════════════════════════════════════════════
    pdf.addPage(
      pw.Page(
        pageTheme: _pageTheme(),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _buildHeader(
              title: 'تقرير نظام إدارة مخيمات النازحين',
              subtitle: 'تاريخ الإصدار: $now',
              baseStyle: baseStyle,
              boldStyle: boldStyle,
              isSecondPage: true,
            ),
            pw.SizedBox(height: 20),
            _sectionTitle('توزيع المساعدات حسب النوع', boldStyle),
            pw.SizedBox(height: 8),
            if (aidByType.isEmpty)
              _emptyRow('لا توجد سجلات مساعدات', baseStyle)
            else
              _aidTable(aidByType, totalAidQty, baseStyle, boldStyle),
            pw.SizedBox(height: 20),
            _sectionTitle('الأسر حسب المخيم', boldStyle),
            pw.SizedBox(height: 8),
            if (familiesByCamp.isEmpty)
              _emptyRow('لا توجد أسر مسجلة', baseStyle)
            else
              _familiesTable(
                  familiesByCamp, families.length, baseStyle, boldStyle),
            pw.SizedBox(height: 20),
            _sectionTitle('النشاط الأخير', boldStyle),
            pw.SizedBox(height: 8),
            if (activities.isEmpty)
              _emptyRow('لا توجد نشاطات', baseStyle)
            else
              _activitiesTable(
                  activities.take(10).toList(), baseStyle, boldStyle),
            pw.Spacer(),
            _buildFooter(baseStyle),
          ],
        ),
      ),
    );

    // ── مشاركة / طباعة PDF ──────────────────────────────────────
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'تقرير_مخيمات_النازحين_$now.pdf',
    );
  }

  // ════════════════════════════════════════════════════════════
  //  مساعدات البناء
  // ════════════════════════════════════════════════════════════

  static pw.PageTheme _pageTheme() => pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        buildBackground: (ctx) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(color: _bgLight),
        ),
      );

  static pw.Widget _buildHeader({
    required String title,
    required String subtitle,
    required pw.TextStyle baseStyle,
    required pw.TextStyle boldStyle,
    bool isSecondPage = false,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _primary,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: boldStyle.copyWith(color: PdfColors.white, fontSize: 16),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                subtitle,
                style: baseStyle.copyWith(
                    color: const PdfColor.fromInt(0xB3FFFFFF), fontSize: 10),
              ),
            ],
          ),
          pw.Container(
            width: 40,
            height: 40,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Center(
              child: pw.Text('NDP',
                  style: boldStyle.copyWith(fontSize: 9, color: _primary)),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _sectionTitle(String title, pw.TextStyle boldStyle) {
    return pw.Row(
      children: [
        pw.Container(
          width: 4,
          height: 18,
          decoration: pw.BoxDecoration(
            color: _primary,
            borderRadius: pw.BorderRadius.circular(2),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          title,
          style: boldStyle.copyWith(fontSize: 13, color: _textPrimary),
        ),
      ],
    );
  }

  static pw.Widget _statCard({
    required String label,
    required String value,
    required String sub,
    required PdfColor color,
    required pw.TextStyle baseStyle,
    required pw.TextStyle boldStyle,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(color: _border, width: 0.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 8,
              height: 8,
              decoration:
                  pw.BoxDecoration(color: color, shape: pw.BoxShape.circle),
            ),
            pw.SizedBox(height: 6),
            pw.Text(value,
                style: boldStyle.copyWith(fontSize: 18, color: color)),
            pw.SizedBox(height: 2),
            pw.Text(label,
                style: baseStyle.copyWith(fontSize: 9, color: _textSecondary)),
            pw.Text(sub,
                style: baseStyle.copyWith(fontSize: 8, color: _textHint)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _campsTable(
    List<Map<String, dynamic>> camps,
    pw.TextStyle baseStyle,
    pw.TextStyle boldStyle,
  ) {
    if (camps.isEmpty) return _emptyRow('لا توجد مخيمات', baseStyle);

    final headerStyle =
        boldStyle.copyWith(fontSize: 10, color: PdfColors.white);
    final cellStyle = baseStyle.copyWith(fontSize: 9, color: _textPrimary);

    return pw.Table(
      border: pw.TableBorder.all(color: _border, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _primary),
          children: [
            _cell('اسم المخيم', headerStyle),
            _cell('الحالة', headerStyle),
            _cell('الطاقة', headerStyle),
            _cell('الحالي', headerStyle),
            _cell('الإشغال', headerStyle),
          ],
        ),
        ...camps.map((c) {
          final cap = (c['capacity'] as int? ?? 1);
          final cur = (c['current'] as int? ?? 0);
          final pct = (cur / cap * 100).toStringAsFixed(0);
          final status = c['status']?.toString() ?? '';
          final statusColor = status == 'متاح'
              ? _success
              : status == 'ممتلئ تقريباً'
                  ? _warning
                  : _critical;
          final pctVal = double.tryParse(pct) ?? 0;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: camps.indexOf(c).isEven
                  ? PdfColors.white
                  : const PdfColor.fromInt(0xFFF8F9FA),
            ),
            children: [
              _cell(c['name']?.toString() ?? '', cellStyle),
              _cellColored(status, cellStyle, statusColor),
              _cell('$cap', cellStyle),
              _cell('$cur', cellStyle),
              _cell(
                  '$pct%',
                  cellStyle.copyWith(
                    color: pctVal >= 90
                        ? _critical
                        : pctVal >= 70
                            ? _warning
                            : _success,
                  )),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _aidTable(
    Map<String, int> aidByType,
    int total,
    pw.TextStyle baseStyle,
    pw.TextStyle boldStyle,
  ) {
    final headerStyle =
        boldStyle.copyWith(fontSize: 10, color: PdfColors.white);
    final cellStyle = baseStyle.copyWith(fontSize: 9, color: _textPrimary);

    return pw.Table(
      border: pw.TableBorder.all(color: _border, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _secondary),
          children: [
            _cell('نوع المساعدة', headerStyle),
            _cell('الكمية', headerStyle),
            _cell('النسبة', headerStyle),
          ],
        ),
        ...aidByType.entries.map((e) {
          final pct =
              total == 0 ? '0' : (e.value / total * 100).toStringAsFixed(1);
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: aidByType.keys.toList().indexOf(e.key).isEven
                  ? PdfColors.white
                  : const PdfColor.fromInt(0xFFF8F9FA),
            ),
            children: [
              _cell(e.key, cellStyle),
              _cell('${e.value} وحدة', cellStyle),
              _cell('$pct%', cellStyle),
            ],
          );
        }),
        pw.TableRow(
          decoration:
              const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE3F2FD)),
          children: [
            _cell('الإجمالي', boldStyle.copyWith(fontSize: 9, color: _primary)),
            _cell('$total وحدة',
                boldStyle.copyWith(fontSize: 9, color: _primary)),
            _cell('100%', boldStyle.copyWith(fontSize: 9, color: _primary)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _familiesTable(
    Map<String, int> byCamp,
    int totalFamilies,
    pw.TextStyle baseStyle,
    pw.TextStyle boldStyle,
  ) {
    final headerStyle =
        boldStyle.copyWith(fontSize: 10, color: PdfColors.white);
    final cellStyle = baseStyle.copyWith(fontSize: 9, color: _textPrimary);

    return pw.Table(
      border: pw.TableBorder.all(color: _border, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _warning),
          children: [
            _cell('اسم المخيم', headerStyle),
            _cell('عدد الأسر', headerStyle),
            _cell('النسبة', headerStyle),
          ],
        ),
        ...byCamp.entries.map((e) {
          final pct = totalFamilies == 0
              ? '0'
              : (e.value / totalFamilies * 100).toStringAsFixed(1);
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: byCamp.keys.toList().indexOf(e.key).isEven
                  ? PdfColors.white
                  : const PdfColor.fromInt(0xFFF8F9FA),
            ),
            children: [
              _cell(e.key, cellStyle),
              _cell('${e.value} أسرة', cellStyle),
              _cell('$pct%', cellStyle),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _activitiesTable(
    List<Map<String, dynamic>> activities,
    pw.TextStyle baseStyle,
    pw.TextStyle boldStyle,
  ) {
    final headerStyle =
        boldStyle.copyWith(fontSize: 10, color: PdfColors.white);
    final cellStyle = baseStyle.copyWith(fontSize: 9, color: _textPrimary);

    return pw.Table(
      border: pw.TableBorder.all(color: _border, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration:
              const pw.BoxDecoration(color: PdfColor.fromInt(0xFF455A64)),
          children: [
            _cell('النشاط', headerStyle),
            _cell('التفاصيل', headerStyle),
          ],
        ),
        ...activities.map((a) => pw.TableRow(
              decoration: pw.BoxDecoration(
                color: activities.indexOf(a).isEven
                    ? PdfColors.white
                    : const PdfColor.fromInt(0xFFF8F9FA),
              ),
              children: [
                _cell(a['title']?.toString() ?? '', cellStyle),
                _cell(a['subtitle']?.toString() ?? '', cellStyle),
              ],
            )),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.TextStyle baseStyle) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _border, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'نظام إدارة مخيمات النازحين',
            style: baseStyle.copyWith(fontSize: 9, color: _textHint),
          ),
          pw.Text(
            'تقرير سري — للاستخدام الداخلي فقط',
            style: baseStyle.copyWith(fontSize: 9, color: _textHint),
          ),
        ],
      ),
    );
  }

  static pw.Widget _cell(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(text, style: style, textAlign: pw.TextAlign.center),
    );
  }

  static pw.Widget _cellColored(
      String text, pw.TextStyle style, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(text,
          style: style.copyWith(color: color, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center),
    );
  }

  static pw.Widget _emptyRow(String msg, pw.TextStyle baseStyle) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _border, width: 0.5),
      ),
      child: pw.Text(msg,
          style: baseStyle.copyWith(fontSize: 10, color: _textHint),
          textAlign: pw.TextAlign.center),
    );
  }
}
