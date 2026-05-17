// import 'package:displacement_camp_management_system/screen/aid_management_screen.dart';
// import 'package:displacement_camp_management_system/screen/camps_management_Screen.dart';
// import 'package:displacement_camp_management_system/screen/dashboard_admin_screen.dart';
// import 'package:displacement_camp_management_system/screen/dashboard_screen.dart';
// import 'package:displacement_camp_management_system/screen/displaced_management_screen.dart';
// import 'package:displacement_camp_management_system/screen/employees_management_screen.dart';
// import 'package:displacement_camp_management_system/screen/inquiry_screen.dart';
// import 'package:displacement_camp_management_system/screen/login_screen.dart';
// import 'package:displacement_camp_management_system/screen/reports_screen.dart';
// import 'package:flutter/material.dart';

// class Screens extends StatelessWidget {
//   const Screens({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
//         child: Column(
//           children: [
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: EdgeInsets.symmetric(vertical: 10),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),

//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (x) => LoginScreen()),
//                   );
//                 },
//                 child: Text('صفحة تسجيل الدخول '),
//               ),
//             ),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (x) => CampsManagementScreen()),
//                   );
//                 },
//                 child: Text('ادارة المخيمات '),
//               ),
//             ),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.all(10),
//                   backgroundColor: Colors.blue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (x) => EmployeesManagementScreen(),
//                     ),
//                   );
//                 },
//                 child: Text('ادارة الموظفين والمتطوعين '),
//               ),
//             ),
//             SizedBox(
//               width: double.infinity,

//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.all(10),
//                   backgroundColor: Colors.blue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (x) => DisplacedManagementScreen(),
//                     ),
//                   );
//                 },
//                 child: Text('ادارة النازحين'),
//               ),
//             ),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.all(10),
//                   backgroundColor: Colors.blue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (x) => ReportsScreen()),
//                   );
//                 },
//                 child: Text('التقارير والحصاء'),
//               ),
//             ),
//             SizedBox(
//               width: double.infinity,

//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.all(10),
//                   backgroundColor: Colors.blue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (x) => DashboardScreen()),
//                   );
//                 },
//                 child: Text('لوحة التحكم'),
//               ),
//             ),
//             SizedBox(
//               width: double.infinity,

//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.all(10),
//                   backgroundColor: Colors.blue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (x) => AidManagementScreen()),
//                   );
//                 },
//                 child: Text('ادارة المساعدات '),
//               ),
//             ),
//             SizedBox(
//               width: double.infinity,

//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.all(10),
//                   backgroundColor: Colors.blue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (x) => DashboardAdminScreen()),
//                   );
//                 },
//                 child: Text('لوحة تحكم مسؤول النظام'),
//               ),
//             ),
//             SizedBox(
//               width: double.infinity,

//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.all(10),
//                   backgroundColor: Colors.blue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (x) => InquiryScreen()),
//                   );
//                 },
//                 child: Text('بوابة الاستعلامات '),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
