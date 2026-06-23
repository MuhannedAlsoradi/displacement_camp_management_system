import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:displacement_camp_management_system/controllers/cubit/app_states.dart';
import 'package:displacement_camp_management_system/utils/enums/user_role.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(InitState()) {
    _initConnectivityListener();
  }
  static AppCubit get(context) => BlocProvider.of(context);
  bool isOnline = true;
  bool hasPendingWrites = false;
  DateTime? lastSyncTime;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  void _initConnectivityListener() {
    Connectivity().checkConnectivity().then(_updateConnectionStatus);
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final online = result != ConnectivityResult.none;
    if (online != isOnline) {
      isOnline = online;
      if (online) {
        lastSyncTime = DateTime.now();
      }
      emit(ConnectivityChangedState(isOnline));
    }
  }

  final Set<String> _pendingCollections = {};

  void _trackPendingWrites(QuerySnapshot snapshot, String collectionName) {
    final pending = snapshot.metadata.hasPendingWrites;
    if (pending) {
      _pendingCollections.add(collectionName);
    } else {
      _pendingCollections.remove(collectionName);
    }

    final newStatus = _pendingCollections.isNotEmpty;
    if (newStatus != hasPendingWrites) {
      hasPendingWrites = newStatus;
      if (!hasPendingWrites) lastSyncTime = DateTime.now();
      emit(SyncStatusChangedState(hasPendingWrites));
    }
  }

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
  StreamSubscription? _notificationsSubscription; // ← جديد
  StreamSubscription? _familyNotificationsSubscription; // ← جديد للنازحين
  StreamSubscription? _campNotificationsSubscription; // ← جديد للنازحين
  StreamSubscription? _resourcesSubscription; // ← جديد

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
  UserRole? currentRole;

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
          listenToNotifications(); // ← جديد
          break;
        case UserRole.volunteer:
          startVolunteerListeners();
          listenToNotifications(); // ← جديد
          break;
        case UserRole.displaced:
          final familyId = userData['familyId'] as String?;
          if (familyId == null || familyId.isEmpty) {
            emit(LoginErrorState('لم يتم ربط حسابك بأسرة'));
            return;
          }
          await getIdpFamily(familyId);
          listenToFamilyAid(familyId);
          listenToNotifications();
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
    notifications = []; // ← مسح الإشعارات عند تسجيل الخروج
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
    listenToResources(); // ← جديد
  }

  void startVolunteerListeners() {
    listenToFamilies();
    listenToAid();
    listenToResources(); // ← جديد
  }

  /// مزامنة البيانات المعلّقة (offline → online)
  Future<void> syncPendingData() async {
    emit(SyncLoadingState());
    try {
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
    _familyAidSubscription?.cancel();
    _notificationsSubscription?.cancel(); // ← جديد
    _familyNotificationsSubscription?.cancel(); // ← جديد للنازحين
    _campNotificationsSubscription?.cancel(); // ← جديد للنازحين
    _resourcesSubscription?.cancel(); // ← جديد
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
    _campsSubscription?.cancel();

    emit(CampsLoadingState());

    _campsSubscription = _db
        .collection('camps')
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true) // ← جديد
        .listen(
      (snapshot) {
        _trackPendingWrites(snapshot, 'camps'); // ← جديد
        camps = snapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data()};
        }).toList();
        emit(CampsSuccessState());
        _recomputeDashboard();
      },
      onError: (e) => emit(CampsErrorState(e.toString())),
    );
  }

  Future<void> getCamps() async => listenToCamps();

  Future<void> addCamp({
    required String name,
    required String location,
    required int capacity,
    required String status,
    File? imageFile,
  }) async {
    emit(AddCampLoadingState());
    try {
      String imageUrl = '';
      if (imageFile != null) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        final ref = _storage.ref('images/camps/$fileName');

        // ✅ استخدم UploadTask بشكل صريح لمعرفة سبب الفشل
        final UploadTask uploadTask = ref.putFile(imageFile);
        final TaskSnapshot snapshot = await uploadTask;

        // ✅ تأكد أن الرفع نجح قبل جلب الرابط
        if (snapshot.state == TaskState.success) {
          imageUrl = await snapshot.ref.getDownloadURL();
        } else {
          throw Exception('فشل رفع الصورة: ${snapshot.state}');
        }
      }

      await _db.collection('camps').add({
        'name': name,
        'location': location,
        'capacity': capacity,
        'current': 0,
        'status': status,
        'image': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await addActivity(
        title: 'إضافة مخيم $name',
        campName: name,
        type: 'camp',
      );

      // ← جديد: إشعار كل الأدمنز بإضافة المخيم
      await notifyAllAdmins(
        title: 'مخيم جديد',
        message: 'تم إضافة مخيم "$name" بسعة $capacity فرد',
        type: 'camp',
        campName: name,
      );

      emit(AddCampSuccessState());
    } on FirebaseException catch (e) {
      // ✅ سيظهر كود الخطأ الحقيقي
      emit(AddCampErrorState('Storage Error [${e.code}]: ${e.message}'));
    } catch (e) {
      emit(AddCampErrorState(e.toString()));
    }
  }

  Future<void> updateCamp(String campId, Map<String, dynamic> data) async {
    try {
      await _db.collection('camps').doc(campId).update(data);
      emit(UpdateCampSuccessState());
    } catch (e) {
      emit(CampsErrorState(e.toString()));
    }
  }

  Future<void> deleteCamp(String campId) async {
    try {
      await _db.collection('camps').doc(campId).delete();
      emit(DeleteCampSuccessState());
    } catch (e) {
      emit(DeleteCampErrorState(e.toString()));
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
          .orderBy('tentId')
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
  //  Tents — Actions (إضافة / تعديل حالة / حذف)
  // ════════════════════════════════════════════════════════

  Future<void> addTent({
    required String campId,
    required String tentId,
    required int capacity,
  }) async {
    emit(TentActionLoadingState());
    try {
      final dup = await _db
          .collection('camps')
          .doc(campId)
          .collection('tents')
          .where('tentId', isEqualTo: tentId)
          .limit(1)
          .get();

      if (dup.docs.isNotEmpty) {
        emit(TentActionErrorState('رقم الخيمة "$tentId" موجود مسبقاً'));
        return;
      }

      await _db.collection('camps').doc(campId).collection('tents').add({
        'tentId': tentId,
        'capacity': capacity,
        'status': 'متاحة',
        'assignedFamily': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      emit(TentActionSuccessState('تم إضافة الخيمة بنجاح'));
      await getAvailableTents(campId);
    } catch (e) {
      emit(TentActionErrorState(e.toString()));
    }
  }

  Future<void> updateTentStatus({
    required String campId,
    required String tentDocId,
    required String newStatus,
  }) async {
    emit(TentActionLoadingState());
    try {
      await _db
          .collection('camps')
          .doc(campId)
          .collection('tents')
          .doc(tentDocId)
          .update({'status': newStatus});

      emit(TentActionSuccessState(
        newStatus == 'متاحة'
            ? 'تم تعيين الخيمة كمتاحة'
            : 'تم تعيين الخيمة كغير متاحة',
      ));
      await getAvailableTents(campId);
    } catch (e) {
      emit(TentActionErrorState(e.toString()));
    }
  }

  Future<void> deleteTent({
    required String campId,
    required String tentDocId,
  }) async {
    emit(TentActionLoadingState());
    try {
      final tentRef = _db
          .collection('camps')
          .doc(campId)
          .collection('tents')
          .doc(tentDocId);

      final tentSnap = await tentRef.get();
      final assignedFamily =
          tentSnap.data()?['assignedFamily']?.toString() ?? '';

      if (assignedFamily.isNotEmpty) {
        emit(TentActionErrorState(
          'لا يمكن حذف الخيمة لأنها مخصصة لعائلة "$assignedFamily" — احذف العائلة أو انقلها أولاً',
        ));
        return;
      }

      await tentRef.delete();

      emit(TentActionSuccessState('تم حذف الخيمة'));
      await getAvailableTents(campId);
    } catch (e) {
      emit(TentActionErrorState(e.toString()));
    }
  }

  // ════════════════════════════════════════════════════════
  //  Families & Displaced — Real-time
  // ════════════════════════════════════════════════════════
  // ════════════════════════════════════════════════════════
  //  Resources / Aid Types — تعريف الأدمن لأنواع المساعدات والكميات
  // ════════════════════════════════════════════════════════
  List<Map<String, dynamic>> resources = [];

  void listenToResources() {
    _resourcesSubscription?.cancel();

    _resourcesSubscription = _db
        .collection('resources')
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true) // ← جديد
        .listen(
      (snapshot) {
        _trackPendingWrites(snapshot, 'resources'); // ← جديد
        resources = snapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data()};
        }).toList();
        emit(ResourcesSuccessState());
      },
      onError: (e) => emit(ResourcesErrorState(e.toString())),
    );
  }

  Future<void> addResource({
    required String aidType,
    required int quantityAvailable,
    String unit = '',
  }) async {
    emit(ResourceActionLoadingState());
    try {
      final dup = await _db
          .collection('resources')
          .where('aidType', isEqualTo: aidType)
          .limit(1)
          .get();

      if (dup.docs.isNotEmpty) {
        emit(ResourceActionErrorState('نوع المساعدة "$aidType" موجود مسبقاً'));
        return;
      }

      await _db.collection('resources').add({
        'aidType': aidType,
        'quantityAvailable': quantityAvailable,
        'unit': unit,
        'createdAt': FieldValue.serverTimestamp(),
      });

      emit(ResourceActionSuccessState('تم إضافة نوع المساعدة بنجاح'));
    } catch (e) {
      emit(ResourceActionErrorState(e.toString()));
    }
  }

  Future<void> updateResourceQuantity({
    required String resourceId,
    required int newQuantity,
  }) async {
    emit(ResourceActionLoadingState());
    try {
      await _db.collection('resources').doc(resourceId).update({
        'quantityAvailable': newQuantity,
      });
      emit(ResourceActionSuccessState('تم تحديث الكمية بنجاح'));
    } catch (e) {
      emit(ResourceActionErrorState(e.toString()));
    }
  }

  Future<void> deleteResource(String resourceId) async {
    emit(ResourceActionLoadingState());
    try {
      await _db.collection('resources').doc(resourceId).delete();
      emit(ResourceActionSuccessState('تم حذف نوع المساعدة'));
    } catch (e) {
      emit(ResourceActionErrorState(e.toString()));
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
        .snapshots(includeMetadataChanges: true) // ← جديد
        .listen(
      (snapshot) {
        _trackPendingWrites(snapshot, 'families'); // ← جديد
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
      listenToFamilies();
      return;
    }
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

      // ← معدّل: هلق منحفظ اسم العائلة على الخيمة المعيّنة، مش بس الحالة
      if (tentDocId.isNotEmpty) {
        final tentRef = _db
            .collection('camps')
            .doc(campId)
            .collection('tents')
            .doc(tentDocId);
        final tentSnap = await tentRef.get();
        if (tentSnap.exists) {
          await tentRef.update({
            'status': 'غير متاحة',
            'assignedFamily': familyName,
          });
        }
      }

      await addActivity(
        title: 'تسجيل عائلة جديدة: $familyName',
        campName: campName,
        type: 'register',
      );

      // ← جديد: إشعار كل الأدمنز بتسجيل العائلة
      await notifyAllAdmins(
        title: 'عائلة جديدة',
        message:
            'تم تسجيل عائلة "$familyName" ($membersCount أفراد) في مخيم $campName',
        type: 'register',
        campName: campName,
      );

      emit(AddDisplacedSuccessState());
    } catch (e) {
      emit(AddDisplacedErrorState(e.toString()));
    }
  }

  Future<void> updateFamily(String familyId, Map<String, dynamic> data) async {
    try {
      await _db.collection('families').doc(familyId).update(data);
    } catch (e) {
      emit(DisplacedErrorState(e.toString()));
    }
  }

  /// تعيين/تغيير خيمة لعائلة مسجّلة مسبقاً
  /// بتحرر الخيمة القديمة (لو موجودة) وبتحجز الجديدة وبتحدّث بيانات العائلة
  Future<void> assignTentToFamily({
    required String familyId,
    required String campId,
    required String familyName,
    required String newTentDocId,
    required String newTentId,
    String oldTentDocId = '',
  }) async {
    emit(TentActionLoadingState());
    try {
      if (oldTentDocId.isNotEmpty && oldTentDocId != newTentDocId) {
        final oldTentRef = _db
            .collection('camps')
            .doc(campId)
            .collection('tents')
            .doc(oldTentDocId);
        final oldSnap = await oldTentRef.get();
        if (oldSnap.exists) {
          await oldTentRef.update({
            'status': 'متاحة',
            'assignedFamily': '',
          });
        }
      }

      await _db
          .collection('camps')
          .doc(campId)
          .collection('tents')
          .doc(newTentDocId)
          .update({
        'status': 'غير متاحة',
        'assignedFamily': familyName,
      });

      await _db.collection('families').doc(familyId).update({
        'tentDocId': newTentDocId,
        'tentId': newTentId,
      });

      emit(TentActionSuccessState('تم تعيين الخيمة بنجاح'));
    } catch (e) {
      emit(TentActionErrorState(e.toString()));
    }
  }

  // ← معدّل: هلق بتقبل tentDocId اختياري، ولو موجود بتحرر الخيمة (ترجعها متاحة وتمسح اسم العائلة)
  Future<void> deleteFamily(
    String familyId,
    String campId,
    int membersCount, {
    String tentDocId = '',
  }) async {
    try {
      await _db.collection('families').doc(familyId).delete();
      await _db.collection('camps').doc(campId).update({
        'current': FieldValue.increment(-membersCount),
      });

      if (tentDocId.isNotEmpty) {
        final tentRef = _db
            .collection('camps')
            .doc(campId)
            .collection('tents')
            .doc(tentDocId);
        final tentSnap = await tentRef.get();
        if (tentSnap.exists) {
          await tentRef.update({
            'status': 'متاحة',
            'assignedFamily': '',
          });
        }
      }

      emit(DeleteFamilySuccessState());
    } catch (e) {
      emit(DeleteFamilyErrorState(e.toString()));
    }
  }

  Future<void> distributeAid({
    required String familyId,
    required String familyName,
    required String campName,
    required String aidType,
    required int quantity,
  }) async {
    emit(AddDisplacedLoadingState());
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final existing = await _db
          .collection('aid_distributions')
          .where('familyId', isEqualTo: familyId)
          .where('aidType', isEqualTo: aidType)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      if (existing.docs.isNotEmpty) {
        emit(AddDisplacedErrorState(
            'تم توزيع $aidType لهذه العائلة اليوم مسبقاً'));
        return;
      }

      // ← جديد: تحديث المخزون المرتبط بنوع المساعدة (لو معرّف بالنظام)
      final resourceQuery = await _db
          .collection('resources')
          .where('aidType', isEqualTo: aidType)
          .limit(1)
          .get();

      if (resourceQuery.docs.isNotEmpty) {
        final resourceDoc = resourceQuery.docs.first;
        final available =
            (resourceDoc.data()['quantityAvailable'] as int?) ?? 0;
        if (available < quantity) {
          emit(AddDisplacedErrorState(
              'الكمية المتاحة من $aidType غير كافية ($available متبقي)'));
          return;
        }
        await resourceDoc.reference.update({
          'quantityAvailable': FieldValue.increment(-quantity),
        });
      }

      await _db.collection('aid_distributions').add({
        'familyId': familyId,
        'familyName': familyName,
        'campName': campName,
        'aidType': aidType,
        'quantity': quantity,
        'distributedBy': currentUsername ?? 'متطوع',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await addActivity(
        title: 'توزيع $aidType على عائلة $familyName',
        campName: campName,
        type: 'aid',
      );

      // ← جديد: إشعار كل الأدمنز بعملية التوزيع
      await notifyAllAdmins(
        title: 'توزيع مساعدة',
        message: 'تم توزيع $quantity وحدة من "$aidType" لعائلة $familyName',
        type: 'aid',
        campName: campName,
        familyId: familyId,
      );

      // ← جديد: إشعار حساب الأسرة نفسها (لو مرتبطة بحساب مستخدم)
      await notifyFamilyUser(
        familyId: familyId,
        title: 'تم توزيع مساعدات جديدة',
        message: 'استلمت أسرتك $quantity وحدة من "$aidType"',
        type: 'aid',
        campName: campName,
      );

      emit(AddDisplacedSuccessState());
    } catch (e) {
      emit(AddDisplacedErrorState(e.toString()));
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
  //  Notifications — Real-time
  // ════════════════════════════════════════════════════════
  List<Map<String, dynamic>> notifications = [];

  /// يبدأ الاستماع لإشعارات المستخدم الحالي فقط
  void listenToNotifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _notificationsSubscription?.cancel();
    _familyNotificationsSubscription?.cancel();
    _campNotificationsSubscription?.cancel();

    if (currentRole == UserRole.displaced) {
      final familyId = currentFamily?['id'] as String? ?? '';
      final campName = currentFamily?['campName'] as String? ?? '';

      // بالنسبة للنازح، نحتاج دمج الإشعارات الخاصة به، والخاصة بعائلته، والخاصة بمخيمه.
      final Map<String, Map<String, dynamic>> mergedNotifications = {};

      void updateListAndEmit() {
        notifications = mergedNotifications.values.toList();
        
        // ترتيب الإشعارات تنازلياً حسب تاريخ الإنشاء (الأحدث أولاً)
        notifications.sort((a, b) {
          final aVal = a['createdAt'];
          final bVal = b['createdAt'];
          if (aVal == null && bVal == null) return 0;
          if (aVal == null) return -1; // الإشعار الجديد بدون تاريخ يكون بالأعلى
          if (bVal == null) return 1;
          
          DateTime? aTime;
          if (aVal is Timestamp) {
            aTime = aVal.toDate();
          } else if (aVal is DateTime) {
            aTime = aVal;
          }
          
          DateTime? bTime;
          if (bVal is Timestamp) {
            bTime = bVal.toDate();
          } else if (bVal is DateTime) {
            bTime = bVal;
          }
          
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return -1;
          if (bTime == null) return 1;
          return bTime.compareTo(aTime);
        });

        emit(NotificationsSuccessState());
      }

      Map<String, dynamic> parseDoc(QueryDocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        final createdAt = data['createdAt'];
        String timeAgo = '';
        if (createdAt != null) {
          DateTime? date;
          if (createdAt is Timestamp) {
            date = createdAt.toDate();
          } else if (createdAt is DateTime) {
            date = createdAt;
          }
          if (date != null) {
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
        }
        return {
          'id': doc.id,
          'userId': data['userId'] ?? '',
          'role': data['role'] ?? '',
          'familyId': data['familyId'] ?? '',
          'campName': data['campName'] ?? '',
          'title': data['title'] ?? '',
          'message': data['message'] ?? '',
          'type': data['type'] ?? 'default',
          'isRead': data['isRead'] ?? false,
          'createdAt': data['createdAt'],
          'timeAgo': timeAgo,
        };
      }

      // 1. اشتراك الإشعارات الموجهة للمستخدم مباشرة
      _notificationsSubscription = _db
          .collection('notifications')
          .where('userId', isEqualTo: uid)
          .snapshots()
          .listen((snapshot) {
        for (final doc in snapshot.docs) {
          mergedNotifications[doc.id] = parseDoc(doc);
        }
        updateListAndEmit();
      }, onError: (_) {});

      // 2. اشتراك الإشعارات الموجهة لعائلة المستخدم
      if (familyId.isNotEmpty) {
        _familyNotificationsSubscription = _db
            .collection('notifications')
            .where('familyId', isEqualTo: familyId)
            .snapshots()
            .listen((snapshot) {
          for (final doc in snapshot.docs) {
            mergedNotifications[doc.id] = parseDoc(doc);
          }
          updateListAndEmit();
        }, onError: (_) {});
      }

      // 3. اشتراك إشعارات المخيم العامة
      if (campName.isNotEmpty) {
        _campNotificationsSubscription = _db
            .collection('notifications')
            .where('campName', isEqualTo: campName)
            .snapshots()
            .listen((snapshot) {
          for (final doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final fid = data['familyId'] as String? ?? '';
            if (fid.isEmpty) {
              mergedNotifications[doc.id] = parseDoc(doc);
            }
          }
          updateListAndEmit();
        }, onError: (_) {});
      }
    } else {
      // بالنسبة للمشرف والمتطوع، فقط الإشعارات الموجهة لهم مباشرة
      _notificationsSubscription = _db
          .collection('notifications')
          .where('userId', isEqualTo: uid)
          .snapshots()
          .listen(
        (snapshot) {
          notifications = snapshot.docs.map((doc) {
            final data = doc.data();
            final createdAt = data['createdAt'];
            String timeAgo = '';
            if (createdAt != null) {
              DateTime? date;
              if (createdAt is Timestamp) {
                date = createdAt.toDate();
              } else if (createdAt is DateTime) {
                date = createdAt;
              }
              if (date != null) {
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
            }
            return {
              'id': doc.id,
              'userId': data['userId'] ?? '',
              'role': data['role'] ?? '',
              'familyId': data['familyId'] ?? '',
              'campName': data['campName'] ?? '',
              'title': data['title'] ?? '',
              'message': data['message'] ?? '',
              'type': data['type'] ?? 'default',
              'isRead': data['isRead'] ?? false,
              'createdAt': data['createdAt'],
              'timeAgo': timeAgo,
            };
          }).toList();

          // ترتيب الإشعارات تنازلياً حسب تاريخ الإنشاء (الأحدث أولاً)
          notifications.sort((a, b) {
            final aVal = a['createdAt'];
            final bVal = b['createdAt'];
            if (aVal == null && bVal == null) return 0;
            if (aVal == null) return -1;
            if (bVal == null) return 1;
            
            DateTime? aTime;
            if (aVal is Timestamp) {
              aTime = aVal.toDate();
            } else if (aVal is DateTime) {
              aTime = aVal;
            }
            
            DateTime? bTime;
            if (bVal is Timestamp) {
              bTime = bVal.toDate();
            } else if (bVal is DateTime) {
              bTime = bVal;
            }
            
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return -1;
            if (bTime == null) return 1;
            return bTime.compareTo(aTime);
          });

          emit(NotificationsSuccessState());
        },
        onError: (_) {},
      );
    }
  }

  /// عدد الإشعارات غير المقروءة — مفيد لشارة الـ badge
  int get unreadNotificationsCount =>
      notifications.where((n) => n['isRead'] == false).length;

  /// تعليم إشعار واحد كمقروء
  Future<void> markNotificationAsRead(String notifId) async {
    try {
      await _db
          .collection('notifications')
          .doc(notifId)
          .update({'isRead': true});
    } catch (_) {}
  }

  /// تعليم جميع الإشعارات كمقروءة دفعةً واحدة
  Future<void> markAllNotificationsAsRead() async {
    try {
      final unread = notifications.where((n) => n['isRead'] == false).toList();
      final batch = _db.batch();
      for (final n in unread) {
        final ref = _db.collection('notifications').doc(n['id'] as String);
        batch.update(ref, {'isRead': true});
      }
      await batch.commit();
    } catch (_) {}
  }

  /// إرسال إشعار لمستخدم معين
  Future<void> sendNotification({
    required String userId,
    required String role,
    required String title,
    required String message,
    required String type,
    String? campName,
    String? familyId,
  }) async {
    try {
      await _db.collection('notifications').add({
        'userId': userId,
        'role': role,
        'title': title,
        'message': message,
        'type': type,
        'campName': campName ?? '',
        'familyId': familyId ?? '',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  /// ← جديد: إرسال إشعار لكل المستخدمين الذين دورهم admin
  /// تُستخدم بعد أي إجراء مهم (إضافة مخيم، تسجيل عائلة، توزيع مساعدة...)
  Future<void> notifyAllAdmins({
    required String title,
    required String message,
    required String type,
    String? campName,
    String? familyId,
  }) async {
    try {
      final admins =
          await _db.collection('users').where('role', isEqualTo: 'admin').get();

      if (admins.docs.isEmpty) return;

      final batch = _db.batch();
      for (final adminDoc in admins.docs) {
        final ref = _db.collection('notifications').doc();
        batch.set(ref, {
          'userId': adminDoc.id,
          'role': 'admin',
          'title': title,
          'message': message,
          'type': type,
          'campName': campName ?? '',
          'familyId': familyId ?? '',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (_) {}
  }

  /// ← جديد: إرسال إشعار لحساب النازح المرتبط بأسرة معيّنة (إن وُجد حساب مرتبط بـ familyId)
  Future<void> notifyFamilyUser({
    required String familyId,
    required String title,
    required String message,
    required String type,
    String? campName,
  }) async {
    try {
      if (familyId.isEmpty) return;

      final userQuery = await _db
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        // الأسرة ما عندها حساب مستخدم مرتبط بعد — تجاهل بصمت
        return;
      }

      final userId = userQuery.docs.first.id;

      await sendNotification(
        userId: userId,
        role: 'displaced',
        title: title,
        message: message,
        type: type,
        campName: campName,
        familyId: familyId,
      );
    } catch (_) {}
  }

  // ════════════════════════════════════════════════════════
  //  Aid Distributions — Real-time
  // ════════════════════════════════════════════════════════
  List<Map<String, dynamic>> aidDistributions = [];
  int totalAid = 0;
  StreamSubscription? _familyAidSubscription;

  void listenToFamilyAid(String familyId) {
    _familyAidSubscription?.cancel();

    _familyAidSubscription = _db
        .collection('aid_distributions')
        .where('familyId', isEqualTo: familyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        aidDistributions = snapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data()};
        }).toList();
        emit(AidSuccessState()); // أو أي state مناسبة عندك
      },
      onError: (_) {},
    );
  }

  void listenToAid() {
    _aidSubscription?.cancel();

    _aidSubscription = _db
        .collection('aid_distributions')
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true) // ← جديد
        .listen(
      (snapshot) {
        _trackPendingWrites(snapshot, 'aid_distributions'); // ← جديد
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

  void _recomputeDashboard() {
    final totalCamps = camps.length;
    final activeCamps = camps.where((c) => c['status'] == 'متاح').length;

    final totalFamilies = families.length;
    final totalDisplaced =
        families.fold<int>(0, (s, f) => s + (f['membersCount'] as int? ?? 1));

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

  Future<void> getDashboardStats() async {
    emit(DashboardLoadingState());

    if (_auth.currentUser != null && currentUsername == null) {
      try {
        final userDoc =
            await _db.collection('users').doc(_auth.currentUser!.uid).get();
        currentUsername = userDoc.data()?['username'] ?? 'مسؤول النظام';
      } catch (_) {}
    }

    if (_campsSubscription == null) startAllListeners();

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
