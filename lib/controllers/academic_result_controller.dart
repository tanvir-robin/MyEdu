import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/academic_result_model.dart';

class AcademicResultController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<AcademicResultModel> academicResults =
      <AcademicResultModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedSemester = 'all'.obs;
  final RxString selectedYear = 'all'.obs;

  // Statistics
  final RxDouble overallGPA = 0.0.obs;
  final RxDouble totalCredits = 0.0.obs;
  final RxInt totalCourses = 0.obs;
  final RxMap<String, int> gradeDistribution = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAcademicResults();
  }

  Future<void> fetchAcademicResults() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('Fetching academic results from Firestore...');

      // Query results for studentId "2002010"
      QuerySnapshot snapshot =
          await _firestore
              .collection('results')
              .where('studentId', isEqualTo: '2002010')
              .get();

      print('Found ${snapshot.docs.length} result documents');

      final results =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            print('Document ${doc.id}: $data');
            return AcademicResultModel.fromMap(doc.id, data);
          }).toList();

      academicResults.value = results;
      _calculateStatistics();

      print('Successfully loaded ${results.length} results');
    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to fetch academic results: $e';
      print('Error fetching results: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load academic results: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStatistics() {
    if (academicResults.isEmpty) {
      overallGPA.value = 0.0;
      totalCredits.value = 0.0;
      totalCourses.value = 0;
      gradeDistribution.value = {};
      return;
    }

    double totalGPA = 0.0;
    double totalCreditsSum = 0.0;
    int totalCoursesCount = 0;
    Map<String, int> distribution = {};

    for (var result in academicResults) {
      totalGPA += result.totalGPA;
      totalCreditsSum += result.totalCredits;
      totalCoursesCount += result.courses.length;

      // Merge grade distributions
      for (var entry in result.gradeDistribution.entries) {
        distribution[entry.key] = (distribution[entry.key] ?? 0) + entry.value;
      }
    }

    overallGPA.value = totalGPA / academicResults.length;
    totalCredits.value = totalCreditsSum;
    totalCourses.value = totalCoursesCount;
    gradeDistribution.value = distribution;
  }

  List<AcademicResultModel> get filteredResults {
    return academicResults.where((result) {
      // Semester filter
      if (selectedSemester.value != 'all' &&
          result.semester != selectedSemester.value) {
        return false;
      }

      // Year filter
      if (selectedYear.value != 'all' &&
          result.academicYear != selectedYear.value) {
        return false;
      }

      return true;
    }).toList();
  }

  List<String> get availableSemesters {
    Set<String> semesters = {};
    for (var result in academicResults) {
      if (result.semester.isNotEmpty) {
        semesters.add(result.semester);
      }
    }
    return ['all', ...semesters.toList()..sort()];
  }

  List<String> get availableYears {
    Set<String> years = {};
    for (var result in academicResults) {
      if (result.academicYear.isNotEmpty) {
        years.add(result.academicYear);
      }
    }
    return ['all', ...years.toList()..sort()];
  }

  void setSemesterFilter(String semester) {
    selectedSemester.value = semester;
  }

  void setYearFilter(String year) {
    selectedYear.value = year;
  }

  void refreshResults() {
    fetchAcademicResults();
  }

  // Get color for grade
  Color getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'A-':
      case 'B+':
        return Colors.lightGreen;
      case 'B':
        return Colors.blue;
      case 'B-':
      case 'C+':
        return Colors.orange;
      case 'C':
        return Colors.deepOrange;
      case 'C-':
      case 'D+':
      case 'D':
        return Colors.red;
      case 'F':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  // Get GPA color
  Color getGPAColor(double gpa) {
    if (gpa >= 3.7) return Colors.green;
    if (gpa >= 3.3) return Colors.lightGreen;
    if (gpa >= 3.0) return Colors.blue;
    if (gpa >= 2.7) return Colors.orange;
    if (gpa >= 2.0) return Colors.deepOrange;
    return Colors.red;
  }
}
