import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import '../models/academic_fee_model.dart';
import '../models/user_model.dart';
import '../services/pdf_receipt_service.dart';
import '../views/payment_success_screen.dart';
import '../views/payment_failed_screen.dart';
import '../controllers/auth_controller.dart';

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
          await _firestore
              .collection('academic_fees')
              // .orderBy('createdAt', descending: true)
              .get();

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
          // First, apply target filtering based on targetType and targetValue
          if (!_shouldShowFee(fee)) {
            return false;
          }

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

  // Method to determine if a fee should be shown based on targetType and targetValue
  bool _shouldShowFee(AcademicFeeModel fee) {
    // Get current user from AuthController
    final authController = Get.find<AuthController>();
    final currentUser = authController.user;

    // If targetType is 'All', show all bills
    if (fee.targetType == 'All') {
      return true;
    }

    // If targetType is 'Individual', check if targetValue matches user's academic ID
    if (fee.targetType == 'Individual' && currentUser != null) {
      return fee.targetValue == currentUser.id;
    }

    // If targetType is not 'All' or 'Individual', only show bills where targetValue matches '6th' or '20-21'
    if (fee.targetType != 'All' && fee.targetType != 'Individual') {
      return fee.targetValue == '6th' || fee.targetValue == '20-21';
    }

    // Otherwise, don't show the bill
    return false;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> processPayment(AcademicFeeModel fee) async {
    final authController = Get.find<AuthController>();
    final currentUser = authController.user;

    if (currentUser == null) {
      Get.snackbar(
        'Error',
        'User not authenticated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Initialize SSL Commerz
      Sslcommerz sslcommerz = Sslcommerz(
        initializer: SSLCommerzInitialization(
          multi_card_name: "visa,master,bkash,nagad",
          currency: SSLCurrencyType.BDT,
          product_category: "Education",
          sdkType: SSLCSdkType.TESTBOX,
          store_id: "algor670ab401dbbcc",
          store_passwd: "algor670ab401dbbcc@ssl",
          total_amount: fee.totalAmount,
          tran_id: DateTime.now().millisecondsSinceEpoch.toString(),
        ),
      );

      var result = await sslcommerz.payNow();

      if (result.status == 'VALID') {
        // Update the fee status to paid
        final updatedFee = fee.copyWith(
          status: FeeStatus.paid,
          paidAt: DateTime.now(),
          receiptNumber: result.tranId,
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

        // Send payment confirmation email
        try {
          await PdfReceiptService.generateAndEmailReceipt(
            fee: updatedFee,
            user: currentUser,
          );
          print('Payment confirmation email sent successfully');
        } catch (e) {
          print('Failed to send payment confirmation email: $e');
          // Don't block the payment success flow if email fails
        }

        // Navigate to Payment Success screen
        Get.to(
          () => PaymentSuccessScreen(
            fee: updatedFee,
            user: currentUser,
            paymentData: {
              'tran_id': result.tranId,
              'amount': result.amount,
              'card_type': result.cardType,
              'bank_tran_id': result.bankTranId,
              'status': result.status,
            },
          ),
        );
      } else {
        // Navigate to Payment Failed screen
        Get.to(
          () => PaymentFailedScreen(
            fee: fee,
            errorMessage: result.status ?? 'Payment failed',
          ),
        );
      }
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

  // Keep the old method name for backward compatibility
  Future<void> payFee(AcademicFeeModel fee) async {
    await processPayment(fee);
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
