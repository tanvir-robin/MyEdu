import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import '../models/academic_fee_model.dart';
import '../models/user_model.dart';
import 'email_service.dart';

class PdfReceiptService {
  static final EmailService _emailService = EmailService();

  static Future<void> generateAndShowReceipt({
    required AcademicFeeModel fee,
    required UserModel user,
  }) async {
    final pdf = pw.Document();

    // Load custom font if available
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Main content
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header with University Name
                  _buildHeader(fontBold, font),
                  pw.SizedBox(height: 30),

                  // Receipt Title and Number
                  _buildReceiptTitle(fee, fontBold, font),
                  pw.SizedBox(height: 25),

                  // Student Information
                  _buildStudentInfo(user, fontBold, font),
                  pw.SizedBox(height: 25),

                  // Payment Details
                  _buildPaymentDetails(fee, fontBold, font),
                  pw.SizedBox(height: 25),

                  // Fee Items Table
                  _buildFeeItemsTable(fee, fontBold, font),
                  pw.SizedBox(height: 25),

                  // Total and Payment Info
                  _buildTotalSection(fee, fontBold, font),
                  pw.SizedBox(height: 30),

                  // Footer
                  _buildFooter(font),
                ],
              ),
              // Watermark
              _buildWatermark(),
            ],
          );
        },
      ),
    );

    // Save and open the PDF file
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/fee_receipt_${fee.receiptNumber}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      // Open the PDF file
      await OpenFile.open(file.path);
    } catch (e) {
      // Fallback to print preview if opening fails
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Fee_Receipt_${fee.receiptNumber}',
      );
    }
  }

  static pw.Widget _buildHeader(pw.Font fontBold, pw.Font font) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue800, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        gradient: const pw.LinearGradient(
          colors: [PdfColors.blue50, PdfColors.white],
          begin: pw.Alignment.topCenter,
          end: pw.Alignment.bottomCenter,
        ),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Patuakhali Science and Technology University',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 24,
              color: PdfColors.blue900,
              letterSpacing: 1.2,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Dumki, Patuakhali-8602, Bangladesh',
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              color: PdfColors.blue700,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Phone: +880-4427-56072, Email: info@pstu.ac.bd',
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              color: PdfColors.blue600,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildReceiptTitle(
    AcademicFeeModel fee,
    pw.Font fontBold,
    pw.Font font,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PAYMENT RECEIPT',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 20,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Academic Fee Payment',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 14,
                  color: PdfColors.blue700,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Receipt No.',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 12,
                  color: PdfColors.blue600,
                ),
              ),
              pw.Text(
                fee.receiptNumber ?? 'N/A',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 16,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Date: ${DateFormat('MMM dd, yyyy').format(fee.paidAt ?? DateTime.now())}',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 12,
                  color: PdfColors.blue700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStudentInfo(
    UserModel user,
    pw.Font fontBold,
    pw.Font font,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'STUDENT INFORMATION',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 16,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Name', user.name, fontBold, font),
                    _buildInfoRow('Student ID', user.id, fontBold, font),
                    _buildInfoRow('Registration', user.regi, fontBold, font),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Faculty', user.faculty, fontBold, font),
                    _buildInfoRow('Email', user.email, fontBold, font),
                    _buildInfoRow('Phone', user.phone, fontBold, font),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(
    String label,
    String value,
    pw.Font fontBold,
    pw.Font font,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                color: PdfColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPaymentDetails(
    AcademicFeeModel fee,
    pw.Font fontBold,
    pw.Font font,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PAYMENT DETAILS',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 16,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Purpose', fee.purpose, fontBold, font),
                    _buildInfoRow(
                      'Academic Year',
                      fee.academicYear,
                      fontBold,
                      font,
                    ),
                    _buildInfoRow('Semester', fee.semester, fontBold, font),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      'Due Date',
                      DateFormat('MMM dd, yyyy').format(fee.deadline),
                      fontBold,
                      font,
                    ),
                    _buildInfoRow(
                      'Payment Date',
                      DateFormat('MMM dd, yyyy').format(fee.paidAt!),
                      fontBold,
                      font,
                    ),
                    _buildInfoRow('Status', 'PAID', fontBold, font),
                  ],
                ),
              ),
            ],
          ),
          if (fee.description != null) ...[
            pw.SizedBox(height: 8),
            _buildInfoRow('Description', fee.description!, fontBold, font),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildFeeItemsTable(
    AcademicFeeModel fee,
    pw.Font fontBold,
    pw.Font font,
  ) {
    if (fee.items.isEmpty) {
      return pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(15),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'FEE BREAKDOWN',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 16,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  fee.purpose,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 14,
                    color: PdfColors.black,
                  ),
                ),
                pw.Text(
                  '৳${fee.amount.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 14,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(15),
            decoration: const pw.BoxDecoration(
              color: PdfColors.blue100,
              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Text(
              'FEE BREAKDOWN',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 16,
                color: PdfColors.blue900,
              ),
            ),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _buildTableCell('Description', fontBold, isHeader: true),
                  _buildTableCell('Amount (৳)', fontBold, isHeader: true),
                ],
              ),
              // Data rows
              ...fee.items.map(
                (item) => pw.TableRow(
                  children: [
                    _buildTableCell(
                      '${item.name}${item.description != null ? '\n${item.description}' : ''}',
                      font,
                    ),
                    _buildTableCell(item.amount.toStringAsFixed(2), font),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text,
    pw.Font font, {
    bool isHeader = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 12 : 11,
          color: isHeader ? PdfColors.blue900 : PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _buildTotalSection(
    AcademicFeeModel fee,
    pw.Font fontBold,
    pw.Font font,
  ) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue300, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        gradient: const pw.LinearGradient(
          colors: [PdfColors.blue50, PdfColors.white],
          begin: pw.Alignment.topCenter,
          end: pw.Alignment.bottomCenter,
        ),
      ),
      child: pw.Column(
        children: [
          if (fee.lateFee != null && fee.lateFee! > 0) ...[
            _buildTotalRow('Subtotal', fee.amount, fontBold, font, false),
            _buildTotalRow('Late Fee', fee.lateFee!, fontBold, font, false),
          ],
          if (fee.discount != null && fee.discount! > 0)
            _buildTotalRow('Discount', -fee.discount!, fontBold, font, false),
          _buildTotalRow('Total Amount', fee.totalAmount, fontBold, font, true),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRow(
    String label,
    double amount,
    pw.Font fontBold,
    pw.Font font,
    bool isTotal,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration:
          isTotal
              ? const pw.BoxDecoration(
                color: PdfColors.blue900,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
              )
              : null,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: isTotal ? fontBold : font,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? PdfColors.white : PdfColors.blue900,
            ),
          ),
          pw.Text(
            '৳${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? PdfColors.white : PdfColors.blue900,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Font font) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 15),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Generated on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now())}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'This is a computer generated receipt.',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'For queries, contact:',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  'accounts@pstu.ac.bd',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColors.blue700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildWatermark() {
    return pw.Positioned.fill(
      child: pw.Center(
        child: pw.Opacity(
          opacity: 0.1, // Simulate transparency
          child: pw.Transform.rotate(
            angle: 0.5, // ~-30 degrees
            child: pw.Text(
              'PAID',
              style: pw.TextStyle(
                fontSize: 200,
                color: PdfColors.red,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<File> saveReceiptPdf({
    required AcademicFeeModel fee,
    required UserModel user,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Main content
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader(fontBold, font),
                  pw.SizedBox(height: 30),
                  _buildReceiptTitle(fee, fontBold, font),
                  pw.SizedBox(height: 25),
                  _buildStudentInfo(user, fontBold, font),
                  pw.SizedBox(height: 25),
                  _buildPaymentDetails(fee, fontBold, font),
                  pw.SizedBox(height: 25),
                  _buildFeeItemsTable(fee, fontBold, font),
                  pw.SizedBox(height: 25),
                  _buildTotalSection(fee, fontBold, font),
                  pw.SizedBox(height: 30),
                  _buildFooter(font),
                ],
              ),
              // Watermark
              _buildWatermark(),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/receipt_${fee.receiptNumber}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // New method to generate and email receipt
  static Future<void> generateAndEmailReceipt({
    required AcademicFeeModel fee,
    required UserModel user,
  }) async {
    final pdf = pw.Document();

    // Load custom font if available
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Main content
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header with University Name
                  _buildHeader(fontBold, font),
                  pw.SizedBox(height: 30),

                  // Receipt Title and Number
                  _buildReceiptTitle(fee, fontBold, font),
                  pw.SizedBox(height: 25),

                  // Student Information
                  _buildStudentInfo(user, fontBold, font),
                  pw.SizedBox(height: 25),

                  // Payment Details
                  _buildPaymentDetails(fee, fontBold, font),
                  pw.SizedBox(height: 25),

                  // Fee Items Table
                  _buildFeeItemsTable(fee, fontBold, font),
                  pw.SizedBox(height: 25),

                  // Total and Payment Info
                  _buildTotalSection(fee, fontBold, font),
                  pw.SizedBox(height: 30),

                  // Footer
                  _buildFooter(font),
                ],
              ),
              // Watermark
              _buildWatermark(),
            ],
          );
        },
      ),
    );

    // Save PDF to file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/receipt_${fee.receiptNumber}.pdf');
    await file.writeAsBytes(await pdf.save());

    // Send email with receipt
    try {
      await _emailService.sendPaymentConfirmationEmail(
        receiverEmail: user.email,
        studentName: user.name,
        receiptNumber: fee.receiptNumber ?? 'N/A',
        amount: fee.totalAmount,
        purpose: fee.purpose,
        academicYear: fee.academicYear,
        semester: fee.semester,
        paymentDate: fee.paidAt ?? DateTime.now(),
        receiptPdf: file,
        paymentData: {
          'receipt_number': fee.receiptNumber,
          'amount': fee.totalAmount,
          'purpose': fee.purpose,
        },
      );

      // Format SMS message
      final message = Uri.encodeComponent(
        'Payment Confirmation: BDT ${fee.totalAmount.toStringAsFixed(2)} '
        'has been received for ${fee.purpose}. '
        'Receipt ID #${fee.receiptNumber ?? 'N/A'}. Thank you.\n'
        '-MyEdu (PSTU)',
      );

      // Send SMS notification
      final smsUrl =
          'http://bulksmsbd.net/api/smsapi?api_key=hYMFUDHeRp6chuAINbkZ'
          '&type=text&number=${user.phone}&senderid=8809617627045&message=$message';

      await http.get(Uri.parse(smsUrl));
      print('SMS sent successfully to ${user.phone}');
    } catch (e) {
      print('Failed to send payment confirmation email: $e');
      rethrow;
    }
  }
}
