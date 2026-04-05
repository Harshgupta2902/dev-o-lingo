import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/models/get_home_language_model.dart';
import 'package:lingolearn/main.dart' hide userStatsController;
import 'package:lingolearn/utilities/constants/assets_path.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/skeleton/lesson_path_skeleton.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

class LessonPathScreen extends StatefulWidget {
  const LessonPathScreen({super.key});

  @override
  State<LessonPathScreen> createState() => _LessonPathScreenState();
}

class _LessonPathScreenState extends State<LessonPathScreen>
    with TickerProviderStateMixin {
  final Map<int, GlobalKey> _unitKeys = {};
  bool _hasScrolledToActiveUnit = false;
  int _selectedTab = 0; // 0 for Ongoing, 1 for Completed

  @override
  void initState() {
    super.initState();
  }

  void _onUnitSelected(Units unit) {
    MyNavigator.pushNamed(
      GoPaths.unitLessonsView,
      extra: {
        'selectedUnit': unit,
        'units': languageController.state?.data?.units ?? <Units>[],
        'lastCompletedId':
            languageController.state?.data?.lastCompletedLessonId,
      },
    );
  }

  Future<void> _onRefresh() async {
    _hasScrolledToActiveUnit = false;
    await appController.refreshAllData();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: kBeigeBg,
      body: languageController.obx(
        (state) {
          if (state == null) {
            return const Center(child: Text("No data found"));
          }

          final unitsFromApi = state.data?.units ?? <Units>[];
          final lastCompletedId = state.data?.lastCompletedLessonId;

          // Process logic for unlocking (derivations)
          final allLessons = unitsFromApi
              .expand((u) => u.lessons ?? const <Lessons>[])
              .toList();

          if (allLessons.isNotEmpty && lastCompletedId != null) {
            bool unlocked = true;
            for (final lesson in allLessons) {
              final lessonId = lesson.id ?? 0;
              if (lessonId == (lastCompletedId + 1)) {
                lesson.isCompleted = false; // Next lesson is not completed yet
                lesson.isCurrent = true;
                unlocked = false;
              } else if (unlocked) {
                lesson.isCompleted = true;
                lesson.isCurrent = false;
              } else {
                lesson.isCompleted = false;
                lesson.isCurrent = false;
              }
            }
          }

          // --- Filtering Logic for Ongoing vs Completed ---
          final filteredUnits = unitsFromApi.where((unit) {
            int completedCount =
                unit.lessons?.where((l) => l.isCompleted == true).length ?? 0;
            int totalCount = unit.lessons?.length ?? 0;
            if (totalCount == 0) totalCount = unit.lessonCount?.toInt() ?? 1;

            bool isDone = completedCount >= totalCount && totalCount > 0;
            return _selectedTab == 1 ? isDone : !isDone;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderTitle(),
              _buildModernTabs(),
              Expanded(
                child: Builder(builder: (context) {
                  int activeIndex = 0;
                  if (lastCompletedId != null) {
                    for (int i = 0; i < filteredUnits.length; i++) {
                      if (filteredUnits[i]
                              .lessons
                              ?.any((l) => l.id == (lastCompletedId + 1)) ??
                          false) {
                        activeIndex = i;
                        break;
                      }
                    }
                  }

                  // Trigger scroll animation
                  if (!_hasScrolledToActiveUnit && filteredUnits.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      void scroll() {
                        final key = _unitKeys[activeIndex];
                        if (key?.currentContext != null) {
                          Scrollable.ensureVisible(
                            key!.currentContext!,
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeInOutCubic,
                            alignment: 0.5,
                          );
                          _hasScrolledToActiveUnit = true;
                        } else {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (mounted && !_hasScrolledToActiveUnit) {
                              scroll();
                            }
                          });
                        }
                      }

                      scroll();
                    });
                  }

                  if (filteredUnits.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedTab == 1
                                ? Icons.check_circle_outline_rounded
                                : Icons.flag_outlined,
                            size: 64,
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedTab == 1
                                ? "No units completed yet."
                                : "You've finished everything!",
                            style: TextStyle(
                                color: Colors.grey.withValues(alpha: 0.6),
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    itemCount: filteredUnits.length,
                    itemBuilder: (context, index) {
                      final unit = filteredUnits[index];
                      final color =
                          unitCardColors[index % unitCardColors.length];
                      _unitKeys[index] ??= GlobalKey();

                      return _ModernUnitCard(
                        key: _unitKeys[index],
                        unit: unit,
                        unitIndex: index + 1,
                        backgroundColor: color,
                        onTap: () => _onUnitSelected(unit),
                      );
                    },
                  );
                }),
              ),
            ],
          );
        },
        onLoading: const LessonPathSkeleton(isUnitList: true),
        onError: (err) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.orange),
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

  Widget _buildHeaderTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Improve ${languageController.state?.data?.languageTitle ?? ""}",
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 36,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
              letterSpacing: -1,
            ),
          ),
          const Text(
            "day by day",
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 36,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9CA3AF),
              fontStyle: FontStyle.italic,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFEFECCF).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: _TabItem(
                label: "Ongoing",
                isSelected: _selectedTab == 0,
                onTap: () => setState(() => _selectedTab = 0),
              ),
            ),
            Expanded(
              child: _TabItem(
                label: "Completed",
                isSelected: _selectedTab == 1,
                onTap: () => setState(() => _selectedTab = 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFECCF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _ModernUnitCard extends StatelessWidget {
  final Units unit;
  final int unitIndex;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ModernUnitCard({
    super.key,
    required this.unit,
    required this.unitIndex,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    int completedCount =
        unit.lessons?.where((l) => l.isCompleted == true).length ?? 0;
    int totalCount = unit.lessons?.length ?? 0;
    if (totalCount == 0) totalCount = unit.lessonCount?.toInt() ?? 1;
    double progressValue = totalCount > 0 ? (completedCount / totalCount) : 0;
    int starCount = (progressValue * 5).floor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
            bottomLeft: Radius.circular(8),
          ),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit.name ?? "Unit $unitIndex",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          index < starCount
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 20,
                          color: index < starCount
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF1F2937).withValues(alpha: 0.1),
                        ),
                      );
                    }),
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
