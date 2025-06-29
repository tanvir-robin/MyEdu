import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/academic_fee_model.dart';
import '../controllers/academic_fees_controller.dart';

class PaymentPage extends StatefulWidget {
  final AcademicFeeModel fee;

  const PaymentPage({Key? key, required this.fee}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool isLoading = false;

  final AcademicFeesController feesController =
      Get.find<AcademicFeesController>();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: AnimationLimiter(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 600),
              childAnimationBuilder:
                  (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
              children: [
                _buildPaymentHeader(),
                const SizedBox(height: 32),
                _buildFeeDetails(),
                const SizedBox(height: 32),
                _buildPaymentMethods(),
                const SizedBox(height: 32),
                _buildPaymentButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentHeader() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.payment, size: 48, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Payment Gateway',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Secure payment powered by SSLCommerz',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeeDetails() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fee Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Fee Purpose', widget.fee.purpose),
          _buildDetailRow('Academic Year', widget.fee.academicYear),
          _buildDetailRow('Semester', widget.fee.semester),
          _buildDetailRow('Due Date', _formatDate(widget.fee.deadline)),
          const Divider(height: 20),
          _buildDetailRow(
            'Total Amount',
            feesController.formatCurrency(widget.fee.totalAmount),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? const Color(0xFF6366F1) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildPaymentMethod(
            'Credit/Debit Cards',
            Icons.credit_card,
            'Visa, MasterCard',
          ),
          _buildPaymentMethod(
            'Mobile Banking',
            Icons.phone_android,
            'bKash, Nagad',
          ),
          _buildPaymentMethod(
            'Internet Banking',
            Icons.account_balance,
            'All Banks',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(String title, IconData icon, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Column(
      children: [
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Proceed to Payment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Your payment information is secure and encrypted',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _processPayment() async {
    setState(() {
      isLoading = true;
    });

    try {
      await feesController.payFee(widget.fee);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process payment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
