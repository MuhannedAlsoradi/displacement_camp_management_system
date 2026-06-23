import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../controllers/cubit/app_cubit.dart';
import '../../../controllers/cubit/app_states.dart';
import '../../../utils/enums/user_role.dart';
import '../../../utils/styles/colors.dart';

class SharedNotificationsScreen extends StatefulWidget {
  /// لو null، القرار بيصير تلقائياً حسب دور المستخدم
  /// (الأدمن = AppBar ظاهر لأنها مستقلة، غيره = بدون AppBar لأنها جوه Tab).
  /// لو القيمة محددة بشكل صريح من الخارج، بتفرض نفسها بكل الحالات.
  final bool? showAppBar;

  const SharedNotificationsScreen({super.key, this.showAppBar});

  @override
  State<SharedNotificationsScreen> createState() =>
      _SharedNotificationsScreenState();
}

class _SharedNotificationsScreenState extends State<SharedNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        final role = cubit.currentRole;
        final shouldShowAppBar = widget.showAppBar ?? (role == UserRole.admin);
        return Scaffold(
          backgroundColor: AppColors.backgroundPage,
          appBar: shouldShowAppBar ? _buildAppBar(context, cubit, role) : null,
          body: _buildBody(context, cubit, role),
        );
      },
    );
  }

  // ─── AppBar ───────────────────────────────────────────────

  AppBar _buildAppBar(BuildContext context, AppCubit cubit, UserRole? role) {
    return AppBar(
      backgroundColor: AppColors.backgroundCard,
      elevation: 0,
      title: const Text(
        'الإشعارات',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: AppColors.textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      actions: [
        // زر "قراءة الكل"
        if (cubit.unreadNotificationsCount > 0)
          TextButton(
            onPressed: () => cubit.markAllNotificationsAsRead(),
            child: const Text(
              'قراءة الكل',
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ),
        IconButton(
          onPressed: () => cubit.getDashboardStats(),
          icon: const Icon(Icons.refresh, color: AppColors.primary),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: _buildRoleBadge(role),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole? role) {
    final config = _getRoleConfig(role);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.backgroundCard,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: config.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: config.color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(config.icon, color: config.color, size: 14),
              const SizedBox(width: 6),
              Text(
                config.label,
                style: TextStyle(
                    color: config.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Body ─────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, AppCubit cubit, UserRole? role) {
    final notifList = cubit.notifications;

    if (notifList.isEmpty) {
      return _emptyState(role);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: notifList.length,
      itemBuilder: (context, index) {
        final item = notifList[index];
        return _notificationCard(context, cubit, item, role);
      },
    );
  }

  // ─── بطاقة الإشعار ────────────────────────────────────────

  Widget _notificationCard(
    BuildContext context,
    AppCubit cubit,
    Map<String, dynamic> notif,
    UserRole? role,
  ) {
    final type = notif['type'] as String? ?? 'default';
    final isRead = notif['isRead'] as bool? ?? false;
    final notifId = notif['id'] as String? ?? '';
    final color = _getColor(type);
    final icon = _getIcon(type);

    return GestureDetector(
      onTap: () {
        if (!isRead && notifId.isNotEmpty) {
          cubit.markNotificationAsRead(notifId);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? AppColors.backgroundCard : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: isRead ? null : Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── أيقونة
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (!isRead)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.backgroundPage, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // ─── المحتوى
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان + badge "جديد"
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getTitle(notif, role),
                          style: TextStyle(
                            fontWeight:
                                isRead ? FontWeight.normal : FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'جديد',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // رسالة الإشعار (message) — المحتوى الرئيسي
                  if ((notif['message'] as String? ?? '').isNotEmpty)
                    Text(
                      notif['message'] as String,
                      style: TextStyle(
                        color: isRead
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 4),

                  // اسم المخيم + الوقت
                  Row(
                    children: [
                      if ((notif['campName'] as String? ?? '').isNotEmpty) ...[
                        const Icon(Icons.location_on,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Text(
                          notif['campName'] as String,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        notif['timeAgo'] as String? ?? '',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // نوع الإشعار كـ badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getTypeName(type),
                      style: TextStyle(color: color, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── عنوان مخصص حسب الدور ────────────────────────────────

  String _getTitle(Map<String, dynamic> notif, UserRole? role) {
    final original = notif['title'] as String? ?? '';
    final type = notif['type'] as String? ?? '';

    if (role == UserRole.displaced) {
      switch (type) {
        case 'aid':
          return 'تم توزيع مساعدات جديدة';
        case 'warning':
          return 'تنبيه هام من إدارة المخيم';
        default:
          return original;
      }
    }

    return original;
  }

  // ─── حالة فارغة مخصصة ────────────────────────────────────

  Widget _emptyState(UserRole? role) {
    final config = _getRoleConfig(role);
    final messages = {
      UserRole.admin: 'لا توجد إشعارات حديثة في النظام',
      UserRole.volunteer: 'لا توجد إشعارات أو تحديثات حالياً',
      UserRole.displaced: 'لا توجد إشعارات لك في الوقت الحالي',
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.notifications_none, color: config.color, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد إشعارات',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            messages[role] ?? 'لا توجد إشعارات حالياً',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────

  _RoleConfig _getRoleConfig(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return _RoleConfig(
          label: 'إشعارات المسؤول',
          icon: Icons.admin_panel_settings,
          color: AppColors.secondary,
        );
      case UserRole.volunteer:
        return _RoleConfig(
          label: 'إشعارات المتطوع',
          icon: Icons.volunteer_activism,
          color: AppColors.primary,
        );
      case UserRole.displaced:
        return _RoleConfig(
          label: 'إشعاراتك الشخصية',
          icon: Icons.person,
          color: AppColors.warning,
        );
      default:
        return _RoleConfig(
          label: 'الإشعارات',
          icon: Icons.notifications,
          color: AppColors.primary,
        );
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'register':
        return Icons.person_add;
      case 'aid':
        return Icons.volunteer_activism;
      case 'camp':
        return Icons.location_on;
      case 'shipment':
        return Icons.local_shipping;
      case 'warning':
        return Icons.warning_amber;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'register':
        return AppColors.secondary;
      case 'aid':
        return AppColors.primary;
      case 'camp':
        return AppColors.warning;
      case 'shipment':
        return AppColors.success;
      case 'warning':
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'register':
        return 'تسجيل';
      case 'aid':
        return 'مساعدات';
      case 'camp':
        return 'مخيم';
      case 'shipment':
        return 'شحنة';
      case 'warning':
        return 'تنبيه';
      default:
        return 'خاص';
    }
  }
}

// ─── Helper class ─────────────────────────────────────────

class _RoleConfig {
  final String label;
  final IconData icon;
  final Color color;

  _RoleConfig({
    required this.label,
    required this.icon,
    required this.color,
  });
}
