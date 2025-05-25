import 'package:cloud_firestore/cloud_firestore.dart';

enum FeeStatus { pending, paid, overdue }

enum FeeType {
  tuition,
  registration,
  exam,
  library,
  laboratory,
  sports,
  development,
  miscellaneous,
}

class FeeItem {
  final String name;
  final double amount;
  final String? description;

  FeeItem({required this.name, required this.amount, this.description});

  factory FeeItem.fromMap(Map<String, dynamic> map) {
    return FeeItem(
      name: map['detail'] ?? '',
      amount: _parseAmount(map['amount'] ?? 0),
      description: map['description'],
    );
  }

  static double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is String) {
      final cleanValue = value.replaceAll(RegExp(r'[৳$,\s]'), '');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return (value as num).toDouble();
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'amount': amount, 'description': description};
  }
}

class AcademicFeeModel {
  final String id;
  final String purpose;
  final double amount;
  final DateTime deadline;
  final DateTime createdAt;
  final FeeStatus status;
  final FeeType type;
  final String? description;
  final String? receiptNumber;
  final DateTime? paidAt;
  final String semester;
  final String academicYear;
  final bool isRecurring;
  final List<String> applicableFaculties;
  final double? lateFee;
  final double? discount;
  final List<FeeItem> items;

  AcademicFeeModel({
    required this.id,
    required this.purpose,
    required this.amount,
    required this.deadline,
    required this.createdAt,
    required this.status,
    required this.type,
    this.description,
    this.receiptNumber,
    this.paidAt,
    required this.semester,
    required this.academicYear,
    this.isRecurring = false,
    this.applicableFaculties = const [],
    this.lateFee,
    this.discount,
    this.items = const [],
  });

  // Calculate total amount including late fee and discount
  double get totalAmount {
    double total = amount;
    if (lateFee != null && isOverdue) {
      total += lateFee!;
    }
    if (discount != null) {
      total -= discount!;
    }
    return total;
  }

  // Check if fee is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(deadline) && status == FeeStatus.pending;
  }

  // Days remaining until due date
  int get daysRemaining {
    if (status == FeeStatus.paid) return 0;
    final difference = deadline.difference(DateTime.now()).inDays;
    return difference < 0 ? 0 : difference;
  }

  // Get status based on current date and payment status
  FeeStatus get currentStatus {
    if (status == FeeStatus.paid) return FeeStatus.paid;
    if (DateTime.now().isAfter(deadline)) return FeeStatus.overdue;
    return FeeStatus.pending;
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purpose': purpose,
      'amount': amount,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'description': description,
      'receiptNumber': receiptNumber,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'semester': semester,
      'academicYear': academicYear,
      'isRecurring': isRecurring,
      'applicableFaculties': applicableFaculties,
      'lateFee': lateFee,
      'discount': discount,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  // Create from Firestore Map - Updated to handle your actual document structure
  factory AcademicFeeModel.fromMap(String docId, Map<String, dynamic> map) {
    return AcademicFeeModel(
      id: docId,
      purpose: map['purpose'] ?? map['title'] ?? '',
      amount: _parseAmount(map['amount'] ?? map['total'] ?? 0),
      deadline: _parseDate(map['deadline'] ?? map['dueDate']) ?? DateTime.now(),
      createdAt: _parseDate(map['createdAt']) ?? DateTime.now(),
      status: _parseStatus(map['status']),
      type: _parseType(map['type'] ?? map['category'] ?? map['purpose']),
      description: map['description'] ?? map['details'],
      receiptNumber: map['receiptNumber'],
      paidAt: _parseDate(map['paidAt']),
      semester: map['semester'] ?? '',
      academicYear: map['academicYear'] ?? map['year'] ?? '',
      isRecurring: map['isRecurring'] ?? false,
      applicableFaculties: _parseStringList(map['applicableFaculties']),
      lateFee: _parseAmount(map['lateFee']),
      discount: _parseAmount(map['discount']),
      items: _parseItems(map['items'] ?? map['breakdown'] ?? map['details']),
    );
  }

  static double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is String) {
      // Remove currency symbols and parse
      final cleanValue = value.replaceAll(RegExp(r'[৳$,\s]'), '');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return (value as num).toDouble();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static List<FeeItem> _parseItems(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) {
            if (item is Map<String, dynamic>) {
              return FeeItem.fromMap(item);
            }
            return null;
          })
          .where((item) => item != null)
          .cast<FeeItem>()
          .toList();
    }
    return [];
  }

  static FeeStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return FeeStatus.paid;
      case 'overdue':
        return FeeStatus.overdue;
      case 'pending':
      default:
        return FeeStatus.pending;
    }
  }

  static FeeType _parseType(String? type) {
    if (type == null) return FeeType.miscellaneous;

    final typeStr = type.toLowerCase();

    // Check for tuition-related keywords
    if (typeStr.contains('tuition') ||
        typeStr.contains('semester') ||
        typeStr.contains('academic')) {
      return FeeType.tuition;
    }

    // Check for registration-related keywords
    if (typeStr.contains('registration') ||
        typeStr.contains('admission') ||
        typeStr.contains('enrollment')) {
      return FeeType.registration;
    }

    // Check for exam-related keywords
    if (typeStr.contains('exam') ||
        typeStr.contains('test') ||
        typeStr.contains('final') ||
        typeStr.contains('midterm')) {
      return FeeType.exam;
    }

    // Check for library-related keywords
    if (typeStr.contains('library') || typeStr.contains('book')) {
      return FeeType.library;
    }

    // Check for lab-related keywords
    if (typeStr.contains('laboratory') ||
        typeStr.contains('lab') ||
        typeStr.contains('practical')) {
      return FeeType.laboratory;
    }

    // Check for sports-related keywords
    if (typeStr.contains('sports') ||
        typeStr.contains('athletic') ||
        typeStr.contains('physical')) {
      return FeeType.sports;
    }

    // Check for development-related keywords
    if (typeStr.contains('development') ||
        typeStr.contains('infrastructure') ||
        typeStr.contains('building')) {
      return FeeType.development;
    }

    // Direct matches
    switch (typeStr) {
      case 'tuition':
        return FeeType.tuition;
      case 'registration':
        return FeeType.registration;
      case 'exam':
        return FeeType.exam;
      case 'library':
        return FeeType.library;
      case 'laboratory':
      case 'lab':
        return FeeType.laboratory;
      case 'sports':
        return FeeType.sports;
      case 'development':
        return FeeType.development;
      default:
        return FeeType.miscellaneous;
    }
  }

  // Copy with method for updates
  AcademicFeeModel copyWith({
    String? id,
    String? purpose,
    double? amount,
    DateTime? deadline,
    DateTime? createdAt,
    FeeStatus? status,
    FeeType? type,
    String? description,
    String? receiptNumber,
    DateTime? paidAt,
    String? semester,
    String? academicYear,
    bool? isRecurring,
    List<String>? applicableFaculties,
    double? lateFee,
    double? discount,
    List<FeeItem>? items,
  }) {
    return AcademicFeeModel(
      id: id ?? this.id,
      purpose: purpose ?? this.purpose,
      amount: amount ?? this.amount,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      type: type ?? this.type,
      description: description ?? this.description,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      paidAt: paidAt ?? this.paidAt,
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
      isRecurring: isRecurring ?? this.isRecurring,
      applicableFaculties: applicableFaculties ?? this.applicableFaculties,
      lateFee: lateFee ?? this.lateFee,
      discount: discount ?? this.discount,
      items: items ?? this.items,
    );
  }
}
