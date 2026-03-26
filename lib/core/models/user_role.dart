enum UserRole { admin, vendeur }

extension UserRoleExt on UserRole {
  String get name {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.vendeur:
        return 'vendeur';
    }
  }

  static UserRole fromString(String s) {
    if (s == 'vendeur') return UserRole.vendeur;
    return UserRole.admin;
  }
}
