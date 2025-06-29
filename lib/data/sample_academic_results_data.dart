import '../models/academic_result_model.dart';

class SampleAcademicResultsData {
  static List<Map<String, dynamic>> sampleResults = [
    {
      'studentId': '2002010',
      'studentName': 'John Doe',
      'semester': '6th',
      'academicYear': '2023-24',
      'department': 'Computer Science & Engineering',
      'courses': [
        {
          'courseId': 'CSE-601',
          'courseName': 'Advanced Database Management',
          'credit': '3.0',
          'grade': 'A',
          'gpa': '4.0',
        },
        {
          'courseId': 'CSE-602',
          'courseName': 'Software Engineering',
          'credit': '3.0',
          'grade': 'A-',
          'gpa': '3.7',
        },
        {
          'courseId': 'CSE-603',
          'courseName': 'Computer Networks',
          'credit': '3.0',
          'grade': 'B+',
          'gpa': '3.3',
        },
        {
          'courseId': 'CSE-604',
          'courseName': 'Artificial Intelligence',
          'credit': '3.0',
          'grade': 'A',
          'gpa': '4.0',
        },
        {
          'courseId': 'CSE-605',
          'courseName': 'Web Development',
          'credit': '3.0',
          'grade': 'A-',
          'gpa': '3.7',
        },
      ],
    },
    {
      'studentId': '2002010',
      'studentName': 'John Doe',
      'semester': '5th',
      'academicYear': '2022-23',
      'department': 'Computer Science & Engineering',
      'courses': [
        {
          'courseId': 'CSE-501',
          'courseName': 'Data Structures & Algorithms',
          'credit': '3.0',
          'grade': 'A',
          'gpa': '4.0',
        },
        {
          'courseId': 'CSE-502',
          'courseName': 'Object Oriented Programming',
          'credit': '3.0',
          'grade': 'A-',
          'gpa': '3.7',
        },
        {
          'courseId': 'CSE-503',
          'courseName': 'Operating Systems',
          'credit': '3.0',
          'grade': 'B+',
          'gpa': '3.3',
        },
        {
          'courseId': 'CSE-504',
          'courseName': 'Computer Architecture',
          'credit': '3.0',
          'grade': 'A',
          'gpa': '4.0',
        },
        {
          'courseId': 'CSE-505',
          'courseName': 'Digital Logic Design',
          'credit': '3.0',
          'grade': 'A-',
          'gpa': '3.7',
        },
      ],
    },
  ];

  static List<AcademicResultModel> getSampleAcademicResults() {
    return sampleResults.map((data) {
      return AcademicResultModel.fromMap(
        'sample_${data['semester']}_${data['academicYear']}',
        data,
      );
    }).toList();
  }
}
