import 'package:flutter/material.dart';

class AidManagementScreen extends StatelessWidget {
  const AidManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'إدارة المساعدات',
          style: TextStyle(color: Colors.black),
        ),
        leading: const Icon(Icons.add, color: Colors.blue),
        actions: const [
          Icon(Icons.menu, color: Colors.black),
          SizedBox(width: 10),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// الكروت
            Row(
              children: [
                _buildCard(
                  title: "إجمالي الوحدات",
                  value: "150",
                  percent: "+12%",
                  icon: Icons.inventory_2_outlined,
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                _buildCard(
                  title: "المستفيدين اليوم",
                  value: "45",
                  percent: "+0%",
                  icon: Icons.groups,
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// الفلاتر
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _chip("الكل", true),
                  _chip("غذاء", false),
                  _chip("دواء", false),
                  _chip("ملابس", false),
                  _chip("إيواء", false),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// العنوان
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "التوزيعات الأخيرة",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("عرض الكل", style: TextStyle(color: Colors.blue)),
              ],
            ),

            const SizedBox(height: 10),

            /// القائمة
            Expanded(
              child: ListView(
                children: const [
                  _item(
                    "عائلة أحمد محمد",
                    "سلة غذائية عائلية - عدد",
                    "منذ ساعتين",
                    Icons.fastfood,
                    Colors.orange,
                  ),
                  _item(
                    "فاطمة علي",
                    "3 علب مضاد حيوي",
                    "منذ 4 ساعات",
                    Icons.medication,
                    Colors.red,
                  ),
                  _item(
                    "أطفال مخيم السلام",
                    "50 قطعة كسوة شتوية",
                    "أمس",
                    Icons.checkroom,
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      /// زر QR
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.qr_code),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// Bottom Navigation
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Icon(Icons.person),
              Icon(Icons.campaign),
              SizedBox(width: 40), // فراغ للزر
              Icon(Icons.favorite),
              Icon(Icons.home),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildCard({
    required String title,
    required String value,
    required String percent,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title)),

                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, color: color),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(percent, style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }

  static Widget _chip(String text, bool selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Chip(
        label: Text(text),
        backgroundColor: selected ? Colors.blue : Colors.white,
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
      ),
    );
  }
}

/// عنصر القائمة
class _item extends StatelessWidget {
  final String title, subtitle, time;
  final IconData icon;
  final Color color;

  const _item(this.title, this.subtitle, this.time, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(time),
    );
  }
}
