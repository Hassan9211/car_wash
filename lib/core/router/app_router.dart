import 'package:car_wash/core/router/app_routes.dart';
import 'package:car_wash/core/location/app_location_details.dart';
import 'package:car_wash/features/authentication/presentation/check_email_screen.dart';
import 'package:car_wash/features/authentication/presentation/forgot_password_screen.dart';
import 'package:car_wash/features/authentication/presentation/login_screen.dart';
import 'package:car_wash/features/authentication/presentation/otp_verification_screen.dart';
import 'package:car_wash/features/authentication/presentation/role_selection_screen.dart';
import 'package:car_wash/features/authentication/presentation/signup_screen.dart';
import 'package:car_wash/features/authentication/presentation/verification_complete_screen.dart';
import 'package:car_wash/features/home/data/provider_catalog.dart';
import 'package:car_wash/features/home/booking/model/booking_flow_details.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:car_wash/features/home/booking/model/booking_payment_method.dart';
import 'package:car_wash/features/home/booking/model/booking_payment_success_details.dart';
import 'package:car_wash/features/home/booking/presentation/booking_card_details_screen.dart';
import 'package:car_wash/features/home/booking/presentation/booking_checkout_screen.dart';
import 'package:car_wash/features/home/booking/presentation/bookings_screen.dart';
import 'package:car_wash/features/home/booking/presentation/booking_payment_success_screen.dart';
import 'package:car_wash/features/home/booking/presentation/booking_review_screen.dart';
import 'package:car_wash/features/home/booking/presentation/booking_screen.dart';
import 'package:car_wash/features/home/booking/presentation/booking_tracking_screen.dart';
import 'package:car_wash/features/home/booking/presentation/booking_location_screen.dart';
import 'package:car_wash/features/home/booking/presentation/booking_payment_screen.dart';
import 'package:car_wash/features/home/booking/presentation/booking_payment_method_screen.dart';
import 'package:car_wash/features/home/booking/presentation/booking_schedule_screen.dart';
import 'package:car_wash/features/home/model/service_provider_profile.dart';
import 'package:car_wash/features/home/presentation/edit_profile_screen.dart';
import 'package:car_wash/features/home/presentation/home_screen.dart';
import 'package:car_wash/features/home/presentation/my_profile_screen.dart';
import 'package:car_wash/features/home/presentation/profile_support_screens.dart';
import 'package:car_wash/features/home/presentation/profile_screen.dart';
import 'package:car_wash/features/home/presentation/service_detail_screen.dart';
import 'package:car_wash/features/home/presentation/wallet_screen.dart';
import 'package:car_wash/features/language/presentation/language_screen.dart';
import 'package:car_wash/features/location/presentation/location_access_screen.dart';
import 'package:car_wash/features/notifications/presentation/notifications_screen.dart';
import 'package:car_wash/features/onboarding/presentation/onboarding_screen.dart';
import 'package:car_wash/features/services/presentation/services_screen.dart';
import 'package:car_wash/features/splash/presentation/splash_screen.dart';
import 'package:car_wash/features/washer/presentation/service_provider_setup_screen.dart';
import 'package:car_wash/features/washer/presentation/service_provider_bookings_screen.dart';
import 'package:car_wash/features/washer/presentation/service_provider_home_screen.dart';
import 'package:car_wash/features/washer/presentation/service_provider_payment_history_screen.dart';
import 'package:car_wash/features/washer/presentation/service_provider_profile_screen.dart';
import 'package:car_wash/features/washer/presentation/service_provider_settings_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.otpVerification,
      builder: (context, state) => const OtpVerificationScreen(),
    ),
    GoRoute(
      path: AppRoutes.verificationComplete,
      builder: (context, state) => const VerificationCompleteScreen(),
    ),
    GoRoute(
      path: AppRoutes.locationAccess,
      builder: (context, state) => const LocationAccessScreen(),
    ),
    GoRoute(
      path: AppRoutes.serviceProviderSetup,
      builder: (context, state) => const ServiceProviderSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.serviceProviderHome,
      builder: (context, state) => const ServiceProviderHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.serviceProviderBookings,
      builder: (context, state) => const ServiceProviderBookingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.serviceProviderPaymentHistory,
      builder: (context, state) => const ServiceProviderPaymentHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.serviceProviderProfile,
      builder: (context, state) => const ServiceProviderProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.serviceProviderSettings,
      builder: (context, state) => const ServiceProviderSettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.checkEmail,
      builder: (context, state) => const CheckEmailScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.bookings,
      builder: (context, state) => const BookingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.wallet,
      builder: (context, state) => const WalletScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.myProfile,
      builder: (context, state) => const MyProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.privacyPolicy,
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: AppRoutes.termsConditions,
      builder: (context, state) => const TermsConditionsScreen(),
    ),
    GoRoute(
      path: AppRoutes.helpCenter,
      builder: (context, state) => const HelpCenterScreen(),
    ),
    GoRoute(
      path: AppRoutes.profileEdit,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.serviceDetail,
      builder: (context, state) => ServiceDetailScreen(
        provider: state.extra is ServiceProviderProfile
            ? state.extra! as ServiceProviderProfile
            : ProviderCatalog.fallbackProvider,
      ),
    ),
    GoRoute(
      path: AppRoutes.booking,
      builder: (context, state) => BookingScreen(
        provider: state.extra is ServiceProviderProfile
            ? state.extra! as ServiceProviderProfile
            : ProviderCatalog.fallbackProvider,
      ),
    ),
    GoRoute(
      path: AppRoutes.bookingLocation,
      builder: (context, state) => BookingLocationScreen(
        initialLocation: state.extra is AppLocationDetails
            ? state.extra! as AppLocationDetails
            : null,
      ),
    ),
    GoRoute(
      path: AppRoutes.bookingSchedule,
      builder: (context, state) => BookingScheduleScreen(
        details: state.extra is BookingFlowDetails
            ? state.extra! as BookingFlowDetails
            : BookingFlowDetails(provider: ProviderCatalog.fallbackProvider),
      ),
    ),
    GoRoute(
      path: AppRoutes.bookingPayment,
      builder: (context, state) => BookingPaymentScreen(
        details: state.extra is BookingFlowDetails
            ? state.extra! as BookingFlowDetails
            : BookingFlowDetails(provider: ProviderCatalog.fallbackProvider),
      ),
    ),
    GoRoute(
      path: AppRoutes.bookingCheckout,
      builder: (context, state) => BookingCheckoutScreen(
        details: state.extra is BookingFlowDetails
            ? state.extra! as BookingFlowDetails
            : BookingFlowDetails(provider: ProviderCatalog.fallbackProvider),
      ),
    ),
    GoRoute(
      path: AppRoutes.bookingPaymentMethod,
      builder: (context, state) => BookingPaymentMethodScreen(
        selectedMethod: state.extra is BookingPaymentMethod
            ? state.extra! as BookingPaymentMethod
            : BookingPaymentMethod.creditCard,
      ),
    ),
    GoRoute(
      path: AppRoutes.bookingCardDetails,
      builder: (context, state) => BookingCardDetailsScreen(
        initialMethod: state.extra is BookingPaymentMethod
            ? state.extra! as BookingPaymentMethod
            : BookingPaymentMethod.creditCard,
      ),
    ),
    GoRoute(
      path: AppRoutes.bookingPaymentSuccess,
      builder: (context, state) => BookingPaymentSuccessScreen(
        details: state.extra is BookingPaymentSuccessDetails
            ? state.extra! as BookingPaymentSuccessDetails
            : BookingPaymentSuccessDetails.fallback,
      ),
    ),
    GoRoute(
      path: AppRoutes.bookingReview,
      builder: (context, state) => BookingReviewScreen(
        order: state.extra is BookingOrderItem
            ? state.extra! as BookingOrderItem
            : BookingOrderItem(
                id: 'fallback_review_order',
                status: BookingOrderStatus.completed,
                orderDate: DateTime(2026, 4, 7),
                paymentDate: DateTime(2026, 4, 7, 15, 20),
                rating: '5.0',
                reviews: '13.7K',
                totalPayment: '\$45.00',
                serviceProviderName: 'Ahmed',
                serviceType: 'Basic wash',
                customerName: 'Customer',
              ),
      ),
    ),
    GoRoute(
      path: AppRoutes.bookingTracking,
      builder: (context, state) => BookingTrackingScreen(
        order: state.extra is BookingOrderItem
            ? state.extra! as BookingOrderItem
            : BookingOrderItem(
                id: 'fallback_tracking_order',
                status: BookingOrderStatus.inProgress,
                orderDate: DateTime(2026, 4, 7),
                paymentDate: DateTime(2026, 4, 7, 15, 20),
                rating: '5.0',
                reviews: '13.7K',
                totalPayment: '\$45.00',
                serviceProviderName: 'Ahmed',
                serviceType: 'Basic wash',
                customerName: 'Customer',
              ),
      ),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.services,
      builder: (context, state) => const ServicesScreen(),
    ),
    GoRoute(
      path: AppRoutes.language,
      builder: (context, state) => const LanguageScreen(),
    ),
    GoRoute(
      path: AppRoutes.roleSelection,
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
  ],
);
