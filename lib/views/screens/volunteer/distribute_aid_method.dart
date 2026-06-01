// // ════════════════════════════════════════════════════════
// // أضف هذه الدالة داخل AppCubit بعد دالة deleteFamily
// // ════════════════════════════════════════════════════════

// Future<void> distributeAid({
//   required String familyId,
//   required String familyName,
//   required String campName,
//   required String aidType,
//   required int quantity,
// }) async {
//   emit(AddDisplacedLoadingState()); // نستخدم نفس الـ state للـ loading
//   try {
//     // التحقق من عدم التكرار (نفس العائلة ونفس النوع في نفس اليوم)
//     final today = DateTime.now();
//     final startOfDay =
//         DateTime(today.year, today.month, today.day);

//     final existing = await _db
//         .collection('aid_distributions')
//         .where('familyId', isEqualTo: familyId)
//         .where('aidType', isEqualTo: aidType)
//         .where('createdAt',
//             isGreaterThanOrEqualTo:
//                 Timestamp.fromDate(startOfDay))
//         .get();

//     if (existing.docs.isNotEmpty) {
//       emit(AddDisplacedErrorState(
//           'تم توزيع $aidType لهذه العائلة اليوم مسبقاً'));
//       return;
//     }

//     await _db.collection('aid_distributions').add({
//       'familyId': familyId,
//       'familyName': familyName,
//       'campName': campName,
//       'aidType': aidType,
//       'quantity': quantity,
//       'distributedBy': currentUsername ?? 'متطوع',
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     await addActivity(
//       title: 'توزيع $aidType على عائلة $familyName',
//       campName: campName,
//       type: 'aid',
//     );

//     emit(AddDisplacedSuccessState());
//   } catch (e) {
//     emit(AddDisplacedErrorState(e.toString()));
//   }
// }
