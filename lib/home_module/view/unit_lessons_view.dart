import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:lingolearn/auth_module/models/lesson_model.dart';
import 'package:lingolearn/home_module/models/get_home_language_model.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/config.dart';
import 'package:lingolearn/main.dart' hide userStatsController;
import 'package:lingolearn/utilities/theme/app_colors.dart';
import 'package:lingolearn/home_module/widgets/course_overview_card.dart';
import 'package:lingolearn/utilities/common/secondary_header.dart';

class UnitLessonsView extends StatefulWidget {
  final Units selectedUnit;
  final List<Units> units;
  final int? lastCompletedId;

  const UnitLessonsView({
    super.key,
    required this.selectedUnit,
    required this.units,
    this.lastCompletedId,
  });

  @override
  State<UnitLessonsView> createState() => _UnitLessonsViewState();
}

class _UnitLessonsViewState extends State<UnitLessonsView>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
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
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedUnitLessons =
        widget.selectedUnit.lessons ?? const <Lessons>[];
    final allLessons =
        widget.units.expand((u) => u.lessons ?? const <Lessons>[]).toList();

    // build pathItems for the selected unit
    final pathItems = <PathItem>[];
    int pathItemIndex = 0;

    pathItems.add(PathItem(
      type: 'unit',
      data: widget.selectedUnit,
      pathIndex: pathItemIndex++,
      unitIndex: widget.units.indexOf(widget.selectedUnit) + 1,
    ));

    for (final lesson in selectedUnitLessons) {
      pathItems.add(PathItem(
        type: 'lesson',
        data: lesson,
        pathIndex: pathItemIndex++,
        unitIndex: widget.units.indexOf(widget.selectedUnit) + 1,
      ));
    }

    return Scaffold(
      backgroundColor: kSurface,
      body: Column(
        children: [
          _buildUnitHeader(),
          Expanded(
            child: DuolingoLessonPathView(
              pathItems: pathItems,
              allLessons: allLessons,
              bounceAnimation: _bounceAnimation,
              floatAnimation: _floatAnimation,
              pulseAnimation: _pulseAnimation,
              units: [widget.selectedUnit],
              lastCompletedId: widget.lastCompletedId,
              onRefresh: () async {
                await appController.refreshAllData();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitHeader() {
    final unitIndex = widget.units.indexOf(widget.selectedUnit) + 1;
    final accentColor = unitColors[(unitIndex - 1) % unitColors.length];

    return SecondaryHeader(
      title: widget.selectedUnit.name ?? "Lessons",
      subtitle: "UNIT $unitIndex",
      subtitleColor: accentColor.withValues(alpha: 0.8),
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

  bool _hasInitialScrollHappened = false;

  void _initScroll() {
    if (widget.pathItems.isEmpty || _hasInitialScrollHappened) return;

    final firstLessonIndex =
        widget.pathItems.indexWhere((p) => p.type == 'lesson');
    if (firstLessonIndex == -1) return;

    // Prioritize "isCurrent" lesson
    int targetIndex = widget.pathItems.indexWhere(
        (p) => p.type == 'lesson' && (p.data as Lessons).isCurrent == true);

    // Fallback to last completed lesson if no current lesson marked
    if (targetIndex == -1) {
      targetIndex = widget.pathItems.indexWhere((p) =>
          p.type == 'lesson' &&
          widget.lastCompletedId != null &&
          (p.data as Lessons).id == widget.lastCompletedId);
    }

    if (targetIndex == -1) targetIndex = firstLessonIndex;

    final targetLesson = widget.pathItems[targetIndex];

    void executeScroll() {
      final key = _lessonKeys[targetLesson.pathIndex];
      final ctx = key?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
          alignment: 0.5,
        );
        _hasInitialScrollHappened = true;
      } else {
        // Retry if context not ready
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && !_hasInitialScrollHappened) {
            executeScroll();
          }
        });
      }
    }

    executeScroll();
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
        final screenHeight = MediaQuery.of(context).size.height;
        final buttonHeight = box.size.height;
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
    } catch (e) {}
  }

  void _onScroll() {
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
        CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: _buildSliverLessonPath(),
        ),
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
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 10)));

    // Add Unit Overview Card at the top
    if (widget.units.isNotEmpty) {
      slivers.add(SliverToBoxAdapter(
        child: UnitOverviewCard(
          unit: widget.units.first,
          unitColor: unitColors[
              (widget.pathItems[0].unitIndex! - 1) % unitColors.length],
        ),
      ));
    }

    final unitColor =
        unitColors[(widget.pathItems[0].unitIndex! - 1) % unitColors.length];

    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 30)));

    for (int i = 0; i < widget.pathItems.length; i++) {
      final item = widget.pathItems[i];
      if (item.type == 'unit') continue;
      final lessonData = item.data as Lessons;
      final isLastInUnit = lessonData.id == widget.units.first.lessons?.last.id;
      final isFirstInUnit =
          i == 0 || (i > 0 && widget.pathItems[i - 1].type == 'unit');

      slivers.add(SliverToBoxAdapter(
        child: TimelineLessonItem(
          key: _lessonKeys[item.pathIndex],
          lesson: lessonData,
          unitColor: unitColor,
          isLast: isLastInUnit,
          isFirst: isFirstInUnit,
          unitNumber: widget.units.first.id?.toInt() ?? 0,
        ),
      ));
    }

    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 100)));
    return slivers;
  }
}

class TimelineLessonItem extends StatelessWidget {
  final Lessons lesson;
  final Color unitColor;
  final bool isLast;
  final bool isFirst;
  final int unitNumber;

  const TimelineLessonItem({
    super.key,
    required this.lesson,
    required this.unitColor,
    required this.isLast,
    required this.isFirst,
    required this.unitNumber,
  });

  void _handleNavigation(BuildContext context, String lessonId) {
    if (kDebugMode) print("🚀 [Navigation] Tapped lesson: ${lesson.name}");

    if (!appController.performActionWithConnection(context,
        actionName: "start this lesson")) {
      if (kDebugMode) print("❌ [Navigation] Blocked by connection check");
      return;
    }
    HapticFeedback.mediumImpact();

    final isCompleted = lesson.isCompleted ?? false;
    final isCurrent = lesson.isCurrent ?? false;

    if (kDebugMode) {
      print(
          "🔍 [Navigation] Status: isCompleted=$isCompleted, isCurrent=$isCurrent");
      print(
          "🔍 [Navigation] ExternalID: ${lesson.externalId}, UnitNumber: $unitNumber");
    }

    if (!isCompleted && !isCurrent) {
      if (kDebugMode) print("⚠️ [Navigation] Lesson is LOCKED. Aborting.");
      return;
    }

    if (lesson.externalId == null) {
      return;
    }

    MyNavigator.pushNamed(
      GoPaths.exercisesView,
      extra: {'slug': lesson.externalId, "lessonId": lessonId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = lesson.isCompleted ?? false;
    final bool isCurrent = lesson.isCurrent ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vertical Timeline Line and Circle
            SizedBox(
              width: 60,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Line
                  if (!isLast)
                    Positioned(
                      top: 40,
                      bottom: 0,
                      child: Container(
                        width: 2.5,
                        color: kBorder,
                      ),
                    ),
                  if (!isFirst)
                    Positioned(
                      top: 0,
                      bottom: 40,
                      child: Container(
                        width: 2.5,
                        color: kBorder,
                      ),
                    ),
                  // The Circle
                  Positioned(
                    top: 5,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? kDarkSlate
                            : (isCompleted
                                ? kDarkSlate
                                : kDarkSlate.withValues(alpha: 0.1)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent ? unitColor : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: unitColor.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_rounded
                            : (isCurrent
                                ? Icons.play_arrow_rounded
                                : Icons.lock_outline_rounded),
                        color: isCompleted || isCurrent
                            ? Colors.white
                            : kDarkSlate.withValues(alpha: 0.4),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Content Card
            Expanded(
              child: InkWell(
                onTap: () => _handleNavigation(context, lesson.id.toString()),
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson.name ?? "Lesson",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: kDarkSlate,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isCompleted
                                    ? "Lesson Completed"
                                    : (isCurrent
                                        ? "Ongoing Now"
                                        : "Unlock to continue"),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isCurrent ? unitColor : kMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: kMuted.withValues(alpha: 0.4),
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: kBorder, height: 1),
                    const SizedBox(height: 16), // Spacing for the timeline look
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 20, top: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFC4E83A), // Lime green from reference
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: kDarkSlate,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UnitOverviewCard extends StatelessWidget {
  final Units unit;
  final Color unitColor;

  const UnitOverviewCard({
    super.key,
    required this.unit,
    required this.unitColor,
  });

  @override
  Widget build(BuildContext context) {
    if (unit.description == null || unit.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    final data = _parseMetadata(unit.description!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: CourseOverviewCard(
        description: data.description,
        themeColor: unitColor,
        resources: data.resources
            .map((r) => OverviewResource(
                  type: r.type,
                  title: r.title,
                  url: r.url,
                ))
            .toList(),
      ),
    );
  }

  _ParsedData _parseMetadata(String raw) {
    String title = "";
    String description = "";
    List<_Resource> resources = [];

    final lines = raw.split('\n');
    bool inResources = false;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('# ')) {
        title = line.substring(2);
      } else if (line.toLowerCase().contains('visit the following resources')) {
        inResources = true;
      } else if (inResources && line.startsWith('- ')) {
        final match = RegExp(r'\[@(.*)@(.*)\]\((.*)\)').firstMatch(line);
        if (match != null) {
          resources.add(_Resource(
            type: match.group(1) ?? "info",
            title: match.group(2) ?? "Learn more",
            url: match.group(3) ?? "",
          ));
        }
      } else if (!inResources) {
        if (description.isNotEmpty) description += " ";
        description += line;
      }
    }

    return _ParsedData(
        title: title, description: description, resources: resources);
  }
}

class _Resource {
  final String type;
  final String title;
  final String url;
  _Resource({required this.type, required this.title, required this.url});
}

class _ParsedData {
  final String title;
  final String description;
  final List<_Resource> resources;
  _ParsedData(
      {required this.title,
      required this.description,
      required this.resources});
}
