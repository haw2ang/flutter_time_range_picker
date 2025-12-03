import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:time_range_picker/src/utils.dart';

class ClockPainter extends CustomPainter {
  double? startAngle;
  double? endAngle;

  List<double>? disabledStartAngle = const [];
  List<double>? disabledEndAngle = const [];
  ActiveTime? activeTime;

  double radius;

  double strokeWidth;
  double handlerRadius;
  Color strokeColor;
  Color handlerColor;
  Color selectedColor;
  Color backgroundColor;
  Color disabledColor;
  PaintingStyle paintingStyle;

  Offset? _startHandlerPosition;
  Offset? _endHandlerPosition;
  late TextPainter _textPainter;

  int? ticks;
  double ticksOffset;
  double ticksLength;
  double ticksWidth;
  Color ticksColor;
  List<ClockLabel> labels;
  TextStyle? labelStyle;
  double labelOffset;
  bool rotateLabels;
  bool autoAdjustLabels;

  double offsetRad;

  get startHandlerPosition {
    return _startHandlerPosition;
  }

  get endHandlerPosition {
    return _endHandlerPosition;
  }

  ClockPainter({
    this.startAngle,
    this.endAngle,
    this.disabledStartAngle,
    this.disabledEndAngle,
    this.activeTime,
    required this.radius,
    required this.strokeWidth,
    required this.handlerRadius,
    required this.strokeColor,
    required this.handlerColor,
    required this.selectedColor,
    required this.backgroundColor,
    required this.disabledColor,
    required this.paintingStyle,
    required this.ticks,
    required this.ticksOffset,
    required this.ticksLength,
    required this.ticksWidth,
    required this.ticksColor,
    required this.labels,
    this.labelStyle,
    required this.labelOffset,
    required this.rotateLabels,
    required this.autoAdjustLabels,
    required this.offsetRad,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Rect.fromLTRB(0, 0, radius * 2, radius * 2);

    // Draw outer glow/shadow for depth
    _drawOuterGlow(canvas, rect);

    // Draw background with gradient
    _drawBackgroundGradient(canvas, rect);

    // Draw disabled ranges with modern styling
    if (disabledStartAngle != null &&
        disabledEndAngle != null &&
        disabledStartAngle!.isNotEmpty &&
        disabledEndAngle!.isNotEmpty) {
      _drawDisabledRanges(canvas, rect);
    }

    // Draw modern ticks
    _drawModernTicks(canvas);

    // Draw selected range with gradient
    if (startAngle != null && endAngle != null) {
      _drawSelectedRange(canvas, rect);

      var start = normalizeAngle(startAngle!);
      var end = normalizeAngle(endAngle!);

      drawModernHandler(canvas, ActiveTime.Start, start);
      drawModernHandler(canvas, ActiveTime.End, end);
    }

    // Draw labels with modern styling
    drawLabels(canvas);

    canvas.save();
    canvas.restore();
  }

  void _drawOuterGlow(Canvas canvas, Rect rect) {
    var glowPaint = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20)
      ..color = strokeColor.withOpacity(0.1);

    canvas.drawCircle(rect.center, radius + 10, glowPaint);
  }

  void _drawBackgroundGradient(Canvas canvas, Rect rect) {
    var paint = Paint()
      ..style = paintingStyle
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Add subtle gradient to background
    if (paintingStyle == PaintingStyle.stroke) {
      paint.shader = ui.Gradient.linear(
        Offset(rect.center.dx, rect.top),
        Offset(rect.center.dx, rect.bottom),
        [
          backgroundColor.withOpacity(0.8),
          backgroundColor.withOpacity(0.3),
        ],
      );
    } else {
      paint.color = backgroundColor;
    }

    canvas.drawCircle(rect.center, radius, paint);
  }

  void _drawDisabledRanges(Canvas canvas, Rect rect) {
    var paint = Paint()
      ..style = paintingStyle
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (int i = 0; i < disabledStartAngle!.length; i++) {
      var start = normalizeAngle(disabledStartAngle![i]);
      var end = normalizeAngle(disabledEndAngle![i]);
      var sweep = calcSweepAngle(start, end);

      // Add pattern or texture to disabled areas
      paint.shader = ui.Gradient.sweep(
        rect.center,
        [
          disabledColor.withOpacity(0.3),
          disabledColor.withOpacity(0.5),
          disabledColor.withOpacity(0.3),
        ],
        [0.0, 0.5, 1.0],
      );

      canvas.drawArc(
          rect, start, sweep, paintingStyle == PaintingStyle.fill, paint);
    }
  }

  void _drawSelectedRange(Canvas canvas, Rect rect) {
    var paint = Paint()
      ..style = paintingStyle
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    var start = normalizeAngle(startAngle!);
    var end = normalizeAngle(endAngle!);
    var sweep = calcSweepAngle(start, end);

    // Create vibrant gradient for selected range
    var startPos = calcCoords(radius, radius, start, radius);
    var endPos = calcCoords(radius, radius, end, radius);

    paint.shader = ui.Gradient.linear(
      startPos,
      endPos,
      [
        strokeColor,
        selectedColor,
        strokeColor,
      ],
      [0.0, 0.5, 1.0],
    );

    // Add glow effect to selected range
    var glowPaint = Paint()
      ..style = paintingStyle
      ..strokeWidth = strokeWidth + 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8)
      ..shader = ui.Gradient.linear(
        startPos,
        endPos,
        [
          strokeColor.withOpacity(0.5),
          selectedColor.withOpacity(0.5),
          strokeColor.withOpacity(0.5),
        ],
      );

    canvas.drawArc(
        rect, start, sweep, paintingStyle == PaintingStyle.fill, glowPaint);

    canvas.drawArc(
        rect, start, sweep, paintingStyle == PaintingStyle.fill, paint);
  }

  void _drawModernTicks(Canvas canvas) {
    var r = radius + ticksOffset - strokeWidth / 2;
    var paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = ticksWidth
      ..isAntiAlias = true;

    List.generate(ticks!, (i) => i + 1).forEach((i) {
      double angle = (360 / ticks!) * i * pi / 180 + offsetRad;

      // Vary tick opacity and length for depth
      bool isMainTick = i % (ticks! ~/ 4) == 0;
      paint.color = ticksColor.withOpacity(isMainTick ? 1.0 : 0.4);
      double tickLen = isMainTick ? ticksLength * 1.5 : ticksLength;

      canvas.drawLine(
        calcCoords(radius, radius, angle, r),
        calcCoords(radius, radius, angle, r + tickLen),
        paint,
      );
    });
  }

  void drawModernHandler(Canvas canvas, ActiveTime type, double angle) {
    bool isActive = activeTime == type;
    Offset handlerPosition = calcCoords(radius, radius, angle, radius);

    // Draw outer glow
    var glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isActive ? 12 : 8)
      ..color = (isActive ? selectedColor : handlerColor).withOpacity(0.4);

    canvas.drawCircle(handlerPosition, handlerRadius * 2, glowPaint);

    // Draw handler shadow for depth
    var shadowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4)
      ..color = Colors.black.withOpacity(0.2);

    canvas.drawCircle(
      handlerPosition + Offset(2, 2),
      handlerRadius,
      shadowPaint,
    );

    // Draw main handler with gradient
    var handlerPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.radial(
        handlerPosition,
        handlerRadius,
        [
          (isActive ? selectedColor : handlerColor).withOpacity(0.9),
          (isActive ? selectedColor : handlerColor),
        ],
        [0.0, 1.0],
      );

    canvas.drawCircle(handlerPosition, handlerRadius, handlerPaint);

    // Draw outer ring with glassmorphism effect
    var ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isActive ? 3 : 2
      ..color = Colors.white.withOpacity(isActive ? 0.8 : 0.5);

    canvas.drawCircle(handlerPosition, handlerRadius * 1.5, ringPaint);

    // Draw inner highlight for glossy effect
    var highlightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.3);

    canvas.drawCircle(
      handlerPosition - Offset(handlerRadius * 0.3, handlerRadius * 0.3),
      handlerRadius * 0.3,
      highlightPaint,
    );

    if (type == ActiveTime.Start)
      _startHandlerPosition = handlerPosition;
    else
      _endHandlerPosition = handlerPosition;
  }

  void drawLabels(Canvas canvas) {
    labels.forEach((label) {
      drawText(
          canvas,
          label.text,
          calcCoords(
              radius, radius, label.angle + offsetRad, radius + labelOffset),
          label.angle + offsetRad);
    });
  }

  void drawText(Canvas canvas, String text, Offset position, double angle) {
    angle = normalizeAngle(angle);

    TextSpan span = TextSpan(
      text: text,
      style: labelStyle?.copyWith(
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );

    _textPainter = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout();
    Offset drawCenter =
        Offset(-(_textPainter.width / 2), -(_textPainter.height / 2));

    if (rotateLabels) {
      bool flipLabel = false;
      if (autoAdjustLabels) {
        if (angle > 0 && angle < pi) {
          flipLabel = true;
        }
      }

      var wordWidth = _textPainter.width;
      var dist = (radius + labelOffset);
      double lengthOffset = 0;
      var chars = !flipLabel ? text.runes : text.runes.toList().reversed;

      chars.forEach((char) {
        prepareTextPainter(String.fromCharCode(char));
        final double curveAngle = angle - (wordWidth / 2 - lengthOffset) / dist;
        double letterAngle = curveAngle + pi / 2;
        if (flipLabel) letterAngle = letterAngle + pi;
        final Offset letterPos = calcCoords(radius, radius, curveAngle, dist);
        drawCenter = Offset(
            flipLabel ? -_textPainter.width : 0, -(_textPainter.height / 2));

        canvas.translate(letterPos.dx, letterPos.dy);
        canvas.rotate(letterAngle);
        _textPainter.paint(canvas, drawCenter);
        canvas.rotate(-letterAngle);
        canvas.translate(-letterPos.dx, -letterPos.dy);
        lengthOffset += _textPainter.width;
      });
    } else {
      _textPainter.paint(canvas, position + drawCenter);
    }
  }

  void prepareTextPainter(String letter) {
    _textPainter.text = TextSpan(
      text: letter,
      style: labelStyle?.copyWith(
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );
    _textPainter.layout();
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) => true;

  Offset calcCoords(double cx, double cy, double angle, double radius) {
    double x = cx + radius * cos(angle);
    double y = cy + radius * sin(angle);
    return Offset(x, y);
  }

  double calcSweepAngle(double init, double end) {
    if (end > init) {
      return end - init;
    } else
      return 2 * pi - (end - init).abs();
  }
}
