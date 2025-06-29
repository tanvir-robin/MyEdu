import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../controllers/academic_fees_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/academic_fee_model.dart';
import '../views/payment_page.dart';
import '../services/pdf_receipt_service.dart';

class AcademicFeesScreen extends StatefulWidget {
  const AcademicFeesScreen({Key? key}) : super(key: key);

  @override
  State<AcademicFeesScreen> createState() => _AcademicFeesScreenState();
}

class _AcademicFeesScreenState extends State<AcademicFeesScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _pulseController;
  late Animation<double> _headerScaleAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _pulseAnimation;

  final AcademicFeesController feesController = Get.put(
    AcademicFeesController(),
  );
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _headerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _pulseController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAnimatedAppBar(),
          _buildStatisticsSection(),
          _buildFiltersSection(),
          _buildFeesListSection(),
        ],
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF6366F1),
      flexibleSpace: FlexibleSpaceBar(
        title: AnimatedBuilder(
          animation: _headerAnimationController,
          builder: (context, child) {
            return SlideTransition(
              position: _headerSlideAnimation,
              child: ScaleTransition(
                scale: _headerScaleAnimation,
                child: const Text(
                  'Academic Fees',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
            );
          },
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Obx(
          () =>
              feesController.overdueCount.value > 0
                  ? AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: IconButton(
                          icon: Stack(
                            children: [
                              const Icon(Icons.warning_amber_rounded),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '${feesController.overdueCount.value}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            feesController.setFilter('overdue');
                            HapticFeedback.lightImpact();
                          },
                        ),
                      );
                    },
                  )
                  : const SizedBox(),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            feesController.refreshFees();
            HapticFeedback.lightImpact();
          },
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (feesController.isLoading.value) {
          return _buildStatisticsShimmer();
        }

        return AnimationLimiter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 600),
                childAnimationBuilder:
                    (widget) => SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Pending',
                          feesController.formatCurrency(
                            feesController.totalPending.value,
                          ),
                          Icons.pending_actions,
                          const Color(0xFF3B82F6), // Blue instead of orange
                          feesController.pendingCount.value +
                              feesController.overdueCount.value,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Total Paid',
                          feesController.formatCurrency(
                            feesController.totalPaid.value,
                          ),
                          Icons.check_circle,
                          const Color(
                            0xFF1E40AF,
                          ), // Darker blue instead of green
                          feesController.paidCount.value,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(
    String title,
    String amount,
    IconData icon,
    Color color,
    int count,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.2), width: 1),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildShimmerCard()),
          const SizedBox(width: 12),
          Expanded(child: _buildShimmerCard()),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search fees...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF6366F1),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ), // Adjusted padding to reduce space
                  suffixIcon:
                      searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              feesController.setSearchQuery('');
                            },
                          )
                          : null,
                ),
                onChanged: (value) {
                  feesController.setSearchQuery(value);
                },
              ),
            ),
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(
                () => Row(
                  children: [
                    _buildFilterChip('All', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Pending', 'pending'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Paid', 'paid'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Overdue', 'overdue'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = feesController.selectedFilter.value == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        feesController.setFilter(value);
        HapticFeedback.selectionClick();
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF6366F1).withOpacity(0.1),
      checkmarkColor: const Color(0xFF6366F1),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF6366F1) : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF6366F1) : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildFeesListSection() {
    return Obx(() {
      if (feesController.isLoading.value) {
        return _buildLoadingList();
      }

      if (feesController.errorMessage.value.isNotEmpty) {
        return _buildErrorState();
      }

      final filteredFees = feesController.filteredFees;

      if (filteredFees.isEmpty) {
        return _buildEmptyState();
      }

      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: AnimationLimiter(
          child: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 600),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildFeeCard(filteredFees[index], index),
                  ),
                ),
              );
            }, childCount: filteredFees.length),
          ),
        ),
      );
    });
  }

  Widget _buildFeeCard(AcademicFeeModel fee, int index) {
    final statusColor = feesController.getStatusColor(fee.currentStatus);
    final typeIcon = feesController.getTypeIcon(fee.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: fee.currentStatus == FeeStatus.overdue ? 8 : 4,
        shadowColor: statusColor.withOpacity(0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showFeeDetails(fee),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    fee.currentStatus == FeeStatus.overdue
                        ? Colors.red.withOpacity(0.3)
                        : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(typeIcon, color: statusColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fee.purpose,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feesController.getTypeDisplayName(fee.type),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        fee.currentStatus
                            .toString()
                            .split('.')
                            .last
                            .toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (fee.description != null) ...[
                  Text(
                    fee.description!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            feesController.formatCurrency(fee.totalAmount),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Due Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy').format(fee.deadline),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (fee.currentStatus != FeeStatus.paid) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            fee.isOverdue ? 'Overdue' : 'Days Left',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            fee.isOverdue
                                ? '${DateTime.now().difference(fee.deadline).inDays}d'
                                : '${fee.daysRemaining}d',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: fee.isOverdue ? Colors.red : statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                if (fee.currentStatus != FeeStatus.paid) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handlePayment(fee),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6), // Blue color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF3B82F6).withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payment, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            fee.isOverdue ? 'Pay Now (Overdue)' : 'Pay Now',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleReceiptGeneration(fee);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E40AF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Show Receipt',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleEmailReceipt(fee);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.email, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Send Email Receipt',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingList() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 180,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }, childCount: 5),
      ),
    );
  }

  Widget _buildErrorState() {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Failed to load fees',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                feesController.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => feesController.refreshFees(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No fees found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No academic fees match your current filter',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeeDetails(AcademicFeeModel fee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFeeDetailsSheet(fee),
    );
  }

  Widget _buildFeeDetailsSheet(AcademicFeeModel fee) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: feesController
                              .getStatusColor(fee.currentStatus)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          feesController.getTypeIcon(fee.type),
                          color: feesController.getStatusColor(
                            fee.currentStatus,
                          ),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fee.purpose,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              feesController.getTypeDisplayName(fee.type),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Fee breakdown section
                  if (fee.items.isNotEmpty) ...[
                    const Text(
                      'Fee Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          ...fee.items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border:
                                    index < fee.items.length - 1
                                        ? Border(
                                          bottom: BorderSide(
                                            color: Colors.grey[200]!,
                                            width: 1,
                                          ),
                                        )
                                        : null,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        if (item.description != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            item.name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    feesController.formatCurrency(item.amount),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: feesController.getStatusColor(
                                        fee.currentStatus,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          // Subtotal
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  feesController.formatCurrency(fee.amount),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    _buildDetailRow(
                      'Amount',
                      feesController.formatCurrency(fee.amount),
                    ),
                  ],
                  if (fee.lateFee != null && fee.isOverdue)
                    _buildDetailRow(
                      'Late Fee',
                      feesController.formatCurrency(fee.lateFee!),
                    ),
                  if (fee.discount != null)
                    _buildDetailRow(
                      'Discount',
                      '-${feesController.formatCurrency(fee.discount!)}',
                    ),
                  const Divider(height: 20),
                  _buildDetailRow(
                    'Total',
                    feesController.formatCurrency(fee.totalAmount),
                    isTotal: true,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Due Date',
                    DateFormat('MMMM dd, yyyy').format(fee.deadline),
                  ),
                  _buildDetailRow('Academic Year', fee.academicYear),
                  _buildDetailRow('Semester', fee.semester),
                  if (fee.description != null)
                    _buildDetailRow('Description', fee.description!),
                  if (fee.status == FeeStatus.paid) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Payment Date',
                      DateFormat('MMMM dd, yyyy').format(fee.paidAt!),
                    ),
                    _buildDetailRow('Receipt Number', fee.receiptNumber!),
                  ],
                  const SizedBox(height: 80), // Space for button
                ],
              ),
            ),
          ),
          // Payment Button (Fixed at bottom)
          if (fee.currentStatus != FeeStatus.paid)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.to(() => PaymentPage(fee: fee));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: feesController.getStatusColor(
                      fee.currentStatus,
                    ),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Pay ${feesController.formatCurrency(fee.totalAmount)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleReceiptGeneration(fee);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E40AF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Show Receipt',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleEmailReceipt(fee);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.email, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Send Email Receipt',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isTotal ? 14 : 13,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTotal ? 16 : 13,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? const Color(0xFF6366F1) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePayment(AcademicFeeModel fee) {
    HapticFeedback.mediumImpact();
    Get.to(() => PaymentPage(fee: fee));
  }

  void _handleReceiptGeneration(AcademicFeeModel fee) async {
    final authController = Get.find<AuthController>();
    if (authController.user == null) {
      Get.snackbar(
        'Error',
        'User information not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    HapticFeedback.lightImpact();
    await feesController.generateReceipt(fee, authController.user!);
  }

  void _handleEmailReceipt(AcademicFeeModel fee) async {
    final authController = Get.find<AuthController>();
    if (authController.user == null) {
      Get.snackbar(
        'Error',
        'User information not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    HapticFeedback.lightImpact();

    try {
      await PdfReceiptService.generateAndEmailReceipt(
        fee: fee,
        user: authController.user!,
      );
      Get.snackbar(
        'Success',
        'Payment confirmation email sent successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send email: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
