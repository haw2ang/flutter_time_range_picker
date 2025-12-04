import 'dart:math';
import 'package:flutter/material.dart';
import 'package:time_range_picker/src/utils.dart';

class ClockPainter extends CustomPainter {
  double? startAngle;
  double? endAngle;

  List<double>? disabledStartAngle = const [];
  List<double>? disabledEndAngle = const [];
  ActiveTime? activeTime;

  // REMOVED: double radius; (Calculated dynamically now)

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
    // REMOVED: required this.radius,
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
    // NEW: Calculate Center and Radius based on available Size
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 2;

    var paint = Paint()
      ..style = paintingStyle
      ..strokeWidth = strokeWidth
      ..color = backgroundColor
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    // NEW: Define rect based on dynamic center and radius
    var rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(rect.center, radius, paint);

    if (disabledStartAngle != null &&
        disabledEndAngle != null &&
        disabledStartAngle!.isNotEmpty &&
        disabledEndAngle!.isNotEmpty) {
      paint.color = disabledColor;

      for (int i = 0; i < disabledStartAngle!.length; i++) {
        var start = normalizeAngle(disabledStartAngle![i]);
        var end = normalizeAngle(disabledEndAngle![i]);
        var sweep = calcSweepAngle(start, end);

        canvas.drawArc(
            rect, start, sweep, paintingStyle == PaintingStyle.fill, paint);
      }
    }

    drawTicks(paint, canvas, center, radius);

    paint.color = strokeColor;
    paint.strokeWidth = strokeWidth;
    if (startAngle != null && endAngle != null) {
      var start = normalizeAngle(startAngle!);
      var end = normalizeAngle(endAngle!);
      var sweep = calcSweepAngle(start, end);

      canvas.drawArc(
          rect, start, sweep, paintingStyle == PaintingStyle.fill, paint);

      drawHandler(paint, canvas, ActiveTime.Start, start, center, radius);
      drawHandler(paint, canvas, ActiveTime.End, end, center, radius);
    }

    drawLabels(paint, canvas, center, radius);

    canvas.save();
    canvas.restore();
  }

  // MODIFIED: Accepts center and radius
  void drawHandler(Paint paint, Canvas canvas, ActiveTime type, double angle,
      Offset center, double radius) {
    paint.style = PaintingStyle.fill;
    paint.color = handlerColor;
    if (activeTime == type) {
      paint.color = selectedColor;
    }

    // MODIFIED: Uses center.dx/dy
    Offset handlerPosition = calcCoords(center.dx, center.dy, angle, radius);
    canvas.drawCircle(handlerPosition, handlerRadius, paint);

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(handlerPosition, handlerRadius * 1.5, paint);

    if (type == ActiveTime.Start)
      _startHandlerPosition = handlerPosition;
    else
      _endHandlerPosition = handlerPosition;
  }

  // MODIFIED: Accepts center and radius
  void drawTicks(Paint paint, Canvas canvas, Offset center, double radius) {
    var r = radius + ticksOffset - strokeWidth / 2;
    paint.color = ticksColor;
    paint.strokeWidth = ticksWidth;
    for (var i in List.generate(ticks!, (i) => i + 1)) {
      double angle = (360 / ticks!) * i * pi / 180 + offsetRad;

      // MODIFIED: Uses center.dx/dy
      canvas.drawLine(calcCoords(center.dx, center.dy, angle, r),
          calcCoords(center.dx, center.dy, angle, r + ticksLength), paint);
    }
  }

  // MODIFIED: Accepts center and radius
  void drawLabels(Paint paint, Canvas canvas, Offset center, double radius) {
    for (var label in labels) {
      // MODIFIED: Uses center.dx/dy and passed radius
      drawText(
          canvas,
          paint,
          label.text,
          calcCoords(center.dx, center.dy, label.angle + offsetRad,
              radius + labelOffset),
          label.angle + offsetRad,
          radius // Pass radius down for rotate calculation
          );
    }
  }

  // MODIFIED: Accepts radius to calculate arc distance
  void drawText(Canvas canvas, Paint paint, String text, Offset position,
      double angle, double radius) {
    angle = normalizeAngle(angle);

    TextSpan span = TextSpan(
      text: text,
      style: labelStyle,
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

      // get the width of the word
      var wordWidth = _textPainter.width;

      //the total distance from center of circle (uses calculated radius)
      var dist = (radius + labelOffset);

      // accumulat the offset of the letter within the word
      double lengthOffset = 0;

      // if flip, reverse letter order
      var chars = !flipLabel ? text.runes : text.runes.toList().reversed;

      for (var char in chars) {
        // put char to textpainter
        prepareTextPainter(String.fromCharCode(char));

        // the angle where the letter appears on the circle
        final double curveAngle = angle - (wordWidth / 2 - lengthOffset) / dist;

        double letterAngle = curveAngle + pi / 2;

        // flip 180°
        if (flipLabel) letterAngle = letterAngle + pi;

        // the position of the letter on the circle.
        // NOTE: We need the actual Center of the canvas here, but drawText currently assumes
        // it's being called within a specific transform context or calculates based on radius.
        // To keep it simple based on previous implementation:
        // calcCoords needs center (cx, cy).
        // Since we are inside drawText, we need access to 'center'.
        // However, looking at the logic, we can derive cx/cy from the 'position' passed in
        // IF 'position' wasn't already calculated. But it is.
        // Let's recalculate center for the letter logic:

        // Logic fix: We need the center of the clock to calculate letter positions.
        // The passed 'position' is the center of the whole word.
        // We can back-calculate the center or pass it in.
        // For cleaner code, let's assume the user of this method passes the clock center,
        // but since I didn't add that arg to drawText signature to avoid breaking too much logic:

        // We can approximate cx/cy by using the passed radius and angle relative to position,
        // but it is safer to pass center explicitly.

        // To solve this without changing signature too much, let's derive cx/cy.
        // position.dx = cx + (radius+offset) * cos(angle)
        // cx = position.dx - (radius+offset) * cos(angle)
        double cx = position.dx - dist * cos(angle);
        double cy = position.dy - dist * sin(angle);

        final Offset letterPos = calcCoords(cx, cy, curveAngle, dist);

        // adjust alignment of the letter (vertically centered)
        drawCenter = Offset(
            flipLabel ? -_textPainter.width : 0, -(_textPainter.height / 2));

        //move canvas to letter position
        canvas.translate(letterPos.dx, letterPos.dy);

        //rotate canvas to letter rotation
        canvas.rotate(letterAngle);

        // paint letter
        _textPainter.paint(canvas, drawCenter);

        //undo movements
        canvas.rotate(-letterAngle);
        canvas.translate(-letterPos.dx, -letterPos.dy);

        //increase letter offset
        lengthOffset += _textPainter.width;
      }
    } else {
      _textPainter.paint(canvas, position + drawCenter);
    }
  }

  /// Calculates width and central angle for the provided [letter].
  void prepareTextPainter(String letter) {
    _textPainter.text = TextSpan(text: letter, style: labelStyle);
    _textPainter.layout();
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) => true;

  /// get the position on the circle for certain [angle]
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
