import 'package:displacement_camp_management_system/layout/home_layout.dart';
import 'package:displacement_camp_management_system/screen/camps_management_Screen.dart';
import 'package:displacement_camp_management_system/screen/login_screen.dart';
import 'package:displacement_camp_management_system/screen/role_selection_screen.dart';
import 'package:displacement_camp_management_system/screen/screens.dart';
import 'package:displacement_camp_management_system/shared/cubit/app_cubit.dart';
import 'package:displacement_camp_management_system/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit(),
      child: MaterialApp(
        theme: AppColors.lightTheme,
        locale: Locale('ar'),
        localizationsDelegates: [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale("ar", "AE"),
          Locale("en", "EN"),
        ],
        debugShowCheckedModeBanner: false,
        home: RoleSelectionScreen(),
      ),
    );
  }
}
