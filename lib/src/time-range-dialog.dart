import 'dart:math';

import 'package:flutter/material.dart';
import 'package:time_range_picker/src/clock-gesture-recognizer.dart';
import 'package:time_range_picker/src/clock-painter.dart';
import 'package:time_range_picker/src/utils.dart';

showTimeRangePicker({
  required BuildContext context,
  TimeOfDay? start,
  TimeOfDay? end,
  List<TimeRange>? disabledTimes,
  Color? disabledColor,
  PaintingStyle paintingStyle = PaintingStyle.stroke,
  void Function(TimeOfDay)? onStartChange,
  void Function(TimeOfDay)? onEndChange,
  Duration interval = const Duration(minutes: 5),
  String fromText = "From",
  String toText = "To",
  bool use24HourFormat = true,
  double padding = 36,
  double strokeWidth = 12,
  Color? strokeColor,
  double handlerRadius = 12,
  Color? handlerColor,
  Color? selectedColor,
  Color? backgroundColor,
  Widget? backgroundWidget,
  int ticks = 0,
  double ticksOffset = 0,
  double? ticksLength,
  double ticksWidth = 1,
  Color ticksColor = Colors.white,
  bool snap = false,
  List<ClockLabel>? labels,
  double labelOffset = 20,
  bool rotateLabels = true,
  bool autoAdjustLabels = true,
  TextStyle? labelStyle,
  TextStyle? timeTextStyle,
  TextStyle? activeTimeTextStyle,
  bool hideTimes = false,
  bool hideButtons = false,
  double clockRotation = 0,
  Duration? maxDuration,
  Duration minDuration = const Duration(minutes: 30),
  TransitionBuilder? builder,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  bool barrierDismissible = true,
}) async {
  assert(debugCheckHasMaterialLocalizations(context));

  // RESPONSIVE DIALOG WRAPPER
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 400 || size.height < 500;

  final Widget dialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 8,
      backgroundColor: Theme.of(context).colorScheme.surface,
      // Adaptive padding based on screen size
      insetPadding: isSmallScreen
          ? const EdgeInsets.all(8)
          : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600, // Prevent it from becoming too wide on desktop
          maxHeight: size.height * 0.9, // Ensure it fits vertically
        ),
        child: TimeRangePicker(
          start: start,
          end: end,
          disabledTimes: disabledTimes,
          paintingStyle: paintingStyle,
          onStartChange: onStartChange,
          onEndChange: onEndChange,
          fromText: fromText,
          toText: toText,
          interval: interval,
          padding: padding,
          strokeWidth: strokeWidth,
          handlerRadius: handlerRadius,
          strokeColor: strokeColor,
          handlerColor: handlerColor,
          selectedColor: selectedColor,
          backgroundColor: backgroundColor,
          disabledColor: disabledColor,
          backgroundWidget: backgroundWidget,
          ticks: ticks,
          ticksLength: ticksLength,
          ticksWidth: ticksWidth,
          ticksOffset: ticksOffset,
          ticksColor: ticksColor,
          snap: snap,
          labels: labels,
          labelOffset: labelOffset,
          rotateLabels: rotateLabels,
          autoAdjustLabels: autoAdjustLabels,
          labelStyle: labelStyle,
          timeTextStyle: timeTextStyle,
          activeTimeTextStyle: activeTimeTextStyle,
          hideTimes: hideTimes,
          use24HourFormat: use24HourFormat,
          clockRotation: clockRotation,
          maxDuration: maxDuration,
          minDuration: minDuration,
          hideButtons: hideButtons,
        ),
      ));

  return await showDialog<TimeRange>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return builder == null ? dialog : builder(context, dialog);
    },
    routeSettings: routeSettings,
  );
}

class TimeRangePicker extends StatefulWidget {
  final TimeOfDay? start;
  final TimeOfDay? end;
  final List<TimeRange>? disabledTimes;
  final void Function(TimeOfDay)? onStartChange;
  final void Function(TimeOfDay)? onEndChange;
  final Duration interval;
  final String toText;
  final String fromText;
  final double padding;
  final double strokeWidth;
  final double handlerRadius;
  final Color? strokeColor;
  final Color? handlerColor;
  final Color? selectedColor;
  final Color? backgroundColor;
  final Color? disabledColor;
  final PaintingStyle paintingStyle;
  final Widget? backgroundWidget;
  final int ticks;
  final double ticksOffset;
  final double ticksLength;
  final double ticksWidth;
  final Color ticksColor;
  final bool snap;
  final List<ClockLabel>? labels;
  final double labelOffset;
  final bool rotateLabels;
  final bool autoAdjustLabels;
  final TextStyle? labelStyle;
  final TextStyle? timeTextStyle;
  final TextStyle? activeTimeTextStyle;
  final bool hideTimes;
  final bool hideButtons;
  final bool use24HourFormat;
  final double clockRotation;
  final Duration? maxDuration;
  final Duration minDuration;

  TimeRangePicker({
    Key? key,
    this.start,
    this.end,
    this.disabledTimes,
    this.onStartChange,
    this.onEndChange,
    this.fromText = "From",
    this.toText = "To",
    this.interval = const Duration(minutes: 5),
    this.padding = 36,
    this.strokeWidth = 12,
    this.handlerRadius = 12,
    this.strokeColor,
    this.handlerColor,
    this.selectedColor,
    this.backgroundColor,
    this.disabledColor,
    this.paintingStyle = PaintingStyle.stroke,
    this.backgroundWidget,
    this.ticks = 0,
    ticksLength,
    this.ticksWidth = 1,
    this.ticksOffset = 0,
    this.ticksColor = Colors.white,
    this.snap = false,
    this.labels,
    this.labelOffset = 20,
    this.rotateLabels = true,
    this.autoAdjustLabels = true,
    this.labelStyle,
    this.timeTextStyle,
    this.activeTimeTextStyle,
    this.clockRotation = 0,
    this.maxDuration,
    this.minDuration = const Duration(minutes: 30),
    this.use24HourFormat = true,
    this.hideTimes = false,
    this.hideButtons = false,
  })  : ticksLength = ticksLength == null ? strokeWidth : 12,
        assert(interval.inSeconds <= minDuration.inSeconds,
            "interval must be smaller or same as min duration"),
        assert(
            interval.inSeconds < 24 * 60 * 60, "interval must be smaller 24h"),
        assert(minDuration.inSeconds < 24 * 60 * 60,
            "min duration must be smaller 24h"),
        super(key: key);

  @override
  TimeRangePickerState createState() => TimeRangePickerState();
}

class TimeRangePickerState extends State<TimeRangePicker>
    with SingleTickerProviderStateMixin {
  ActiveTime? _activeTime;
  double _startAngle = 0;
  double _endAngle = 0;

  List<double>? _disabledStartAngle = [];
  List<double>? _disabledEndAngle = [];

  final GlobalKey _circleKey = GlobalKey();

  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  double _radius = 50;
  double _offsetRad = 0;

  @override
  void initState() {
    _offsetRad = (widget.clockRotation * pi / 180);
    setAngles();
    super.initState();
  }

  void setAngles() {
    setState(() {
      var startTime = widget.start ?? TimeOfDay.now();
      var endTime = widget.end ??
          startTime.replacing(
              hour: startTime.hour < 21
                  ? startTime.hour + 3
                  : startTime.hour - 21);

      _startTime = _roundMinutes(startTime.hour * 60 + startTime.minute * 1.0);
      _startAngle = timeToAngle(_startTime, _offsetRad);
      _endTime = _roundMinutes(endTime.hour * 60 + endTime.minute * 1.0);

      if (widget.maxDuration != null) {
        var startDate =
            DateTime(2020, 1, 1, _startTime.hour, _startTime.minute);
        var endDate = DateTime(2020, 1, 1, _endTime.hour, _endTime.minute);
        var duration = endDate.difference(startDate);
        if (duration.inMinutes > widget.maxDuration!.inMinutes) {
          var maxDate = startDate.add(widget.maxDuration!);
          _endTime = TimeOfDay(hour: maxDate.hour, minute: maxDate.minute);
        }
      }

      _endAngle = timeToAngle(_endTime, _offsetRad);

      if (widget.disabledTimes != null && widget.disabledTimes!.isNotEmpty) {
        _disabledStartAngle = [];
        _disabledEndAngle = [];
        for (var disabledTime in widget.disabledTimes!) {
          _disabledStartAngle
              ?.add(timeToAngle(disabledTime.startTime, _offsetRad));
          _disabledEndAngle?.add(timeToAngle(disabledTime.endTime, _offsetRad));
        }
      }
    });
  }

  TimeOfDay _angleToTime(double angle) {
    angle = normalizeAngle(angle - pi / 2);
    double min = 24 * 60 * (angle) / (pi * 2);
    return _roundMinutes(min);
  }

  TimeOfDay _roundMinutes(double min) {
    int roundedMin =
        ((min / widget.interval.inMinutes).round() * widget.interval.inMinutes);
    int hours = (roundedMin / 60).floor();
    int minutes = (roundedMin % 60).round();
    return TimeOfDay(hour: hours, minute: minutes);
  }

  Future<void> _openTimePicker(bool isStartTime) async {
    final initialTime = isStartTime ? _startTime : _endTime;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: widget.use24HourFormat),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      int pickedMinutes = pickedTime.hour * 60 + pickedTime.minute;
      int minDurationMinutes = widget.minDuration.inMinutes;

      TimeOfDay newStart = _startTime;
      TimeOfDay newEnd = _endTime;

      if (isStartTime) {
        newStart = _roundMinutes(pickedMinutes.toDouble());
        int startMins = newStart.hour * 60 + newStart.minute;
        int endMins = newEnd.hour * 60 + newEnd.minute;

        if (endMins < startMins) endMins += 24 * 60;

        if (endMins - startMins < minDurationMinutes) {
          int newEndTotal = startMins + minDurationMinutes;
          newEnd = _minutesToTime(newEndTotal);
        }
      } else {
        newEnd = _roundMinutes(pickedMinutes.toDouble());
        int startMins = newStart.hour * 60 + newStart.minute;
        int endMins = newEnd.hour * 60 + newEnd.minute;

        if (endMins < startMins) endMins += 24 * 60;

        if (endMins - startMins < minDurationMinutes) {
          int newStartTotal = endMins - minDurationMinutes;
          newStart = _minutesToTime(newStartTotal);
        }
      }

      setState(() {
        _startTime = newStart;
        _startAngle = timeToAngle(_startTime, _offsetRad);

        _endTime = newEnd;
        _endAngle = timeToAngle(_endTime, _offsetRad);

        if (widget.onStartChange != null && isStartTime)
          widget.onStartChange!(_startTime);
        if (widget.onEndChange != null && !isStartTime)
          widget.onEndChange!(_endTime);
      });
    }
  }

  TimeOfDay _minutesToTime(int totalMinutes) {
    while (totalMinutes >= 24 * 60) totalMinutes -= 24 * 60;
    while (totalMinutes < 0) totalMinutes += 24 * 60;

    return TimeOfDay(
        hour: (totalMinutes / 60).floor(), minute: totalMinutes % 60);
  }

  bool _panStart(PointerDownEvent ev) {
    bool isHandler = false;
    var globalPoint = ev.position;
    var snap = widget.handlerRadius * 2.5;
    RenderBox circle =
        _circleKey.currentContext!.findRenderObject() as RenderBox;

    CustomPaint customPaint = _circleKey.currentWidget as CustomPaint;
    ClockPainter _clockPainter = customPaint.painter as ClockPainter;

    if (_clockPainter.startHandlerPosition == null) {
      setState(() {
        _activeTime = ActiveTime.Start;
      });
      return false;
    }

    Offset globalStartOffset =
        circle.localToGlobal(_clockPainter.startHandlerPosition);
    if (globalPoint.dx < globalStartOffset.dx + snap &&
        globalPoint.dx > globalStartOffset.dx - snap &&
        globalPoint.dy < globalStartOffset.dy + snap &&
        globalPoint.dy > globalStartOffset.dy - snap) {
      setState(() {
        _activeTime = ActiveTime.Start;
      });
      isHandler = true;
    }

    if (_clockPainter.endHandlerPosition == null) {
      setState(() {
        _activeTime = ActiveTime.End;
      });
      return false;
    }

    Offset globalEndOffset =
        circle.localToGlobal(_clockPainter.endHandlerPosition);

    if (globalPoint.dx < globalEndOffset.dx + snap &&
        globalPoint.dx > globalEndOffset.dx - snap &&
        globalPoint.dy < globalEndOffset.dy + snap &&
        globalPoint.dy > globalEndOffset.dy - snap) {
      setState(() {
        _activeTime = ActiveTime.End;
      });
      isHandler = true;
    }

    return isHandler;
  }

  void _panUpdate(PointerMoveEvent ev) {
    if (_activeTime == null) return;
    RenderBox circle =
        _circleKey.currentContext!.findRenderObject() as RenderBox;
    final center = circle.size.center(Offset.zero);
    final point = circle.globalToLocal(ev.position);
    final touchPositionFromCenter = point - center;
    var dir = normalizeAngle(touchPositionFromCenter.direction);

    var minDurationSigned = durationToAngle(widget.minDuration);
    var minDurationAngle =
        minDurationSigned < 0 ? 2 * pi + minDurationSigned : minDurationSigned;

    if (_activeTime == ActiveTime.Start) {
      var angleToEndSigned = signedAngle(_endAngle, dir);
      var angleToEnd =
          angleToEndSigned < 0 ? 2 * pi + angleToEndSigned : angleToEndSigned;

      if (widget.disabledTimes != null && widget.disabledTimes!.isNotEmpty) {
        for (var i = 0; i < _disabledStartAngle!.length; i++) {
          var angleToDisabledStart = signedAngle(_disabledStartAngle![i], dir);
          var disabledAngleSigned =
              signedAngle(_disabledEndAngle![i], _disabledStartAngle![i]);
          var disabledDiff = disabledAngleSigned < 0
              ? 2 * pi + disabledAngleSigned
              : disabledAngleSigned;

          if (angleToDisabledStart - minDurationAngle < 0 &&
              angleToDisabledStart > -disabledDiff / 2) {
            dir = _disabledStartAngle![i] - minDurationAngle;
            _updateTimeAndSnapAngle(ActiveTime.End, _disabledStartAngle![i]);
          }
        }
      }

      if (angleToEnd > 0 && angleToEnd < minDurationAngle) {
        var angle = dir + minDurationAngle;
        _updateTimeAndSnapAngle(ActiveTime.End, angle);
      }

      if (widget.maxDuration != null) {
        var startSigned = signedAngle(_endAngle, dir);
        var startDiff = startSigned < 0 ? 2 * pi + startSigned : startSigned;
        var maxSigned = durationToAngle(widget.maxDuration!);
        var maxDiff = maxSigned < 0 ? 2 * pi + maxSigned : maxSigned;
        if (startDiff > maxDiff) {
          var angle = dir + maxSigned;
          _updateTimeAndSnapAngle(ActiveTime.End, angle);
        }
      }
    } else {
      var angleToStartSigned = signedAngle(dir, _startAngle);
      var angleToStart = angleToStartSigned < 0
          ? 2 * pi + angleToStartSigned
          : angleToStartSigned;

      if (widget.disabledTimes != null && widget.disabledTimes!.isNotEmpty) {
        for (var i = 0; i < _disabledStartAngle!.length; i++) {
          var angleToDisabledStart = signedAngle(_disabledStartAngle![i], dir);
          var angleToDisabledEnd = signedAngle(_disabledEndAngle![i], dir);
          var disabledAngleSigned =
              signedAngle(_disabledEndAngle![i], _disabledStartAngle![i]);
          var disabledDiff = disabledAngleSigned < 0
              ? 2 * pi + disabledAngleSigned
              : disabledAngleSigned;

          if (angleToDisabledStart < 0 &&
              angleToDisabledStart > -disabledDiff / 2) {
            dir = _disabledStartAngle![i];
          } else if (angleToDisabledEnd + minDurationAngle > 0 &&
              angleToDisabledEnd < disabledDiff / 2) {
            dir = _disabledEndAngle![i] + minDurationAngle;
            _updateTimeAndSnapAngle(ActiveTime.Start, _disabledEndAngle![i]);
          }
        }
      }

      if (angleToStart > 0 && angleToStart < minDurationAngle) {
        var angle = dir - minDurationAngle;
        _updateTimeAndSnapAngle(ActiveTime.Start, angle);
      }

      if (widget.maxDuration != null) {
        var endSigned = signedAngle(dir, _startAngle);
        var endDiff = endSigned < 0 ? 2 * pi + endSigned : endSigned;
        var maxSigned = durationToAngle(widget.maxDuration!);
        var maxDiff = maxSigned < 0 ? 2 * pi + maxSigned : maxSigned;
        if (endDiff > maxDiff) {
          var angle = dir - maxSigned;
          _updateTimeAndSnapAngle(ActiveTime.Start, angle);
        }
      }
    }
    _updateTimeAndSnapAngle(_activeTime!, dir);
  }

  _updateTimeAndSnapAngle(ActiveTime type, double angle) {
    var time = _angleToTime(angle - _offsetRad);
    if (time.hour == 24) time = TimeOfDay(hour: 0, minute: time.minute);
    final snapped =
        widget.snap == true ? timeToAngle(time, -_offsetRad) : angle;

    if (type == ActiveTime.Start) {
      setState(() {
        _startAngle = snapped;
        _startTime = time;
      });
      if (widget.onStartChange != null) {
        widget.onStartChange!(_startTime);
      }
    } else {
      setState(() {
        _endAngle = snapped;
        _endTime = time;
      });
      if (widget.onEndChange != null) {
        widget.onEndChange!(_endTime);
      }
    }
  }

  void _panEnd(PointerUpEvent ev) {
    setState(() {
      _activeTime = null;
    });
  }

  _submit() {
    Navigator.of(context)
        .pop(TimeRange(startTime: _startTime, endTime: _endTime));
  }

  _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);

    // Dynamic layout determination
    return LayoutBuilder(builder: (context, constraints) {
      final isLandscape = constraints.maxWidth > constraints.maxHeight;

      if (!isLandscape) {
        // PORTRAIT LAYOUT
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (!widget.hideTimes) buildHeader(false),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: _buildResponsiveClock(localizations, themeData),
              ),
            ),
            if (!widget.hideButtons)
              buildButtonBar(localizations: localizations)
          ],
        );
      } else {
        // LANDSCAPE LAYOUT
        return Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!widget.hideTimes) buildHeader(true),
                  const Spacer(),
                  if (!widget.hideButtons)
                    buildButtonBar(localizations: localizations),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: _buildResponsiveClock(localizations, themeData),
              ),
            ),
          ],
        );
      }
    });
  }

  /// Calculates radius dynamically based on available space
  Widget _buildResponsiveClock(
      MaterialLocalizations localizations, ThemeData themeData) {
    return LayoutBuilder(builder: (context, constraints) {
      // Calculate radius instantly based on smallest dimension
      double dimension = min(constraints.maxWidth, constraints.maxHeight);
      _radius = (dimension / 2) - widget.padding;

      // Safe guard against negative radius
      if (_radius <= 0) _radius = 10;

      return Stack(
        alignment: Alignment.center,
        children: [
          if (widget.backgroundWidget != null) widget.backgroundWidget!,
          buildTimeRange(
            localizations: localizations,
            themeData: themeData,
            radius: _radius, // Pass calculated radius
          ),
        ],
      );
    });
  }

  Widget buildButtonBar({required MaterialLocalizations localizations}) =>
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: OverflowBar(
          alignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
              child: Text(localizations.cancelButtonLabel),
              onPressed: _cancel,
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24)),
              child: Text(localizations.okButtonLabel),
              onPressed: _submit,
            ),
          ],
        ),
      );

  Widget buildTimeRange({
    required MaterialLocalizations localizations,
    required ThemeData themeData,
    required double radius,
  }) =>
      RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          ClockGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<ClockGestureRecognizer>(
            () => ClockGestureRecognizer(
                panStart: _panStart, panUpdate: _panUpdate, panEnd: _panEnd),
            (ClockGestureRecognizer instance) {},
          ),
        },
        child: CustomPaint(
          key: _circleKey,
          painter: ClockPainter(
              activeTime: _activeTime,
              startAngle: _startAngle,
              endAngle: _endAngle,
              disabledStartAngle: _disabledStartAngle,
              disabledEndAngle: _disabledEndAngle,
              radius: radius,
              strokeWidth: widget.strokeWidth,
              handlerRadius: widget.handlerRadius,
              strokeColor: widget.strokeColor ?? themeData.primaryColor,
              handlerColor: widget.handlerColor ?? themeData.primaryColor,
              selectedColor:
                  widget.selectedColor ?? themeData.primaryColorLight,
              backgroundColor:
                  widget.backgroundColor ?? Colors.grey.withOpacity(0.3),
              disabledColor:
                  widget.disabledColor ?? Colors.red.withOpacity(0.5),
              paintingStyle: widget.paintingStyle,
              ticks: widget.ticks,
              ticksColor: widget.ticksColor,
              ticksLength: widget.ticksLength,
              ticksWidth: widget.ticksWidth,
              ticksOffset: widget.ticksOffset,
              labels: widget.labels ?? new List.empty(),
              labelStyle: widget.labelStyle ?? themeData.textTheme.bodyLarge,
              labelOffset: widget.labelOffset,
              rotateLabels: widget.rotateLabels,
              autoAdjustLabels: widget.autoAdjustLabels,
              offsetRad: _offsetRad),
          size: Size.fromRadius(radius),
        ),
      );

  Widget buildHeader(bool landscape) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withOpacity(0.3),
            colorScheme.secondaryContainer.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Flex(
        direction: landscape ? Axis.vertical : Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimeDisplay(
            label: widget.fromText,
            time: _startTime,
            isActive: _activeTime == ActiveTime.Start,
            onTap: () => _openTimePicker(true),
            theme: theme,
            colorScheme: colorScheme,
            isLandscape: landscape,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: landscape ? 0 : 8,
              vertical: landscape ? 8 : 0,
            ),
            child: Icon(
              landscape
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_forward_rounded,
              color: colorScheme.primary.withOpacity(0.5),
              size: 20,
            ),
          ),
          _buildTimeDisplay(
            label: widget.toText,
            time: _endTime,
            isActive: _activeTime == ActiveTime.End,
            onTap: () => _openTimePicker(false),
            theme: theme,
            colorScheme: colorScheme,
            isLandscape: landscape,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay({
    required String label,
    required TimeOfDay time,
    required bool isActive,
    required VoidCallback onTap,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isLandscape,
  }) {
    // Determine Width based on orientation to ensure equal sizing
    return Flexible(
      flex: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: isLandscape ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary
                : colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.outline.withOpacity(0.2),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isActive ? colorScheme.onPrimary : colorScheme.primary,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  MaterialLocalizations.of(context).formatTimeOfDay(
                    time,
                    alwaysUse24HourFormat: widget.use24HourFormat,
                  ),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: isActive
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
