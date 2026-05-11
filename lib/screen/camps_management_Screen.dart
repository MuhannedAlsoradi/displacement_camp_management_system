import 'dart:ui';

import 'package:flutter/material.dart';

class CampsManagementScreen extends StatelessWidget {
  CampsManagementScreen({super.key});

  final List<Map<String, dynamic>> camps = [
    {
      'name': 'مخيم جباليا',
      'location': 'شمال غزة',
      'capacity': 50000,
      'current': 35000,
      'status': 'متاح',
      'image': 'images/camps/image1.png',
    },
    {
      'name': 'مخيم الشاطي',
      'location': 'غرب غزة',
      'capacity': 40000,
      'current': 38000,
      'status': 'ممتلئ تقريبا',
      'image': 'images/camps/image2.png',
    },
    {
      'name': 'مخيم البريج',
      'location': 'وسط القطاع',
      'capacity': 25000,
      'current': 13000,
      'status': 'متاح',
      'image': 'images/camps/image3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f7fb),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Icon(Icons.arrow_forward),
        title: Text(
          'ادارة المخيمات قطاع غزة',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff136DEC1A),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.add, color: const Color(0xff136DEC), size: 30),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            // البحث
            TextField(
              decoration: InputDecoration(
                hintText: 'بحث عن مخيم...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                filterChip('الكل', true),
                filterChip('مفتوح', false),
                filterChip('ممتلئ', false),
                filterChip('قيد الصيانة ', false),
              ],
            ),

            Expanded(
              child: ListView.builder(
                itemCount: camps.length,
                itemBuilder: (context, index) => campCard(camps[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterChip(String text, bool selected) {
    return Chip(
      label: Text(text),
      backgroundColor: selected ? Colors.blue : Colors.white,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: selected ? Colors.blue : Colors.white),
      ),
    );
  }

  Widget campCard(Map<String, dynamic> camp) {
    double percent = camp['current'] / camp['capacity'];
    Color statusColor = camp['status'] == 'متاح' ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.asset(
                  camp['image'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        camp['status'],
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 10,
                left: 10,
                child: Column(
                  children: [
                    Text(
                      camp['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white),
                        Text(
                          camp['location'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xfff5f7fb),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'السعة الاجمالية',
                        style: TextStyle(
                          color: Color(0xff617289),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${camp['capacity']}',
                        style: TextStyle(
                          color: Color(0xff111418),
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'المقيمين حاليا',
                        style: TextStyle(
                          color: Color(0xff617289),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${camp['current']}',
                        style: TextStyle(
                          color: Color(0xff111418),
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'نسبة الاشتعال ',
                  style: TextStyle(
                    color: Color(0xff617289),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${percent * 100}%',
                  style: TextStyle(
                    color: percent > 0.9 ? Colors.red : Colors.blue,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 10,
                color: percent > 0.9 ? Colors.red : Colors.blue,
                backgroundColor: Color(0xffDBE0E6),
              ),
            ),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
