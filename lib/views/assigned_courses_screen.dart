import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignedCoursesScreen extends StatefulWidget {
  const AssignedCoursesScreen({Key? key}) : super(key: key);

  @override
  State<AssignedCoursesScreen> createState() => _AssignedCoursesScreenState();
}

class _AssignedCoursesScreenState extends State<AssignedCoursesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchCourses() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('courses/main/6th').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAnimatedAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildCoursesList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6),
              const Color(0xFFA855F7),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: const Text(
            'Assigned Courses',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          background: Stack(
            children: [
              // Animated background patterns
              Positioned(
                top: -50,
                right: -50,
                child: _buildFloatingIcon(Icons.school, 100, 0.1),
              ),
              Positioned(
                top: 50,
                left: -30,
                child: _buildFloatingIcon(Icons.menu_book, 80, 0.08),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: _buildFloatingIcon(Icons.assignment, 60, 0.12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon, double size, double opacity) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 3),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 0.1,
          child: Transform.translate(
            offset: Offset(0, 10 * (0.5 - (value % 1.0).abs())),
            child: Icon(
              icon,
              size: size,
              color: Colors.white.withOpacity(opacity),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoursesList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchCourses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading();
        } else if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final courses = snapshot.data!;
        _staggerController.forward();

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(courses.length),
              const SizedBox(height: 20),
              ...courses.asMap().entries.map((entry) {
                final index = entry.key;
                final course = entry.value;
                return _buildAnimatedCourseCard(course, index);
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(int courseCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Courses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$courseCount ${courseCount == 1 ? 'course' : 'courses'} enrolled',
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
        ],
      ),
    );
  }

  Widget _buildAnimatedCourseCard(Map<String, dynamic> course, int index) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final delay = index * 0.1;
        final animationValue = Curves.easeOutCubic.transform(
          (_staggerController.value - delay).clamp(0.0, 1.0),
        );

        return Transform.translate(
          offset: Offset(0, 50 * (1 - animationValue)),
          child: Opacity(opacity: animationValue, child: child!),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: _buildCourseCard(course, index),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, int index) {
    final colors = [
      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      [const Color(0xFF10B981), const Color(0xFF059669)],
      [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      [const Color(0xFFEF4444), const Color(0xFFDC2626)],
      [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
      [const Color(0xFF06B6D4), const Color(0xFF0891B2)],
    ];

    final colorPair = colors[index % colors.length];

    return GestureDetector(
      onTap: () {
        // Add haptic feedback
        HapticFeedback.lightImpact();
        // Navigate to course details
        _showCourseDetails(course);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colorPair,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorPair[0].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                top: -50,
                right: -50,
                child: Icon(
                  Icons.school,
                  size: 120,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getCourseIcon(course['code'] ?? ''),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course['name'] ?? 'Unknown Course',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  course['code'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (course['teachers'] != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Instructors: ${(course['teachers'] as List).join(', ')}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionButton(
                          'View Details',
                          Icons.visibility,
                          () => _showCourseDetails(course),
                        ),
                        _buildActionButton(
                          'Resources',
                          Icons.library_books,
                          () => _showResources(course),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCourseIcon(String courseCode) {
    final code = courseCode.toLowerCase();
    if (code.contains('cse') || code.contains('cs') || code.contains('prog')) {
      return Icons.computer;
    } else if (code.contains('math') || code.contains('calc')) {
      return Icons.calculate;
    } else if (code.contains('eng') || code.contains('english')) {
      return Icons.language;
    } else if (code.contains('phy') || code.contains('physics')) {
      return Icons.science;
    } else if (code.contains('chem') || code.contains('chemistry')) {
      return Icons.biotech;
    } else {
      return Icons.menu_book;
    }
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: List.generate(3, (index) => _buildShimmerCard())),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[300]!, Colors.grey[100]!],
        ),
      ),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1500),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[300]!, Colors.white, Colors.grey[300]!],
                stops: [value - 0.3, value, value + 0.3],
              ).createShader(bounds);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Icon(
                    Icons.school_outlined,
                    size: 100,
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'No Courses Assigned',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your assigned courses will appear here once they are available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please try again later',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCourseDetails(Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCourseDetailsModal(course),
    );
  }

  void _showResources(Map<String, dynamic> course) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Resources for ${course['name']} coming soon!'),
        backgroundColor: const Color(0xFF6366F1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildCourseDetailsModal(Map<String, dynamic> course) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['name'] ?? 'Unknown Course',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      course['code'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (course['teachers'] != null) ...[
                    _buildDetailSection(
                      'Instructors',
                      Icons.person,
                      (course['teachers'] as List).join(', '),
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildDetailSection(
                    'Course Code',
                    Icons.code,
                    course['code'] ?? 'N/A',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
