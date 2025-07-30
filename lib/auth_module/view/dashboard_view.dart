import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'package:lingolearn/auth_module/models/lesson_model.dart';
import 'package:lingolearn/utilities/constants/assets_path.dart';
import 'package:lingolearn/utilities/enums.dart';
import 'package:lingolearn/utilities/theme/app_box_decoration.dart';

class LessonPathScreen extends StatefulWidget {
  const LessonPathScreen({super.key});

  @override
  State<LessonPathScreen> createState() => _LessonPathScreenState();
}

class _LessonPathScreenState extends State<LessonPathScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _floatController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late AnimationController _pulseController;

  final List<LessonData> allLessons = List.generate(
    30,
    (index) => LessonData(
      index + 1,
      "Lesson ${index + 1}",
      "Learn new concepts and practice",
      (index + 1) % 5 == 0 ? LessonType.bonus : LessonType.normal,
      index < 2,
      index == 2,
    ),
  );

  final List<UnitData> units = [
    UnitData(
        1, "Unit 1", "Learning basic objects", const Color(0xFFE57373), 0, 7),
    UnitData(
        2, "Unit 2", "Family and relationships", const Color(0xFF4CAF50), 7, 7),
    UnitData(3, "Unit 3", "Food and cooking", const Color(0xFF42A5F5), 14, 7),
    UnitData(4, "Unit 4", "Travel and places", const Color(0xFFAB47BC), 21, 7),
  ];

  final List<PathItem> pathItems = [];

// Function to build the interleaved path items
  void _buildPathItems() {
    pathItems.clear();
    int currentLessonIndex = 0;
    int pathItemIndex = 0;

    for (var unit in units) {
      pathItems
          .add(PathItem(type: 'unit', data: unit, pathIndex: pathItemIndex++));
      for (int i = 0; i < unit.lessonCount; i++) {
        if (currentLessonIndex < allLessons.length) {
          pathItems.add(PathItem(
              type: 'lesson',
              data: allLessons[currentLessonIndex],
              pathIndex: pathItemIndex++));
          currentLessonIndex++;
        }
      }
    }
    // Add any remaining lessons not covered by units (if any)
    while (currentLessonIndex < allLessons.length) {
      pathItems.add(PathItem(
          type: 'lesson',
          data: allLessons[currentLessonIndex],
          pathIndex: pathItemIndex++));
      currentLessonIndex++;
    }
  }

  @override
  void initState() {
    super.initState();
    _buildPathItems();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutCubic,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: -12.0, // Bounce upwards
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut, // Approximating elasticInOut for bounce
    ));

    _floatAnimation = Tween<double>(
      begin: -6.0,
      end: 6.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _bounceController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: DuolingoLessonPathView(
              pathItems: pathItems,
              allLessons: allLessons,
              bounceAnimation: _bounceAnimation,
              floatAnimation: _floatAnimation,
              pulseAnimation: _pulseAnimation,
              units: units,
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF5A52E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(Icons.local_fire_department, "7", Colors.orange),
          _buildStatItem(Icons.diamond, "1,234", Colors.blue),
          _buildStatItem(Icons.favorite, "5", Colors.red),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, "Home", true),
          _buildNavItem(Icons.book, "Stories", false),
          _buildNavItem(Icons.leaderboard, "Leaderboard", false),
          _buildNavItem(Icons.person, "Profile", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF6C63FF) : Colors.grey,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF6C63FF) : Colors.grey,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class DuolingoLessonPathView extends StatefulWidget {
  final List<PathItem> pathItems;
  final List<LessonData> allLessons;
  final List<UnitData> units;
  final Animation<double> bounceAnimation;
  final Animation<double> floatAnimation;
  final Animation<double> pulseAnimation;

  const DuolingoLessonPathView({
    super.key,
    required this.pathItems,
    required this.bounceAnimation,
    required this.floatAnimation,
    required this.allLessons,
    required this.pulseAnimation,
    required this.units,
  });

  @override
  State<DuolingoLessonPathView> createState() => _DuolingoLessonPathViewState();
}

class _DuolingoLessonPathViewState extends State<DuolingoLessonPathView> {
  late final ScrollController _scrollController;
  final Map<int, GlobalKey> _lessonKeys = {};
  int? _currentUnitIndex;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    for (var item in widget.pathItems) {
      _lessonKeys[item.pathIndex] = GlobalKey();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentLessonPathItem = widget.pathItems.firstWhere(
        (item) => item.type == 'lesson' && (item.data as LessonData).isCurrent,
        orElse: () =>
            PathItem(type: 'lesson', data: widget.allLessons[0], pathIndex: 0),
      );

      for (int i = currentLessonPathItem.pathIndex; i >= 0; i--) {
        if (widget.pathItems[i].type == 'unit') {
          setState(() {
            _currentUnitIndex = widget.pathItems[i].pathIndex;
          });
          break;
        }
      }

      final key = _lessonKeys[currentLessonPathItem.pathIndex];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
          alignment: 0.5,
        );
      }
    });
  }

  void _onScroll() {
    for (int i = 0; i < widget.pathItems.length; i++) {
      final item = widget.pathItems[i];
      if (item.type == 'unit') {
        final key = _lessonKeys[item.pathIndex];
        if (key != null && key.currentContext != null) {
          final box = key.currentContext!.findRenderObject() as RenderBox;
          final offset = box.localToGlobal(Offset.zero).dy;
          if (offset >= 0 && offset < 150) {
            if (_currentUnitIndex != item.pathIndex) {
              setState(() {
                _currentUnitIndex = item.pathIndex;
              });
            }
            break;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: _buildSliverLessonPath(),
    );
  }

  List<Widget> _buildSliverLessonPath() {
    List<Widget> slivers = [];

    if (_currentUnitIndex != null) {
      final unitData = widget.pathItems[_currentUnitIndex!].data as UnitData;
      slivers.add(SliverPersistentHeader(
        pinned: true,
        delegate: _UnitHeaderDelegate(
          title: unitData.title,
          description: unitData.description,
          isActive: true,
          unitColor: unitData.color,
        ),
      ));
    }

    for (var item in widget.pathItems) {
      if (item.type == 'unit') {
        slivers.add(
          SliverToBoxAdapter(
            child: Container(
              key: _lessonKeys[item.pathIndex],
              height: 1,
              color: Colors.transparent,
            ),
          ),
        );
      } else {
        final lessonData = item.data as LessonData;
        final translateX = 80 * math.sin((item.pathIndex * 120) / 100);

        slivers.add(SliverToBoxAdapter(
          key: _lessonKeys[item.pathIndex],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Transform.translate(
              offset: Offset(translateX, 0),
              child: Center(
                child: ModernLevelButton(
                  lessonNumber: lessonData.id,
                  isCompleted: lessonData.isCompleted,
                  isCurrent: lessonData.isCurrent,
                  isBonus: lessonData.type == LessonType.bonus,
                  bounceAnimation: widget.bounceAnimation,
                  floatAnimation: widget.floatAnimation,
                  pulseAnimation: widget.pulseAnimation,
                ),
              ),
            ),
          ),
        ));

        bool isLastInUnit = false;
        for (var unit in widget.units) {
          int unitLastIndex = unit.startIndex + unit.lessonCount - 1;
          if (lessonData.id - 1 == unitLastIndex) {
            isLastInUnit = true;
            break;
          }
        }

        if (isLastInUnit) {
          slivers.add(SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🎉 Chapter Ended!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ),
          ));
        }
      }
    }

    return slivers;
  }
}

class _UnitHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final String description;
  final bool isActive;
  final Color unitColor;

  _UnitHeaderDelegate({
    required this.title,
    required this.description,
    required this.isActive,
    required this.unitColor,
  });

  @override
  double get maxExtent => 100.0;

  @override
  double get minExtent => 100.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.all(12),
      alignment: Alignment.centerLeft,
      decoration: AppBoxDecoration.getBoxDecoration(
        color: unitColor,
        borderRadius: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isActive ? Icons.play_arrow : Icons.lock,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(description,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _UnitHeaderDelegate oldDelegate) {
    return title != oldDelegate.title ||
        description != oldDelegate.description ||
        isActive != oldDelegate.isActive ||
        unitColor != oldDelegate.unitColor;
  }
}

class ModernLevelButton extends StatefulWidget {
  final int lessonNumber;
  final bool isCompleted;
  final bool isCurrent;
  final bool isBonus;
  final Animation<double> bounceAnimation;
  final Animation<double> floatAnimation;
  final Animation<double> pulseAnimation;

  const ModernLevelButton({
    super.key,
    required this.lessonNumber,
    required this.isCompleted,
    required this.isCurrent,
    required this.isBonus,
    required this.bounceAnimation,
    required this.floatAnimation,
    required this.pulseAnimation,
  });

  @override
  State<ModernLevelButton> createState() => _ModernLevelButtonState();
}

class _ModernLevelButtonState extends State<ModernLevelButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _tapController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _tapController.reverse();
  }

  void _handleTapCancel() {
    _tapController.reverse();
  }

  void _handlePress() {
    HapticFeedback.mediumImpact();
    debugPrint('Lesson ${widget.lessonNumber} clicked!');
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor;
    Color textColor;
    IconData? icon;

    if (widget.isCompleted) {
      buttonColor = const Color(0xFF10B981);
      textColor = Colors.white;
      icon = Icons.check_rounded;
    } else if (widget.isCurrent) {
      buttonColor = const Color(0xFF667EEA);
      textColor = Colors.white;
    } else {
      buttonColor = const Color(0xFFE5E7EB);
      textColor = const Color(0xFF6B7280);
    }

    if (widget.isBonus) {
      buttonColor = const Color(0xFFF59E0B);
      textColor = Colors.white;
      icon = Icons.star_rounded;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.bounceAnimation,
        widget.floatAnimation,
        widget.pulseAnimation,
        _scaleAnimation,
      ]),
      builder: (context, child) {
        double combinedY = 0;
        double scale = _scaleAnimation.value;

        if (widget.isCurrent) {
          combinedY =
              widget.bounceAnimation.value + widget.floatAnimation.value;
          scale *= widget.pulseAnimation.value;
        }

        return Transform.translate(
          offset: Offset(0, combinedY),
          child: Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: _handlePress,
              child: SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (widget.isCurrent)
                      Positioned(
                        top: -50,
                        child: Container(
                          decoration: AppBoxDecoration.getBoxDecoration(
                              color: Colors.white, borderRadius: 16),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: const Text(
                            'START',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    SvgPicture.asset(AssetPath.buttonSvg),
                    if (icon != null)
                      Positioned(
                        child: Icon(
                          icon,
                          color: textColor,
                          size: 28,
                        ),
                      ),
                    if (widget.isCompleted && !widget.isBonus)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF10B981),
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
