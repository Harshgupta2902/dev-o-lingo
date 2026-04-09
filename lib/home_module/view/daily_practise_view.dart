import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lingolearn/home_module/controller/daily_practise_controller.dart';
import 'package:lingolearn/utilities/common/core_app_bar.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/packages/liquid_pull_to_refresh.dart';
import 'package:lingolearn/utilities/skeleton/practise_list_skeleton.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

final dailyPractiseController = Get.put(DailyPractiseController());

class DailyPracticesScreen extends StatefulWidget {
  const DailyPracticesScreen({super.key});

  @override
  State<DailyPracticesScreen> createState() => _DailyPracticesScreenState();
}

class _DailyPracticesScreenState extends State<DailyPracticesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) dailyPractiseController.getDailyPractise();
    });
  }

  Future<void> _refresh() async {
    await dailyPractiseController.getDailyPractise();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: SafeArea(
        top: true,
        child: LiquidPullToRefresh(
          onRefresh: _refresh,
          color: kPrimary,
          backgroundColor: Colors.white,
          animSpeedFactor: 2.0,
          child: Column(
            children: [
              const CustomHeader(
                  title: "Daily Practice", icon: Icons.event_note_rounded),
              Expanded(
                child: dailyPractiseController.obx(
                  (state) {
                    final data = state?.practices ?? [];
                    if (data.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                          const Center(
                            child: Text(
                              'No activities scheduled yet.',
                              style: TextStyle(
                                  color: kMuted, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) => PracticeTile(
                        key: ValueKey(
                            '${data[i].practiceId ?? data[i].date}-${data[i].status}'),
                        item: data[i],
                        onOpen: _handleOpen,
                      ),
                    );
                  },
                  onLoading: const PracticeListShimmer(),
                  onEmpty: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      const Center(
                        child: Text(
                          'No practices scheduled yet.',
                          style: TextStyle(
                              color: kMuted, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  onError: (err) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Failed to load: $err',
                            style: const TextStyle(
                                color: kMuted, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleOpen(PracticeItem item) async {
    if (item.practiceId == null) return;
    if (item.status.toLowerCase() == 'locked') return;
    if (item.status.toLowerCase() == 'completed') return;

    final result = await MyNavigator.pushNamedForResult(
      GoPaths.practicesQuestionScreen,
      extra: {"practiceId": item.practiceId.toString()},
    );

    if (!mounted) return;
    if (result == true) {
      _refresh();
    }
  }
}

class PracticeTile extends StatefulWidget {
  final PracticeItem item;
  final void Function(PracticeItem) onOpen;

  const PracticeTile({super.key, required this.item, required this.onOpen});

  @override
  State<PracticeTile> createState() => _PracticeTileState();
}

class _PracticeTileState extends State<PracticeTile>
    with AutomaticKeepAliveClientMixin {
  Timer? _ticker;

  // --- Normalized helpers ---
  String get _status => widget.item.status.toString().toLowerCase().trim();

  @override
  void initState() {
    super.initState();
    _computeTargetAndStart();
  }

  @override
  void didUpdateWidget(covariant PracticeTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.date != widget.item.date ||
        oldWidget.item.status != widget.item.status ||
        oldWidget.item.isToday != widget.item.isToday ||
        oldWidget.item.done != widget.item.done ||
        oldWidget.item.total != widget.item.total) {
      _computeTargetAndStart();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  int get _done => widget.item.done;
  int get _total => widget.item.total;
  bool get _isInProgress => (widget.item.isToday == true) && _done < _total;
  String get _uiStatus => _isInProgress ? 'available' : _status;

  void _computeTargetAndStart() {
    _ticker?.cancel();

    if ((_uiStatus == 'available') && (widget.item.isToday == true)) {
      _ticker =
          Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    } else {
      if (mounted) setState(() {});
    }
  }

  String _prettyDate(String ymd) {
    try {
      final dt = DateTime.parse('${ymd}T00:00:00.000');
      return DateFormat('EEEE, d MMMM').format(dt);
    } catch (_) {
      return ymd;
    }
  }

  Color _chipColor() {
    switch (_status) {
      case 'available':
        return kCardBlue;
      case 'completed':
        return successBackground;
      case 'missed':
        return errorBackground;
      default:
        return kBeigeBg;
    }
  }

  Color _accentColor() {
    switch (_status) {
      case 'available':
        return infoMain;
      case 'completed':
        return successMain;
      case 'missed':
        return errorMain;
      default:
        return kMuted;
    }
  }

  IconData _leadingIcon() {
    switch (_uiStatus) {
      case 'available':
        return Icons.play_arrow_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'missed':
        return Icons.event_busy_rounded;
      default:
        return Icons.lock_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final item = widget.item;
    final pct = item.total == 0 ? 0.0 : (item.done / item.total);
    final backgroundColor = _chipColor();
    final accentColor = _accentColor();

    return GestureDetector(
      onTap: () => widget.onOpen(widget.item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kBorder, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_leadingIcon(), color: accentColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _prettyDate(item.date),
                                style: const TextStyle(
                                  fontFamily: 'serif',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: kOnSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            if (item.isToday)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: kAmberAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: kAmberAccent, width: 1),
                                ),
                                child: const Text(
                                  'TODAY',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: kAmberAccent,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: accentColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 10,
                            backgroundColor: kBorder.withOpacity(0.4),
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStatChip(
                              icon: Icons.task_alt_rounded,
                              label: '${item.done}/${item.total}',
                            ),
                            const SizedBox(width: 12),
                            _buildStatChip(
                              icon: Icons.bolt_rounded,
                              label: '${item.earnedXp} XP',
                            ),
                            const SizedBox(width: 12),
                            _buildStatChip(
                              icon: Icons.diamond_rounded,
                              label: '${item.earnedGems}',
                            ),
                          ],
                        ),
                        if (item.completedAtAgo != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Completed ${item.completedAtAgo}',
                            style: TextStyle(
                              color: kMuted.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: kMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: kOnSurface.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
