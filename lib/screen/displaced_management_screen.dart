import 'package:flutter/material.dart';

class DisplacedManagementScreen extends StatelessWidget {
  const DisplacedManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const Icon(Icons.notifications_none, color: Colors.black),
        title: Text('ادارة النازحين', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'ابحث بالاسم او رقم الهوية ',
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                filterChoiceChip('الكل', true),
                filterChoiceChip('حسب العمر', false),
                filterChoiceChip('حسب العمر', false),
              ],
            ),

            SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "عرض الكل",
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
                Text(
                  "النتائج 14 شخص",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),

            Expanded(
              child: ListView(
                children: [
                  personItem(
                    "#4992831",
                    "منى العلي",
                    "مخيم السلام",
                    "تم التسجيل",
                    Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterChoiceChip(String text, bool selected) {
    return ChoiceChip(
      label: Text(text),
      selected: selected,
      selectedColor: const Color(0xff2F80ED),
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
      onSelected: (_) {},
      side: BorderSide(color: selected ? Colors.blue : Colors.white),
    );
  }

  Widget personItem(
    String id,
    String name,
    String camp,
    String status,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          /// ... Menu
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xffF0F2F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(id, style: const TextStyle(fontSize: 10)),
              ),

              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),

          const SizedBox(width: 10),

          /// Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                /// ID
                const SizedBox(height: 4),

                /// Name
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 2),

                /// Camp
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      camp,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                  ],
                ),

                const SizedBox(height: 6),

                /// Status
                Text(status, style: TextStyle(color: color, fontSize: 11)),
              ],
            ),
          ),

          const SizedBox(width: 10),

          /// Avatar + Status Dot
          Stack(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
