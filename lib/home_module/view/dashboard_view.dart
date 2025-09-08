import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:lingolearn/auth_module/models/lesson_model.dart';
import 'package:lingolearn/home_module/controller/language_controller.dart';
import 'package:lingolearn/home_module/models/get_home_language_model.dart';
import 'package:lingolearn/home_module/view/quiz_screen.dart';
import 'package:lingolearn/utilities/constants/assets_path.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/skeleton/lesson_path_skeleton.dart';
import 'package:lingolearn/utilities/theme/app_box_decoration.dart';

final languageController = Get.put(LanguageController());

const List<Color> unitColors = [
  Color(0xFFA568CC),
  Color(0xFFFF981F),
  Color(0xFF543ACC)
];

final Map<Color, Map<String, String>> unitColorAssetMap = {
  const Color(0xFFA568CC): {
    'normal': AssetPath.purpleSvg,
    'starred': AssetPath.purpleStarredSvg,
    'inactive': AssetPath.inactiveSvg,
    'inactive_starred': AssetPath.inactiveStarredSvg,
  },
  const Color(0xFFFF981F): {
    'normal': AssetPath.yellowSvg,
    'starred': AssetPath.yellowStarredSvg,
    'inactive': AssetPath.inactiveSvg,
    'inactive_starred': AssetPath.inactiveStarredSvg,
  },
  const Color(0xFF543ACC): {
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

  List<Lessons> allLessons = [];
  List<Units> units = [];
  final List<PathItem> pathItems = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        if (languageController.state != null) {
          _mapApiData(languageController.state!);
        }
      },
    );
  }

  List<Units> mapUnits(List<Units> apiUnits) {
    return apiUnits.asMap().entries.map((entry) {
      final u = entry.value;
      return Units(
        id: u.id,
        languageId: u.languageId ?? 0,
        name: u.name,
        externalId: u.externalId,
        lessonCount: u.lessonCount?.toInt() ?? 0,
      );
    }).toList();
  }

  List<Lessons> mapLessons(List<Units> apiUnits) {
    return apiUnits.expand((u) {
      return u.lessons?.map((l) {
            return Lessons(
              id: l.id,
              unitId: l.unitId ?? 0,
              name: l.name ?? "",
              externalId: l.externalId,
            );
          }).toList() ??
          <Lessons>[];
    }).toList();
  }

  void _mapApiData(GetHomeLanguageModel model) {
    final unitsFromApi = model.data?.units ?? [];
    final lastCompletedId = model.data?.lastCompletedLessonId;

    units = unitsFromApi;
    allLessons =
        unitsFromApi.expand((unit) => unit.lessons ?? <Lessons>[]).toList();

    if (lastCompletedId != null) {
      bool unlocked = true;
      for (var lesson in allLessons) {
        if (lesson.id == lastCompletedId) {
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
      _buildPathItems();
    });
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

      for (int i = 0; i < unit.lessonCount!; i++) {
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
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: allLessons.isEmpty
          ? const LessonPathSkeleton()
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
                      lastCompletedId: languageController
                          .state?.data?.lastCompletedLessonId),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return userStatsController.obx(
      (state) {
        return Container(
          padding:
              const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(Icons.local_fire_department,
                  "${state?.streak ?? 0}", Colors.orange),
              _buildStatItem(Icons.diamond, "${state?.gems ?? 0}", Colors.blue),
              _buildStatItem(Icons.star, "${state?.xp ?? 0}", Colors.purple),
              _buildStatItem(
                  Icons.favorite, "${state?.hearts ?? 0}", Colors.red),
            ],
          ),
        );
      },
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
}

class DuolingoLessonPathView extends StatefulWidget {
  final List<PathItem> pathItems;
  final List<Lessons> allLessons;
  final List<Units> units;
  final Animation<double> bounceAnimation;
  final Animation<double> floatAnimation;
  final Animation<double> pulseAnimation;
  final int? lastCompletedId;
  const DuolingoLessonPathView({
    super.key,
    required this.pathItems,
    required this.bounceAnimation,
    required this.floatAnimation,
    required this.allLessons,
    required this.pulseAnimation,
    required this.units,
    this.lastCompletedId,
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

    // ✅ Default header ke liye first unit
    final firstUnitIndex = widget.pathItems.indexWhere((p) => p.type == 'unit');
    if (firstUnitIndex != -1) {
      _currentUnitIndex = widget.pathItems[firstUnitIndex].pathIndex;
    }

    // ✅ Post-frame scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetLesson = widget.pathItems.firstWhere(
        (item) =>
            item.type == 'lesson' &&
            widget.lastCompletedId != null &&
            (item.data as Lessons).id == widget.lastCompletedId,
        orElse: () => widget.pathItems.firstWhere(
          (p) => p.type == 'lesson',
          orElse: () => widget.pathItems[firstUnitIndex],
        ),
      );

      // Header ko sahi unit par set karo
      for (int i = targetLesson.pathIndex; i >= 0; i--) {
        if (widget.pathItems[i].type == 'unit') {
          if (_currentUnitIndex != widget.pathItems[i].pathIndex) {
            setState(() {
              _currentUnitIndex = widget.pathItems[i].pathIndex;
            });
          }
          break;
        }
      }

      // ✅ Scroll to target lesson
      final key = _lessonKeys[targetLesson.pathIndex];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
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

    if (_currentUnitIndex != null &&
        _currentUnitIndex! < widget.pathItems.length &&
        widget.pathItems[_currentUnitIndex!].type == 'unit') {
      final unitData = widget.pathItems[_currentUnitIndex!].data as Units;
      final unitIndex = widget.pathItems[_currentUnitIndex!].unitIndex ?? 1;
      slivers.add(SliverPersistentHeader(
        pinned: true,
        delegate: _UnitHeaderDelegate(
          title: unitData.name ?? "",
          unitId: unitData.sortOrder!,
          externalId: unitData.externalId ?? "",
          isActive: true,
          unitColor: unitColors[(unitIndex - 1) % unitColors.length],
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
        final lessonData = item.data as Lessons;
        final lessonNumber = item.unitIndex ?? 0;
        final translateX = 80 * math.sin((item.pathIndex * 120) / 100);
        final unitNumber = lessonData.id ?? 0;
        final unitColor = unitColors[(lessonNumber - 1) % unitColors.length];

        final slug = lessonData.externalId;

        bool isLastInUnit = false;
        for (var unit in widget.units) {
          int unitLastIndex = unit.lessons?.last.id ?? 0;
          if (lessonData.id == unitLastIndex) {
            isLastInUnit = true;
            break;
          }
        }

        slivers.add(SliverToBoxAdapter(
          key: _lessonKeys[item.pathIndex],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Transform.translate(
              offset: Offset(translateX, 0),
              child: Center(
                child: ModernLevelButton(
                  slug: slug ?? "",
                  lessonNumber: lessonNumber,
                  unitNumber: unitNumber,
                  isCompleted: lessonData.isCompleted ?? false,
                  isCurrent: lessonData.isCurrent ?? false,
                  isBonus: false,
                  isLastInUnit: isLastInUnit,
                  bounceAnimation: widget.bounceAnimation,
                  floatAnimation: widget.floatAnimation,
                  pulseAnimation: widget.pulseAnimation,
                  unitColor: unitColor,
                ),
              ),
            ),
          ),
        ));

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
  final num unitId;
  final String externalId;
  final bool isActive;
  final Color unitColor;

  _UnitHeaderDelegate({
    required this.externalId,
    required this.unitId,
    required this.title,
    required this.isActive,
    required this.unitColor,
  });

  @override
  double get maxExtent => 86;

  @override
  double get minExtent => 86;

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
          GestureDetector(
            onTap: () => debugPrint("external id $externalId"),
            child: Container(
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Unit $unitId",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
        isActive != oldDelegate.isActive ||
        unitColor != oldDelegate.unitColor;
  }
}

class ModernLevelButton extends StatefulWidget {
  final int lessonNumber;
  final String slug;
  final bool isCompleted;
  final bool isCurrent;
  final bool isBonus;
  final bool isLastInUnit;
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
    required this.isLastInUnit,
    required this.bounceAnimation,
    required this.floatAnimation,
    required this.pulseAnimation,
    required this.unitColor,
    required this.slug,
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

  void _handlePress() {
    HapticFeedback.mediumImpact();

    if (widget.isCompleted && !widget.isCurrent) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Restart Lesson"),
          content: const Text("Do you want to start again?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _navigateToLesson();
              },
              child: const Text("Yes"),
            ),
          ],
        ),
      );
    } else {
      _navigateToLesson();
    }
  }

  void _navigateToLesson() {
    MyNavigator.pushNamed(
      GoPaths.exercisesView,
      extra: {
        'slug': widget.slug,
        "lessonId": widget.unitNumber.toString(),
      },
    );
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
              onTap: _handlePress,
              child: SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    SvgPicture.asset(
                      widget.isLastInUnit
                          ? (unitColorAssetMap[widget.unitColor]?['starred'] ??
                              AssetPath.inactiveStarredSvg)
                          : (unitColorAssetMap[widget.unitColor]?['normal'] ??
                              AssetPath.inactiveStarredSvg),

                      // widget.isBonus
                      //     ? AssetPath.inactiveStarredSvg
                      //     : (widget.isCurrent
                      //         ? (unitColorAssetMap[widget.unitColor]
                      //                 ?['starred'] ??
                      //             AssetPath.purpleStarredSvg)
                      //         : (widget.isCompleted
                      //             ? (unitColorAssetMap[widget.unitColor]
                      //                     ?['normal'] ??
                      //                 AssetPath.purpleSvg)
                      //             : (unitColorAssetMap[widget.unitColor]
                      //                     ?['inactive'] ??
                      //                 AssetPath.inactiveSvg))),
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
