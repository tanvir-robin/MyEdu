class CourseResult {
  final String courseId;
  final String courseName;
  final String credit;
  final String grade;
  final String gpa;

  CourseResult({
    required this.courseId,
    required this.courseName,
    required this.credit,
    required this.grade,
    required this.gpa,
  });

  factory CourseResult.fromMap(Map<String, dynamic> map) {
    return CourseResult(
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      credit: map['credit']?.toString() ?? '',
      grade: map['grade'] ?? '',
      gpa: map['gpa']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'credit': credit,
      'grade': grade,
      'gpa': gpa,
    };
  }
}

class AcademicResultModel {
  final String id;
  final String studentId;
  final String studentName;
  final String semester;
  final String academicYear;
  final String department;
  final List<CourseResult> courses;

  AcademicResultModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.semester,
    required this.academicYear,
    required this.department,
    required this.courses,
  });

  // Calculate total GPA
  double get totalGPA {
    if (courses.isEmpty) return 0.0;

    double totalGPA = 0.0;
    double totalCredits = 0.0;

    for (var course in courses) {
      double gpa = double.tryParse(course.gpa) ?? 0.0;
      double credit = double.tryParse(course.credit) ?? 0.0;

      totalGPA += gpa * credit;
      totalCredits += credit;
    }

    return totalCredits > 0 ? totalGPA / totalCredits : 0.0;
  }

  // Calculate total credits
  double get totalCredits {
    return courses.fold(
      0.0,
      (total, course) => total + (double.tryParse(course.credit) ?? 0.0),
    );
  }

  // Get grade distribution
  Map<String, int> get gradeDistribution {
    Map<String, int> distribution = {};
    for (var course in courses) {
      distribution[course.grade] = (distribution[course.grade] ?? 0) + 1;
    }
    return distribution;
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'semester': semester,
      'academicYear': academicYear,
      'department': department,
      'courses': courses.map((course) => course.toMap()).toList(),
    };
  }

  // Create from Firestore Map
  factory AcademicResultModel.fromMap(String docId, Map<String, dynamic> map) {
    return AcademicResultModel(
      id: docId,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      semester: map['semester'] ?? '',
      academicYear: map['academicYear'] ?? '',
      department: map['department'] ?? '',
      courses: _parseCourses(map['courses'] ?? []),
    );
  }

  static List<CourseResult> _parseCourses(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((course) => CourseResult.fromMap(course)).toList();
    }
    return [];
  }
}
