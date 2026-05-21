import 'package:displacement_camp_management_system/styles/colors.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الاشعارات',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios)),
      ),
      body: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: 15,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(
              bottom: 12, left: 12, right: 12, top: index == 0 ? 12 : 0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'وصول صهريج مياه بسعة 10 كوب',
                ),
                Icon(
                  Icons.circle,
                  size: 5,
                ),
                Text('8:15 م'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
