enum UserRole { admin, displaced, volunteer }

// ─── helper لتحويل String من Firestore → UserRole ───
UserRole? parseUserRole(String? role) {
  switch (role?.toLowerCase().trim()) {
    case 'admin':
      return UserRole.admin;
    case 'displaced':
      return UserRole.displaced;
    case 'volunteer':
      return UserRole.volunteer;
    default:
      return null;
  }
}
