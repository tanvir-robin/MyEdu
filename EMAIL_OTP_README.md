# Email OTP Verification System

This document describes the email OTP (One-Time Password) verification system implemented in the MyEdu application.

## Overview

The OTP verification system adds an extra layer of security to the user registration process. When a user signs up, they must verify their email address by entering a 6-digit OTP code sent to their email.

## Features

### 1. OTP Email Service (`lib/services/email_service.dart`)
- **Email Credentials**: Uses Gmail SMTP with the provided credentials
- **OTP Email**: Sends 6-digit OTP codes to user emails
- **Invoice Email**: Sends payment receipts as PDF attachments
- **Marksheet Email**: Sends academic marksheets as PDF attachments

### 2. OTP Verification Flow
1. User fills out the sign-up form
2. System validates form data
3. System generates a 6-digit OTP
4. OTP is sent to user's email address
5. User is redirected to OTP verification screen
6. User enters the OTP code
7. System verifies OTP and creates the account
8. User is redirected to dashboard

### 3. OTP Verification Screen (`lib/views/otp_verification_view.dart`)
- Clean, modern UI with animations
- 6-digit OTP input field with validation
- Resend OTP functionality with 60-second cooldown
- Error handling and user feedback
- Responsive design

### 4. Enhanced Auth Controller (`lib/controllers/auth_controller.dart`)
- OTP generation and validation
- Email sending integration
- Session management for OTP data
- Error handling and user feedback

## Email Service Methods

### `sendOtpEmail(String receiverEmail, String otp)`
Sends a 6-digit OTP code to the specified email address.

### `sendInvoiceEmail(String receiverEmail, File pdfFile)`
Sends a payment receipt PDF to the user's email.

### `sendMarksheetEmail(String receiverEmail, File pdfFile, String studentName)`
Sends an academic marksheet PDF to the student's email.

## PDF Services Integration

### PDF Marksheet Service
- `generateAndEmailComprehensiveMarksheet()`: Generates and emails comprehensive marksheets
- `generateAndEmailSemesterMarksheet()`: Generates and emails semester-specific marksheets

### PDF Receipt Service
- `generateAndEmailReceipt()`: Generates and emails payment receipts

## Security Features

1. **OTP Expiration**: OTP codes expire after 5 minutes
2. **Session Validation**: OTP is tied to the specific email and session
3. **Rate Limiting**: Resend functionality has a 60-second cooldown
4. **Input Validation**: OTP must be exactly 6 digits
5. **Error Handling**: Comprehensive error messages for various scenarios

## Configuration

### Email Settings
- **SMTP Server**: smtp.gmail.com
- **Port**: 465
- **SSL**: Enabled
- **Username**: tanvirrobin0@gmail.com
- **Password**: 4uhurwkwebgj

### OTP Settings
- **Length**: 6 digits
- **Expiration**: 5 minutes
- **Resend Cooldown**: 60 seconds

## Usage Examples

### Sending OTP for Sign-up
```dart
// In AuthController
await sendOtpEmail(userEmail);
```

### Verifying OTP and Creating Account
```dart
// In OTP verification screen
final success = await controller.verifyOtpAndSignUp(
  otp: otpCode,
  name: userName,
  email: userEmail,
  password: userPassword,
  faculty: userFaculty,
  id: userId,
  regi: userRegi,
  phone: userPhone,
);
```

### Sending PDF via Email
```dart
// Send marksheet
await PdfMarksheetService.generateAndEmailComprehensiveMarksheet(
  results, user
);

// Send receipt
await PdfReceiptService.generateAndEmailReceipt(
  fee: fee, user: user
);
```

## Error Handling

The system handles various error scenarios:
- Invalid OTP codes
- Expired OTP codes
- Email sending failures
- Network connectivity issues
- Invalid email addresses

## Future Enhancements

1. **SMS OTP**: Add SMS-based OTP as an alternative
2. **Email Templates**: Customizable email templates
3. **OTP History**: Track OTP usage and history
4. **Advanced Security**: Add CAPTCHA or other anti-bot measures
5. **Multi-language Support**: Support for multiple languages in emails

## Dependencies

- `mailer: ^6.0.1` - For email functionality
- `pdf: ^3.11.0` - For PDF generation
- `path_provider: ^2.1.2` - For file system access
- `get: ^4.7.2` - For state management and navigation

## Testing

Run the email service tests:
```bash
flutter test test/email_service_test.dart
```

## Notes

- The email service uses Gmail SMTP with app-specific passwords
- OTP codes are generated using Dart's Random class
- All email templates are HTML-based for better formatting
- PDF attachments are automatically generated and attached to emails
- The system is designed to be scalable and maintainable 