import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:lingolearn/auth_module/models/lesson_model.dart';
import 'package:lingolearn/home_module/models/get_home_language_model.dart';
import 'package:lingolearn/home_module/view/quiz_screen.dart';
import 'package:lingolearn/main.dart' hide userStatsController;
import 'package:lingolearn/utilities/constants/assets_path.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/packages/liquid_pull_to_refresh.dart';
import 'package:lingolearn/utilities/skeleton/lesson_path_skeleton.dart';
import 'package:lingolearn/home_module/view/path_painter.dart';
import 'package:lingolearn/utilities/theme/app_box_decoration.dart';
import 'package:lingolearn/config.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

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
  final _selectedUnit = Rxn<Units>();
  final Map<int, GlobalKey> _unitKeys = {};
  bool _hasScrolledToActiveUnit = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
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

  void _onUnitSelected(Units unit) {
    _selectedUnit.value = unit;
  }

  void _onBackToUnits() {
    _selectedUnit.value = null;
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _floatController.dispose();
    _pulseController.dispose(); // Added missing dispose for _pulseController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: languageController.obx(
        (state) {
          if (state == null) {
            return const Center(child: Text("No data found"));
          }

          // ---- derive view-model from controller state ----
          final unitsFromApi = state.data?.units ?? <Units>[];
          final lastCompletedId = state.data?.lastCompletedLessonId;

          return Obx(() {
            // ---- global data marking (applies to Unit List and Lesson Path) ----
            final allLessons = unitsFromApi
                .expand((u) => u.lessons ?? const <Lessons>[])
                .toList();

            if (allLessons.isNotEmpty && lastCompletedId != null) {
              bool unlocked = true;
              for (final lesson in allLessons) {
                if (lesson.id == (lastCompletedId + 1)) {
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

            if (_selectedUnit.value == null) {
              return Column(
                children: [
                  Obx(() => !appController.isOnline.value
                      ? _buildOfflineBanner()
                      : const SizedBox.shrink()),
                  _buildHeader(),
                  Expanded(
                    child: LiquidPullToRefresh(
                      onRefresh: _onRefresh,
                      color: kPrimary,
                      backgroundColor: Colors.white,
                      animSpeedFactor: 2.0,
                      child: Builder(builder: (context) {
                        // Calculate active index once per refresh
                        int activeIndex = 0;
                        if (lastCompletedId != null) {
                          for (int i = 0; i < unitsFromApi.length; i++) {
                            if (unitsFromApi[i].lessons?.any(
                                    (l) => l.id == (lastCompletedId + 1)) ??
                                false) {
                              activeIndex = i;
                              break;
                            }
                          }
                        }

                        // Trigger scroll animation
                        if (!_hasScrolledToActiveUnit &&
                            unitsFromApi.isNotEmpty) {
                          _hasScrolledToActiveUnit = true;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final key = _unitKeys[activeIndex];
                            if (key?.currentContext != null) {
                              Scrollable.ensureVisible(
                                key!.currentContext!,
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeInOutCubic,
                                alignment: 0.5,
                              );
                            }
                          });
                        }

                        return ListView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          children: List.generate(unitsFromApi.length, (index) {
                            final unit = unitsFromApi[index];
                            final color = unitColors[index % unitColors.length];
                            _unitKeys[index] ??= GlobalKey();

                            return UnitCard(
                              key: _unitKeys[index],
                              unit: unit,
                              unitIndex: index + 1,
                              color: color,
                              onTap: () => _onUnitSelected(unit),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ],
              );
            }

            // ---- derive view-model for SELECTED unit ----
            final selectedUnitLessons =
                _selectedUnit.value!.lessons ?? const <Lessons>[];

            // build pathItems for the selected unit
            final pathItems = <PathItem>[];
            int pathItemIndex = 0;

            pathItems.add(PathItem(
              type: 'unit',
              data: _selectedUnit.value!,
              pathIndex: pathItemIndex++,
              unitIndex: unitsFromApi.indexOf(_selectedUnit.value!) + 1,
            ));

            for (final lesson in selectedUnitLessons) {
              pathItems.add(PathItem(
                type: 'lesson',
                data: lesson,
                pathIndex: pathItemIndex++,
                unitIndex: unitsFromApi.indexOf(_selectedUnit.value!) + 1,
              ));
            }

            return Column(
              children: [
                Obx(() => !appController.isOnline.value
                    ? _buildOfflineBanner()
                    : const SizedBox.shrink()),
                _buildLessonHeader(),
                Expanded(
                  child: DuolingoLessonPathView(
                    pathItems: pathItems,
                    allLessons: allLessons,
                    bounceAnimation: _bounceAnimation,
                    floatAnimation: _floatAnimation,
                    pulseAnimation: _pulseAnimation,
                    units: [_selectedUnit.value!],
                    lastCompletedId: lastCompletedId,
                    onRefresh: _onRefresh,
                  ),
                ),
              ],
            );
          });
        },
        onLoading: Obx(
            () => LessonPathSkeleton(isUnitList: _selectedUnit.value == null)),
        onError: (err) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text("Error: $err", textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onRefresh,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonHeader() {
    final unitIndex =
        (languageController.state?.data?.units?.indexOf(_selectedUnit.value!) ??
                0) +
            1;
    final color = unitColors[(unitIndex - 1) % unitColors.length];

    return Container(
      padding: const EdgeInsets.only(top: 40, left: 10, right: 20, bottom: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: _onBackToUnits,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.grey, size: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "UNIT $unitIndex",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  _selectedUnit.value?.name ?? "Lessons",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    _hasScrolledToActiveUnit = false;
    await appController.refreshAllData();
  }

  Widget _buildHeader() {
    return userStatsController.obx(
      (state) {
        return Container(
          padding:
              const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 10),
          child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(Icons.local_fire_department,
                      "${state?.streak ?? 0}", Colors.orange),
                  GestureDetector(
                    onTap: () => MyNavigator.pushNamed(GoPaths.shopScreen),
                    child: _buildStatItem(
                        Icons.diamond, "${state?.gems ?? 0}", Colors.blue),
                  ),
                  _buildStatItem(
                      Icons.star, "${state?.xp ?? 0}", Colors.purple),
                  _buildStatItem(
                      Icons.favorite, "${state?.hearts ?? 0}", Colors.red),
                  if (!appController.isOnline.value)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_off_rounded,
                          color: Colors.orange, size: 20),
                    ),
                ],
              )),
        );
      },
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 44, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Offline Mode",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Showing last saved progress",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _onRefresh,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "SYNC",
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
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
}

class DuolingoLessonPathView extends StatefulWidget {
  final List<PathItem> pathItems;
  final List<Lessons> allLessons;
  final List<Units> units;
  final Animation<double> bounceAnimation;
  final Animation<double> floatAnimation;
  final Animation<double> pulseAnimation;
  final int? lastCompletedId;
  final Future<void> Function() onRefresh;

  const DuolingoLessonPathView({
    super.key,
    required this.pathItems,
    required this.bounceAnimation,
    required this.floatAnimation,
    required this.allLessons,
    required this.pulseAnimation,
    required this.units,
    required this.onRefresh,
    this.lastCompletedId,
  });

  @override
  State<DuolingoLessonPathView> createState() => _DuolingoLessonPathViewState();
}

class _DuolingoLessonPathViewState extends State<DuolingoLessonPathView> {
  late final ScrollController _scrollController;
  final Map<int, GlobalKey> _lessonKeys = {};
  int? _currentUnitIndex;
  bool _isStartButtonVisible = true;
  bool _isStartButtonAbove = false;
  int? _startButtonPathIndex;
  Color _startButtonUnitColor = unitColors[0];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _generateKeys();
    _findStartButton();

    // ✅ Post-frame scroll and visibility check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initScroll();
        _checkStartButtonVisibility();
      }
    });
  }

  @override
  void didUpdateWidget(covariant DuolingoLessonPathView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pathItems != widget.pathItems) {
      _generateKeys();
      _findStartButton();
      _checkStartButtonVisibility();
    }
  }

  void _generateKeys() {
    for (var item in widget.pathItems) {
      if (!_lessonKeys.containsKey(item.pathIndex)) {
        _lessonKeys[item.pathIndex] = GlobalKey();
      }
    }
  }

  void _findStartButton() {
    final startIndex = widget.pathItems.indexWhere(
        (p) => p.type == 'lesson' && (p.data as Lessons).isCurrent == true);
    if (startIndex != -1) {
      final item = widget.pathItems[startIndex];
      _startButtonPathIndex = item.pathIndex;
      final unitIndex = item.unitIndex ?? 1;
      _startButtonUnitColor = unitColors[(unitIndex - 1) % unitColors.length];
    }
  }

  void _initScroll() {
    if (widget.pathItems.isEmpty) return;

    // Default header
    final firstUnitIndex = widget.pathItems.indexWhere((p) => p.type == 'unit');
    if (firstUnitIndex != -1) {
      _currentUnitIndex = widget.pathItems[firstUnitIndex].pathIndex;
    }

    // Pick target lesson safely
    final firstLessonIndex =
        widget.pathItems.indexWhere((p) => p.type == 'lesson');
    if (firstLessonIndex == -1) return;

    int targetIndex = widget.pathItems.indexWhere((p) =>
        p.type == 'lesson' &&
        widget.lastCompletedId != null &&
        (p.data as Lessons).id == widget.lastCompletedId);

    if (targetIndex == -1) {
      // If no last completed, target the current (active) lesson
      targetIndex = widget.pathItems.indexWhere(
          (p) => p.type == 'lesson' && (p.data as Lessons).isCurrent == true);
    }

    if (targetIndex == -1) targetIndex = firstLessonIndex;

    final targetLesson = widget.pathItems[targetIndex];

    // Set header to the unit above target lesson
    for (int i = targetLesson.pathIndex; i >= 0; i--) {
      if (widget.pathItems[i].type == 'unit') {
        _currentUnitIndex = widget.pathItems[i].pathIndex;
        break;
      }
    }

    // Scroll into view
    final key = _lessonKeys[targetLesson.pathIndex];
    final ctx = key?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
        alignment: 0.5,
      );
    }
  }

  void _checkStartButtonVisibility() {
    if (_startButtonPathIndex == null) return;

    final key = _lessonKeys[_startButtonPathIndex];
    if (key == null || key.currentContext == null) return;

    try {
      final renderObject = key.currentContext!.findRenderObject();
      if (renderObject == null) return;

      if (renderObject is RenderBox) {
        final box = renderObject;
        final offset = box.localToGlobal(Offset.zero).dy;
        // Button height is typically 72px for the button,
        // but the card is larger. We use a buffer.
        final screenHeight = MediaQuery.of(context).size.height;
        final buttonHeight = box.size.height;

        // Button is visible if it's within screen bounds (with buffer for headers)
        // Adjust the range: 140px is a safe area below the header
        final isVisible =
            (offset + buttonHeight) >= 160 && offset <= (screenHeight - 80);

        final isAbove = offset < 160;

        if (_isStartButtonVisible != isVisible ||
            _isStartButtonAbove != isAbove) {
          setState(() {
            _isStartButtonVisible = isVisible;
            _isStartButtonAbove = isAbove;
          });
        }
      }
    } catch (e) {
      // Ignore errors during visibility check
    }
  }

  void _onScroll() {
    // Check unit headers
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

    // Check if START button is visible
    _checkStartButtonVisibility();
  }

  void _scrollToStartButton() {
    if (_startButtonPathIndex != null) {
      final key = _lessonKeys[_startButtonPathIndex];
      final ctx = key?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
          alignment: 0.5,
        );
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
    return Stack(
      children: [
        LiquidPullToRefresh(
          backgroundColor: Colors.white,
          animSpeedFactor: 2.0,
          onRefresh: widget.onRefresh,
          color: widget.pathItems.isNotEmpty
              ? unitColors[
                  (widget.pathItems[0].unitIndex ?? 1 - 1) % unitColors.length]
              : unitColors[0],
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: _buildSliverLessonPath(),
          ),
        ),

        // Floating action button to scroll to START
        if (AppConfig.showRecenterButton &&
            !_isStartButtonVisible &&
            _startButtonPathIndex != null)
          Positioned(
            right: 16,
            bottom: 30,
            child: FloatingActionButton(
              onPressed: _scrollToStartButton,
              backgroundColor: _startButtonUnitColor,
              elevation: 4,
              heroTag: 'start_fab',
              child: Icon(
                _isStartButtonAbove
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildSliverLessonPath() {
    List<Widget> slivers = [];

    // Add some top padding
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 20)));

    for (int i = 0; i < widget.pathItems.length; i++) {
      final item = widget.pathItems[i];
      if (item.type == 'unit') {
        // Skip unit header inside the list as we have a pinned one in LessonPathScreen
        continue;
      } else {
        final lessonData = item.data as Lessons;
        final lessonNumber = item.unitIndex ?? 0;

        // Refined snake path: uses pathIndex to create a symmetric horizontal wave
        final translateX = 60 * math.sin((i * 1.0));
        final unitNumber = lessonData.id ?? 0;
        final unitColor = unitColors[(lessonNumber - 1) % unitColors.length];
        final slug = lessonData.externalId;

        // Determine if we should draw a path to the next item
        bool shouldDrawPath = false;
        double nextTranslateX = 0;

        // Look ahead
        if (i + 1 < widget.pathItems.length) {
          final nextItem = widget.pathItems[i + 1];
          // Only draw path if next item is also a lesson (not a unit header)
          if (nextItem.type == 'lesson') {
            nextTranslateX = 80 * math.sin((nextItem.pathIndex * 120) / 100);
            shouldDrawPath = true;
          }
        }

        bool isLastInUnit = false;
        for (var unit in widget.units) {
          int unitLastIndex = unit.lessons?.last.id ?? 0;
          if (lessonData.id == unitLastIndex) {
            isLastInUnit = true;
            break;
          }
        }

        // Color logic for the path:
        // Use unitColor if this lesson is completed (implying path to next is active/done)
        // OR if next is completed.
        // If current is NOT completed, path is gray (locked).
        // Exceptions: if current is active (isCurrent), path out from it is typically gray (locked) util we finish.
        final pathColor =
            (lessonData.isCompleted == true) ? unitColor : Colors.grey.shade300;

        slivers.add(SliverToBoxAdapter(
          child: Container(
            key: _lessonKeys[item.pathIndex],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Transform.translate(
                offset: Offset(translateX, 0),
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // The Path Painter (drawing line from bottom edge to next top edge)
                      if (AppConfig.showLessonPathLines &&
                          shouldDrawPath &&
                          !isLastInUnit)
                        Positioned(
                          top: 72, // Bottom edge of 72px button
                          left: 36, // Center horizontally
                          child: CustomPaint(
                            painter: PathPainter(
                              startX: 0,
                              endX: nextTranslateX - translateX,
                              height: 32, // Gap between buttons (16 + 16)
                              color: pathColor,
                            ),
                          ),
                        ),

                      // The actual button or card
                      ModernLevelButton(
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
                        lessonName: lessonData.name ?? "",
                        totalLessons: widget.units
                                .firstWhere((u) => u.id == lessonData.unitId,
                                    orElse: () => widget.units.isNotEmpty
                                        ? widget.units.first
                                        : Units())
                                .lessonCount
                                ?.toInt() ??
                            0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));

        if (isLastInUnit) {
          slivers.add(SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: unitColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Unit Complete!',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.check_circle_rounded,
                      color: unitColor,
                      size: 24,
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
  final String lessonName;
  final int totalLessons;

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
    required this.lessonName,
    required this.totalLessons,
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
    if (!appController.performActionWithConnection(context,
        actionName: "start this lesson")) {
      return;
    }
    HapticFeedback.mediumImpact();

    if (!widget.isCompleted && !widget.isCurrent) {
      // Locked lesson, do nothing or show a brief toast
      return;
    }

    if (widget.isCompleted && !widget.isCurrent) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  widget.unitColor.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: widget.unitColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 48,
                    color: widget.unitColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Restart Lesson?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'You\'ve already completed this lesson.\nWould you like to practice again?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Restart button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (appController.performActionWithConnection(context,
                              actionName: "start this lesson")) {
                            _navigateToLesson();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.unitColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Restart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

        if (widget.isCurrent && AppConfig.showFloatingStartButton) {
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
                    // The SVG button
                    SvgPicture.asset(
                      (!widget.isCompleted && !widget.isCurrent)
                          ? (widget.isLastInUnit
                              ? AssetPath.inactiveStarredSvg
                              : AssetPath.inactiveSvg)
                          : (widget.isLastInUnit
                              ? (unitColorAssetMap[widget.unitColor]
                                      ?['starred'] ??
                                  AssetPath.inactiveStarredSvg)
                              : (unitColorAssetMap[widget.unitColor]
                                      ?['normal'] ??
                                  AssetPath.inactiveSvg)),
                    ),

                    // Expanded Lesson Card for Current Lesson
                    if (widget.isCurrent)
                      Positioned(
                        top: 85,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: widget.unitColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.lessonName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Lesson ${widget.lessonNumber} of ${widget.totalLessons}",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {
                                  if (appController.performActionWithConnection(
                                      context,
                                      actionName: "start this lesson")) {
                                    _navigateToLesson();
                                  }
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "START",
                                    style: TextStyle(
                                      color: widget.unitColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Pointer pointing UP to the icon
                    if (widget.isCurrent)
                      Positioned(
                        top: 73,
                        child: CustomPaint(
                          size: const Size(24, 12),
                          painter:
                              _SpeechBubbleTailPainter(color: widget.unitColor),
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

// Speech bubble tail painter
class _SpeechBubbleTailPainter extends CustomPainter {
  final Color color;

  _SpeechBubbleTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class UnitCard extends StatelessWidget {
  final Units unit;
  final int unitIndex;
  final Color color;
  final VoidCallback onTap;

  const UnitCard({
    super.key,
    required this.unit,
    required this.unitIndex,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress
    int completedCount =
        unit.lessons?.where((l) => l.isCompleted == true).length ?? 0;
    int totalCount = unit.lessons?.length ?? 0;
    if (totalCount == 0) totalCount = unit.lessonCount?.toInt() ?? 1;
    double progress = totalCount > 0 ? (completedCount / totalCount) : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: AppBoxDecoration.getBoxDecoration(
          color: Colors.white,
          borderRadius: 24,
        ),
        child: Column(
          children: [
            // Top Section with Color
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "UNIT $unitIndex",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          unit.name ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Section with Progress
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${(progress * 100).toInt()}% COMPLETE",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        "$completedCount/$totalCount Lessons",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
