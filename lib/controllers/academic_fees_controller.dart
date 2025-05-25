import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/academic_fee_model.dart';
import '../models/user_model.dart';
import '../services/pdf_receipt_service.dart';

class AcademicFeesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<AcademicFeeModel> academicFees = <AcademicFeeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedFilter = 'all'.obs;
  final RxString searchQuery = ''.obs;

  // Statistics
  final RxDouble totalPending = 0.0.obs;
  final RxDouble totalPaid = 0.0.obs;
  final RxInt pendingCount = 0.obs;
  final RxInt paidCount = 0.obs;
  final RxInt overdueCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAcademicFees();
  }

  Future<void> fetchAcademicFees() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('Fetching academic fees from Firestore...');

      // Remove the orderBy to avoid errors if field doesn't exist
      QuerySnapshot snapshot =
          await _firestore.collection('academic_fees').get();

      print('Found ${snapshot.docs.length} documents');

      final fees =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            print('Document ${doc.id}: $data');
            return AcademicFeeModel.fromMap(doc.id, data);
          }).toList();

      academicFees.value = fees;
      _calculateStatistics();

      print('Successfully loaded ${fees.length} fees');
    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to fetch academic fees: $e';
      print('Error fetching fees: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load academic fees: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStatistics() {
    double pending = 0.0;
    double paid = 0.0;
    int pendingFees = 0;
    int paidFees = 0;
    int overdueFees = 0;

    for (var fee in academicFees) {
      switch (fee.currentStatus) {
        case FeeStatus.pending:
          pending += fee.totalAmount;
          pendingFees++;
          break;
        case FeeStatus.paid:
          paid += fee.totalAmount;
          paidFees++;
          break;
        case FeeStatus.overdue:
          pending += fee.totalAmount;
          overdueFees++;
          break;
      }
    }

    totalPending.value = pending;
    totalPaid.value = paid;
    pendingCount.value = pendingFees;
    paidCount.value = paidFees;
    overdueCount.value = overdueFees;
  }

  List<AcademicFeeModel> get filteredFees {
    var fees =
        academicFees.where((fee) {
          // Search filter
          if (searchQuery.value.isNotEmpty) {
            final query = searchQuery.value.toLowerCase();
            if (!fee.purpose.toLowerCase().contains(query) &&
                !(fee.description?.toLowerCase().contains(query) ?? false)) {
              return false;
            }
          }

          // Status filter
          switch (selectedFilter.value) {
            case 'pending':
              return fee.currentStatus == FeeStatus.pending;
            case 'paid':
              return fee.currentStatus == FeeStatus.paid;
            case 'overdue':
              return fee.currentStatus == FeeStatus.overdue;
            default:
              return true;
          }
        }).toList();

    // Sort by priority: overdue first, then by due date
    fees.sort((a, b) {
      if (a.currentStatus == FeeStatus.overdue &&
          b.currentStatus != FeeStatus.overdue) {
        return -1;
      }
      if (b.currentStatus == FeeStatus.overdue &&
          a.currentStatus != FeeStatus.overdue) {
        return 1;
      }
      return a.deadline.compareTo(b.deadline);
    });

    return fees;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> payFee(AcademicFeeModel fee) async {
    try {
      isLoading.value = true;

      // In a real app, you would integrate with a payment gateway here
      // For now, we'll simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      final updatedFee = fee.copyWith(
        status: FeeStatus.paid,
        paidAt: DateTime.now(),
        receiptNumber: 'RCP${DateTime.now().millisecondsSinceEpoch}',
      );

      await _firestore
          .collection('academic_fees')
          .doc(fee.id)
          .update(updatedFee.toMap());

      // Update local data
      final index = academicFees.indexWhere((f) => f.id == fee.id);
      if (index != -1) {
        academicFees[index] = updatedFee;
        _calculateStatistics();
      }

      Get.snackbar(
        'Payment Successful',
        'Payment for ${fee.purpose} has been processed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Payment Failed',
        'Failed to process payment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void refreshFees() {
    fetchAcademicFees();
  }

  String formatCurrency(double amount) {
    return '৳${amount.toStringAsFixed(2)}';
  }

  Color getStatusColor(FeeStatus status) {
    switch (status) {
      case FeeStatus.paid:
        return const Color(0xFF3B82F6); // Blue for paid
      case FeeStatus.overdue:
        return Colors.red;
      case FeeStatus.pending:
        return const Color(0xFF3B82F6); // Blue for pending
    }
  }

  Future<void> generateReceipt(AcademicFeeModel fee, UserModel user) async {
    try {
      await PdfReceiptService.generateAndShowReceipt(fee: fee, user: user);
      Get.snackbar(
        'Success',
        'Receipt generated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF3B82F6),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate receipt: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  IconData getTypeIcon(FeeType type) {
    switch (type) {
      case FeeType.tuition:
        return Icons.school;
      case FeeType.registration:
        return Icons.app_registration;
      case FeeType.exam:
        return Icons.quiz;
      case FeeType.library:
        return Icons.local_library;
      case FeeType.laboratory:
        return Icons.science;
      case FeeType.sports:
        return Icons.sports;
      case FeeType.development:
        return Icons.construction;
      case FeeType.miscellaneous:
        return Icons.more_horiz;
    }
  }

  String getTypeDisplayName(FeeType type) {
    switch (type) {
      case FeeType.tuition:
        return 'Tuition Fee';
      case FeeType.registration:
        return 'Registration Fee';
      case FeeType.exam:
        return 'Exam Fee';
      case FeeType.library:
        return 'Library Fee';
      case FeeType.laboratory:
        return 'Laboratory Fee';
      case FeeType.sports:
        return 'Sports Fee';
      case FeeType.development:
        return 'Development Fee';
      case FeeType.miscellaneous:
        return 'Miscellaneous Fee';
    }
  }
}
