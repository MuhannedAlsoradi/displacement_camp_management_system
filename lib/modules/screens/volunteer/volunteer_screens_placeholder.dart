// ضع كل ملف في: lib/modules/screens/volunteer/

// ─── volunteer_dashboard_screen.dart ──────────
import 'package:flutter/material.dart';

class VolunteerDashboardScreen extends StatelessWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('لوحة تحكم المتطوع'));
  }
}

// ─── volunteer_families_screen.dart ───────────
class VolunteerFamiliesScreen extends StatelessWidget {
  const VolunteerFamiliesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('إدارة العائلات'));
  }
}

// ─── volunteer_aid_screen.dart ─────────────────
class VolunteerAidScreen extends StatelessWidget {
  const VolunteerAidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('توزيع المساعدات'));
  }
}

// ─── volunteer_profile_screen.dart ────────────
class VolunteerProfileScreen extends StatelessWidget {
  const VolunteerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('الملف الشخصي'));
  }
}
