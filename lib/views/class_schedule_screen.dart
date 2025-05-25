import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../controllers/class_schedule_controller.dart';
import '../models/class_schedule_model.dart';

class ClassScheduleScreen extends StatelessWidget {
  const ClassScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClassScheduleController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(context, controller);
        }

        return NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                _buildAnimatedAppBar(context, controller),
              ],
          body: RefreshIndicator(
            onRefresh: () => controller.fetchClassSchedule(),
            color: const Color(0xFF6366F1),
            child: AnimationLimiter(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 600),
                  childAnimationBuilder:
                      (widget) => SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                  children: [
                    _buildTodaySection(context, controller),
                    const SizedBox(height: 32),
                    _buildTomorrowSection(context, controller),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnimatedAppBar(
    BuildContext context,
    ClassScheduleController controller,
  ) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF6366F1),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: const Text(
            'Class Schedule',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
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
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => controller.refresh(),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading your schedule...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ClassScheduleController controller,
  ) {
    return Center(
      child: AnimationConfiguration.staggeredList(
        position: 0,
        duration: const Duration(milliseconds: 600),
        child: SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Oops! Something went wrong',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => controller.refresh(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySection(
    BuildContext context,
    ClassScheduleController controller,
  ) {
    return Column(
      children: [
        _buildSectionHeader(
          'Today\'s Classes',
          '${controller.getCurrentDayName()}, ${_getFormattedDate(DateTime.now())}',
          Icons.today_rounded,
          const Color(0xFF6366F1),
          true,
        ),
        const SizedBox(height: 20),
        _buildClassList(controller.getTodaysClasses(), true),
      ],
    );
  }

  Widget _buildTomorrowSection(
    BuildContext context,
    ClassScheduleController controller,
  ) {
    return Column(
      children: [
        _buildSectionHeader(
          'Tomorrow\'s Classes',
          '${controller.getTomorrowDayName()}, ${_getFormattedDate(DateTime.now().add(const Duration(days: 1)))}',
          Icons.calendar_today_rounded,
          const Color(0xFF10B981),
          false,
        ),
        const SizedBox(height: 20),
        _buildClassList(controller.getTomorrowsClasses(), false),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isToday,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassList(List<TimeSlot> classes, bool isToday) {
    if (classes.isEmpty) {
      return _buildEmptyState(isToday);
    }

    // Sort classes by time
    classes.sort((a, b) {
      DateTime? timeA = a.getStartTime();
      DateTime? timeB = b.getStartTime();
      if (timeA != null && timeB != null) {
        return timeA.compareTo(timeB);
      }
      return 0;
    });

    return AnimationLimiter(
      child: Column(
        children: List.generate(
          classes.length,
          (index) => AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildClassCard(classes[index], isToday),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isToday) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.free_breakfast_rounded,
              size: 48,
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No classes scheduled',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isToday ? 'Enjoy your free day!' : 'No classes tomorrow',
            style: const TextStyle(fontSize: 15, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(TimeSlot timeSlot, bool isToday) {
    bool isCurrent = isToday && timeSlot.isCurrentClass();
    bool isUpcoming = isToday && timeSlot.isUpcoming();

    Color primaryColor = const Color(0xFF6366F1);
    Color currentColor = const Color(0xFF10B981);
    Color upcomingColor = const Color(0xFFF59E0B);

    if (isCurrent) {
      primaryColor = currentColor;
    } else if (isUpcoming) {
      primaryColor = upcomingColor;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isCurrent || isUpcoming
                  ? primaryColor.withOpacity(0.3)
                  : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isCurrent || isUpcoming
                    ? primaryColor.withOpacity(0.2)
                    : Colors.black.withOpacity(0.06)),
            blurRadius: isCurrent || isUpcoming ? 20 : 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Add any tap functionality here
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Time Section
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getStartTime(timeSlot.timeRange),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 20,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getEndTime(timeSlot.timeRange),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Course Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              timeSlot.subject,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          if (isCurrent)
                            _buildStatusBadge('LIVE', currentColor),
                          if (isUpcoming)
                            _buildStatusBadge('NEXT', upcomingColor),
                        ],
                      ),
                      if (timeSlot.code.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            timeSlot.code,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStartTime(String timeRange) {
    if (timeRange.contains('-')) {
      return timeRange.split('-')[0].trim();
    }
    return timeRange.trim();
  }

  String _getEndTime(String timeRange) {
    if (timeRange.contains('-')) {
      final parts = timeRange.split('-');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }
    return '';
  }
}
