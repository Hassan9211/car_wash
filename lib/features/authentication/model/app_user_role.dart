enum AppUserRole {
  customer,
  serviceProvider;

  String get label {
    switch (this) {
      case AppUserRole.customer:
        return 'Customer';
      case AppUserRole.serviceProvider:
        return 'Service Provider';
    }
  }

  String get description {
    switch (this) {
      case AppUserRole.customer:
        return 'Book washes, track providers, and manage payments.';
      case AppUserRole.serviceProvider:
        return 'Manage requests, track jobs,\nhandle your earnings.';
    }
  }
}
