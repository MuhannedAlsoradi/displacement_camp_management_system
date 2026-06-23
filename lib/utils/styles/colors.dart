import 'package:flutter/material.dart';

/// نظام الألوان لتطبيق إدارة مخيمات النازحين
/// المقترح الأول — الثقة والأمان
class AppColors {
  AppColors._();

  // ─── الألوان الرئيسية (Primary — أخضر زيتوني) ───────────────────────
  static const Color primary50 = Color(0xFFE1F5EE);
  static const Color primary100 = Color(0xFF9FE1CB);
  static const Color primary200 = Color(0xFF5DCAA5);
  static const Color primary400 = Color(0xFF1D9E75); // اللون الرئيسي
  static const Color primary600 = Color(0xFF0F6E56);
  static const Color primary800 = Color(0xFF085041);
  static const Color primary900 = Color(0xFF04342C);

  /// اختصارات للاستخدام اليومي
  static const Color primary = primary400;
  static const Color primaryLight = primary50;
  static const Color primaryDark = primary600;
  static const Color primaryDarker = primary800;

  // ─── اللون الثانوي (Secondary — أزرق رسمي) ──────────────────────────
  static const Color secondary50 = Color(0xFFE6F1FB);
  static const Color secondary100 = Color(0xFFB5D4F4);
  static const Color secondary200 = Color(0xFF85B7EB);
  static const Color secondary400 = Color(0xFF378ADD); // اللون الثانوي
  static const Color secondary600 = Color(0xFF185FA5);
  static const Color secondary800 = Color(0xFF0C447C);
  static const Color secondary900 = Color(0xFF042C53);

  static const Color secondary = secondary400;
  static const Color secondaryLight = secondary50;
  static const Color secondaryDark = secondary600;

  // ─── الرمادي الدافئ (Neutral) ────────────────────────────────────────
  static const Color neutral50 = Color(0xFFF1EFE8);
  static const Color neutral100 = Color(0xFFD3D1C7);
  static const Color neutral200 = Color(0xFFB4B2A9);
  static const Color neutral400 = Color(0xFF888780);
  static const Color neutral600 = Color(0xFF5F5E5A);
  static const Color neutral800 = Color(0xFF444441);
  static const Color neutral900 = Color(0xFF2C2C2A);

  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundPage = Color(0xFFF5F7FA);
  static const Color backgroundCard = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = neutral50;
  static const Color border = neutral100;
  static const Color borderStrong = neutral200;

  static const Color textPrimary = neutral900;
  static const Color textSecondary = neutral600;
  static const Color textHint = neutral400;
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // ─── الألوان الوظيفية ────────────────────────────────────────────────

  /// 🔴 طوارئ — للحالات الحرجة فقط (نقص غذاء، حالة طبية حرجة)
  static const Color danger50 = Color(0xFFFCEBEB);
  static const Color danger200 = Color(0xFFF09595);
  static const Color danger400 = Color(0xFFE24B4A);
  static const Color danger600 = Color(0xFFA32D2D);
  static const Color danger800 = Color(0xFF791F1F);

  static const Color danger = danger400;
  static const Color dangerLight = danger50;
  static const Color dangerDark = danger600;

  /// 🟡 تحذير — موارد منخفضة، مواعيد قريبة
  static const Color warning50 = Color(0xFFFAEEDA);
  static const Color warning200 = Color(0xFFFAC775);
  static const Color warning400 = Color(0xFFEF9F27);
  static const Color warning600 = Color(0xFFBA7517);
  static const Color warning800 = Color(0xFF854F0B);

  static const Color warning = warning400;
  static const Color warningLight = warning50;
  static const Color warningDark = warning600;

  /// 🟢 نجاح — عمليات مكتملة، حالة جيدة
  static const Color success50 = Color(0xFFEAF3DE);
  static const Color success200 = Color(0xFF97C459);
  static const Color success400 = Color(0xFF639922);
  static const Color success600 = Color(0xFF3B6D11);
  static const Color success800 = Color(0xFF27500A);

  static const Color success = success400;
  static const Color successLight = success50;
  static const Color successDark = success600;

  /// ⚫ معطّل / غير نشط
  static const Color disabled = neutral200;
  static const Color disabledText = neutral400;
  static const Color disabledBg = neutral50;

  // ─── حالات المخيم ────────────────────────────────────────────────────
  /// استخدام خاص لحالات وضع المخيم أو حالة النازح

  static const Color statusCritical = danger400; // حرج
  static const Color statusWarning = warning400; // تحذير
  static const Color statusStable = primary400; // مستقر
  static const Color statusGood = success400; // جيد
  static const Color statusInactive = neutral400; // غير نشط / مغلق

  // ─── الوضع الليلي (Dark Mode) ────────────────────────────────────────
  static const Color darkBackground = Color(0xFF1A1A18);
  static const Color darkBackgroundCard = Color(0xFF242422);
  static const Color darkSurfaceSecondary = Color(0xFF2C2C2A);
  static const Color darkBorder = Color(0xFF444441);
  static const Color darkBorderStrong = Color(0xFF5F5E5A);
  static const Color darkTextPrimary = Color(0xFFF1EFE8);
  static const Color darkTextSecondary = Color(0xFFB4B2A9);
  static const Color darkTextHint = Color(0xFF888780);

  // ─── ColorScheme جاهز للاستخدام مع MaterialApp ─────────────────────
  static ColorScheme get lightScheme => const ColorScheme(
        background: Colors.white,
        onBackground: Colors.white,
        brightness: Brightness.light,
        primary: primary,
        onPrimary: textOnPrimary,
        primaryContainer: primary50,
        onPrimaryContainer: primary900,
        secondary: secondary,
        onSecondary: textOnSecondary,
        secondaryContainer: secondary50,
        onSecondaryContainer: secondary900,
        error: danger,
        onError: Color(0xFFFFFFFF),
        errorContainer: danger50,
        onErrorContainer: danger800,
        surface: background,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        outline: border,
        outlineVariant: borderStrong,
      );

  static ColorScheme get darkScheme => const ColorScheme(
        background: Colors.white,
        onBackground: Colors.white,
        brightness: Brightness.dark,
        primary: primary200,
        onPrimary: primary900,
        primaryContainer: primary800,
        onPrimaryContainer: primary50,
        secondary: secondary200,
        onSecondary: secondary900,
        secondaryContainer: secondary800,
        onSecondaryContainer: secondary50,
        error: danger200,
        onError: danger800,
        errorContainer: danger800,
        onErrorContainer: danger50,
        surface: darkBackground,
        onSurface: darkTextPrimary,
        onSurfaceVariant: darkTextSecondary,
        outline: darkBorder,
        outlineVariant: darkBorderStrong,
      );

  // ─── ThemeData جاهز ─────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        scaffoldBackgroundColor: backgroundPage,
        cardColor: backgroundCard,
        dividerColor: border,
        fontFamily: 'Cairo',
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: darkBackground,
        cardColor: darkBackgroundCard,
        dividerColor: darkBorder,
        fontFamily: 'Cairo',
      );
}
