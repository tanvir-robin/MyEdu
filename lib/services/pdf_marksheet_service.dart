import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/academic_result_model.dart';
import '../models/user_model.dart';
import 'email_service.dart';

class PdfMarksheetService {
  static final EmailService _emailService = EmailService();

  static Future<void> generateComprehensiveMarksheet(
    List<AcademicResultModel> results,
    UserModel user,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build:
            (context) => [
              _buildProfessionalHeader(user),
              _buildStudentDetailsSection(user),
              _buildAcademicSummarySection(results),
              _buildDetailedResultsSection(results),
              _buildGradeAnalysisSection(results),
              _buildFooter(),
            ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/comprehensive_marksheet_${user.name.replaceAll(' ', '_')}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);
  }

  static Future<void> generateSemesterMarksheet(
    AcademicResultModel result,
    UserModel user,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build:
            (context) => [
              _buildProfessionalHeader(user),
              _buildStudentDetailsSection(user),
              _buildSemesterSpecificSection(result),
              _buildCourseTable(result),
              _buildSemesterSummary(result),
              _buildFooter(),
            ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/semester_marksheet_${result.semester}_${result.academicYear}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);
  }

  // New method to generate and email comprehensive marksheet
  static Future<void> generateAndEmailComprehensiveMarksheet(
    List<AcademicResultModel> results,
    UserModel user,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build:
            (context) => [
              _buildProfessionalHeader(user),
              _buildStudentDetailsSection(user),
              _buildAcademicSummarySection(results),
              _buildDetailedResultsSection(results),
              _buildGradeAnalysisSection(results),
              _buildFooter(),
            ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/comprehensive_marksheet_${user.name.replaceAll(' ', '_')}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    // Send email with PDF attachment
    await _emailService.sendMarksheetEmail(user.email, file, user.name);
  }

  // New method to generate and email semester marksheet
  static Future<void> generateAndEmailSemesterMarksheet(
    AcademicResultModel result,
    UserModel user,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build:
            (context) => [
              _buildProfessionalHeader(user),
              _buildStudentDetailsSection(user),
              _buildSemesterSpecificSection(result),
              _buildCourseTable(result),
              _buildSemesterSummary(result),
              _buildFooter(),
            ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/semester_marksheet_${result.semester}_${result.academicYear}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    // Send email with PDF attachment
    await _emailService.sendMarksheetEmail(user.email, file, user.name);
  }

  static pw.Widget _buildProfessionalHeader(UserModel user) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.blue, PdfColors.indigo],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Container(
                width: 70,
                height: 70,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.white,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Center(
                  child: pw.Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: pw.TextStyle(
                      color: PdfColors.blue,
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 25),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'PSTU',
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    'Official Academic Transcript',
                    style: pw.TextStyle(
                      fontSize: 18,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                  pw.Text(
                    'Student ID: ${user.id}',
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.white),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Divider(color: PdfColors.white, thickness: 2),
        ],
      ),
    );
  }

  static pw.Widget _buildStudentDetailsSection(UserModel user) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: PdfColors.blue, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'STUDENT INFORMATION',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            children: [
              pw.Expanded(child: _buildInfoRow('Full Name', user.name)),
              pw.Expanded(child: _buildInfoRow('Student ID', user.id)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(child: _buildInfoRow('Registration No.', user.regi)),
              pw.Expanded(child: _buildInfoRow('Faculty', user.faculty)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(child: _buildInfoRow('Email', user.email)),
              pw.Expanded(child: _buildInfoRow('Phone', user.phone)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildInfoRow('Issue Date', _getCurrentDate()),
              ),
              pw.Expanded(
                child: _buildInfoRow('Document Type', 'Academic Transcript'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAcademicSummarySection(
    List<AcademicResultModel> results,
  ) {
    if (results.isEmpty) return pw.SizedBox();

    final totalGPA =
        results.map((r) => r.totalGPA).reduce((a, b) => a + b) / results.length;
    final totalCredits = results
        .map((r) => r.totalCredits)
        .reduce((a, b) => a + b);
    final totalCourses = results
        .map((r) => r.courses.length)
        .reduce((a, b) => a + b);

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: PdfColors.blue, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ACADEMIC SUMMARY',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryCard(
                'Overall GPA',
                totalGPA.toStringAsFixed(2),
                '4.00',
                PdfColors.green,
              ),
              _buildSummaryCard(
                'Total Credits',
                totalCredits.toStringAsFixed(1),
                '${(results.length * 15).toStringAsFixed(1)}',
                PdfColors.blue,
              ),
              _buildSummaryCard(
                'Total Courses',
                totalCourses.toString(),
                '${results.length * 5}',
                PdfColors.purple,
              ),
              _buildSummaryCard(
                'Semesters',
                results.length.toString(),
                '${results.length}',
                PdfColors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDetailedResultsSection(
    List<AcademicResultModel> results,
  ) {
    if (results.isEmpty) return pw.SizedBox();

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DETAILED ACADEMIC RESULTS',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 15),
          ...results.map((result) => _buildSemesterResultCard(result)).toList(),
        ],
      ),
    );
  }

  static pw.Widget _buildSemesterResultCard(AcademicResultModel result) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${result.semester} Semester - ${result.academicYear}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  color: _getGPAColor(result.totalGPA),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(15),
                  ),
                ),
                child: pw.Text(
                  'GPA: ${result.totalGPA.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          _buildCourseTable(result),
        ],
      ),
    );
  }

  static pw.Widget _buildSemesterSpecificSection(AcademicResultModel result) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: PdfColors.blue, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SEMESTER PERFORMANCE',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryCard(
                'Semester GPA',
                result.totalGPA.toStringAsFixed(2),
                '4.00',
                PdfColors.green,
              ),
              _buildSummaryCard(
                'Total Credits',
                result.totalCredits.toStringAsFixed(1),
                '15.0',
                PdfColors.blue,
              ),
              _buildSummaryCard(
                'Courses Completed',
                result.courses.length.toString(),
                '5',
                PdfColors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCourseTable(AcademicResultModel result) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.blue, width: 1),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.2),
        1: pw.FlexColumnWidth(2.8),
        2: pw.FlexColumnWidth(0.8),
        3: pw.FlexColumnWidth(0.8),
        4: pw.FlexColumnWidth(0.8),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue),
          children: [
            _buildTableHeader('Course ID'),
            _buildTableHeader('Course Name'),
            _buildTableHeader('Credit'),
            _buildTableHeader('Grade'),
            _buildTableHeader('GPA'),
          ],
        ),
        // Data rows
        ...result.courses
            .map(
              (course) => pw.TableRow(
                children: [
                  _buildTableCell(course.courseId, isBold: true),
                  _buildTableCell(course.courseName),
                  _buildTableCell(course.credit),
                  _buildTableCell(
                    course.grade,
                    color: _getGradeColor(course.grade),
                  ),
                  _buildTableCell(course.gpa),
                ],
              ),
            )
            .toList(),
      ],
    );
  }

  static pw.Widget _buildGradeAnalysisSection(
    List<AcademicResultModel> results,
  ) {
    if (results.isEmpty) return pw.SizedBox();

    Map<String, int> overallDistribution = {};
    for (var result in results) {
      for (var entry in result.gradeDistribution.entries) {
        overallDistribution[entry.key] =
            (overallDistribution[entry.key] ?? 0) + entry.value;
      }
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: PdfColors.grey, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'GRADE DISTRIBUTION ANALYSIS',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children:
                overallDistribution.entries
                    .map(
                      (entry) =>
                          _buildGradeCard(entry.key, entry.value.toString()),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSemesterSummary(AcademicResultModel result) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: PdfColors.grey, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SEMESTER SUMMARY',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children:
                result.gradeDistribution.entries
                    .map(
                      (entry) =>
                          _buildGradeCard(entry.key, entry.value.toString()),
                    )
                    .toList(),
          ),
          pw.SizedBox(height: 15),
          pw.Divider(color: PdfColors.grey),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Semester GPA:',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                result.totalGPA.toStringAsFixed(2),
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
            fontWeight: pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryCard(
    String title,
    String value,
    String max,
    PdfColor color,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: color, width: 1),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
              fontWeight: pw.FontWeight.normal,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.Text(
            'Max: $max',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isBold = false,
    PdfColor? color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: color ?? PdfColors.black,
          fontSize: 9,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildGradeCard(String grade, String count) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _getGradeColor(grade), width: 1),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            grade,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _getGradeColor(grade),
            ),
          ),
          pw.Text(
            count,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 30),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Registrar',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Patuakhali Science and Technology University',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    'Date: ${_getCurrentDate()}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ],
              ),
              pw.Container(
                width: 100,
                height: 50,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey, width: 1),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(5),
                  ),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'OFFICIAL\nSTAMP',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'This is an official academic transcript issued by the University of Excellence. '
            'Any alteration or modification of this document is strictly prohibited. '
            'This document contains sensitive academic information and should be handled with confidentiality.',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static PdfColor _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':
        return PdfColors.green;
      case 'A-':
      case 'B+':
        return PdfColors.lightGreen;
      case 'B':
        return PdfColors.blue;
      case 'B-':
      case 'C+':
        return PdfColors.orange;
      case 'C':
        return PdfColors.deepOrange;
      case 'C-':
      case 'D+':
      case 'D':
        return PdfColors.red;
      case 'F':
        return PdfColors.red900;
      default:
        return PdfColors.grey;
    }
  }

  static PdfColor _getGPAColor(double gpa) {
    if (gpa >= 3.7) return PdfColors.green;
    if (gpa >= 3.3) return PdfColors.lightGreen;
    if (gpa >= 3.0) return PdfColors.blue;
    if (gpa >= 2.7) return PdfColors.orange;
    if (gpa >= 2.0) return PdfColors.deepOrange;
    return PdfColors.red;
  }

  static String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }
}
