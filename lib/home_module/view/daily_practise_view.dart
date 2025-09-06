import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lingolearn/home_module/controller/daily_practise_controller.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';

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
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SizedBox(height: kToolbarHeight),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: dailyPractiseController.obx(
          // ===== SUCCESS UI =====
          (state) {
            final data = state?.practices ?? [];
            if (data.isEmpty) {
              return const Center(child: Text('No practices scheduled yet.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => PracticeTile(
                item: data[i],
                onOpen: _handleOpen,
              ),
            );
          },

          // ===== OPTIONAL STATES =====
          onLoading: const Center(child: CircularProgressIndicator()),
          onEmpty: const Center(child: Text('No practices scheduled yet.')),
          onError: (err) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Failed to load: $err'),
            ),
          ),
        ),
      ),
    );
  }

  void _handleOpen(PracticeItem item) async {
    if (item.practiceId == null) return;
    if (item.status == 'locked') return;

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

class _PracticeTileState extends State<PracticeTile> {
  Timer? _ticker;
  Duration _remaining = Duration.zero;
  String _label = ''; // "Ends in" / "Starts in"
  DateTime? _target; // countdown target

  @override
  void initState() {
    super.initState();
    _computeTargetAndStart();
  }

  @override
  void didUpdateWidget(covariant PracticeTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.date != widget.item.date ||
        oldWidget.item.status != widget.item.status) {
      _computeTargetAndStart();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // Helpers
  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 0, 0, 0);

  DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59);

  void _computeTargetAndStart() {
    _ticker?.cancel();

    final now = DateTime.now();
    // item.date is "YYYY-MM-DD"
    DateTime date;
    try {
      date = DateTime.parse('${widget.item.date}T00:00:00.000');
    } catch (_) {
      date = now;
    }

    if (widget.item.status == 'available') {
      _label = 'Ends in';
      _target = _endOfDay(now); // today end
    } else if (widget.item.status == 'locked') {
      _label = 'Starts in';
      _target = _startOfDay(date); // day start
    } else {
      _label = '';
      _target = null;
    }

    if (_target != null) {
      _tick(); // initial compute
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    } else {
      setState(() => _remaining = Duration.zero);
    }
  }

  void _tick() {
    final now = DateTime.now();
    final diff = _target!.difference(now);
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  String _fmtDur(Duration d, {bool showDays = true}) {
    int days = d.inDays;
    int hours = d.inHours % 24;
    int minutes = d.inMinutes % 60;
    int seconds = d.inSeconds % 60;

    if (showDays && days > 0) {
      return '${days}d ${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // UI helpers copied from your previous tile
  String _prettyDate(String ymd) {
    try {
      final dt = DateTime.parse('${ymd}T00:00:00.000');
      final fmt = DateFormat('EEE, d MMM');
      return fmt.format(dt);
    } catch (_) {
      return ymd;
    }
  }

  Color _chipColor(BuildContext context) {
    switch (widget.item.status) {
      case 'available':
        return Colors.blue.shade50;
      case 'completed':
        return Colors.green.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _chipBorder(BuildContext context) {
    switch (widget.item.status) {
      case 'available':
        return Colors.blue.shade300;
      case 'completed':
        return Colors.green.shade300;
      default:
        return Colors.grey.shade400;
    }
  }

  IconData _leadingIcon() {
    switch (widget.item.status) {
      case 'available':
        return Icons.play_arrow_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      default:
        return Icons.lock_rounded;
    }
  }

  String _ctaText() {
    switch (widget.item.status) {
      case 'available':
        return widget.item.isToday ? 'Start' : 'Open';
      case 'completed':
        return 'Completed';
      default:
        return 'Locked';
    }
  }

  bool get _ctaEnabled =>
      widget.item.status == 'available' && widget.item.practiceId != null;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final pct = item.total == 0 ? 0.0 : (item.done / item.total);
    final chipColor = _chipColor(context);
    final chipBorder = _chipBorder(context);

    final showCountdown = _target != null && _label.isNotEmpty;
    final showDays = widget.item.status == 'locked'; // locked: show day part

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
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
                                item.status.toUpperCase(),
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
                                  border:
                                      Border.all(color: Colors.orange.shade300),
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
                          ),
                        ),
                        const SizedBox(height: 8),

                        // stats row (wrap to avoid overflow)
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
                            const Text(
                              '•',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'XP ${item.earnedXp}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Gems ${item.earnedGems}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                            if (item.completedAtAgo != null)
                              Text(
                                'Completed ${item.completedAtAgo}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (_ctaText().toLowerCase() != "completed")
                Row(
                  children: [
                    if (showCountdown)
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isNarrow = constraints.maxWidth < 220;
                              final labelText = isNarrow
                                  ? (widget.item.status == 'locked'
                                      ? 'Starts'
                                      : 'Ends')
                                  : (widget.item.status == 'locked'
                                      ? 'Starts in'
                                      : 'Ends in');

                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      widget.item.status == 'locked'
                                          ? Icons.hourglass_bottom_rounded
                                          : Icons.timer_rounded,
                                      size: 16,
                                      color: Colors.grey.shade800,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$labelText ${_fmtDur(_remaining, showDays: showDays)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    const SizedBox(width: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 160),
                      child: ElevatedButton(
                        onPressed:
                            _ctaEnabled ? () => widget.onOpen(item) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _ctaEnabled ? Colors.black : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.w700),
                          minimumSize: const Size(0, 40), // height clamp
                        ),
                        child: Text(
                          _ctaText(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
