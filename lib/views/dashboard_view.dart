import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/theme_controller.dart';
import 'id_card_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.put(DashboardController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Dashboard',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GetBuilder<ThemeController>(
                              builder:
                                  (controller) => IconButton(
                                    icon: Icon(
                                      controller.isDarkMode
                                          ? Icons.light_mode
                                          : Icons.dark_mode,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => controller.toggleTheme(),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GetBuilder<AuthController>(
                          builder: (authControllerLocal) {
                            return Row(
                              children: [
                                GestureDetector(
                                  onTap:
                                      () =>
                                          dashboardController
                                              .uploadProfileImage(),
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child:
                                        authControllerLocal
                                                    .user
                                                    ?.profileImageUrl ==
                                                null
                                            ? const CircleAvatar(
                                              radius: 35,
                                              backgroundColor: Colors.white,
                                              child: Icon(
                                                Icons.camera_alt,
                                                color: Colors.grey,
                                                size: 30,
                                              ),
                                            )
                                            : ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    authControllerLocal
                                                        .user!
                                                        .profileImageUrl!,
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                                placeholder:
                                                    (context, url) =>
                                                        const CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                              ),
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome, ${authController.user?.name ?? 'Student'}!',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        authController.user?.email ??
                                            'No email available',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
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
                const SizedBox(height: 15),
                _buildPrimaryActionsGrid(context),
                const SizedBox(height: 25),

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
              value: '7th',
              color: Colors.blue,
            ),
          ),
          Container(width: 1, height: 50, color: Colors.grey.withOpacity(0.3)),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.book,
              title: 'Active Courses',
              value: '6',
              color: Colors.green,
            ),
          ),
          Container(width: 1, height: 50, color: Colors.grey.withOpacity(0.3)),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.grade,
              title: 'CGPA',
              value: '3.85',
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
                  onTap: () {},
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
        'onTap': () {},
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
        'onTap': () {},
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
}
