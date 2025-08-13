import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:lingolearn/auth_module/models/lesson_model.dart';
import 'package:lingolearn/utilities/constants/assets_path.dart';
import 'package:lingolearn/utilities/enums.dart';
import 'package:lingolearn/utilities/firebase/core_prefs.dart';
import 'package:lingolearn/utilities/theme/app_box_decoration.dart';

const List<Color> unitColors = [
  Color(0xFFA568CC),
  Color(0xFFFF981F),
  Color(0xFF543ACC)
];

final Map<Color, Map<String, String>> unitColorAssetMap = {
  Color(0xFFA568CC): {
    'normal': AssetPath.purpleSvg,
    'starred': AssetPath.purpleStarredSvg,
    'inactive': AssetPath.inactiveSvg,
    'inactive_starred': AssetPath.inactiveStarredSvg,
  },
  Color(0xFFFF981F): {
    'normal': AssetPath.yellowSvg,
    'starred': AssetPath.yellowStarredSvg,
    'inactive': AssetPath.inactiveSvg,
    'inactive_starred': AssetPath.inactiveStarredSvg,
  },
  Color(0xFF543ACC): {
    'normal': AssetPath.blueSvg,
    'starred': AssetPath.blueStarredSvg,
    'inactive': AssetPath.inactiveSvg,
    'inactive_starred': AssetPath.inactiveStarredSvg,
  },
};

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

  List<LessonData> allLessons = [];
  List<UnitData> units = [];
  final List<PathItem> pathItems = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadDataFromFirestore();
  }

  void _initAnimations() {
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
      end: -12.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
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

  Future<void> _loadDataFromFirestore() async {
    final firestore = FirebaseFirestore.instance;
    final userId = await getUuid();

    final unitSnap = await firestore
        .collection('languages')
        .doc('flutter')
        .collection('units')
        .orderBy('order')
        .get();

    units = unitSnap.docs.asMap().entries.map((entry) {
      final index = entry.key;
      final doc = entry.value;
      final data = doc.data();
      return UnitData(
        data['order'],
        data['title'],
        data['description'],
        unitColors[index % unitColors.length], // ✅ Use index instead
        0,
        (data['lessons'] as List).length,
      );
    }).toList();

    final allLessonIds = units
        .expand((u) => unitSnap.docs
            .firstWhere((e) => e.data()['title'] == u.title)
            .data()['lessons'] as List)
        .cast<String>()
        .toList();

    final lessonChunks = <List<String>>[];
    for (var i = 0; i < allLessonIds.length; i += 10) {
      lessonChunks.add(allLessonIds.sublist(
          i, i + 10 > allLessonIds.length ? allLessonIds.length : i + 10));
    }

    List<LessonData> fetchedLessons = [];
    for (final chunk in lessonChunks) {
      final snap = await firestore
          .collection('chapters')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      fetchedLessons.addAll(snap.docs.map((doc) {
        final data = doc.data();
        return LessonData(
          data['id'] != null
              ? int.tryParse(data['id']
                      .toString()
                      .replaceAll(RegExp(r'[^0-9]'), '')) ??
                  0
              : 0,
          data['title'],
          '',
          data['isBonus'] == true ? LessonType.bonus : LessonType.normal,
          false,
          false,
        );
      }));
    }

    if (userId != null) {
      final progressSnap = await firestore
          .collection('user_progress')
          .doc(userId)
          .collection('progress')
          .doc('flutter_progress')
          .get();

      final lastCompletedId = progressSnap.data()?['lastCompletedLessonId'];
      print("progress $lastCompletedId");

      bool unlocked = true;
      for (var lesson in fetchedLessons) {
        if ('lesson_${lesson.id.toString()}' == lastCompletedId) {
          lesson.isCompleted = true;
          lesson.isCurrent = true;
          unlocked = false;
        } else if (unlocked) {
          lesson.isCompleted = true;
        } else {
          lesson.isCompleted = false;
          lesson.isCurrent = false;
        }
      }
    }

    setState(() {
      allLessons = fetchedLessons;
      _buildPathItems();
    });
  }

  void _buildPathItems() {
    pathItems.clear();
    int currentLessonIndex = 0;
    int pathItemIndex = 0;
    int unitCounter = 1;

    for (var unit in units) {
      pathItems.add(PathItem(
        type: 'unit',
        data: unit,
        pathIndex: pathItemIndex++,
        unitIndex: unitCounter,
      ));

      for (int i = 0; i < unit.lessonCount; i++) {
        if (currentLessonIndex < allLessons.length) {
          pathItems.add(PathItem(
            type: 'lesson',
            data: allLessons[currentLessonIndex],
            pathIndex: pathItemIndex++,
            unitIndex: unitCounter,
          ));
          currentLessonIndex++;
        }
      }
      unitCounter++;
    }

    while (currentLessonIndex < allLessons.length) {
      pathItems.add(
        PathItem(
          type: 'lesson',
          data: allLessons[currentLessonIndex],
          pathIndex: pathItemIndex++,
        ),
      );
      currentLessonIndex++;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: allLessons.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
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
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
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
        final unitNumber = item.unitIndex ?? 0;
        final unitColor = widget.pathItems[item.pathIndex].unitIndex != null
            ? widget
                .units[widget.pathItems[item.pathIndex].unitIndex! - 1].color
            : unitColors[0];
        slivers.add(SliverToBoxAdapter(
          key: _lessonKeys[item.pathIndex],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Transform.translate(
              offset: Offset(translateX, 0),
              child: Center(
                child: ModernLevelButton(
                    lessonNumber: lessonData.id,
                    unitNumber: unitNumber,
                    isCompleted: lessonData.isCompleted,
                    isCurrent: lessonData.isCurrent,
                    isBonus: lessonData.type == LessonType.bonus,
                    bounceAnimation: widget.bounceAnimation,
                    floatAnimation: widget.floatAnimation,
                    pulseAnimation: widget.pulseAnimation,
                    unitColor: unitColor),
              ),
            ),
          ),
        ));

        bool isLastInUnit = false;
        for (var unit in widget.units) {
          int unitLastIndex = unit.startIndex + unit.lessonCount - 1;
          if (lessonData.id == unitLastIndex) {
            isLastInUnit = true;
            break;
          }
        }

        if (isLastInUnit) {
          slivers.add(SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1.2,
                        indent: 16,
                        endIndent: 8,
                      ),
                    ),
                    Text(
                      'CHAPTER ENDED',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1.2,
                        indent: 8,
                        endIndent: 16,
                      ),
                    ),
                  ],
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
  double get maxExtent => 86.0;

  @override
  double get minExtent => 86.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                Text(
                  description,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
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
  final int unitNumber;
  final Color unitColor;

  const ModernLevelButton({
    super.key,
    required this.lessonNumber,
    required this.isCompleted,
    required this.isCurrent,
    required this.unitNumber,
    required this.isBonus,
    required this.bounceAnimation,
    required this.floatAnimation,
    required this.pulseAnimation,
    required this.unitColor,
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
                    SvgPicture.asset(
                      widget.isBonus
                          ? AssetPath.bonusSvg
                          : (widget.isCurrent
                              ? (unitColorAssetMap[widget.unitColor]
                                      ?['starred'] ??
                                  AssetPath.purpleStarredSvg)
                              : (widget.isCompleted
                                  ? (unitColorAssetMap[widget.unitColor]
                                          ?['normal'] ??
                                      AssetPath.purpleSvg)
                                  : (unitColorAssetMap[widget.unitColor]
                                          ?['inactive_starred'] ??
                                      AssetPath.inactiveStarredSvg))),
                    ),
                    if (widget.isCurrent)
                      Positioned(
                        top: -20,
                        child: Text(
                          "START",
                          style: Get.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
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
