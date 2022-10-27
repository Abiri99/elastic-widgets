import 'package:flutter/material.dart';

class RangePickerPainter extends CustomPainter {
  double? x1;
  late double y1;
  double? x2;
  late double y2;

  double? firstThumbX;
  double? firstThumbY;
  double? secThumbX;
  double? secThumbY;

  double? circleRadius;

  double? thickLineStrokeWidth;
  double? thinLineStrokeWidth;

  Color? thickLineColor;
  Color? thinLineColor;

  late Path path;

  double? width;
  double? height;
  bool? firstNodeTouched;
  bool? secNodeTouched;

  RangePickerPainter({
    this.firstThumbX,
    this.firstThumbY,
    this.secThumbX,
    this.secThumbY,
    this.width,
    this.height,
    this.firstNodeTouched,
    this.secNodeTouched,
    this.circleRadius,
    this.thickLineStrokeWidth,
    this.thinLineStrokeWidth,
    this.thickLineColor,
    this.thinLineColor,
  }) {
    path = Path();
    path.reset();
  }

  double get trackEndX {
    return width! - circleRadius! - thickLineStrokeWidth! / 2;
  }

  double get trackStartX {
    return circleRadius! + thickLineStrokeWidth! / 2;
  }

  double get trackY {
    return height! / 2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var mFirstThumbY = firstThumbY! + height! / 2;
    var mSecThumbY = secThumbY! + height! / 2;

    path.reset();

    final Paint progressLinePainter = Paint()
      ..color = thickLineColor!
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = thickLineStrokeWidth!;

    final Paint defaultPainter = Paint()
      ..color = thinLineColor!
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = thinLineStrokeWidth!;

    final Paint firstCirclePainter = Paint()
      ..color = thickLineColor!
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickLineStrokeWidth!;

    final Paint firstCircleInsidePainter = Paint()
      ..color = thickLineColor!.withOpacity(firstNodeTouched! ? 0.9 : 0.4)
      ..style = PaintingStyle.fill;

    final Paint secCirclePainter = Paint()
      ..color = thickLineColor!
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickLineStrokeWidth!;

    final Paint secCircleInsidePainter = Paint()
      ..color = thickLineColor!.withOpacity(secNodeTouched! ? 0.9 : 0.4)
      ..style = PaintingStyle.fill;

    x1 = (firstThumbX! + trackStartX) / 2;
    y1 = height! / 2;
    x2 = x1;
    y2 = mFirstThumbY;

    path.moveTo(trackStartX, height! / 2);
    path.cubicTo(x1!, y1, x2!, y2, firstThumbX! - circleRadius!, mFirstThumbY);
    if (firstThumbX! - circleRadius! >= trackStartX)
      canvas.drawPath(path, defaultPainter);

    path.reset();
    path.moveTo(firstThumbX! + circleRadius!, mFirstThumbY);

//    x1 = firstThumbX + (secThumbX - firstThumbX) / 2;
    x1 = (firstThumbX! + secThumbX!) / 2;
    y1 = mFirstThumbY;
    x2 = x1;
    y2 = mSecThumbY;

    path.cubicTo(x1!, y1, x2!, y2, secThumbX! - circleRadius!, mSecThumbY);
    canvas.drawPath(path, progressLinePainter);

    path.reset();
    path.moveTo(secThumbX! + circleRadius!, mSecThumbY);

    x1 = (secThumbX! + trackEndX) / 2;
    y1 = mSecThumbY;
    x2 = x1;
    y2 = height! / 2;

    path.cubicTo(x1!, y1, x2!, y2, trackEndX, trackY);
    if (secThumbX! + circleRadius! <= trackEndX)
      canvas.drawPath(path, defaultPainter);

    canvas.drawCircle(
        Offset(firstThumbX!, mFirstThumbY), circleRadius!, firstCirclePainter);
    canvas.drawCircle(Offset(firstThumbX!, mFirstThumbY),
        circleRadius! - thickLineStrokeWidth! / 2, firstCircleInsidePainter);
    canvas.drawCircle(
        Offset(secThumbX!, mSecThumbY), circleRadius!, secCirclePainter);
    canvas.drawCircle(Offset(secThumbX!, mSecThumbY),
        circleRadius! - thickLineStrokeWidth! / 2, secCircleInsidePainter);

    path.reset();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
