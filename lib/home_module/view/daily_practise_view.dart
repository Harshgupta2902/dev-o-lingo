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
    return SafeArea(
      top: true,
      child: LiquidPullToRefresh(
        onRefresh: _refresh,
        color: kPrimary,
        backgroundColor: Colors.white,
        animSpeedFactor: 2.0,
        child: Column(
          children: [
            const CustomHeader(
                title: "Daily Practise", icon: Icons.event_note_rounded),
            Expanded(
              child: dailyPractiseController.obx(
                (state) {
                  final data = state?.practices ?? [];
                  if (data.isEmpty) {
                    return const Center(
                        child: Text('No practices scheduled yet.'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => PracticeTile(
                      key: ValueKey(
                          '${data[i].practiceId ?? data[i].date}-${data[i].status}'),
                      item: data[i],
                      onOpen: _handleOpen,
                    ),
                  );
                },
                onLoading: const PracticeListShimmer(),
                onEmpty:
                    const Center(child: Text('No practices scheduled yet.')),
                onError: (err) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Failed to load: $err'),
                  ),
                ),
              ),
            ),
          ],
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
  String get _status =>
      widget.item.status.toString().toLowerCase().trim();

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
        oldWidget.item.done != widget.item.done || // NEW
        oldWidget.item.total != widget.item.total) {
      // NEW
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
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    } else {
      if (mounted) setState(() {});
    }
  }


  String _prettyDate(String ymd) {
    try {
      final dt = DateTime.parse('${ymd}T00:00:00.000');
      return DateFormat('EEE, d MMM').format(dt);
    } catch (_) {
      return ymd;
    }
  }

  Color _chipColor(BuildContext context) {
    switch (_status) {
      case 'available':
        return Colors.blue.shade50;
      case 'completed':
        return Colors.green.shade50;
      case 'missed':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _chipBorder(BuildContext context) {
    switch (_status) {
      case 'available':
        return Colors.blue.shade300;
      case 'completed':
        return Colors.green.shade300;
      case 'missed':
        return Colors.red.shade300;
      default:
        return Colors.grey.shade400;
    }
  }

  IconData _leadingIcon() {
    switch (_uiStatus) {
      case 'available':
        return Icons.play_arrow_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'missed':
        return Icons.cancel_rounded;
      default:
        return Icons.lock_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final item = widget.item;
    final pct = item.total == 0 ? 0.0 : (item.done / item.total);
    final chipColor = _chipColor(context);
    final chipBorder = _chipBorder(context);

    return GestureDetector(
      onTap: () => widget.onOpen(widget.item),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: chipColor,
                      child: Icon(_leadingIcon(), color: chipBorder),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                _prettyDate(item.date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: chipColor,
                                  border: Border.all(color: chipBorder),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: chipBorder,
                                  ),
                                ),
                              ),
                              if (item.isToday)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.orange.shade300),
                                  ),
                                  child: Text(
                                    'TODAY',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // progress
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade200,
                              color: kPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // stats
                          Wrap(
                            spacing: 10,
                            runSpacing: 6,
                            children: [
                              Text(
                                'Done ${item.done}/${item.total}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                              const Text('•', style: TextStyle(fontSize: 12)),
                              Text('XP ${item.earnedXp}',
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12)),
                              Text('Gems ${item.earnedGems}',
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12)),
                              if (item.completedAtAgo != null)
                                Text('Completed ${item.completedAtAgo}',
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
