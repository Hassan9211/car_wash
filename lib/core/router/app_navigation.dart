import 'package:car_wash/core/router/app_routes.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/authentication/model/app_user_role.dart';
import 'package:car_wash/features/home/booking/model/booking_flow_details.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:car_wash/features/home/booking/model/booking_payment_method.dart';
import 'package:car_wash/features/home/booking/model/booking_payment_success_details.dart';
import 'package:car_wash/features/home/model/service_provider_profile.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

extension AppNavigation on BuildContext {
  void goToSplash() => go(AppRoutes.splash);

  void goToOnboarding() => go(AppRoutes.onboarding);

  void goToLanguage() => go(AppRoutes.language);

  void goToRoleSelection() => go(AppRoutes.roleSelection);

  void goToLogin() => go(AppRoutes.login);

  void goToSignup() => go(AppRoutes.signup);

  void goToOtpVerification() => go(AppRoutes.otpVerification);

  void goToVerificationComplete() => go(AppRoutes.verificationComplete);

  void goToLocationAccess() => go(AppRoutes.locationAccess);

  void goToServiceProviderSetup() => go(AppRoutes.serviceProviderSetup);

  void goToServiceProviderHome() => go(AppRoutes.serviceProviderHome);

  void goToServiceProviderBookings() => go(AppRoutes.serviceProviderBookings);

  void goToServiceProviderPaymentHistory() =>
      go(AppRoutes.serviceProviderPaymentHistory);

  void goToServiceProviderProfile() => go(AppRoutes.serviceProviderProfile);

  Future<void> pushToServiceProviderSettings() =>
      push(AppRoutes.serviceProviderSettings);

  void goToServices() => go(AppRoutes.services);

  void pushToServiceDetail(ServiceProviderProfile provider) =>
      push(AppRoutes.serviceDetail, extra: provider);

  void pushToNotifications() => push(AppRoutes.notifications);

  Future<void> pushToPrivacyPolicy() => push(AppRoutes.privacyPolicy);

  Future<void> pushToTermsConditions() => push(AppRoutes.termsConditions);

  Future<void> pushToHelpCenter() => push(AppRoutes.helpCenter);

  void pushToBooking(ServiceProviderProfile provider) =>
      push(AppRoutes.booking, extra: provider);

  Future<String?> pushToBookingLocation([String? initialLocation]) =>
      push<String>(AppRoutes.bookingLocation, extra: initialLocation);

  Future<void> pushToBookingSchedule(BookingFlowDetails details) =>
      push(AppRoutes.bookingSchedule, extra: details);

  Future<void> pushToBookingPayment(BookingFlowDetails details) =>
      push(AppRoutes.bookingPayment, extra: details);

  Future<void> pushToBookingCheckout(BookingFlowDetails details) =>
      push(AppRoutes.bookingCheckout, extra: details);

  Future<BookingPaymentMethod?> pushToBookingPaymentMethod(
    BookingPaymentMethod selectedMethod,
  ) => push<BookingPaymentMethod>(
    AppRoutes.bookingPaymentMethod,
    extra: selectedMethod,
  );

  Future<BookingPaymentMethod?> pushToBookingCardDetails(
    BookingPaymentMethod selectedMethod,
  ) => push<BookingPaymentMethod>(
    AppRoutes.bookingCardDetails,
    extra: selectedMethod,
  );

  Future<void> pushToBookingPaymentSuccess(
    BookingPaymentSuccessDetails details,
  ) => push(AppRoutes.bookingPaymentSuccess, extra: details);

  Future<bool?> pushToBookingReview(BookingOrderItem order) =>
      push<bool>(AppRoutes.bookingReview, extra: order);

  Future<void> pushToBookingTracking(BookingOrderItem order) =>
      push(AppRoutes.bookingTracking, extra: order);

  void goToForgotPassword() => go(AppRoutes.forgotPassword);

  void goToCheckEmail() => go(AppRoutes.checkEmail);

  void goToBookings() => go(AppRoutes.bookings);

  void goToWallet() => go(AppRoutes.wallet);

  void goToProfile() => go(AppRoutes.profile);

  Future<void> pushToMyProfile() => push(AppRoutes.myProfile);

  Future<bool?> pushToProfileEdit() => push<bool>(AppRoutes.profileEdit);

  void goToHome() {
    if (AuthSession.effectiveRole == AppUserRole.serviceProvider) {
      go(AppRoutes.serviceProviderHome);
      return;
    }

    go(AppRoutes.home);
  }
}
