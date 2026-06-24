import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:displacement_camp_management_system/views/screens/shared/role_selection_screen.dart';
import 'package:displacement_camp_management_system/controllers/cubit/app_cubit.dart';
import 'package:displacement_camp_management_system/utils/styles/colors.dart';
import 'package:displacement_camp_management_system/views/layout/admin_layout_screen.dart';
import 'package:displacement_camp_management_system/views/layout/idp_layout_screen.dart';
import 'package:displacement_camp_management_system/views/layout/volunteer_layout_screen.dart';
import 'package:displacement_camp_management_system/utils/enums/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // تحقق من وجود بيانات محفوظة للـ auto-login
  final prefs = await SharedPreferences.getInstance();
  final savedUsername = prefs.getString('saved_username');
  final savedPassword = prefs.getString('saved_password');
  final savedRole = prefs.getString('saved_role');
  final rememberMe = prefs.getBool('remember_me') ?? false;

  Widget homeScreen = const RoleSelectionScreen();

  if (rememberMe &&
      savedUsername != null &&
      savedPassword != null &&
      savedRole != null) {
    homeScreen = AutoLoginScreen(
      username: savedUsername,
      password: savedPassword,
      role: savedRole,
    );
  }

  runApp(MyApp(homeScreen: homeScreen));
}

class MyApp extends StatelessWidget {
  final Widget homeScreen;
  const MyApp({super.key, required this.homeScreen});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit(),
      child: MaterialApp(
        theme: AppColors.lightTheme,
        locale: const Locale('ar'),
        localizationsDelegates: const [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale("ar", "AE"),
          Locale("en", "EN"),
        ],
        debugShowCheckedModeBanner: false,
        home: homeScreen,
      ),
    );
  }
}

// ─── شاشة الـ Auto Login ─────────────────────────────────────────────────────
// تظهر فقط لما في بيانات محفوظة — تسجل دخول تلقائياً وتحوّل للشاشة المناسبة
class AutoLoginScreen extends StatefulWidget {
  final String username;
  final String password;
  final String role;

  const AutoLoginScreen({
    super.key,
    required this.username,
    required this.password,
    required this.role,
  });

  @override
  State<AutoLoginScreen> createState() => _AutoLoginScreenState();
}

class _AutoLoginScreenState extends State<AutoLoginScreen> {
  @override
  void initState() {
    super.initState();
    _autoLogin();
  }

  Future<void> _autoLogin() async {
    final cubit = AppCubit.get(context);
    UserRole? expectedRole;
    switch (widget.role) {
      case 'admin':
        expectedRole = UserRole.admin;
        break;
      case 'volunteer':
        expectedRole = UserRole.volunteer;
        break;
      case 'displaced':
        expectedRole = UserRole.displaced;
        break;
    }

    await cubit.loginWithUsername(
      widget.username,
      widget.password,
      expectedRole: expectedRole,
    );

    if (!mounted) return;

    final role = cubit.currentRole;
    if (role == null) {
      // فشل الـ auto-login — امسح البيانات وروّح لصفحة الاختيار
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
      return;
    }

    Widget destination;
    switch (role) {
      case UserRole.admin:
        destination = const HomeLayout();
        break;
      case UserRole.volunteer:
        destination = const VolunteerLayoutScreen();
        break;
      case UserRole.displaced:
        destination = const IdpHomeLayout();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home_work_outlined, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text(
                    'نظام إدارة المخيمات',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'جاري تسجيل الدخول...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
