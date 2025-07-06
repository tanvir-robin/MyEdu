import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/notifications_controller.dart';
import 'id_card_view.dart';
import 'notice_screen.dart';
import 'academic_details_screen.dart';
import 'class_schedule_screen.dart';
import 'assigned_courses_screen.dart';
import 'academic_fees_screen.dart';
import 'all_notifications_screen.dart';
import 'academic_result_screen.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.put(DashboardController());
    final authController = Get.find<AuthController>();
    final notificationsController = Get.put(NotificationsController());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF6366F1),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                      Color(0xFFA855F7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background decorative elements - Academic themed illustrations
                    // Large circle top-right
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    // Medium circle bottom-left
                    Positioned(
                      bottom: -25,
                      left: -25,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    // Small floating circles
                    Positioned(
                      top: 20,
                      left: 50,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 80,
                      right: 80,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.10),
                        ),
                      ),
                    ),
                    // Academic icons as decorative elements
                    Positioned(
                      top: 30,
                      right: 20,
                      child: Transform.rotate(
                        angle: 0.2,
                        child: Icon(
                          Icons.school_outlined,
                          size: 32,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 20,
                      child: Transform.rotate(
                        angle: -0.3,
                        child: Icon(
                          Icons.book_outlined,
                          size: 28,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    // Geometric shapes for modern look
                    Positioned(
                      top: 60,
                      left: 15,
                      child: Transform.rotate(
                        angle: 0.4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      right: 30,
                      child: Transform.rotate(
                        angle: -0.6,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.10),
                            shape: BoxShape.rectangle,
                          ),
                        ),
                      ),
                    ),
                    // Dotted pattern for texture
                    Positioned(
                      top: 45,
                      right: 60,
                      child: Row(
                        children: List.generate(
                          3,
                          (index) => Container(
                            margin: const EdgeInsets.only(right: 4),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 60,
                      left: 40,
                      child: Column(
                        children: List.generate(
                          3,
                          (index) => Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Main content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Header with title and theme toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Dashboard',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Row(
                                  children: [
                                    // Logout button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.logout,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed:
                                            () => _showLogoutDialog(
                                              context,
                                              authController,
                                            ),
                                        constraints: const BoxConstraints(
                                          minWidth: 40,
                                          minHeight: 40,
                                        ),
                                        tooltip: 'Logout',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Theme toggle button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: GetBuilder<ThemeController>(
                                        builder:
                                            (controller) => IconButton(
                                              icon: Icon(
                                                controller.isDarkMode
                                                    ? Icons.light_mode
                                                    : Icons.dark_mode,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              onPressed:
                                                  () =>
                                                      controller.toggleTheme(),
                                              constraints: const BoxConstraints(
                                                minWidth: 40,
                                                minHeight: 40,
                                              ),
                                              tooltip:
                                                  controller.isDarkMode
                                                      ? 'Light Mode'
                                                      : 'Dark Mode',
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // User info section
                            GetBuilder<AuthController>(
                              builder: (authControllerLocal) {
                                return Row(
                                  children: [
                                    // Profile image
                                    GestureDetector(
                                      onTap:
                                          () =>
                                              dashboardController
                                                  .uploadProfileImage(),
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.15,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child:
                                            authControllerLocal
                                                        .user
                                                        ?.profileImageUrl ==
                                                    null
                                                ? CircleAvatar(
                                                  radius: 23,
                                                  backgroundColor: Colors.white
                                                      .withOpacity(0.9),
                                                  child: const Icon(
                                                    Icons.person,
                                                    color: Color(0xFF6366F1),
                                                    size: 24,
                                                  ),
                                                )
                                                : ClipOval(
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        authControllerLocal
                                                            .user!
                                                            .profileImageUrl!,
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (
                                                          context,
                                                          url,
                                                        ) => Container(
                                                          color: Colors.white
                                                              .withOpacity(0.9),
                                                          child: const SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                    Color
                                                                  >(
                                                                    Color(
                                                                      0xFF6366F1,
                                                                    ),
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                    errorWidget:
                                                        (
                                                          context,
                                                          url,
                                                          error,
                                                        ) => CircleAvatar(
                                                          radius: 23,
                                                          backgroundColor:
                                                              Colors.white
                                                                  .withOpacity(
                                                                    0.9,
                                                                  ),
                                                          child: const Icon(
                                                            Icons.person,
                                                            color: Color(
                                                              0xFF6366F1,
                                                            ),
                                                            size: 24,
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // User details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Welcome back!',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            authController.user?.name ??
                                                'Student',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.3,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            authController.user?.email ??
                                                'No email available',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Quick action buttons
                                    Row(
                                      children: [
                                        // Logout button
                                        // Container(
                                        //   decoration: BoxDecoration(
                                        //     color: Colors.white.withOpacity(
                                        //       0.15,
                                        //     ),
                                        //     borderRadius: BorderRadius.circular(
                                        //       10,
                                        //     ),
                                        //   ),
                                        //   child: IconButton(
                                        //     onPressed:
                                        //         () => _showLogoutDialog(
                                        //           context,
                                        //           authController,
                                        //         ),
                                        //     icon: const Icon(
                                        //       Icons.logout,
                                        //       color: Colors.white,
                                        //       size: 18,
                                        //     ),
                                        //     constraints: const BoxConstraints(
                                        //       minWidth: 36,
                                        //       minHeight: 36,
                                        //     ),
                                        //     tooltip: 'Logout',
                                        //   ),
                                        // ),
                                        const SizedBox(width: 8),
                                        // Notifications button
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  Get.to(
                                                    () =>
                                                        const AllNotificationsScreen(),
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.notifications_outlined,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 36,
                                                      minHeight: 36,
                                                    ),
                                              ),
                                              Obx(
                                                () =>
                                                    notificationsController
                                                                .unreadCount
                                                                .value >
                                                            0
                                                        ? Positioned(
                                                          right: 6,
                                                          top: 6,
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  2,
                                                                ),
                                                            decoration:
                                                                BoxDecoration(
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                            constraints:
                                                                const BoxConstraints(
                                                                  minWidth: 16,
                                                                  minHeight: 16,
                                                                ),
                                                            child: Text(
                                                              notificationsController
                                                                          .unreadCount
                                                                          .value >
                                                                      99
                                                                  ? '99+'
                                                                  : notificationsController
                                                                      .unreadCount
                                                                      .value
                                                                      .toString(),
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        )
                                                        : const SizedBox.shrink(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick Stats Section
                _buildQuickStatsSection(context),
                const SizedBox(height: 25),

                // Primary Actions Section
                _buildSectionTitle('Academic Hub'),
                // const SizedBox(height: 15),
                _buildPrimaryActionsGrid(context),
                const SizedBox(height: 10),

                // Secondary Actions Section
                _buildSectionTitle('Services & Information'),
                const SizedBox(height: 15),
                _buildSecondaryActionsList(context),
                const SizedBox(height: 25),

                // Recent Activity Section
                _buildSectionTitle('Recent Activity'),
                const SizedBox(height: 15),
                _buildRecentActivity(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildQuickStatsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.school,
              title: 'Current Semester',
              value: '6th',
              color: Colors.blue,
            ),
          ),
          Container(width: 1, height: 50, color: Colors.grey.withOpacity(0.3)),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.book,
              title: 'Active Courses',
              value: '9',
              color: Colors.green,
            ),
          ),
          Container(width: 1, height: 50, color: Colors.grey.withOpacity(0.3)),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.grade,
              title: 'CGPA',
              value: '3.36',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPrimaryActionsGrid(BuildContext context) {
    return AnimationLimiter(
      child: GridView.count(
        padding: const EdgeInsets.symmetric(vertical: 10),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.1,
        children: List.generate(4, (index) {
          final actions = [
            {
              'title': 'Academic Results',
              'subtitle': 'View grades & transcripts',
              'icon': Icons.bar_chart,
              'gradient': [Colors.blue.shade400, Colors.blue.shade600],
            },
            {
              'title': 'Current Courses',
              'subtitle': 'Course materials & info',
              'icon': Icons.book,
              'gradient': [Colors.green.shade400, Colors.green.shade600],
            },
            {
              'title': 'Class Schedule',
              'subtitle': 'Today\'s classes',
              'icon': Icons.schedule,
              'gradient': [Colors.purple.shade400, Colors.purple.shade600],
            },
            {
              'title': 'Academic Details',
              'subtitle': 'Student information',
              'icon': Icons.school,
              'gradient': [Colors.orange.shade400, Colors.orange.shade600],
            },
          ];

          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildPrimaryActionCard(
                  context,
                  title: actions[index]['title'] as String,
                  subtitle: actions[index]['subtitle'] as String,
                  icon: actions[index]['icon'] as IconData,
                  gradient: actions[index]['gradient'] as List<Color>,
                  onTap: () {
                    if (index == 0) {
                      // Navigate to Academic Results screen
                      Get.to(() => const AcademicResultScreen());
                    } else if (index == 2) {
                      // Navigate to Class Schedule screen
                      Get.to(() => const ClassScheduleScreen());
                    } else if (index == 1) {
                      // Navigate to Assigned Courses screen
                      Get.to(() => const AssignedCoursesScreen());
                    } else if (index == 3) {
                      // Navigate to Academic Details screen
                      Get.to(() => const AcademicDetailsScreen());
                    }
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPrimaryActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionsList(BuildContext context) {
    final actions = [
      {
        'title': 'Academic Bills',
        'subtitle': 'View and pay fees',
        'icon': Icons.receipt_long,
        'color': Colors.red,
        'onTap': () {
          Get.to(() => const AcademicFeesScreen());
        },
      },
      {
        'title': 'Hall Attachment Bills',
        'subtitle': 'Hostel fee management',
        'icon': Icons.home,
        'color': Colors.teal,
        'onTap': () {},
      },
      {
        'title': 'ID Card Generation',
        'subtitle': 'Generate student ID',
        'icon': Icons.badge,
        'color': Colors.indigo,
        'onTap': () {
          Get.to(() => const IDCardView());
        },
      },
      {
        'title': 'Latest Notices',
        'subtitle': 'University announcements',
        'icon': Icons.notifications_active,
        'color': Colors.amber,
        'onTap': () {
          Get.to(() => NoticeScreen());
        },
      },
      {
        'title': 'Library Services',
        'subtitle': 'Books and resources',
        'icon': Icons.library_books,
        'color': Colors.brown,
        'onTap': () {},
      },
      {
        'title': 'Campus Map',
        'subtitle': 'Navigate the campus',
        'icon': Icons.map,
        'color': Colors.pink,
        'onTap': () {},
      },
    ];

    return Column(
      children:
          actions
              .map(
                (action) => _buildSecondaryActionTile(
                  context,
                  title: action['title'] as String,
                  subtitle: action['subtitle'] as String,
                  icon: action['icon'] as IconData,
                  color: action['color'] as Color,
                  onTap: action['onTap'] as VoidCallback,
                ),
              )
              .toList(),
    );
  }

  Widget _buildSecondaryActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActivityItem(
            context,
            title: 'Assignment submitted',
            subtitle: 'Mobile App Development - Project 1',
            time: '2 hours ago',
            icon: Icons.assignment_turned_in,
            color: Colors.green,
          ),
          const Divider(height: 24),
          _buildActivityItem(
            context,
            title: 'New notice published',
            subtitle: 'Semester exam schedule released',
            time: '5 hours ago',
            icon: Icons.announcement,
            color: Colors.blue,
          ),
          const Divider(height: 24),
          _buildActivityItem(
            context,
            title: 'Fee payment due',
            subtitle: 'Semester fee deadline: Dec 15',
            time: '1 day ago',
            icon: Icons.payment,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from your account?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                authController.signOut();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }
}
