import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../controllers/cubit/app_cubit.dart';
import '../../../utils/styles/colors.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _roleFilter = 'الكل';

  final List<String> _roleFilters = ['الكل', 'admin', 'volunteer', 'displaced'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final snapshot = await _db.collection('users').get();
      _users = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
      _applyFilter();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      _filtered = _users.where((u) {
        final matchSearch = _searchQuery.isEmpty ||
            (u['username']?.toString() ?? '')
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (u['email']?.toString() ?? '')
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
        final matchRole =
            _roleFilter == 'الكل' || u['role']?.toString() == _roleFilter;
        return matchSearch && matchRole;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'إدارة المستخدمين',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.primary, size: 22),
            onPressed: _loadUsers,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          // ── شريط البحث ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
              ),
              child: TextField(
                textDirection: TextDirection.rtl,
                onChanged: (v) {
                  _searchQuery = v;
                  _applyFilter();
                },
                decoration: const InputDecoration(
                  hintText: 'ابحث باسم المستخدم أو البريد...',
                  hintStyle:
                      TextStyle(color: AppColors.textHint, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.textHint, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // ── فلاتر الدور ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _roleFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final f = _roleFilters[index];
                  final isSelected = _roleFilter == f;
                  final color = _roleColor(f);
                  return GestureDetector(
                    onTap: () {
                      _roleFilter = f;
                      _applyFilter();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? color : AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? color : AppColors.border,
                        ),
                      ),
                      child: Text(
                        _roleArabic(f),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── عداد + زر إضافة ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filtered.length} مستخدم',
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                TextButton.icon(
                  onPressed: () => _showAddUserDialog(context),
                  icon: const Icon(Icons.person_add_rounded,
                      size: 16, color: AppColors.primary),
                  label: const Text('إضافة مستخدم',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    backgroundColor: AppColors.primary.withOpacity(0.07),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          // ── القائمة ─────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : _error != null
                    ? _errorView()
                    : _filtered.isEmpty
                        ? _emptyState()
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) =>
                                _userCard(_filtered[index]),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _userCard(Map<String, dynamic> user) {
    final role = user['role']?.toString() ?? '';
    final username = user['username']?.toString() ?? '';
    final email = user['email']?.toString() ?? '';
    final familyId = user['familyId']?.toString() ?? '';

    // ← الإصلاح: نحسب اسم الأسرة ديناميكياً من قائمة العائلات المحمّلة
    // بدل الاعتماد على حقل familyName المخزّن وقت إنشاء الحساب
    String familyName = '';
    if (familyId.isNotEmpty) {
      final matchedFamily = AppCubit.get(context).families.firstWhere(
            (f) => f['id'] == familyId,
            orElse: () => <String, dynamic>{},
          );
      familyName = matchedFamily['familyName']?.toString() ?? '';
    }

    final color = _roleColor(role);
    final icon = _roleIcon(role);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // ── الصورة الرمزية ────────────────
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),

          // ── المعلومات ─────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(email,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _roleArabic(role),
                        style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    // ← جديد: بادچ يوضح اسم الأسرة المرتبطة (لو الدور نازح)
                    // ← بادچ يوضح اسم الأسرة المرتبطة (لو الدور نازح وله familyId)
                    if (role == 'displaced' && familyId.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.textHint.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.family_restroom_rounded,
                                size: 10, color: AppColors.textSecondary),
                            const SizedBox(width: 3),
                            Text(
                              familyName.isNotEmpty
                                  ? familyName
                                  : 'أسرة مرتبطة',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // ← تحذير لو الحساب نازح بدون أي ربط بأسرة إطلاقاً
                    if (role == 'displaced' && familyId.isEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.statusCritical.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'بدون أسرة!',
                          style: TextStyle(
                              color: AppColors.statusCritical,
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // ── القائمة ───────────────────────
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: AppColors.textHint, size: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) => _onUserAction(value, user),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('تعديل الدور'),
                ]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline,
                      size: 18, color: AppColors.statusCritical),
                  SizedBox(width: 8),
                  Text('حذف المستخدم',
                      style: TextStyle(color: AppColors.statusCritical)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onUserAction(String action, Map<String, dynamic> user) {
    if (action == 'edit') {
      _showEditRoleDialog(user);
    } else if (action == 'delete') {
      _confirmDeleteUser(user);
    }
  }

  void _showEditRoleDialog(Map<String, dynamic> user) {
    String selectedRole = user['role']?.toString() ?? 'volunteer';
    final roles = ['admin', 'volunteer', 'displaced'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('تعديل دور: ${user['username']}',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: roles.map((r) {
              final color = _roleColor(r);
              final isSelected = selectedRole == r;
              return GestureDetector(
                onTap: () => setDialogState(() => selectedRole = r),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isSelected ? color : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(_roleIcon(r),
                          color: isSelected ? color : AppColors.textHint,
                          size: 18),
                      const SizedBox(width: 10),
                      Text(_roleArabic(r),
                          style: TextStyle(
                              color: isSelected ? color : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _db
                      .collection('users')
                      .doc(user['id'])
                      .update({'role': selectedRole});
                  _loadUsers();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'تم تحديث دور ${user['username']} إلى ${_roleArabic(selectedRole)}'),
                      backgroundColor: AppColors.statusStable,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('فشل التحديث: $e'),
                      backgroundColor: AppColors.statusCritical,
                    ));
                  }
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.statusCritical, size: 22),
          SizedBox(width: 8),
          Text('تأكيد الحذف',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        content: Text(
          'هل تريد حذف مستخدم "${user['username']}"؟\nلا يمكن التراجع عن هذه العملية.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCritical,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _db.collection('users').doc(user['id']).delete();
                _loadUsers();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('تم حذف المستخدم بنجاح'),
                    backgroundColor: AppColors.statusStable,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('فشل الحذف: $e'),
                    backgroundColor: AppColors.statusCritical,
                  ));
                }
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'volunteer';

    Map<String, dynamic>? selectedFamily;
    String familySearch = '';
    bool loadingFamilies = false;
    List<Map<String, dynamic>> familiesCache = [];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          if (familiesCache.isEmpty && !loadingFamilies) {
            familiesCache = AppCubit.get(context).families;
          }

          final filteredFamilies = familySearch.isEmpty
              ? familiesCache
              : familiesCache.where((f) {
                  return (f['familyName'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(familySearch.toLowerCase()) ||
                      (f['representativeName'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(familySearch.toLowerCase());
                }).toList();

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('إضافة مستخدم جديد',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(
                      controller: usernameController,
                      label: 'اسم المستخدم',
                      icon: Icons.person_outline),
                  const SizedBox(height: 10),
                  _dialogField(
                      controller: emailController,
                      label: 'البريد الإلكتروني',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 10),
                  _dialogField(
                      controller: passwordController,
                      label: 'كلمة المرور',
                      icon: Icons.lock_outline,
                      obscure: true),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('الدور:',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: ['volunteer', 'admin', 'displaced'].map((r) {
                      final color = _roleColor(r);
                      final isSelected = selectedRole == r;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() {
                            selectedRole = r;
                            if (r != 'displaced') selectedFamily = null;
                          }),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: isSelected ? color : AppColors.border),
                            ),
                            child: Text(
                              _roleArabic(r),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: isSelected
                                      ? color
                                      : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (selectedRole == 'displaced') ...[
                    const SizedBox(height: 14),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text('اختر الأسرة المرتبطة:',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundPage,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.border.withOpacity(0.5)),
                      ),
                      child: TextField(
                        textDirection: TextDirection.rtl,
                        onChanged: (v) =>
                            setDialogState(() => familySearch = v),
                        decoration: const InputDecoration(
                          hintText: 'ابحث باسم الأسرة...',
                          hintStyle: TextStyle(
                              color: AppColors.textHint, fontSize: 13),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: AppColors.textHint, size: 18),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (familiesCache.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'لا توجد أسر مسجّلة بعد — سجّل الأسرة أولاً من شاشة العائلات',
                          style:
                              TextStyle(color: AppColors.warning, fontSize: 11),
                        ),
                      )
                    else
                      Container(
                        constraints: const BoxConstraints(maxHeight: 160),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundPage,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.border.withOpacity(0.4)),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int index = 0;
                                  index < filteredFamilies.length;
                                  index++) ...[
                                if (index > 0)
                                  const Divider(
                                      height: 1, color: AppColors.border),
                                Builder(builder: (context) {
                                  final fam = filteredFamilies[index];
                                  final isSel =
                                      selectedFamily?['id'] == fam['id'];
                                  return GestureDetector(
                                    onTap: () => setDialogState(
                                        () => selectedFamily = fam),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSel
                                            ? AppColors.primary
                                                .withOpacity(0.08)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.family_restroom_rounded,
                                            size: 16,
                                            color: isSel
                                                ? AppColors.primary
                                                : AppColors.textHint,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  fam['familyName'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: isSel
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: isSel
                                                        ? AppColors.primary
                                                        : AppColors.textPrimary,
                                                  ),
                                                ),
                                                Text(
                                                  fam['campName'] ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          AppColors.textHint),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isSel)
                                            const Icon(
                                                Icons.check_circle_rounded,
                                                color: AppColors.primary,
                                                size: 16),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                      ),
                    if (selectedFamily != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'مرتبط بأسرة: ${selectedFamily!['familyName']}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final username = usernameController.text.trim();
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();

                  if (username.isEmpty || email.isEmpty) return;
                  if (password.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('كلمة المرور يجب أن تكون 6 أحرف على الأقل'),
                      backgroundColor: AppColors.statusCritical,
                    ));
                    return;
                  }

                  if (selectedRole == 'displaced' && selectedFamily == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('يجب اختيار الأسرة المرتبطة بهذا الحساب'),
                      backgroundColor: AppColors.statusCritical,
                    ));
                    return;
                  }

                  Navigator.pop(context);

                  FirebaseApp? tempApp;
                  try {
                    tempApp = await Firebase.initializeApp(
                      name:
                          'tempUserCreation_${DateTime.now().millisecondsSinceEpoch}',
                      options: Firebase.app().options,
                    );
                    final tempAuth = FirebaseAuth.instanceFor(app: tempApp);

                    final cred = await tempAuth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    final userData = <String, dynamic>{
                      'username': username,
                      'email': email,
                      'role': selectedRole,
                      'createdAt': FieldValue.serverTimestamp(),
                    };

                    if (selectedRole == 'displaced' && selectedFamily != null) {
                      userData['familyId'] = selectedFamily!['id'];
                      userData['familyName'] =
                          selectedFamily!['familyName'] ?? '';
                    }

                    await _db
                        .collection('users')
                        .doc(cred.user!.uid)
                        .set(userData);

                    await tempAuth.signOut();
                    _loadUsers();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('تم إضافة المستخدم بنجاح'),
                        backgroundColor: AppColors.statusStable,
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  } on FirebaseAuthException catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(_addUserAuthError(e.code)),
                        backgroundColor: AppColors.statusCritical,
                      ));
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('فشل الإضافة: $e'),
                        backgroundColor: AppColors.statusCritical,
                      ));
                    }
                  } finally {
                    await tempApp?.delete();
                  }
                },
                child: const Text('إضافة'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.backgroundPage,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.statusCritical.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.wifi_off_rounded,
                color: AppColors.statusCritical, size: 40),
          ),
          const SizedBox(height: 12),
          const Text('تعذّر تحميل المستخدمين',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 15)),
          const SizedBox(height: 4),
          Text(_error ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.people_outline,
                color: AppColors.primary.withOpacity(0.4), size: 48),
          ),
          const SizedBox(height: 14),
          const Text('لا يوجد مستخدمون',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
            'جرب بحثاً مختلفاً أو غيّر الفلتر',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.secondary;
      case 'volunteer':
        return AppColors.primary;
      case 'displaced':
        return AppColors.warning;
      default:
        return AppColors.textHint;
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      case 'volunteer':
        return Icons.volunteer_activism_rounded;
      case 'displaced':
        return Icons.person_rounded;
      default:
        return Icons.person_outline;
    }
  }

  String _roleArabic(String role) {
    switch (role) {
      case 'admin':
        return 'مسؤول';
      case 'volunteer':
        return 'متطوع';
      case 'displaced':
        return 'نازح';
      default:
        return role;
    }
  }

  String _addUserAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم مسبقاً';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      default:
        return 'حدث خطأ أثناء إنشاء الحساب';
    }
  }
}
