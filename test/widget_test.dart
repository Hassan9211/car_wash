import 'package:car_wash/app.dart';
import 'package:car_wash/features/authentication/presentation/login_screen.dart';
import 'package:car_wash/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows validation errors on login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('home search filters providers and shows notification button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.byKey(const Key('home_notification_button')), findsOneWidget);
    expect(find.text('Ahmed'), findsOneWidget);
    expect(find.text('Youssef'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('home_search_input')), 'samir');
    await tester.pumpAndSettle();

    expect(find.text('Samir'), findsOneWidget);
    expect(find.text('Ahmed'), findsNothing);
    expect(find.text('Youssef'), findsNothing);
  });

  testWidgets('home provider cards do not overflow on narrow screen', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'shows splash then onboarding then auth flow and opens services',
    (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Lavego'), findsOneWidget);
    expect(find.byKey(const Key('splash_logo_badge')), findsOneWidget);
    expect(find.byKey(const Key('splash_progress')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to LaveGo!'), findsOneWidget);
    expect(find.byKey(const Key('onboarding_next_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding_next_button')));
    await tester.pumpAndSettle();

    expect(find.text('Book in Seconds'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding_next_button')));
    await tester.pumpAndSettle();

    expect(find.text('Track Your Washer.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding_next_button')));
    await tester.pumpAndSettle();

    expect(find.text('Choose Language'), findsOneWidget);
    expect(find.byKey(const Key('language_option_french')), findsOneWidget);
    expect(find.byKey(const Key('language_continue_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('language_continue_button')));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
    expect(find.byKey(const Key('login_email_field')), findsOneWidget);
    final loginEmailField = tester.widget<TextFormField>(
      find.descendant(
        of: find.byKey(const Key('login_email_field')),
        matching: find.byType(TextFormField),
      ),
    );
    expect(loginEmailField.controller?.text ?? '', isEmpty);

    await tester.tap(find.byKey(const Key('login_forgot_password_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('forgot_password_screen_title')), findsOneWidget);
    final forgotEmailField = tester.widget<TextFormField>(
      find.descendant(
        of: find.byKey(const Key('forgot_password_email_field')),
        matching: find.byType(TextFormField),
      ),
    );
    expect(forgotEmailField.controller?.text ?? '', isEmpty);

    await tester.tap(find.byKey(const Key('forgot_password_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('forgot_password_email_field')),
      'sam@example.com',
    );
    await tester.tap(find.byKey(const Key('forgot_password_submit_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('check_email_screen_title')), findsOneWidget);

    await tester.tap(find.byKey(const Key('check_email_back_to_login_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_screen_title')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('login_to_signup_link')));
    await tester.tap(find.byKey(const Key('login_to_signup_link')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('signup_screen_title')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('signup_name_field')), 'Sam');
    await tester.enterText(
      find.byKey(const Key('signup_email_field')),
      'sam@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('signup_password_field')),
      'secret123',
    );
    await tester.enterText(
      find.byKey(const Key('signup_repeat_password_field')),
      'secret123',
    );
    await tester.ensureVisible(find.byKey(const Key('signup_submit_button')));
    await tester.tap(find.byKey(const Key('signup_submit_button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Please agree to the Terms and Conditions'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('signup_terms_checkbox')));
    await tester.ensureVisible(find.byKey(const Key('signup_submit_button')));
    await tester.tap(find.byKey(const Key('signup_submit_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('otp_screen_title')), findsOneWidget);
    expect(find.byKey(const Key('otp_confirm_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('otp_confirm_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('otp_invalid_code_message')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('otp_digit_0')), '1');
    await tester.enterText(find.byKey(const Key('otp_digit_1')), '2');
    await tester.enterText(find.byKey(const Key('otp_digit_2')), '3');
    await tester.enterText(find.byKey(const Key('otp_digit_3')), '4');
    await tester.enterText(find.byKey(const Key('otp_digit_4')), '5');
    await tester.enterText(find.byKey(const Key('otp_digit_5')), '6');
    await tester.tap(find.byKey(const Key('otp_confirm_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('verification_complete_title')), findsOneWidget);

    await tester.tap(find.byKey(const Key('verification_continue_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('location_access_title')), findsOneWidget);

    await tester.tap(find.byKey(const Key('location_access_allow_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_location_label')), findsOneWidget);
    expect(find.byKey(const Key('home_search_bar')), findsOneWidget);
    expect(find.byKey(const Key('home_notification_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('home_notification_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('notifications_screen_title')), findsOneWidget);

    await tester.tap(find.byKey(const Key('notifications_back_button')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('provider_view_details_ahmed')),
    );
    await tester.tap(find.byKey(const Key('provider_view_details_ahmed')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('service_detail_provider_name')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('service_detail_book_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('booking_screen_title')), findsOneWidget);

    await tester.tap(find.byKey(const Key('booking_back_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('service_detail_back_button')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('home_services_see_all_button')));
    await tester.tap(find.byKey(const Key('home_services_see_all_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('services_screen_title')), findsOneWidget);
  });
}
