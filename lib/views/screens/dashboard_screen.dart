import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'لوحة التحكم',
          style: TextStyle(
            color: Color(0xff2F3E46),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black54),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(backgroundColor: Colors.grey, radius: 18),
          const SizedBox(width: 12),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔍 Search
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'بحث عن نازح، مخيم، أو طلب...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 📊 Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
              children: [
                _buildCard(
                  title: 'عدد المخيمات',
                  value: '12',
                  subtitle: 'نشط حالياً',
                  icon: Icons.location_on,
                ),
                _buildCard(
                  title: 'عدد النازحين',
                  value: '25,430',
                  subtitle: '+2.4%',
                  icon: Icons.people,
                  valueColor: Colors.blueGrey,
                  subtitleColor: Colors.green,
                ),
                _buildCard(
                  title: 'السعة المتاحة',
                  value: '1,200',
                  subtitle: 'متاح للتسجيل',
                  icon: Icons.event_seat,
                ),
                _buildProgressCard(),
              ],
            ),

            const SizedBox(height: 20),

            /// 📈 Section Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'توزيع النازحين حسب المدينة',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(Icons.more_horiz),
              ],
            ),

            const SizedBox(height: 10),

            /// 📉 Placeholder Chart
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Text(
                'لا توجد بيانات حالياً',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            /// ⚡ Quick Actions Title
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'إجراءات سريعة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            const SizedBox(height: 10),

            /// 🔘 Quick Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _quickButton(Icons.person_add, 'إضافة نازح'),
                _quickButton(Icons.home_work, 'إضافة مخيم'),
                _quickButton(Icons.assignment, 'طلب جديد'),
              ],
            ),
          ],
        ),
      ),

      /// 🔻 Bottom Nav
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_work),
            label: 'المخيمات',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'النازحين'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }

  /// 📦 Card Widget
  Widget _buildCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    Color valueColor = Colors.black,
    Color subtitleColor = Colors.grey,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(icon, color: Colors.grey),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: subtitleColor)),
        ],
      ),
    );
  }

  /// 📊 Progress Card
  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Icon(Icons.volunteer_activism, color: Colors.grey),
          const Spacer(),
          const Text('المساعدات الموزعة', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          const Text(
            '85%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.85,
              minHeight: 8,
              color: Colors.green,
              backgroundColor: Colors.black12,
            ),
          ),
        ],
      ),
    );
  }

  /// ⚡ Quick Button
  Widget _quickButton(IconData icon, String text) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blueGrey),
            const SizedBox(height: 6),
            Text(text),
          ],
        ),
      ),
    );
  }
}
