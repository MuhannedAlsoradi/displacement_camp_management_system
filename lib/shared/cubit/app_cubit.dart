import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:displacement_camp_management_system/shared/cubit/app_states.dart';
import 'package:displacement_camp_management_system/shared/enums/user_role.dart';

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
  //  Stream Subscriptions — تُلغى عند إغلاق الـ Cubit
  // ════════════════════════════════════════════════════════
  StreamSubscription? _campsSubscription;
  StreamSubscription? _familiesSubscription;
  StreamSubscription? _activitiesSubscription;
  StreamSubscription? _aidSubscription;

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
  UserRole? currentRole; // ← الدور بعد تسجيل الدخول

  Future<void> loginWithUsername(
    String username,
    String password, {
    UserRole? expectedRole,
  }) async {
    emit(LoginLoadingState());
    try {
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
      final roleStr = userData['role'] as String?;

      currentRole = parseUserRole(roleStr);
      if (currentRole == null) {
        emit(LoginErrorState('صلاحية غير معروفة: $roleStr'));
        return;
      }

      if (expectedRole != null && currentRole != expectedRole) {
        currentRole = null;
        emit(LoginErrorState('بيانات الدخول غير صحيحة'));
        return;
      }

      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      currentUser = result.user;
      currentUsername = userData['username'];

      switch (currentRole!) {
        case UserRole.admin:
          startAllListeners();
          break;
        case UserRole.volunteer:
          startVolunteerListeners();
          break;
        case UserRole.displaced:
          final familyId = userData['familyId'] as String?;
          if (familyId == null || familyId.isEmpty) {
            emit(LoginErrorState('لم يتم ربط حسابك بأسرة'));
            return;
          }
          await getIdpFamily(familyId);
          break;
      }

      emit(LoginSuccessState());
    } on FirebaseAuthException catch (e) {
      emit(LoginErrorState(_authErrorMessage(e.code)));
    } catch (e) {
      emit(LoginErrorState('حدث خطأ غير متوقع'));
    }
  }

  Future<void> logout() async {
    stopAllListeners();
    await _auth.signOut();
    currentUser = null;
    currentUsername = null;
    currentRole = null;
    emit(LogoutSuccessState());
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

  void startAllListeners() {
    listenToCamps();
    listenToFamilies();
    listenToActivities();
    listenToAid();
  }

  void startVolunteerListeners() {
    listenToFamilies();
    listenToAid();
  }

  /// مزامنة البيانات المعلّقة (offline → online)
  Future<void> syncPendingData() async {
    emit(SyncLoadingState());
    try {
      // أضف منطق المزامنة هنا لاحقاً (Hive / SharedPreferences)
      await Future.delayed(const Duration(seconds: 1));
      emit(SyncSuccessState());
    } catch (e) {
      emit(SyncErrorState(e.toString()));
    }
  }

  /// تُستدعى عند تسجيل الخروج أو إغلاق التطبيق
  void stopAllListeners() {
    _campsSubscription?.cancel();
    _familiesSubscription?.cancel();
    _activitiesSubscription?.cancel();
    _aidSubscription?.cancel();
  }

  @override
  Future<void> close() {
    stopAllListeners();
    return super.close();
  }

  // ════════════════════════════════════════════════════════
  //  Camps — Real-time
  // ════════════════════════════════════════════════════════
  List<Map<String, dynamic>> camps = [];

  void listenToCamps() {
    // إلغاء أي subscription سابق قبل إنشاء واحد جديد
    _campsSubscription?.cancel();

    emit(CampsLoadingState());

    _campsSubscription = _db
        .collection('camps')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        camps = snapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data()};
        }).toList();
        emit(CampsSuccessState());
        // كل تغيير في المخيمات يعيد حساب إحصائيات الـ Dashboard تلقائياً
        _recomputeDashboard();
      },
      onError: (e) => emit(CampsErrorState(e.toString())),
    );
  }

  /// الاستدعاء اليدوي لا يزال متاحاً للتوافق مع الكود القديم
  Future<void> getCamps() async => listenToCamps();

  Future<void> addCamp({
    required String name,
    required String location,
    required int capacity,
    required String status,
  }) async {
    emit(AddCampLoadingState());
    try {
      await _db.collection('camps').add({
        'name': name,
        'location': location,
        'capacity': capacity,
        'current': 0,
        'status': status,
        'image': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await addActivity(
        title: 'إضافة مخيم $name',
        campName: name,
        type: 'camp',
      );
      // لا حاجة لـ getCamps() — الـ stream سيُحدَّث تلقائياً
      emit(AddCampSuccessState());
    } catch (e) {
      emit(AddCampErrorState(e.toString()));
    }
  }

  Future<void> updateCamp(String campId, Map<String, dynamic> data) async {
    try {
      await _db.collection('camps').doc(campId).update(data);
      // لا حاجة لـ getCamps() — الـ stream سيُحدَّث تلقائياً
    } catch (e) {
      emit(CampsErrorState(e.toString()));
    }
  }

  Future<void> deleteCamp(String campId) async {
    try {
      await _db.collection('camps').doc(campId).delete();
      // لا حاجة لـ getCamps() — الـ stream سيُحدَّث تلقائياً
    } catch (e) {
      emit(CampsErrorState(e.toString()));
    }
  }

  // ════════════════════════════════════════════════════════
  //  Tents (الخيام) — subcollection، تُجلب عند الحاجة فقط
  // ════════════════════════════════════════════════════════
  List<Map<String, dynamic>> availableTents = [];

  Future<void> getAvailableTents(String campId) async {
    emit(CampsLoadingState());
    try {
      final snapshot = await _db
          .collection('camps')
          .doc(campId)
          .collection('tents')
          .where('status', isEqualTo: 'متاحة')
          .get();

      availableTents = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();

      emit(CampsSuccessState());
    } catch (e) {
      emit(CampsErrorState(e.toString()));
    }
  }

  // ════════════════════════════════════════════════════════
  //  Families & Displaced — Real-time
  // ════════════════════════════════════════════════════════
  List<Map<String, dynamic>> families = [];

  void listenToFamilies() {
    _familiesSubscription?.cancel();

    emit(DisplacedLoadingState());

    _familiesSubscription = _db
        .collection('families')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        families = snapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data()};
        }).toList();
        emit(DisplacedSuccessState());
        _recomputeDashboard();
      },
      onError: (e) => emit(DisplacedErrorState(e.toString())),
    );
  }

  /// الاستدعاء اليدوي مع دعم البحث (محلي — لا استدعاء Firestore إضافي)
  Future<void> getFamilies({String? searchQuery}) async {
    if (_familiesSubscription == null) {
      // لو الـ stream لم يبدأ بعد، ابدأه
      listenToFamilies();
      return;
    }
    // البحث يُطبَّق محلياً في الـ UI — لا نُعيد الاشتراك
    emit(DisplacedSuccessState());
  }

  Map<String, dynamic>? currentFamily;

  Future<void> getIdpFamily(String familyId) async {
    emit(IdpFamilyLoadingState());
    try {
      final familyDoc = await _db.collection('families').doc(familyId).get();

      if (!familyDoc.exists) {
        emit(IdpFamilyErrorState('لم يتم العثور على بيانات الأسرة'));
        return;
      }

      currentFamily = {'id': familyDoc.id, ...familyDoc.data()!};
      emit(IdpFamilySuccessState());
    } catch (e) {
      emit(IdpFamilyErrorState(e.toString()));
    }
  }

  Future<void> addFamily({
    required String familyName,
    required String representativeName,
    required String nationalId,
    required int membersCount,
    required String campId,
    required String campName,
    required String originCity,
    String tentId = '',
    String tentDocId = '',
    String needs = '',
    String? photoUrl,
  }) async {
    emit(AddDisplacedLoadingState());
    try {
      await _db.collection('families').add({
        'familyName': familyName,
        'representativeName': representativeName,
        'nationalId': nationalId,
        'membersCount': membersCount,
        'campId': campId,
        'campName': campName,
        'tentId': tentId,
        'tentDocId': tentDocId,
        'originCity': originCity,
        'needs': needs,
        'status': 'تم التسجيل',
        'photoUrl': photoUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _db.collection('camps').doc(campId).update({
        'current': FieldValue.increment(membersCount),
      });

      if (tentDocId.isNotEmpty) {
        final tentRef = _db
            .collection('camps')
            .doc(campId)
            .collection('tents')
            .doc(tentDocId);
        final tentSnap = await tentRef.get();
        if (tentSnap.exists) {
          await tentRef.update({'status': 'غير متاحة'});
        }
      }

      await addActivity(
        title: 'تسجيل عائلة جديدة: $familyName',
        campName: campName,
        type: 'register',
      );

      // لا حاجة لـ getFamilies() — الـ stream سيُحدَّث تلقائياً
      emit(AddDisplacedSuccessState());
    } catch (e) {
      emit(AddDisplacedErrorState(e.toString()));
    }
  }

  Future<void> updateFamily(String familyId, Map<String, dynamic> data) async {
    try {
      await _db.collection('families').doc(familyId).update(data);
      // لا حاجة لـ getFamilies() — الـ stream سيُحدَّث تلقائياً
    } catch (e) {
      emit(DisplacedErrorState(e.toString()));
    }
  }

  Future<void> deleteFamily(
      String familyId, String campId, int membersCount) async {
    try {
      await _db.collection('families').doc(familyId).delete();
      await _db.collection('camps').doc(campId).update({
        'current': FieldValue.increment(-membersCount),
      });
      // لا حاجة لـ getFamilies() — الـ stream سيُحدَّث تلقائياً
    } catch (e) {
      emit(DisplacedErrorState(e.toString()));
    }
  }

  // ════════════════════════════════════════════════════════
  //  Activities — Real-time
  // ════════════════════════════════════════════════════════
  List<Map<String, dynamic>> recentActivities = [];

  void listenToActivities() {
    _activitiesSubscription?.cancel();

    _activitiesSubscription = _db
        .collection('activities')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .listen(
      (snapshot) {
        recentActivities = snapshot.docs.map((doc) {
          final data = doc.data();
          final createdAt = data['createdAt'];
          String timeAgo = '';
          if (createdAt != null) {
            final date = (createdAt as Timestamp).toDate();
            final diff = DateTime.now().difference(date);
            if (diff.inMinutes < 1) {
              timeAgo = 'الآن';
            } else if (diff.inMinutes < 60) {
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
        // أعِد حساب الـ Dashboard عند وجود نشاطات جديدة
        _recomputeDashboard();
      },
      onError: (_) {},
    );
  }

  Future<void> addActivity({
    required String title,
    required String campName,
    required String type,
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
  //  Aid Distributions — Real-time
  // ════════════════════════════════════════════════════════
  List<Map<String, dynamic>> aidDistributions = [];
  int totalAid = 0;

  void listenToAid() {
    _aidSubscription?.cancel();

    _aidSubscription = _db
        .collection('aid_distributions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        aidDistributions = snapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data()};
        }).toList();
        totalAid = aidDistributions.fold<int>(
          0,
          (sum, d) => sum + (d['quantity'] as int? ?? 0),
        );
        _recomputeDashboard();
      },
      onError: (_) {},
    );
  }

  // ════════════════════════════════════════════════════════
  //  Dashboard — يُحسَب محلياً من البيانات المُحمَّلة
  // ════════════════════════════════════════════════════════
  Map<String, dynamic> dashboardStats = {};

  /// يُستدعى تلقائياً كلما تغيّر camps أو families أو activities أو aid
  void _recomputeDashboard() {
    // ── المخيمات ──────────────────────────────────────────
    final totalCamps = camps.length;
    final activeCamps = camps.where((c) => c['status'] == 'متاح').length;

    // ── العائلات والنازحين ────────────────────────────────
    final totalFamilies = families.length;
    final totalDisplaced =
        families.fold<int>(0, (s, f) => s + (f['membersCount'] as int? ?? 1));

    // ── نسبة الإشغال ──────────────────────────────────────
    final totalCapacity =
        camps.fold<int>(0, (s, c) => s + (c['capacity'] as int? ?? 0));
    final totalCurrent =
        camps.fold<int>(0, (s, c) => s + (c['current'] as int? ?? 0));
    final occupancyPercent = totalCapacity == 0
        ? '0'
        : ((totalCurrent / totalCapacity) * 100).toStringAsFixed(0);

    dashboardStats = {
      'totalCamps': totalCamps,
      'activeCamps': activeCamps,
      'totalFamilies': totalFamilies,
      'totalDisplaced': totalDisplaced,
      'totalAid': totalAid,
      'campsPercent': totalCamps == 0 ? '0 نشط' : '$activeCamps نشط',
      'occupancyPercent': occupancyPercent,
      'totalCapacity': totalCapacity,
    };

    emit(DashboardSuccessState());
  }

  /// الاستدعاء اليدوي للتوافق مع الكود القديم
  Future<void> getDashboardStats() async {
    emit(DashboardLoadingState());

    // تحميل اسم المستخدم إن لم يكن محمّلاً
    if (_auth.currentUser != null && currentUsername == null) {
      try {
        final userDoc =
            await _db.collection('users').doc(_auth.currentUser!.uid).get();
        currentUsername = userDoc.data()?['username'] ?? 'مسؤول النظام';
      } catch (_) {}
    }

    // إذا كانت الـ streams لم تبدأ بعد، ابدأها
    if (_campsSubscription == null) startAllListeners();

    // إذا كانت البيانات موجودة أصلاً، احسب مباشرة
    if (camps.isNotEmpty || families.isNotEmpty) {
      _recomputeDashboard();
    }
  }

  // ════════════════════════════════════════════════════════
  //  Storage
  // ════════════════════════════════════════════════════════
  String? uploadedFileUrl;

  Future<void> uploadFile(File file, String folder, String entityId) async {
    emit(UploadFileLoadingState());
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref('$folder/$entityId/$fileName');
      final task = await ref.putFile(file);
      uploadedFileUrl = await task.ref.getDownloadURL();
      emit(UploadFileSuccessState(uploadedFileUrl!));
    } catch (e) {
      emit(UploadFileErrorState(e.toString()));
    }
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      await _storage.refFromURL(fileUrl).delete();
    } catch (e) {
      emit(UploadFileErrorState(e.toString()));
    }
  }
}
