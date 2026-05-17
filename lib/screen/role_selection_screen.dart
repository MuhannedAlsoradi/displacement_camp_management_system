import 'package:flutter/material.dart';

import '../styles/colors.dart';
import 'login_screen.dart';

enum UserRole { admin, displaced, volunteer }

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  UserRole? _selectedRole;
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_selectedRole == null) return;
    // TODO: Navigate to LoginScreen and pass the role
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(role: _selectedRole!),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Logo / Brand ──────────────────────────────────────
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.home_work_outlined,
                    color: Colors.white,
                    size: 38,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'نظام إدارة المخيمات',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'اختر نوع حسابك للمتابعة',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 36),

                // ── Role Cards ────────────────────────────────────────
                _RoleCard(
                  role: UserRole.admin,
                  selectedRole: _selectedRole,
                  icon: Icons.admin_panel_settings_outlined,
                  activeIcon: Icons.admin_panel_settings,
                  title: 'مسؤول النظام',
                  subtitle: 'إدارة المخيمات والتقارير والمستخدمين',
                  color: AppColors.secondary,
                  lightColor: AppColors.secondary50,
                  onTap: () => setState(() => _selectedRole = UserRole.admin),
                ),

                const SizedBox(height: 14),

                _RoleCard(
                  role: UserRole.displaced,
                  selectedRole: _selectedRole,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  title: 'نازح',
                  subtitle: 'عرض بياناتك واحتياجاتك في المخيم',
                  color: AppColors.primary,
                  lightColor: AppColors.primary50,
                  onTap: () =>
                      setState(() => _selectedRole = UserRole.displaced),
                ),

                const SizedBox(height: 14),

                _RoleCard(
                  role: UserRole.volunteer,
                  selectedRole: _selectedRole,
                  icon: Icons.volunteer_activism_outlined,
                  activeIcon: Icons.volunteer_activism,
                  title: 'متطوع',
                  subtitle: 'دعم العمليات وتوزيع المساعدات',
                  color: AppColors.success,
                  lightColor: AppColors.successLight,
                  onTap: () =>
                      setState(() => _selectedRole = UserRole.volunteer),
                ),

                const SizedBox(height: 36),

                // ── Continue Button ───────────────────────────────────
                AnimatedOpacity(
                  opacity: _selectedRole != null ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 250),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedRole != null
                            ? _roleColor(_selectedRole)
                            : AppColors.neutral200,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _selectedRole != null ? _onContinue : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'متابعة',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_back, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Footer ────────────────────────────────────────────
                const Text(
                  'Gaza Camp Management System 2026 ©',
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _roleColor(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.secondary;
      case UserRole.displaced:
        return AppColors.primary;
      case UserRole.volunteer:
        return AppColors.success;
      default:
        return AppColors.neutral200;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role Card Widget
// ─────────────────────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.selectedRole,
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.lightColor,
    required this.onTap,
  });

  final UserRole role;
  final UserRole? selectedRole;
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final String subtitle;
  final Color color;
  final Color lightColor;
  final VoidCallback onTap;

  bool get isSelected => selectedRole == role;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? lightColor : AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? color : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                // Icon container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected ? color : AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    color: isSelected ? Colors.white : AppColors.textHint,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? color : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? color : AppColors.borderStrong,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
