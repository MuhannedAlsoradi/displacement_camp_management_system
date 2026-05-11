import 'package:flutter/material.dart';

class DashboardAdminScreen extends StatelessWidget {
  const DashboardAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Header
              _buildHeader(),

              const SizedBox(height: 20),

              /// 🔹 Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      "عدد المخيمات",
                      "12",
                      "+12%",
                      Icons.location_on,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      "إجمالي النازحين",
                      "1,240",
                      "+5%",
                      Icons.group,
                      Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// 🔹 Blue Card
              _blueCard(),

              const SizedBox(height: 20),

              /// 🔹 Quick Actions
              const Text(
                "إجراءات سريعة",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      "شحنة جديدة",
                      Icons.local_shipping,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(
                      "إضافة مستفيد",
                      Icons.add,
                      Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔹 Chart Placeholder
              _chartCard(),

              const SizedBox(height: 20),

              /// 🔹 Activities
              const Text(
                "آخر النشاطات",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _activityItem(
                "وصول شحنة أغذية",
                "مخيم السلام - منذ 2 ساعة",
                Icons.inventory,
              ),
              _activityItem(
                "تسجيل عائلة جديدة",
                "مخيم الأمل - منذ 5 ساعات",
                Icons.person_add,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= Widgets =================

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.notifications_none),
        Column(
          children: const [
            Text(
              "أهلاً بك، مسؤول النظام",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("15 محرم 1445", style: TextStyle(color: Colors.grey)),
          ],
        ),
        const CircleAvatar(),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    String percent,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(percent, style: const TextStyle(color: Colors.green)),
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _blueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff2D6CDF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.volunteer_activism, color: Colors.white),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("المساعدات الموزعة", style: TextStyle(color: Colors.white)),
              SizedBox(height: 6),
              Text(
                "4,000 وحدة",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _chartCard() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: Text("هنا الرسم البياني")),
    );
  }

  Widget _activityItem(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 2,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "الإعدادات"),
        BottomNavigationBarItem(icon: Icon(Icons.home_work), label: "المخيمات"),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "الرئيسية"),
      ],
    );
  }
}
