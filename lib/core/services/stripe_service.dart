import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  StripeService._();

  static String get _secretKey => dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  /// Initialize Stripe — call this in main.dart
  static void initialize() {
    Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
    Stripe.merchantIdentifier = 'merchant.com.lavego.carwash';
  }

  /// Creates a PaymentIntent on Stripe and returns the clientSecret.
  static Future<String> _createPaymentIntent({
    required int amountInCents,
    required String currency,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': amountInCents.toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create payment intent: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['client_secret'] as String;
  }

  /// Shows Stripe payment sheet and processes payment.
  /// Throws StripeException if payment fails or is cancelled.
  static Future<void> processPayment({
    required double amount,
    required String currency,
    required String customerEmail,
    required String description,
  }) async {
    final amountInCents = (amount * 100).round();

    // Create payment intent
    final clientSecret = await _createPaymentIntent(
      amountInCents: amountInCents,
      currency: currency,
    );

    // Initialize payment sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'LaveGo Car Wash',
        billingDetails: BillingDetails(email: customerEmail),
        style: ThemeMode.system,
      ),
    );

    // Present payment sheet — throws StripeException if cancelled or failed
    await Stripe.instance.presentPaymentSheet();
  }
}
