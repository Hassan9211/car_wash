import 'dart:async';
import 'dart:io';

import 'package:car_wash/core/location/app_location_details.dart';
import 'package:car_wash/features/authentication/model/app_user_role.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  AuthSession._();

  static final ValueNotifier<int> _listenable = ValueNotifier<int>(0);

  static const String _defaultEmail = 'guest@carwash.app';
  static const String _defaultPhoneNumber = '+92 36047678';
  static const String _defaultLocationLabel = 'New York, USA';
  static const String _defaultAvatarAssetPath =
      'assets/images/onboarding/pexels-karola-g-4870700.jpg';
  static const String _prefsEmailKey = 'auth_session.email';
  static const String _prefsNameKey = 'auth_session.name';
  static const String _prefsPhoneNumberKey = 'auth_session.phone_number';
  static const String _prefsDateOfBirthKey = 'auth_session.date_of_birth';
  static const String _prefsAvatarImagePathKey = 'auth_session.avatar_image';
  static const String _prefsLocationLabelKey = 'auth_session.location_label';
  static const String _prefsLatitudeKey = 'auth_session.latitude';
  static const String _prefsLongitudeKey = 'auth_session.longitude';
  static const String _prefsRoleKey = 'auth_session.role';
  static const String _prefsIsAuthenticatedKey =
      'auth_session.is_authenticated';
  static const String _prefsTokenKey = 'auth_session.token';
  static const String _prefsUserIdKey = 'auth_session.user_id';
  static const String _prefsProviderSetupCompletedKey = 'auth_session.provider_setup_completed';
  static final DateTime _defaultDateOfBirth = DateTime(2000, 9, 20);

  static String? _currentToken;
  static String? _currentUserId;
  static String? _currentEmail;
  static String? _currentName;
  static String? _currentPhoneNumber;
  static DateTime? _currentDateOfBirth;
  static String? _currentAvatarImagePath;
  static String? _currentLocationLabel;
  static double? _currentLatitude;
  static double? _currentLongitude;
  static AppUserRole? _currentRole;
  static bool _isAuthenticated = false;
  static bool _isProviderSetupCompleted = false;

  static ValueNotifier<int> get listenable => _listenable;

  static String? get currentEmail => _currentEmail;
  static String? get currentName => _currentName;
  static String? get currentUserId => _currentUserId;
  static String? get currentPhoneNumber => _currentPhoneNumber;
  static String? get authToken => _currentToken;
  static DateTime? get currentDateOfBirth => _currentDateOfBirth;
  static String? get currentAvatarImagePath => _currentAvatarImagePath;
  static String? get currentLocationLabel => _currentLocationLabel;
  static double? get currentLatitude => _currentLatitude;
  static double? get currentLongitude => _currentLongitude;
  static AppUserRole? get currentRole => _currentRole;
  static bool get isAuthenticated => _isAuthenticated;
  static bool get isProviderSetupCompleted => _isProviderSetupCompleted;
  static AppLocationDetails? get currentLocationDetails {
    final latitude = _currentLatitude;
    final longitude = _currentLongitude;
    if (latitude == null || longitude == null) {
      return null;
    }

    return AppLocationDetails(
      latitude: latitude,
      longitude: longitude,
      label: displayLocationLabel,
    );
  }

  static AppUserRole get effectiveRole => _currentRole ?? AppUserRole.customer;

  static String get displayName {
    final trimmedName = _currentName?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      return trimmedName;
    }

    final trimmedEmail = _currentEmail?.trim();
    if (trimmedEmail != null && trimmedEmail.isNotEmpty) {
      return _formatNameFromEmail(trimmedEmail);
    }

    return 'Guest User';
  }

  static String get displayEmail {
    final trimmedEmail = _currentEmail?.trim();
    if (trimmedEmail != null && trimmedEmail.isNotEmpty) {
      return trimmedEmail;
    }

    return _defaultEmail;
  }

  static String get displayPhoneNumber {
    final trimmedPhoneNumber = _currentPhoneNumber?.trim();
    if (trimmedPhoneNumber != null && trimmedPhoneNumber.isNotEmpty) {
      return trimmedPhoneNumber;
    }

    return _defaultPhoneNumber;
  }

  static DateTime get effectiveDateOfBirth =>
      _currentDateOfBirth ?? _defaultDateOfBirth;

  static String get displayDateOfBirth => _formatDate(effectiveDateOfBirth);

  static String get displayLocationLabel {
    final trimmedLocation = _currentLocationLabel?.trim();
    if (trimmedLocation != null && trimmedLocation.isNotEmpty) {
      return trimmedLocation;
    }

    return _defaultLocationLabel;
  }

  static ImageProvider<Object> get avatarImage {
    final trimmedPath = _currentAvatarImagePath?.trim();
    if (trimmedPath != null && trimmedPath.isNotEmpty) {
      return FileImage(File(trimmedPath));
    }

    return const AssetImage(_defaultAvatarAssetPath);
  }

  static ImageProvider<Object> avatarImageFromPath(String path) {
    final trimmedPath = path.trim();
    if (trimmedPath.isEmpty) {
      return avatarImage;
    }

    return FileImage(File(trimmedPath));
  }

  static String get initials {
    final words = displayName
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);

    if (words.isEmpty) {
      return 'GU';
    }

    if (words.length == 1) {
      final word = words.first;
      return word.length >= 2
          ? word.substring(0, 2).toUpperCase()
          : word.toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  static void setCurrentUser({
    required String email,
    String? userId,
    String? token,
    String? name,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? avatarImagePath,
  }) {
    _currentUserId = _normalize(userId);
    _currentToken = _normalize(token);
    _currentEmail = _normalize(email);
    _currentName = _normalize(name);
    _currentPhoneNumber = _normalize(phoneNumber);
    _currentDateOfBirth = dateOfBirth;
    _currentAvatarImagePath = _normalize(avatarImagePath);
    _persistSessionAsync();
    _notifyListeners();
  }

  static void setCurrentEmail(String email) {
    _currentEmail = _normalize(email);
    _persistSessionAsync();
    _notifyListeners();
  }

  static void setCurrentName(String? name) {
    _currentName = _normalize(name);
    _persistSessionAsync();
    _notifyListeners();
  }

  static void updateProfile({
    String? userId,
    String? token,
    required String name,
    required String email,
    required String phoneNumber,
    required DateTime dateOfBirth,
    String? avatarImagePath,
  }) {
    _currentUserId = _normalize(userId) ?? _currentUserId;
    _currentToken = _normalize(token) ?? _currentToken;
    _currentName = _normalize(name);
    _currentEmail = _normalize(email);
    _currentPhoneNumber = _normalize(phoneNumber);
    _currentDateOfBirth = dateOfBirth;
    _currentAvatarImagePath = _normalize(avatarImagePath);
    _persistSessionAsync();
    _notifyListeners();
  }

  static void updateAvatarImagePath(String? avatarImagePath) {
    _currentAvatarImagePath = _normalize(avatarImagePath);
    _persistSessionAsync();
    _notifyListeners();
  }

  static void updateCurrentLocation({
    required double latitude,
    required double longitude,
    String? label,
  }) {
    _currentLatitude = latitude;
    _currentLongitude = longitude;
    _currentLocationLabel = _normalize(label) ??
        'Lat ${latitude.toStringAsFixed(4)}, Lng ${longitude.toStringAsFixed(4)}';
    _persistSessionAsync();
    _notifyListeners();
  }

  static void setCurrentLocationDetails(AppLocationDetails location) {
    _currentLatitude = location.latitude;
    _currentLongitude = location.longitude;
    _currentLocationLabel = _normalize(location.label);
    _persistSessionAsync();
    _notifyListeners();
  }

  static void setCurrentLocationLabel(String locationLabel) {
    _currentLocationLabel = _normalize(locationLabel);
    _persistSessionAsync();
    _notifyListeners();
  }

  static void setCurrentRole(AppUserRole role) {
    _currentRole = role;
    _persistSessionAsync();
    _notifyListeners();
  }

  static void setAuthenticated(bool value) {
    _isAuthenticated = value;
    _persistSessionAsync();
    _notifyListeners();
  }

  static void setProviderSetupCompleted(bool value) {
    _isProviderSetupCompleted = value;
    _persistSessionAsync();
    _notifyListeners();
  }

  static void clear() {
    _currentToken = null;
    _currentUserId = null;
    _currentEmail = null;
    _currentName = null;
    _currentPhoneNumber = null;
    _currentDateOfBirth = null;
    _currentAvatarImagePath = null;
    _currentLocationLabel = null;
    _currentLatitude = null;
    _currentLongitude = null;
    _currentRole = null;
    _isAuthenticated = false;
    _isProviderSetupCompleted = false;
    _persistSessionAsync();
    _notifyListeners();
  }

  static Future<void> restore() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      _currentToken = _normalize(preferences.getString(_prefsTokenKey));
      _currentUserId = _normalize(preferences.getString(_prefsUserIdKey));
      _currentEmail = _normalize(preferences.getString(_prefsEmailKey));
      _currentName = _normalize(preferences.getString(_prefsNameKey));
      _currentPhoneNumber = _normalize(
        preferences.getString(_prefsPhoneNumberKey),
      );
      _currentAvatarImagePath = _normalize(
        preferences.getString(_prefsAvatarImagePathKey),
      );
      _currentLocationLabel = _normalize(
        preferences.getString(_prefsLocationLabelKey),
      );
      _currentLatitude = preferences.getDouble(_prefsLatitudeKey);
      _currentLongitude = preferences.getDouble(_prefsLongitudeKey);
      _isAuthenticated = preferences.getBool(_prefsIsAuthenticatedKey) ?? false;
      _isProviderSetupCompleted = preferences.getBool(_prefsProviderSetupCompletedKey) ?? false;

      final savedDateOfBirth = preferences.getInt(_prefsDateOfBirthKey);
      _currentDateOfBirth = savedDateOfBirth == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(savedDateOfBirth);

      final savedRole = preferences.getString(_prefsRoleKey);
      _currentRole = _roleFromName(savedRole);
    } catch (_) {
      _currentToken = null;
      _currentUserId = null;
      _currentEmail = null;
      _currentName = null;
      _currentPhoneNumber = null;
      _currentDateOfBirth = null;
      _currentAvatarImagePath = null;
      _currentLocationLabel = null;
      _currentLatitude = null;
      _currentLongitude = null;
      _currentRole = null;
      _isAuthenticated = false;
      _isProviderSetupCompleted = false;
    }

    _notifyListeners();
  }

  static String _formatNameFromEmail(String email) {
    final localPart = email.split('@').first.trim();
    final cleanedValue = localPart.replaceAll(RegExp(r'[._-]+'), ' ').trim();

    if (cleanedValue.isEmpty) {
      return 'Guest User';
    }

    return cleanedValue
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map(_capitalize)
        .join(' ');
  }

  static String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
  }

  static String? _normalize(String? value) {
    final trimmedValue = value?.trim();
    if (trimmedValue == null || trimmedValue.isEmpty) {
      return null;
    }

    return trimmedValue;
  }

  static String _formatDate(DateTime value) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${value.day} ${monthNames[value.month - 1]} ${value.year}';
  }

  static void _notifyListeners() {
    _listenable.value++;
  }

  static void _persistSessionAsync() {
    unawaited(_persistSession());
  }

  static Future<void> _persistSession() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      await _setOrRemoveString(preferences, _prefsEmailKey, _currentEmail);
      await _setOrRemoveString(preferences, _prefsTokenKey, _currentToken);
      await _setOrRemoveString(preferences, _prefsUserIdKey, _currentUserId);
      await _setOrRemoveString(preferences, _prefsNameKey, _currentName);
      await _setOrRemoveString(
        preferences,
        _prefsPhoneNumberKey,
        _currentPhoneNumber,
      );
      await _setOrRemoveInt(
        preferences,
        _prefsDateOfBirthKey,
        _currentDateOfBirth?.millisecondsSinceEpoch,
      );
      await _setOrRemoveString(
        preferences,
        _prefsAvatarImagePathKey,
        _currentAvatarImagePath,
      );
      await _setOrRemoveString(
        preferences,
        _prefsLocationLabelKey,
        _currentLocationLabel,
      );
      await _setOrRemoveDouble(
        preferences,
        _prefsLatitudeKey,
        _currentLatitude,
      );
      await _setOrRemoveDouble(
        preferences,
        _prefsLongitudeKey,
        _currentLongitude,
      );
      await _setOrRemoveString(preferences, _prefsRoleKey, _currentRole?.name);
      await preferences.setBool(_prefsIsAuthenticatedKey, _isAuthenticated);
      await preferences.setBool(_prefsProviderSetupCompletedKey, _isProviderSetupCompleted);
    } catch (_) {
      // Ignore local persistence failures and keep the in-memory session active.
    }
  }

  static Future<void> _setOrRemoveString(
    SharedPreferences preferences,
    String key,
    String? value,
  ) async {
    if (value == null || value.trim().isEmpty) {
      await preferences.remove(key);
      return;
    }

    await preferences.setString(key, value);
  }

  static Future<void> _setOrRemoveInt(
    SharedPreferences preferences,
    String key,
    int? value,
  ) async {
    if (value == null) {
      await preferences.remove(key);
      return;
    }

    await preferences.setInt(key, value);
  }

  static Future<void> _setOrRemoveDouble(
    SharedPreferences preferences,
    String key,
    double? value,
  ) async {
    if (value == null) {
      await preferences.remove(key);
      return;
    }

    await preferences.setDouble(key, value);
  }

  static AppUserRole? _roleFromName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    for (final role in AppUserRole.values) {
      if (role.name == value) {
        return role;
      }
    }

    return null;
  }
}
