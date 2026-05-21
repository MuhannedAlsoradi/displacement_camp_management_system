import 'package:displacement_camp_management_system/layout/admin_home_layout.dart';
import 'package:displacement_camp_management_system/layout/idp_home_layout.dart';
import 'package:displacement_camp_management_system/layout/volunteer_home_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/cubit/app_cubit.dart';
import '../../shared/cubit/app_states.dart';
import '../../shared/enums/user_role.dart';
import '../../styles/colors.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key, required this.role});
  final UserRole role;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordHidden = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                height: 220,
                width: double.infinity,
                color: AppColors.primary,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home_work_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "نظام إدارة المخيمات",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Card(
                  elevation: 12,
                  shadowColor: AppColors.primary200.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  color: AppColors.backgroundCard,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'تسجيل الدخول',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'يرجى إدخال بيانات الاعتماد للوصول إلى النظام',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 25),

                          // Username Field
                          TextFormField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              labelText: 'اسم المستخدم',
                              labelStyle: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                              hintText: 'أدخل اسم المستخدم',
                              hintStyle: const TextStyle(
                                color: AppColors.textHint,
                              ),
                              prefixIcon: const Icon(
                                Icons.person,
                                color: AppColors.textHint,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: AppColors.danger,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: AppColors.danger,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال اسم المستخدم';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 15),

                          // Password Field
                          TextFormField(
                            controller: passwordController,
                            obscureText: isPasswordHidden,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              labelStyle: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                              hintText: '*******',
                              hintStyle: const TextStyle(
                                color: AppColors.textHint,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: AppColors.textHint,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isPasswordHidden = !isPasswordHidden;
                                  });
                                },
                                icon: Icon(
                                  isPasswordHidden
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.textHint,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: AppColors.danger,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: AppColors.danger,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال كلمة المرور';
                              }
                              return null;
                            },
                          ),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'نسيت كلمة المرور؟',
                                style: TextStyle(color: AppColors.secondary),
                              ),
                            ),
                          ),
                          BlocConsumer<AppCubit, AppStates>(
                            listener: (context, state) {
                              if (state is LoginSuccessState) {
                                switch (AppCubit.get(context).currentRole!) {
                                  case UserRole.displaced:
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const IdpHomeLayout()),
                                      (route) => false,
                                    );
                                    break;
                                  case UserRole.admin:
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const HomeLayout()),
                                      (route) => false,
                                    );
                                  case UserRole.volunteer:
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const VolunteerHomeLayout()),
                                      (route) => false,
                                    );
                                    break;
                                }
                              }
                              if (state is LoginErrorState) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.error),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            builder: (context, state) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: state is LoginLoadingState
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          AppCubit.get(context)
                                              .loginWithUsername(
                                            usernameController.text.trim(),
                                            passwordController.text.trim(),
                                            expectedRole: widget.role,
                                          );
                                        }
                                      },
                                child: state is LoginLoadingState
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.arrow_back,
                                              color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            'تسجيل دخول',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                              );
                            },
                          ), // Login Button
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Support
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'الدعم الفني',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.headset_mic, color: AppColors.textHint),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Gaza Camp Management System 2026 ©',
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'دعم فني',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.shield, color: AppColors.success, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
