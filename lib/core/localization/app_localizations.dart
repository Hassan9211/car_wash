import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'choose_language': 'Choose Language',
      'continue': 'Continue',
      'select_role': 'Select Role',
      'how_to_continue': 'How would you like to continue?',
      'role_description':
          'Choose your app experience. You can continue as a customer to book services or as a service provider to manage jobs and earnings.',
      'customer': 'Customer',
      'customer_subtitle': 'Book washes, track arrivals, and manage orders.',
      'service_provider': 'Service Provider',
      'service_provider_subtitle':
          'Accept requests, manage active jobs, and monitor earnings.',
      'guest': 'Guest',
      'guest_subtitle': 'Explore services and browse the app without an account.',
      'login': 'Login',
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'dont_have_account': "Don't have an account?",
      'already_have_account': 'Already have an account?',
      'signin_to_book': 'Please sign in to book a service.',
      'signin_to_access': 'Please sign in to access {tab}.',
      'signin_signup': 'Sign In / Sign Up',
      'join_community':
          'Join our community to book services, track providers, and manage your car wash history.',
      'browse_as_guest': 'Browse as guest',
      'edit_profile': 'Edit Profile',
      'logout': 'Logout',
      'delete_account': 'Delete Account',
      'switch_to_provider': 'Switch to Service Provider',
      'home': 'Home',
      'bookings': 'Bookings',
      'wallet': 'Wallet',
      'profile': 'Profile',
      'account': 'Account',
      'support': 'Support',
      'account_verification': 'Account Verification',
      'otp_verification': 'OTP Verification',
      'otp_instruction': 'Enter OTP sent to your email to verify your account.',
      'invalid_code': 'Invalid Code',
      'resend': 'Resend',
      'confirm': 'Confirm',
      'language': 'Language',
      'settings': 'Settings',
      'switch_to_customer': 'Switch to Customer Account',
      'notifications': 'Notifications',
      'privacy_policy': 'Privacy Policy',
      'terms_conditions': 'Terms & Conditions',
      'help_center': 'Help Center',
      'switch_customer_title': 'Switch to Customer?',
      'switch_customer_desc': 'Are you sure you want to switch to your customer account?',
      'yes_switch': 'Yes, Switch',
      'cancel': 'Cancel',
      'logout_title': 'Are you sure you want to log out?',
      'logout_desc': 'You will be signed out of the current session and returned to the login screen.',
      'yes': 'Yes',
      'no': 'No',
      'delete_account_title': 'Are you sure you want to delete this account?',
      'delete_account_desc': 'This will clear your saved data from the app and sign you out of the current session.',
    },
    'ar': {
      'choose_language': 'اختر اللغة',
      'continue': 'متابعة',
      'select_role': 'اختر الدور',
      'how_to_continue': 'كيف تود المتابعة؟',
      'role_description':
          'اختر تجربة تطبيقك. يمكنك المتابعة كعميل لحجز الخدمات أو كمزود خدمة لإدارة الوظائف والأرباح.',
      'customer': 'عميل',
      'customer_subtitle': 'احجز خدمات الغسيل، وتتبع الوصول، وإدارة الطلبات.',
      'service_provider': 'مزود الخدمة',
      'service_provider_subtitle': 'قبول الطلبات، وإدارة الوظائف النشطة، ومراقبة الأرباح.',
      'guest': 'ضيف',
      'guest_subtitle': 'استكشف الخدمات وتصفح التطبيق بدون حساب.',
      'login': 'تسجيل الدخول',
      'signup': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgot_password': 'هل نسيت كلمة المرور؟',
      'dont_have_account': 'ليس لديك حساب؟',
      'already_have_account': 'لديك حساب بالفعل؟',
      'signin_to_book': 'يرجى تسجيل الدخول لحجز الخدمة.',
      'signin_to_access': 'يرجى تسجيل الدخول للوصول إلى {tab}.',
      'signin_signup': 'تسجيل الدخول / الاشتراك',
      'join_community': 'انضم إلى مجتمعنا لحجز الخدمات وتتبع المزودين وإدارة سجل غسيل سيارتك.',
      'browse_as_guest': 'تصفح كضيف',
      'edit_profile': 'تعديل الملف الشخصي',
      'logout': 'تسجيل الخروج',
      'delete_account': 'حذف الحساب',
      'switch_to_provider': 'التبديل إلى مزود الخدمة',
      'home': 'الرئيسية',
      'bookings': 'الحجوزات',
      'wallet': 'المحفظة',
      'profile': 'الملف الشخصي',
      'account': 'الحساب',
      'support': 'الدعم',
      'account_verification': 'التحقق من الحساب',
      'otp_verification': 'التحقق من رمز OTP',
      'otp_instruction': 'أدخل رمز OTP المرسل إلى بريدك الإلكتروني للتحقق من حسابك.',
      'invalid_code': 'رمز غير صحيح',
      'resend': 'إعادة إرسال',
      'confirm': 'تأكيد',
      'language': 'اللغة',
      'settings': 'الإعدادات',
      'switch_to_customer': 'التبديل إلى حساب العميل',
      'notifications': 'الإشعارات',
      'privacy_policy': 'سياسة الخصوصية',
      'terms_conditions': 'الشروط والأحكام',
      'help_center': 'مركز المساعدة',
      'switch_customer_title': 'التبديل إلى العميل؟',
      'switch_customer_desc': 'هل أنت متأكد أنك تريد التبديل إلى حساب العميل الخاص بك؟',
      'yes_switch': 'نعم، قم بالتبديل',
      'cancel': 'إلغاء',
      'logout_title': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'logout_desc': 'سيتم تسجيل خروجك من الجلسة الحالية والعودة إلى شاشة تسجيل الدخول.',
      'yes': 'نعم',
      'no': 'لا',
      'delete_account_title': 'هل أنت متأكد أنك تريد حذف هذا الحساب؟',
      'delete_account_desc': 'سيؤدي هذا إلى مسح بياناتك المحفوظة من التطبيق وتسجيل خروجك من الجلسة الحالية.',
    },
  };

  String translate(String key, {Map<String, String>? params}) {
    String value = _localizedValues[locale.languageCode]?[key] ?? key;
    if (params != null) {
      params.forEach((k, v) {
        value = value.replaceAll('{$k}', v);
      });
    }
    return value;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationExtension on BuildContext {
  String translate(String key, {Map<String, String>? params}) {
    return AppLocalizations.of(this)?.translate(key, params: params) ?? key;
  }
}
