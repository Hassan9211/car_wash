class AuthValidators {
  AuthValidators._();

  static final RegExp _emailPattern = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
  );

  static String? validateName(String? value) {
    final trimmedValue = value?.trim() ?? '';

    if (trimmedValue.isEmpty) {
      return 'Full name is required';
    }

    if (trimmedValue.length < 2) {
      return 'Enter your full name';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    final trimmedValue = value?.trim() ?? '';

    if (trimmedValue.isEmpty) {
      return 'Email is required';
    }

    if (!_emailPattern.hasMatch(trimmedValue)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String originalPassword,
  ) {
    final confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Please repeat your password';
    }

    if (confirmPassword != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }
}
