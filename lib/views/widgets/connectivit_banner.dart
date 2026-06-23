// views/widgets/connectivity_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../controllers/cubit/app_cubit.dart';
import '../../controllers/cubit/app_states.dart';
import '../../utils/styles/colors.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      buildWhen: (p, c) =>
          c is ConnectivityChangedState || c is SyncStatusChangedState,
      builder: (context, state) {
        final cubit = AppCubit.get(context);

        if (cubit.isOnline && !cubit.hasPendingWrites) {
          return const SizedBox.shrink(); // كل شي متزامن، ما في بانر
        }

        final isOffline = !cubit.isOnline;
        final color = isOffline ? AppColors.statusCritical : AppColors.warning;
        final icon = isOffline ? Icons.wifi_off_rounded : Icons.sync_rounded;
        final text = isOffline
            ? 'وضع عدم الاتصال — التغييرات محفوظة محلياً وستتزامن تلقائياً'
            : 'جارِ مزامنة البيانات...';

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(text,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
              if (!isOffline && cubit.lastSyncTime != null)
                Text(
                  DateFormat('HH:mm').format(cubit.lastSyncTime!),
                  style: TextStyle(color: color, fontSize: 11),
                ),
            ],
          ),
        );
      },
    );
  }
}
