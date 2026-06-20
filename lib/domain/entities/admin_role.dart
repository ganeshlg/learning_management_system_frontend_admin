enum AdminRole {
  superAdmin,
  trainer;

  static AdminRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'super_admin':
        return AdminRole.superAdmin;
      case 'trainer':
        return AdminRole.trainer;
      default:
        return AdminRole.trainer;
    }
  }

  String get value {
    switch (this) {
      case AdminRole.superAdmin:
        return 'super_admin';
      case AdminRole.trainer:
        return 'trainer';
    }
  }

  String get displayName {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.trainer:
        return 'Trainer';
    }
  }
}
