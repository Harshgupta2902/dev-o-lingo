import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'package:flutter/material.dart';

const double _kDragContainerExtentPercentage = 0.25;
const double _kDragSizeFactorLimit = 1.5;
const Duration _kIndicatorScaleDuration = Duration(milliseconds: 200);
typedef RefreshCallback = Future<void> Function();

enum _LiquidPullToRefreshMode {
  drag, // Pointer is down.
  armed, // Dragged far enough that an up event will run the onRefresh callback.
  snap, // Animating to the indicator's final "displacement".
  refresh, // Running the refresh callback.
  done, // Animating the indicator's fade-out after refreshing.
  canceled, // Animating the indicator's fade-out after not arming.
}

class LiquidPullToRefresh extends StatefulWidget {
  const LiquidPullToRefresh({
    super.key,
    this.animSpeedFactor = 1.0,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.springAnimationDurationInMilliseconds = 1000,
    this.borderWidth = 2.0,
    this.showChildOpacityTransition = false,
  }) : assert(animSpeedFactor >= 1.0);

  final Widget child;
  final int springAnimationDurationInMilliseconds;
  final double animSpeedFactor;
  final double borderWidth;
  final bool showChildOpacityTransition;
  final RefreshCallback onRefresh;
  final Color? color;
  final Color? backgroundColor;

  @override
  LiquidPullToRefreshState createState() => LiquidPullToRefreshState();
}

class LiquidPullToRefreshState extends State<LiquidPullToRefresh>
    with TickerProviderStateMixin<LiquidPullToRefresh> {
  late AnimationController _springController;
  late Animation<double> _springAnimation;

  late AnimationController _progressingController;
  late Animation<double> _progressingRotateAnimation;
  late Animation<double> _progressingPercentAnimation;
  late Animation<double> _progressingStartAngleAnimation;

  late AnimationController _ringDisappearController;
  late Animation<double> _ringRadiusAnimation;
  late Animation<double> _ringOpacityAnimation;

  late AnimationController _showPeakController;
  late Animation<double> _peakHeightUpAnimation;
  late Animation<double> _peakHeightDownAnimation;

  late AnimationController _indicatorMoveWithPeakController;
  late Animation<double> _indicatorTranslateWithPeakAnimation;
  late Animation<double> _indicatorRadiusWithPeakAnimation;

  late AnimationController _indicatorTranslateInOutController;
  late Animation<double> _indicatorTranslateAnimation;

  late AnimationController _radiusController;
  late Animation<double> _radiusAnimation;


  late AnimationController _positionController;
  late Animation<double> _value;
  late Animation<Color?> _valueColor;

  _LiquidPullToRefreshMode? _mode;
  Future<void>? _pendingRefreshFuture;
  bool? _isIndicatorAtTop;
  double? _dragOffset;

  static final Animatable<double> _threeQuarterTween =
      Tween<double>(begin: 0.0, end: 0.75);

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(vsync: this);
    _springAnimation =
        _springController.drive(Tween<double>(begin: 1.0, end: -1.0));

    _progressingController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _progressingRotateAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _progressingController,
      curve: const Interval(0.0, 1.0),
    ));
    _progressingPercentAnimation =
        Tween<double>(begin: 0.25, end: 5 / 6).animate(CurvedAnimation(
      parent: _progressingController,
      curve: Interval(0.0, 1.0, curve: ProgressRingCurve()),
    ));
    _progressingStartAngleAnimation =
        Tween<double>(begin: -2 / 3, end: 1 / 2).animate(CurvedAnimation(
      parent: _progressingController,
      curve: const Interval(0.5, 1.0),
    ));

    _ringDisappearController = AnimationController(vsync: this);
    _ringRadiusAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
        CurvedAnimation(
            parent: _ringDisappearController,
            curve: const Interval(0.0, 0.2, curve: Curves.easeOut)));
    _ringOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _ringDisappearController,
            curve: const Interval(0.0, 0.2, curve: Curves.easeIn)));

    _showPeakController = AnimationController(vsync: this);
    _peakHeightUpAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _showPeakController,
            curve: const Interval(0.1, 0.2, curve: Curves.easeOut)));
    _peakHeightDownAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _showPeakController,
            curve: const Interval(0.2, 0.3, curve: Curves.easeIn)));

    _indicatorMoveWithPeakController = AnimationController(vsync: this);
    _indicatorTranslateWithPeakAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: _indicatorMoveWithPeakController,
            curve: const Interval(0.1, 0.2, curve: Curves.easeOut)));
    _indicatorRadiusWithPeakAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: _indicatorMoveWithPeakController,
            curve: const Interval(0.1, 0.2, curve: Curves.easeOut)));

    _indicatorTranslateInOutController = AnimationController(vsync: this);
    _indicatorTranslateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _indicatorTranslateInOutController,
            curve: const Interval(0.2, 0.6, curve: Curves.easeOut)));

    _radiusController = AnimationController(vsync: this);
    _radiusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _radiusController, curve: Curves.easeIn));

    _positionController = AnimationController(vsync: this);
    _value = _positionController.drive(_threeQuarterTween);

  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _valueColor = _positionController.drive(
      ColorTween(
              begin: (widget.color ?? theme.colorScheme.secondary)
                  .withValues(alpha: 0.0),
              end: (widget.color ?? theme.colorScheme.secondary)
                  .withValues(alpha: 1.0))
          .chain(CurveTween(
              curve: const Interval(0.0, 1.0 / _kDragSizeFactorLimit))),
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _springController.dispose();
    _progressingController.dispose();
    _positionController.dispose();
    _ringDisappearController.dispose();
    _showPeakController.dispose();
    _indicatorMoveWithPeakController.dispose();
    _indicatorTranslateInOutController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.metrics.extentBefore == 0.0 &&
        _mode == null &&
        _start(notification.metrics.axisDirection)) {
      setState(() {
        _mode = _LiquidPullToRefreshMode.drag;
      });
      return false;
    }
    bool? indicatorAtTopNow;
    switch (notification.metrics.axisDirection) {
      case AxisDirection.down:
        indicatorAtTopNow = true;
        break;
      case AxisDirection.up:
        indicatorAtTopNow = false;
        break;
      case AxisDirection.left:
      case AxisDirection.right:
        indicatorAtTopNow = null;
        break;
    }
    if (indicatorAtTopNow != _isIndicatorAtTop) {
      if (_mode == _LiquidPullToRefreshMode.drag ||
          _mode == _LiquidPullToRefreshMode.armed) {
        _dismiss(_LiquidPullToRefreshMode.canceled);
      }
    } else if (notification is ScrollUpdateNotification) {
      if (_mode == _LiquidPullToRefreshMode.drag ||
          _mode == _LiquidPullToRefreshMode.armed) {
        if (notification.metrics.extentBefore > 0.0) {
          _dismiss(_LiquidPullToRefreshMode.canceled);
        } else {
          if (_dragOffset != null) {
            _dragOffset = _dragOffset! - notification.scrollDelta!;
          }
          _checkDragOffset(notification.metrics.viewportDimension);
        }
      }
      if (_mode == _LiquidPullToRefreshMode.armed &&
          notification.dragDetails == null) {
        _show();
      }
    } else if (notification is OverscrollNotification) {
      if (_mode == _LiquidPullToRefreshMode.drag ||
          _mode == _LiquidPullToRefreshMode.armed) {
        if (_dragOffset != null) {
          _dragOffset = _dragOffset! - notification.overscroll / 2.0;
        }
        _checkDragOffset(notification.metrics.viewportDimension);
      }
    } else if (notification is ScrollEndNotification) {
      switch (_mode) {
        case _LiquidPullToRefreshMode.armed:
          _show();
          break;
        case _LiquidPullToRefreshMode.drag:
          _dismiss(_LiquidPullToRefreshMode.canceled);
          break;
        default:
          break;
      }
    }
    return false;
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth != 0 || !notification.leading) return false;
    if (_mode == _LiquidPullToRefreshMode.drag) {
      notification.disallowIndicator();
      return true;
    }
    return false;
  }

  Future<void> _dismiss(_LiquidPullToRefreshMode newMode) async {
    await Future<void>.value();
    assert(newMode == _LiquidPullToRefreshMode.canceled ||
        newMode == _LiquidPullToRefreshMode.done);
    setState(() {
      _mode = newMode;
    });
    switch (_mode) {
      case _LiquidPullToRefreshMode.done:
        //stop progressing animation
        _progressingController.stop();

        _ringDisappearController.animateTo(1.0,
            duration: Duration(
                milliseconds: (widget.springAnimationDurationInMilliseconds /
                        widget.animSpeedFactor)
                    .round()),
            curve: Curves.linear);

        // indicator translate out
        _indicatorMoveWithPeakController.animateTo(0.0,
            duration: Duration(
                milliseconds: (widget.springAnimationDurationInMilliseconds /
                        widget.animSpeedFactor)
                    .round()),
            curve: Curves.linear);
        _indicatorTranslateInOutController.animateTo(0.0,
            duration: Duration(
                milliseconds: (widget.springAnimationDurationInMilliseconds /
                        widget.animSpeedFactor)
                    .round()),
            curve: Curves.linear);

        //initial value of controller is 1.0
        await _showPeakController.animateTo(0.3,
            duration: Duration(
                milliseconds: (widget.springAnimationDurationInMilliseconds /
                        widget.animSpeedFactor)
                    .round()),
            curve: Curves.linear);

        _radiusController.animateTo(0.0,
            duration: Duration(
                milliseconds: (widget.springAnimationDurationInMilliseconds /
                        (widget.animSpeedFactor * 5))
                    .round()),
            curve: Curves.linear);

        _showPeakController.value = 0.175;
        await _showPeakController.animateTo(0.1,
            duration: Duration(
                milliseconds: (widget.springAnimationDurationInMilliseconds /
                        (widget.animSpeedFactor * 5))
                    .round()),
            curve: Curves.easeOut);
        _showPeakController.value = 0.0;

        await _positionController.animateTo(0.0,
            duration: Duration(
                milliseconds: (widget.springAnimationDurationInMilliseconds /
                        widget.animSpeedFactor)
                    .round()));
        break;

      case _LiquidPullToRefreshMode.canceled:
        await _positionController.animateTo(0.0,
            duration: _kIndicatorScaleDuration);
        break;
      default:
        assert(false);
    }
    if (mounted && _mode == newMode) {
      _dragOffset = null;
      _isIndicatorAtTop = null;
      setState(() {
        _mode = null;
      });
    }
  }

  bool _start(AxisDirection direction) {
    assert(_mode == null);
    assert(_isIndicatorAtTop == null);
    assert(_dragOffset == null);
    switch (direction) {
      case AxisDirection.down:
        _isIndicatorAtTop = true;
        break;
      case AxisDirection.up:
        _isIndicatorAtTop = false;
        break;
      case AxisDirection.left:
      case AxisDirection.right:
        _isIndicatorAtTop = null;
        // we do not support horizontal scroll views.
        return false;
    }
    _dragOffset = 0.0;
    _positionController.value = 0.0;
    _springController.value = 0.0;
    _progressingController.value = 0.0;
    _ringDisappearController.value = 1.0;
    _showPeakController.value = 0.0;
    _indicatorMoveWithPeakController.value = 0.0;
    _indicatorTranslateInOutController.value = 0.0;
    _radiusController.value = 1.0;
    return true;
  }

  void _checkDragOffset(double containerExtent) {
    assert(_mode == _LiquidPullToRefreshMode.drag ||
        _mode == _LiquidPullToRefreshMode.armed);
    double newValue =
        _dragOffset! / (containerExtent * _kDragContainerExtentPercentage);
    if (_mode == _LiquidPullToRefreshMode.armed) {
      newValue = math.max(newValue, 1.0 / _kDragSizeFactorLimit);
    }
    _positionController.value =
        newValue.clamp(0.0, 1.0); // this triggers various rebuilds
    if (_mode == _LiquidPullToRefreshMode.drag &&
        _valueColor.value!.a == 1.0) {
      _mode = _LiquidPullToRefreshMode.armed;
    }
  }

  void _show() {
    assert(_mode != _LiquidPullToRefreshMode.refresh);
    assert(_mode != _LiquidPullToRefreshMode.snap);
    final Completer<void> completer = Completer<void>();
    _pendingRefreshFuture = completer.future;
    _mode = _LiquidPullToRefreshMode.snap;

    _positionController.animateTo(1.0 / _kDragSizeFactorLimit,
        duration: Duration(
            milliseconds: widget.springAnimationDurationInMilliseconds),
        curve: Curves.linear);

    _showPeakController.animateTo(1.0,
        duration: Duration(
            milliseconds: widget.springAnimationDurationInMilliseconds),
        curve: Curves.linear);

    //indicator translate in with peak
    _indicatorMoveWithPeakController.animateTo(1.0,
        duration: Duration(
            milliseconds: widget.springAnimationDurationInMilliseconds),
        curve: Curves.linear);

    //indicator move to center
    _indicatorTranslateInOutController.animateTo(1.0,
        duration: Duration(
            milliseconds: widget.springAnimationDurationInMilliseconds),
        curve: Curves.linear);

    // progress ring fade in
    _ringDisappearController.animateTo(0.0,
        duration: Duration(
            milliseconds: widget.springAnimationDurationInMilliseconds));

    _springController
        .animateTo(0.5,
            duration: Duration(
                milliseconds: widget.springAnimationDurationInMilliseconds),
            curve: Curves.elasticOut)
        .then<void>((void value) {
      if (mounted && _mode == _LiquidPullToRefreshMode.snap) {
        setState(() {
          // Show the indeterminate progress indicator.
          _mode = _LiquidPullToRefreshMode.refresh;
        });

        //run progress animation
        _progressingController.repeat();

        final Future<void> refreshResult = widget.onRefresh();

        refreshResult.whenComplete(() {
          if (mounted && _mode == _LiquidPullToRefreshMode.refresh) {
            completer.complete();

            _dismiss(_LiquidPullToRefreshMode.done);
          }
        });
      }
    });
  }

  Future<void>? show({bool atTop = true}) {
    if (_mode != _LiquidPullToRefreshMode.refresh &&
        _mode != _LiquidPullToRefreshMode.snap) {
      if (_mode == null) _start(atTop ? AxisDirection.down : AxisDirection.up);
      _show();
    }
    return _pendingRefreshFuture;
  }

  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));

    Color defaultColor = Theme.of(context).colorScheme.secondary;
    Color defaultBackgroundColor = Theme.of(context).canvasColor;

    Color color = (widget.color != null) ? widget.color! : defaultColor;
    Color backgroundColor = (widget.backgroundColor != null)
        ? widget.backgroundColor!
        : defaultBackgroundColor;
    double height = kToolbarHeight;

    final Widget child = NotificationListener<ScrollNotification>(
      key: _key,
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: _handleGlowNotification, child: widget.child),
    );

    if (_mode == null) {
      assert(_dragOffset == null);
      assert(_isIndicatorAtTop == null);
      return child;
    }
    assert(_dragOffset != null);
    assert(_isIndicatorAtTop != null);

    return Stack(
      children: <Widget>[
        AnimatedBuilder(
          animation: _positionController,
          child: child,
          builder: (BuildContext buildContext, Widget? child) {
            final double dy = _positionController.value * height * 1.5;

            return Transform.translate(
              offset: Offset(0.0, dy),
              child: child,
            );
          },
        ),
        AnimatedBuilder(
          animation: Listenable.merge([
            _positionController,
            _springController,
            _showPeakController,
          ]),
          builder: (BuildContext buildContext, Widget? child) {
            return ClipPath(
              clipper: CurveHillClipper(
                centreHeight: height,
                curveHeight: height / 2 * _springAnimation.value, // 50.0
                peakHeight: height *
                    3 /
                    10 *
                    ((_peakHeightUpAnimation.value != 1.0) //30.0
                        ? _peakHeightUpAnimation.value
                        : _peakHeightDownAnimation.value),
                peakWidth: (_peakHeightUpAnimation.value != 0.0 &&
                        _peakHeightDownAnimation.value != 0.0)
                    ? height * 35 / 100 //35.0
                    : 0.0,
              ),
              child: Container(
                height: _value.value * height * 2, // 100.0
                color: color,
              ),
            );
          },
        ),
        SizedBox(
          height: height, //100.0
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _progressingController,
              _ringDisappearController,
              _indicatorMoveWithPeakController,
              _indicatorTranslateInOutController,
              _radiusController,
            ]),
            builder: (BuildContext buildContext, Widget? child) {
              return Align(
                alignment: Alignment(
                  0.0,
                  (1.0 -
                      (0.36 * _indicatorTranslateWithPeakAnimation.value) -
                      (0.64 * _indicatorTranslateAnimation.value)),
                ),
                child: Transform(
                  transform: Matrix4.identity()
                    ..rotateZ(_progressingRotateAnimation.value * 5 * pi / 6),
                  alignment: FractionalOffset.center,
                  child: CircularProgress(
                    backgroundColor: backgroundColor,
                    progressCircleOpacity: _ringOpacityAnimation.value,
                    innerCircleRadius: height *
                        15 /
                        100 * // 15.0
                        ((_mode != _LiquidPullToRefreshMode.done)
                            ? _indicatorRadiusWithPeakAnimation.value
                            : _radiusAnimation.value),
                    progressCircleBorderWidth: widget.borderWidth,
                    //2.0
                    progressCircleRadius: (_ringOpacityAnimation.value != 0.0)
                        ? (height * 2 / 10) * _ringRadiusAnimation.value //20.0
                        : 0.0,
                    startAngle: _progressingStartAngleAnimation.value * pi,
                    progressPercent: _progressingPercentAnimation.value,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProgressRingCurve extends Curve {
  @override
  double transform(double t) {
    if (t <= 0.5) {
      return 2 * t;
    } else {
      return 2 * (1 - t);
    }
  }
}

class CurveHillClipper extends CustomClipper<Path> {
  final double centreHeight;
  double curveHeight;
  final double peakHeight;
  final double peakWidth;

  CurveHillClipper({
    required this.centreHeight,
    required this.curveHeight,
    required this.peakHeight,
    required this.peakWidth,
  });

  @override
  Path getClip(Size size) {
    var path = Path();
    if (size.height >= centreHeight) {
      if (curveHeight > (size.height - centreHeight)) {
        curveHeight = size.height - centreHeight;
      }

      path.lineTo(0.0, centreHeight);

      path.quadraticBezierTo(size.width / 4, centreHeight + curveHeight,
          (size.width / 2) - (peakWidth / 2), centreHeight + curveHeight);

      path.quadraticBezierTo(
          (size.width / 2) - (peakWidth / 4),
          centreHeight + curveHeight - peakHeight,
          (size.width / 2),
          centreHeight + curveHeight - peakHeight);

      path.quadraticBezierTo(
          (size.width / 2) + (peakWidth / 4),
          centreHeight + curveHeight - peakHeight,
          (size.width / 2) + (peakWidth / 2),
          centreHeight + curveHeight);

      path.quadraticBezierTo(size.width * 3 / 4, centreHeight + curveHeight,
          size.width, centreHeight);

      path.lineTo(size.width, 0.0);

      path.lineTo(0.0, 0.0);
    } else {
      path.lineTo(0.0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0.0);
      path.lineTo(0.0, 0.0);
    }

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class CircularProgress extends StatefulWidget {
  final double innerCircleRadius;
  final double progressPercent;
  final double progressCircleOpacity;
  final double progressCircleRadius;
  final double progressCircleBorderWidth;
  final Color backgroundColor;
  final double startAngle;

  const CircularProgress({
    super.key,
    required this.innerCircleRadius,
    required this.progressPercent,
    required this.progressCircleRadius,
    required this.progressCircleBorderWidth,
    required this.backgroundColor,
    required this.progressCircleOpacity,
    required this.startAngle,
  });

  @override
  State<CircularProgress> createState() => _CircularProgressState();
}

class _CircularProgressState extends State<CircularProgress> {
  @override
  Widget build(BuildContext context) {
    double containerLength =
        2 * max(widget.progressCircleRadius, widget.innerCircleRadius);

    return SizedBox(
      height: containerLength,
      width: containerLength,
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: widget.progressCircleOpacity,
            child: SizedBox(
              height: widget.progressCircleRadius * 2,
              width: widget.progressCircleRadius * 2,
              child: CustomPaint(
                painter: RingPainter(
                  startAngle: widget.startAngle,
                  paintWidth: widget.progressCircleBorderWidth,
                  progressPercent: widget.progressPercent,
                  trackColor: widget.backgroundColor,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: widget.innerCircleRadius * 2,
              height: widget.innerCircleRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.backgroundColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  final double paintWidth;
  final Paint trackPaint;
  final Color trackColor;
  final double progressPercent;
  final double startAngle;

  RingPainter({
    required this.startAngle,
    required this.paintWidth,
    required this.progressPercent,
    required this.trackColor,
  }) : trackPaint = Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = paintWidth
          ..strokeCap = StrokeCap.square;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - paintWidth) / 2;

    final progressAngle = 2 * pi * progressPercent;

    canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        startAngle,
        progressAngle,
        false,
        trackPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
