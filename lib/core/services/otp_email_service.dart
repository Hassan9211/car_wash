import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class OtpEmailService {
  OtpEmailService._();

  // Signup verification OTP
  static String? _signupOtp;
  static String? _signupOtpEmail;

  // Password reset OTP
  static String? _resetOtp;
  static String? _resetOtpEmail;

  /// Generates a 6-digit OTP, stores it, and sends it to [email] for signup.
  static Future<void> sendOtp(String email) async {
    _signupOtp = _generateOtp();
    _signupOtpEmail = email.trim().toLowerCase();

    final smtpEmail = dotenv.env['SMTP_EMAIL'] ?? '';
    final smtpPassword = dotenv.env['SMTP_PASSWORD'] ?? '';
    final smtpServer = gmail(smtpEmail, smtpPassword);

    final message = Message()
      ..from = Address(smtpEmail, 'CarWash App')
      ..recipients.add(email)
      ..subject = 'Your CarWash Verification Code'
      ..html = _buildOtpEmailHtml(_signupOtp!);

    await send(message, smtpServer);
  }

  /// Sends a password reset OTP to [email].
  static Future<void> sendPasswordResetLink(String email) async {
    _resetOtp = _generateOtp();
    _resetOtpEmail = email.trim().toLowerCase();

    final smtpEmail = dotenv.env['SMTP_EMAIL'] ?? '';
    final smtpPassword = dotenv.env['SMTP_PASSWORD'] ?? '';
    final smtpServer = gmail(smtpEmail, smtpPassword);

    final message = Message()
      ..from = Address(smtpEmail, 'CarWash App')
      ..recipients.add(email)
      ..subject = 'Reset Your CarWash Password'
      ..html = _buildResetOtpEmailHtml(_resetOtp!);

    await send(message, smtpServer);
  }

  /// Verifies signup OTP for [email].
  static bool verifyOtp(String email, String enteredOtp) {
    if (_signupOtp == null || _signupOtpEmail == null) return false;
    return _signupOtpEmail == email.trim().toLowerCase() &&
        _signupOtp == enteredOtp.trim();
  }

  /// Verifies password reset OTP for [email].
  static bool verifyResetOtp(String email, String enteredOtp) {
    if (_resetOtp == null || _resetOtpEmail == null) return false;
    return _resetOtpEmail == email.trim().toLowerCase() &&
        _resetOtp == enteredOtp.trim();
  }

  /// Clears signup OTP after successful verification.
  static void clearOtp() {
    _signupOtp = null;
    _signupOtpEmail = null;
  }

  /// Clears reset OTP after successful verification.
  static void clearResetOtp() {
    _resetOtp = null;
    _resetOtpEmail = null;
  }

  /// Sends a booking notification email to the service provider.
  static Future<void> sendBookingNotificationEmail({
    required String toEmail,
    required String providerName,
    required String customerName,
    required String serviceType,
    required String bookingTime,
  }) async {
    final smtpEmail = dotenv.env['SMTP_EMAIL'] ?? '';
    final smtpPassword = dotenv.env['SMTP_PASSWORD'] ?? '';
    final smtpServer = gmail(smtpEmail, smtpPassword);

    final message = Message()
      ..from = Address(smtpEmail, 'CarWash App')
      ..recipients.add(toEmail)
      ..subject = 'New Booking — $serviceType'
      ..html = _buildBookingEmailHtml(
        providerName: providerName,
        customerName: customerName,
        serviceType: serviceType,
        bookingTime: bookingTime,
      );

    await send(message, smtpServer);
  }

  static String _generateOtp() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  static String _buildOtpEmailHtml(String otp) {
    return '''
<!DOCTYPE html>
<html>
  <body style="font-family: Arial, sans-serif; background: #f4f4f4; padding: 30px;">
    <div style="max-width: 400px; margin: auto; background: white; border-radius: 12px; padding: 30px; text-align: center;">
      <h2 style="color: #2e7d32;">CarWash Verification</h2>
      <p style="color: #555;">Use the code below to verify your account:</p>
      <div style="font-size: 36px; font-weight: bold; letter-spacing: 10px; color: #2e7d32; margin: 20px 0;">
        $otp
      </div>
      <p style="color: #999; font-size: 13px;">This code expires in 10 minutes. Do not share it with anyone.</p>
    </div>
  </body>
</html>
''';
  }

  static String _buildResetOtpEmailHtml(String otp) {
    return '''
<!DOCTYPE html>
<html>
  <body style="font-family: Arial, sans-serif; background: #f4f4f4; padding: 30px;">
    <div style="max-width: 400px; margin: auto; background: white; border-radius: 12px; padding: 30px; text-align: center;">
      <h2 style="color: #2e7d32;">Reset Your Password</h2>
      <p style="color: #555;">Use the code below to reset your CarWash account password:</p>
      <div style="font-size: 36px; font-weight: bold; letter-spacing: 10px; color: #2e7d32; margin: 20px 0;">
        $otp
      </div>
      <p style="color: #999; font-size: 13px;">This code expires in 10 minutes. If you did not request this, ignore this email.</p>
    </div>
  </body>
</html>
''';
  }

  static String _buildBookingEmailHtml({
    required String providerName,
    required String customerName,
    required String serviceType,
    required String bookingTime,
  }) {
    return '''
<!DOCTYPE html>
<html>
  <body style="font-family: Arial, sans-serif; background: #f4f4f4; padding: 30px;">
    <div style="max-width: 420px; margin: auto; background: white; border-radius: 12px; padding: 30px;">
      <h2 style="color: #2e7d32; text-align: center;">New Booking Request</h2>
      <p style="color: #555;">Hi <strong>$providerName</strong>, you have a new booking!</p>
      <table style="width: 100%; border-collapse: collapse; margin-top: 16px;">
        <tr>
          <td style="padding: 10px; background: #f9f9f9; border-radius: 6px; color: #888; font-size: 13px;">Customer</td>
          <td style="padding: 10px; font-weight: bold; color: #222;">$customerName</td>
        </tr>
        <tr>
          <td style="padding: 10px; color: #888; font-size: 13px;">Service</td>
          <td style="padding: 10px; font-weight: bold; color: #222;">$serviceType</td>
        </tr>
        <tr>
          <td style="padding: 10px; background: #f9f9f9; border-radius: 6px; color: #888; font-size: 13px;">Time</td>
          <td style="padding: 10px; font-weight: bold; color: #2e7d32;">$bookingTime</td>
        </tr>
      </table>
      <p style="color: #999; font-size: 12px; margin-top: 20px; text-align: center;">Open the CarWash app to accept or manage this booking.</p>
    </div>
  </body>
</html>
''';
  }
}
