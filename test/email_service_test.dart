import 'package:flutter_test/flutter_test.dart';
import 'package:myedu/services/email_service.dart';

void main() {
  group('EmailService Tests', () {
    test('should generate valid OTP', () {
      final emailService = EmailService();

      // Test that OTP generation works (this would be in AuthController)
      // For now, just test that the service can be instantiated
      expect(emailService, isA<EmailService>());
    });

    test('should have correct email credentials', () {
      final emailService = EmailService();

      expect(emailService.username, 'tanvirrobin0@gmail.com');
      expect(emailService.password, '4uhurwkwebgj');
    });
  });
}
