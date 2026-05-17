// import 'package:displacement_camp_management_system/shared/cubit/app_states.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class AppCubit extends Cubit<AppStates> {
//   AppCubit() : super(InitState());
//   static AppCubit get(context) => BlocProvider.of(context);
//   int currentIndex = 0;
//   void changeIndex(int index) {
//     currentIndex = index;
//     emit(ChangeCurrentIndexState());
//   }

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   User? currentUser;
//   Future<void> loginWithUsername(String username, String password) async {
//     emit(LoginLoadingState());
//     try {
//       // 1. ابحث عن الـ username في Firestore
//       final query = await _db
//           .collection('users')
//           .where('username', isEqualTo: username.trim())
//           .limit(1)
//           .get();

//       if (query.docs.isEmpty) {
//         emit(LoginErrorState('اسم المستخدم غير موجود'));
//         return;
//       }

//       // 2. جيب الإيميل المرتبط بالـ username
//       final email = query.docs.first.data()['email'] as String;

//       // 3. سجّل دخول بالإيميل
//       final result = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       currentUser = result.user;
//       emit(LoginSuccessState());
//     } on FirebaseAuthException catch (e) {
//       emit(LoginErrorState(_authErrorMessage(e.code)));
//     } catch (e) {
//       emit(LoginErrorState('حدث خطأ غير متوقع'));
//     }
//   }

//   Future<void> logout() async {
//     await _auth.signOut();
//     currentUser = null;
//     emit(LogoutSuccessState());
//   }

//   String _authErrorMessage(String code) {
//     switch (code) {
//       case 'user-not-found':
//         return 'المستخدم غير موجود';
//       case 'wrong-password':
//         return 'كلمة المرور غير صحيحة';
//       case 'invalid-email':
//         return 'البريد الإلكتروني غير صالح';
//       case 'user-disabled':
//         return 'الحساب موقوف';
//       default:
//         return 'حدث خطأ، حاول مرة أخرى';
//     }
//   }
// }
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:displacement_camp_management_system/shared/cubit/app_states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(InitState());
  static AppCubit get(context) => BlocProvider.of(context);

  // ════════════════════════════════════════════════════════
  //  Firebase Instances
  // ════════════════════════════════════════════════════════
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ════════════════════════════════════════════════════════
  //  Navigation
  // ════════════════════════════════════════════════════════
  int currentIndex = 0;

  void changeIndex(int index) {
    currentIndex = index;
    emit(ChangeCurrentIndexState());
  }

  // ════════════════════════════════════════════════════════
  //  Authentication
  // ════════════════════════════════════════════════════════
  User? currentUser;
  String? currentUsername;

  /// تسجيل دخول بـ username
  Future<void> loginWithUsername(String username, String password) async {
    emit(LoginLoadingState());
    try {
      // 1. ابحث عن الـ username في Firestore
      final query = await _db
          .collection('users')
          .where('username', isEqualTo: username.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        emit(LoginErrorState('اسم المستخدم غير موجود'));
        return;
      }

      final userData = query.docs.first.data();
      final email = userData['email'] as String;

      // 2. سجّل دخول بالإيميل المرتبط
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      currentUser = result.user;
      currentUsername = userData['username'];
      emit(LoginSuccessState());
    } on FirebaseAuthException catch (e) {
      emit(LoginErrorState(_authErrorMessage(e.code)));
    } catch (e) {
      emit(LoginErrorState('حدث خطأ غير متوقع'));
    }
  }

  /// تسجيل خروج
  Future<void> logout() async {
    await _auth.signOut();
    currentUser = null;
    currentUsername = null;
    emit(LogoutSuccessState());
  }

  /// إنشاء مستخدم admin — استدعِها مرة واحدة فقط
  Future<void> createAdminUser() async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: 'admin@dcms.com',
        password: 'Admin@1234',
      );
      await _db.collection('users').doc(result.user!.uid).set({
        'username': 'admin',
        'email': 'admin@dcms.com',
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(LoginErrorState(e.toString()));
    }
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'user-disabled':
        return 'الحساب موقوف';
      case 'too-many-requests':
        return 'محاولات كثيرة، حاول لاحقاً';
      default:
        return 'حدث خطأ، حاول مرة أخرى';
    }
  }

  // ════════════════════════════════════════════════════════
  //  Dashboard
  // ════════════════════════════════════════════════════════
  Map<String, dynamic> dashboardStats = {};
  List<Map<String, dynamic>> recentActivities = [];

  Future<void> getDashboardStats() async {
    emit(DashboardLoadingState());
    try {
      // عدد المخيمات
      final campsSnap = await _db.collection('camps').get();
      final totalCamps = campsSnap.docs.length;
      final activeCamps =
          campsSnap.docs.where((d) => d.data()['status'] == 'متاح').length;

      // إجمالي النازحين والعائلات
      final displacedSnap = await _db.collection('displaced_persons').get();
      final totalDisplaced = displacedSnap.docs.length;
      int totalFamilies = 0;
      for (var doc in displacedSnap.docs) {
        totalFamilies += (doc.data()['familySize'] as int? ?? 1);
      }

      // إجمالي المساعدات
      final aidSnap = await _db.collection('aid_distributions').get();
      int totalAid = 0;
      for (var doc in aidSnap.docs) {
        totalAid += (doc.data()['quantity'] as int? ?? 0);
      }

      // آخر 5 نشاطات
      final activitiesSnap = await _db
          .collection('activities')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      recentActivities = activitiesSnap.docs.map((doc) {
        final data = doc.data();
        final createdAt = data['createdAt'];
        String timeAgo = '';
        if (createdAt != null) {
          final date = (createdAt as Timestamp).toDate();
          final diff = DateTime.now().difference(date);
          if (diff.inMinutes < 60) {
            timeAgo = 'منذ ${diff.inMinutes} دقيقة';
          } else if (diff.inHours < 24) {
            timeAgo = 'منذ ${diff.inHours} ساعة';
          } else {
            timeAgo = 'منذ ${diff.inDays} يوم';
          }
        }
        return {
          'title': data['title'] ?? '',
          'subtitle': '${data['campName'] ?? ''} - $timeAgo',
          'type': data['type'] ?? 'default',
        };
      }).toList();

      // اسم المستخدم الحالي
      if (_auth.currentUser != null && currentUsername == null) {
        final userDoc =
            await _db.collection('users').doc(_auth.currentUser!.uid).get();
        currentUsername = userDoc.data()?['username'] ?? 'مسؤول النظام';
      }

      dashboardStats = {
        'totalCamps': totalCamps,
        'activeCamps': activeCamps,
        'totalDisplaced': totalDisplaced,
        'totalFamilies': totalFamilies,
        'totalAid': totalAid,
        'campsPercent':
            '+${((activeCamps / (totalCamps == 0 ? 1 : totalCamps)) * 100).toStringAsFixed(0)}%',
        'displacedPercent': '+${totalDisplaced > 0 ? '5' : '0'}%',
      };

      emit(DashboardSuccessState());
    } catch (e) {
      emit(DashboardErrorState(e.toString()));
    }
  }

  // ════════════════════════════════════════════════════════
  //  Camps
  // ════════════════════════════════════════════════════════
  List<Map<String, dynamic>> camps = [];

  /// جلب المخيمات مرة واحدة
  Future<void> getCamps() async {
    emit(CampsLoadingState());
    try {
      final snapshot = await _db
          .collection('camps')
          .orderBy('createdAt', descending: true)
          .get();

      camps = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();

      emit(CampsSuccessState());
    } catch (e) {
      emit(CampsErrorState(e.toString()));
    }
  }

  /// الاستماع للتغييرات في الوقت الفعلي
  void listenToCamps() {
    _db
        .collection('camps')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      camps = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
      emit(CampsSuccessState());
    });
  }

  /// إضافة مخيم جديد
  Future<void> addCamp({
    required String name,
    required String location,
    required int capacity,
    required String status,
    String? imageUrl,
  }) async {
    try {
      await _db.collection('camps').add({
        'name': name,
        'location': location,
        'capacity': capacity,
        'current': 0,
        'status': status,
        'image': imageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await addActivity(
        title: 'إضافة مخيم $name',
        campName: name,
        type: 'camp',
      );

      await getCamps();
      emit(AddCampSuccessState());
    } catch (e) {
      emit(AddCampErrorState(e.toString()));
    }
  }

  /// تعديل مخيم
  Future<void> updateCamp(String campId, Map<String, dynamic> data) async {
    try {
      await _db.collection('camps').doc(campId).update(data);
      await getCamps();
    } catch (e) {
      emit(CampsErrorState(e.toString()));
    }
  }

  /// حذف مخيم
  Future<void> deleteCamp(String campId) async {
    try {
      await _db.collection('camps').doc(campId).delete();
      await getCamps();
    } catch (e) {
      emit(CampsErrorState(e.toString()));
    }
  }

  // ════════════════════════════════════════════════════════
  //  Displaced Persons
  // ════════════════════════════════════════════════════════
  List<Map<String, dynamic>> displacedPersons = [];

  /// جلب النازحين مع دعم البحث
  Future<void> getDisplacedPersons({String? searchQuery}) async {
    emit(DisplacedLoadingState());
    try {
      final snapshot = await _db
          .collection('displaced_persons')
          .orderBy('createdAt', descending: true)
          .get();

      displacedPersons = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();

      // فلترة محلية بالاسم أو رقم الهوية
      if (searchQuery != null && searchQuery.isNotEmpty) {
        displacedPersons = displacedPersons.where((p) {
          return p['name'].toString().contains(searchQuery) ||
              p['nationalId'].toString().contains(searchQuery);
        }).toList();
      }

      emit(DisplacedSuccessState());
    } catch (e) {
      emit(DisplacedErrorState(e.toString()));
    }
  }

  /// إضافة نازح جديد
  Future<void> addDisplacedPerson({
    required String name,
    required String nationalId,
    required int age,
    required int familySize,
    required String campId,
    required String campName,
    required String originCity,
    String? photoUrl,
    List<String>? documentUrls,
  }) async {
    try {
      await _db.collection('displaced_persons').add({
        'name': name,
        'nationalId': nationalId,
        'age': age,
        'familySize': familySize,
        'campId': campId,
        'campName': campName,
        'originCity': originCity,
        'status': 'تم التسجيل',
        'photoUrl': photoUrl ?? '',
        'documents': documentUrls ?? [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // تحديث عدد المقيمين في المخيم
      await _db.collection('camps').doc(campId).update({
        'current': FieldValue.increment(familySize),
      });

      await addActivity(
        title: 'تسجيل نازح جديد: $name',
        campName: campName,
        type: 'register',
      );

      await getDisplacedPersons();
      emit(AddDisplacedSuccessState());
    } catch (e) {
      emit(AddDisplacedErrorState(e.toString()));
    }
  }

  /// تحديث حالة نازح
  Future<void> updateDisplacedStatus(String personId, String status) async {
    try {
      await _db
          .collection('displaced_persons')
          .doc(personId)
          .update({'status': status});
      await getDisplacedPersons();
    } catch (e) {
      emit(DisplacedErrorState(e.toString()));
    }
  }

  /// حذف نازح
  Future<void> deleteDisplacedPerson(
      String personId, String campId, int familySize) async {
    try {
      await _db.collection('displaced_persons').doc(personId).delete();
      // تخفيض العدد من المخيم
      await _db.collection('camps').doc(campId).update({
        'current': FieldValue.increment(-familySize),
      });
      await getDisplacedPersons();
    } catch (e) {
      emit(DisplacedErrorState(e.toString()));
    }
  }

  // ════════════════════════════════════════════════════════
  //  Activities
  // ════════════════════════════════════════════════════════

  /// إضافة نشاط جديد
  Future<void> addActivity({
    required String title,
    required String campName,
    required String type, // shipment | register | camp | aid | warning
  }) async {
    try {
      await _db.collection('activities').add({
        'title': title,
        'campName': campName,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // ════════════════════════════════════════════════════════
  //  Storage
  // ════════════════════════════════════════════════════════
  String? uploadedFileUrl;

  /// رفع ملف (صورة أو وثيقة)
  Future<void> uploadFile(File file, String folder, String personId) async {
    emit(UploadFileLoadingState());
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref('$folder/$personId/$fileName');
      final task = await ref.putFile(file);
      uploadedFileUrl = await task.ref.getDownloadURL();
      emit(UploadFileSuccessState(uploadedFileUrl!));
    } catch (e) {
      emit(UploadFileErrorState(e.toString()));
    }
  }

  /// حذف ملف من Storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      await _storage.refFromURL(fileUrl).delete();
    } catch (e) {
      emit(UploadFileErrorState(e.toString()));
    }
  }
}
