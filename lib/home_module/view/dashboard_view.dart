import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/controller/profile_controller.dart';
import 'package:lingolearn/home_module/controller/notification_controller.dart';
import 'package:lingolearn/home_module/models/get_home_language_model.dart';
import 'package:lingolearn/main.dart';
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
  final profileController = Get.put(ProfileController());
  final notificationController = Get.put(NotificationController());
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
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildUserProfileHeader(),
              _buildNotificationBell(),
            ],
          ),
          const SizedBox(height: 16),
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
              fontSize: 32,
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

  Widget _buildUserProfileHeader() {
    return profileController.obx(
      (state) {
        final user = state?.data?.user;
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFD6E5), // Soft Pink
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundImage:
                    (user?.profile != null && user!.profile!.isNotEmpty)
                        ? NetworkImage(user.profile!)
                        : null,
                backgroundColor: Colors.transparent,
                child: (user?.profile == null || user!.profile!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userStatsController.obx(
                  (statsState) {
                    final emoji = statsState?.levelEmoji ?? '';
                    final title = statsState?.levelTitle ?? 'Beginner';
                    return Text(
                      '$title $emoji'.trim(),
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                  onLoading: Text(
                    user?.name ?? 'Beginner',
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onError: (_) => const Text(
                    'Beginner',
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  user?.name ?? "Beginner A1",
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        );
      },
      onLoading: const SizedBox.shrink(),
      onError: (_) => const SizedBox.shrink(),
    );
  }

  Widget _buildNotificationBell() {
    return userStatsController.obx((statsState) {
      final unreadCount = statsState?.unreadNotifications ?? 0;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: kCardYellow,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => MyNavigator.pushNamed(GoPaths.notificationView),
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF1F2937),
                size: 24,
              ),
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444), // errorMain / red
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    }, onLoading: _buildBellLoading(), onError: (_) => _buildBellLoading());
  }

  Widget _buildBellLoading() {
    return Container(
      decoration: const BoxDecoration(
        color: kCardYellow,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () => MyNavigator.pushNamed(GoPaths.notificationView),
        icon: const Icon(
          Icons.notifications_none_rounded,
          color: Color(0xFF1F2937),
          size: 24,
        ),
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
    bool isCurrentUnit = unit.lessons?.any((l) => l.isCurrent == true) ?? false;
    double progressValue = totalCount > 0 ? (completedCount / totalCount) : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Stack(
          children: [
            // Main Card
            Container(
              constraints: const BoxConstraints(minHeight: 140),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    backgroundColor,
                    Color.alphaBlend(
                      Colors.white.withValues(alpha: 0.5),
                      backgroundColor,
                    ),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    // Decorative Background Shapes
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: -40,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          // Progress Circular Indicator
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 72,
                                height: 72,
                                child: CircularProgressIndicator(
                                  value: 1.0,
                                  strokeWidth: 8,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                              SizedBox(
                                width: 72,
                                height: 72,
                                child: CircularProgressIndicator(
                                  value: progressValue,
                                  strokeWidth: 8,
                                  strokeCap: StrokeCap.round,
                                  color: const Color(0xFF1B2431),
                                ),
                              ),
                              Container(
                                width: 52,
                                height: 52,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  unitIndex.toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                    color: Color(0xFF1B2431),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),

                          // Unit Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isCurrentUnit)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1B2431),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      "CURRENT",
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                Text(
                                  "UNIT $unitIndex".toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1B2431)
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  unit.name ?? "Basics",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1B2431),
                                    height: 1.1,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.menu_book_rounded,
                                      size: 14,
                                      color: const Color(0xFF1B2431)
                                          .withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "$completedCount/$totalCount Lessons",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1B2431)
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Arrow Icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 20,
                              color: Color(0xFF1B2431),
                            ),
                          ),
                        ],
                      ),
                    ),
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
