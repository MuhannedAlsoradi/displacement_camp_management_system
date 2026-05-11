import 'package:flutter/material.dart';

class EmployeesManagementScreen extends StatelessWidget {
  const EmployeesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'ادارة الموظفين والمتطوعين',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: Icon(Icons.arrow_back_ios),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'ابحث بالاسم او بالرقم الوظيفي',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  filterChip('الكل', true),
                  filterChip('الموظفين', false),
                  filterChip('المتطوعين', false),
                  filterChip('الادارين', false),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  employeeItem(
                    'تور هشام',
                    "لوجستيات",
                    "ID:#EMP-410",
                    'images/employee/image1.jpg',
                    true,
                  ),
                  employeeItem(
                    'يوسف',
                    "مساعد طبي",
                    "ID:#EMP-055",
                    'images/employee/image2.jpg',
                    true,
                  ),
                  employeeItem(
                    'احمد',
                    "مشرف ميداني",
                    "ID:#EMP-204",
                    'images/employee/image3.jpg',
                    true,
                  ),
                  employeeItem(
                    'سارة',
                    "مدخل بينات",
                    "ID:#EMP-305",
                    'images/employee/image4.jpg',
                    true,
                  ),
                  employeeItem(
                    'خالد عمر',
                    "متطوع",
                    "ID:#VOL-112",
                    'images/employee/image5.jpg',
                    false,
                  ),
                ],
              ),
            ),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),

                onPressed: () {},
                child: Text(
                  'اضافة موظف جديد +',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterChip(String text, bool selected) {
    return Chip(
      label: Text(
        text,
        style: TextStyle(color: selected ? Colors.white : Colors.black),
      ),
      backgroundColor: selected ? Color(0xff1F2937) : Colors.grey.shade200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: selected ? Colors.black : Colors.grey.shade200),
      ),
    );
  }

  Widget employeeItem(
    String name,
    String job,
    String id,
    String imageURL,
    bool active,
  ) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 30, backgroundImage: AssetImage(imageURL)),
          SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0xff9333EA).withOpacity(0.1),
                      ),
                      child: Text(
                        job,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xff9333EA),
                        ),
                      ),
                    ),
                  ],
                ),

                Text(id, style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          SizedBox(width: 2),
          Switch(
            value: active,
            onChanged: (value) {},
            activeColor: Colors.blue,
          ),
          SizedBox(width: 2),
          Icon(Icons.more_vert),
        ],
      ),
    );
  }
}
