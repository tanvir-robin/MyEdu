import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:io'; // Required for File

class EmailService {
  final String username = 'tanvirrobin0@gmail.com';
  final String password = 'fkvawdrjzgnklheb';

  // Method to send OTP email
  Future<void> sendOtpEmail(String receiverEmail, String otp) async {
    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      port: 465,
      ssl: true,
      username: username,
      password: password,
    );

    final message =
        Message()
          ..from = Address(username, 'MyEdu University')
          ..recipients.add(receiverEmail)
          ..subject = 'Your OTP Code for Account Verification'
          ..html = '''
    <div style="font-family: Helvetica,Arial,sans-serif;min-width:1000px;overflow:auto;line-height:2">
      <div style="margin:50px auto;width:70%;padding:20px 0">
        <div style="border-bottom:1px solid #eee">
          <a href="" style="font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">MyEdu University</a>
        </div>
        <p style="font-size:1.1em">Hi,</p>
        <p>Thank you for choosing MyEdu University. Use the following OTP to complete your Sign Up procedures. OTP is valid for 5 minutes</p>
        <h2 style="background: #00466a;margin: 0 auto;width: max-content;padding: 0 10px;color: #fff;border-radius: 4px;">$otp</h2>
        <p style="font-size:0.9em;">Regards,<br />MyEdu University</p>
        <hr style="border:none;border-top:1px solid #eee" />
        <div style="float:right;padding:8px 0;color:#aaa;font-size:0.8em;line-height:1;font-weight:300">
          <p>MyEdu University</p>
          <p>Bangladesh</p>
        </div>
      </div>
    </div>
    ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('OTP Email sent: $sendReport');
    } on MailerException catch (e) {
      print('OTP Email not sent. \n${e.toString()}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      rethrow;
    }
  }

  // Method to send invoice email with PDF attachment
  Future<void> sendInvoiceEmail(String receiverEmail, File pdfFile) async {
    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      port: 465,
      ssl: true,
      username: username,
      password: password,
    );

    // Create the email with PDF attachment
    final message =
        Message()
          ..from = Address(username, 'MyEdu University')
          ..recipients.add(receiverEmail)
          ..subject = 'Payment Receipt from MyEdu University'
          ..html = '''
      <div style="font-family: Helvetica,Arial,sans-serif;min-width:1000px;overflow:auto;line-height:2">
        <div style="margin:50px auto;width:70%;padding:20px 0">
          <div style="border-bottom:1px solid #eee">
            <a href="" style="font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">MyEdu University</a>
          </div>
          <p style="font-size:1.1em">Hi,</p>
          <p>Your payment to MyEdu University was successful. Please find your payment receipt attached as a PDF.</p>
          <p style="font-size:0.9em;">Regards,<br />MyEdu University</p>
          <hr style="border:none;border-top:1px solid #eee" />
          <div style="float:right;padding:8px 0;color:#aaa;font-size:0.8em;line-height:1;font-weight:300">
            <p>MyEdu University</p>
            <p>Dhaka, Bangladesh</p>
          </div>
        </div>
      </div>
      '''
          ..attachments.add(FileAttachment(pdfFile)); // Attach PDF file

    try {
      final sendReport = await send(message, smtpServer);
      print('Invoice Email sent: $sendReport');
    } on MailerException catch (e) {
      print('Invoice Email not sent. \n${e.toString()}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      rethrow;
    }
  }

  Future<void> sendMarksheetEmail(
    String receiverEmail,
    File pdfFile,
    String studentName,
  ) async {
    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      port: 465,
      ssl: true,
      username: username,
      password: password,
    );

    // Create the email with PDF attachment
    final message =
        Message()
          ..from = Address(username, 'MyEdu University')
          ..recipients.add(receiverEmail)
          ..subject = 'Your Academic Marksheet from MyEdu University'
          ..html = '''
      <div style="font-family: Helvetica,Arial,sans-serif;min-width:1000px;overflow:auto;line-height:2">
        <div style="margin:50px auto;width:70%;padding:20px 0">
          <div style="border-bottom:1px solid #eee">
            <a href="" style="font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">MyEdu University</a>
          </div>
          <p style="font-size:1.1em">Hi $studentName,</p>
          <p>Your academic marksheet is attached as a PDF. Please review it and keep it for your records.</p>
          <p style="font-size:0.9em;">Regards,<br />MyEdu University</p>
          <hr style="border:none;border-top:1px solid #eee" />
          <div style="float:right;padding:8px 0;color:#aaa;font-size:0.8em;line-height:1;font-weight:300">
            <p>MyEdu University</p>
            <p>Dhaka, Bangladesh</p>
          </div>
        </div>
      </div>
      '''
          ..attachments.add(FileAttachment(pdfFile)); // Attach PDF file

    try {
      final sendReport = await send(message, smtpServer);
      print('Marksheet Email sent: $sendReport');
    } on MailerException catch (e) {
      print('Marksheet Email not sent. \n${e.toString()}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      rethrow;
    }
  }

  Future<void> sendPaymentConfirmationEmail({
    required String receiverEmail,
    required String studentName,
    required String receiptNumber,
    required double amount,
    required String purpose,
    required String academicYear,
    required String semester,
    required DateTime paymentDate,
    required File receiptPdf,
    required Map<String, dynamic> paymentData,
  }) async {
    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      port: 465,
      ssl: true,
      username: username,
      password: password,
    );

    // Format payment date
    final formattedDate =
        '${paymentDate.day}/${paymentDate.month}/${paymentDate.year} at ${paymentDate.hour}:${paymentDate.minute.toString().padLeft(2, '0')}';

    // Format amount
    final formattedAmount = '৳${amount.toStringAsFixed(2)}';

    // Create the email with PDF attachment
    final message =
        Message()
          ..from = Address(username, 'MyEdu University')
          ..recipients.add(receiverEmail)
          ..subject = 'Payment Confirmation - Receipt #$receiptNumber'
          ..html = '''
      <div style="font-family: Helvetica,Arial,sans-serif;min-width:1000px;overflow:auto;line-height:2">
        <div style="margin:50px auto;width:70%;padding:20px 0">
          <div style="border-bottom:1px solid #eee">
            <a href="" style="font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">MyEdu University</a>
          </div>
          
          <h2 style="color: #00466a;margin: 20px 0;">Payment Confirmation</h2>
          
          <p style="font-size:1.1em">Dear $studentName,</p>
          
          <p>We are pleased to confirm that your payment has been successfully processed. Please find the details below:</p>
          
          <div style="background: #f8f9fa;padding: 20px;border-radius: 8px;margin: 20px 0;">
            <h3 style="color: #00466a;margin: 0 0 15px 0;">Payment Details</h3>
            <table style="width: 100%;border-collapse: collapse;">
              <tr>
                <td style="padding: 8px 0;font-weight: bold;color: #555;">Receipt Number:</td>
                <td style="padding: 8px 0;color: #333;">$receiptNumber</td>
              </tr>
              <tr>
                <td style="padding: 8px 0;font-weight: bold;color: #555;">Payment Date:</td>
                <td style="padding: 8px 0;color: #333;">$formattedDate</td>
              </tr>
              <tr>
                <td style="padding: 8px 0;font-weight: bold;color: #555;">Purpose:</td>
                <td style="padding: 8px 0;color: #333;">$purpose</td>
              </tr>
              <tr>
                <td style="padding: 8px 0;font-weight: bold;color: #555;">Academic Year:</td>
                <td style="padding: 8px 0;color: #333;">$academicYear</td>
              </tr>
              <tr>
                <td style="padding: 8px 0;font-weight: bold;color: #555;">Semester:</td>
                <td style="padding: 8px 0;color: #333;">$semester</td>
              </tr>
              <tr>
                <td style="padding: 8px 0;font-weight: bold;color: #555;">Amount Paid:</td>
                <td style="padding: 8px 0;color: #333;font-size: 1.1em;font-weight: bold;">$formattedAmount</td>
              </tr>
            </table>
          </div>
          
          <div style="background: #e8f5e8;padding: 15px;border-radius: 8px;margin: 20px 0;border-left: 4px solid #28a745;">
            <p style="margin: 0;color: #155724;font-weight: bold;">✓ Payment Status: Successfully Completed</p>
          </div>
          
          <p>Your official receipt is attached to this email as a PDF document. Please keep this receipt for your records.</p>
          
          <div style="background: #fff3cd;padding: 15px;border-radius: 8px;margin: 20px 0;border-left: 4px solid #ffc107;">
            <h4 style="margin: 0 0 10px 0;color: #856404;">Important Notes:</h4>
            <ul style="margin: 0;padding-left: 20px;color: #856404;">
              <li>This receipt serves as proof of payment</li>
              <li>Please retain this document for future reference</li>
              <li>For any queries, contact the accounts office</li>
            </ul>
          </div>
          
          <p style="font-size:0.9em;">Thank you for your payment.<br />Regards,<br />Accounts Department<br />MyEdu University</p>
          
          <hr style="border:none;border-top:1px solid #eee" />
          <div style="float:right;padding:8px 0;color:#aaa;font-size:0.8em;line-height:1;font-weight:300">
            <p>MyEdu University</p>
            <p>Dhaka, Bangladesh</p>
            <p>Phone: +880-4427-56072</p>
            <p>Email: accounts@myedu.edu.bd</p>
          </div>
        </div>
      </div>
      '''
          ..attachments.add(FileAttachment(receiptPdf)); // Attach PDF receipt

    try {
      final sendReport = await send(message, smtpServer);
      print('Payment Confirmation Email sent: $sendReport');
    } on MailerException catch (e) {
      print('Payment Confirmation Email not sent. \n${e.toString()}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      rethrow;
    }
  }
}
