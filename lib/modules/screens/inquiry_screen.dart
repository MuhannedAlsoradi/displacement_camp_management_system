import 'package:flutter/material.dart';

class InquiryScreen extends StatelessWidget {
  const InquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'بوابة الاستعلام',
          style: TextStyle(color: Color(0xff2D6CDF)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
        leading: Icon(Icons.menu, color: Color(0xff2D6CDF)),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff2D6CDF),
        onPressed: () {},
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xff2D6CDF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الحساب'),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'المساعدات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'طلباتي',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الاستعلام عن الطلبات',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // 🔍 Search
              TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث برقم الهوية أو رقم الطلب...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 🔘 Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _tab('الكل', true),
                  _tab('قيد المعالجة', false),
                  _tab('مكتملة', false),
                ],
              ),

              const SizedBox(height: 16),

              // 📊 Stats
              Row(
                children: [
                  Expanded(
                    child: _statusCard(
                      'تحت المراجعة',
                      '03',
                      const Color(0xff2D6CDF),
                      Icons.assignment,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statusCard(
                      'تم التسليم',
                      '12',
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 📄 List
              _requestCard(
                title: 'طلب سلة غذائية طارئة',
                status: 'قيد المراجعة',
                color: Colors.orange,
                icon: Icons.shopping_basket,
              ),
              _requestCard(
                title: 'طرد طبر (أدوية مزمنة)',
                status: 'تمت الموافقة',
                color: Colors.blue,
                icon: Icons.medical_services_outlined,
              ),
              _requestCard(
                title: 'طلب خيمة إيواء شتوية',
                status: 'تم التسليم',
                color: Colors.green,
                icon: Icons.chat_bubble_outline,
              ),
              _requestCard(
                title: 'طلب صهريج مياه',
                status: 'مرفوض',
                color: Colors.red,
                icon: Icons.water_drop_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? const Color(0xff2D6CDF) : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _statusCard(String title, String number, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title),
          const SizedBox(height: 8),
          Text(
            number,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestCard({
    required String title,
    required String status,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          // 📦 Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color), // ❗ شلت const
          ),

          const SizedBox(width: 12),

          // 📄 Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔶 Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status, // ✅ الصحيح
                    style: TextStyle(
                      color: color, // ✅ ديناميك
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // 📝 Title
                Text(
                  title, // ✅ ديناميك
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                // 🔢 Info Row
                Row(
                  children: const [
                    Text(
                      '#REF-49210',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(width: 10),
                    Text('•', style: TextStyle(color: Colors.grey)),
                    SizedBox(width: 10),
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      '12 أكتوبر 2023',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 📊 Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.6,
                    minHeight: 6,
                    color: color, // ✅ نفس لون الحالة
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
