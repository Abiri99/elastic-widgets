import 'package:flutter/material.dart';

class SeekBarPainter extends CustomPainter {
  double x1;
  double y1;
  double x2;
  double y2;

  double thumbX;
  double thumbY;

  Path path;

  bool touched;

  double width;
  double height;

  double thickLineStrokeWidth;
  double thinLineStrokeWidth;

  Color thickLineColor;
  Color thinLineColor;

  double circleRadius;

  Paint painter;

  SeekBarPainter({
    @required this.thumbX,
    @required this.thumbY,
    @required this.width,
    @required this.height,
    @required this.thickLineStrokeWidth,
    @required this.thinLineStrokeWidth,
    @required this.thickLineColor,
    @required this.thinLineColor,
    @required this.circleRadius,
    this.touched = false,
  }) {
    path = Path();
    path.reset();
    painter = Paint();
  }

  double get trackEndX {
    return width - circleRadius - thickLineStrokeWidth / 2;
  }

  double get trackStartX {
    return circleRadius + thickLineStrokeWidth / 2;
  }

  double get trackY {
    return height / 2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var mThumbY = thumbY + height / 2;

    // Progress line
    path.reset();
    painter = Paint()
      ..color = thickLineColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = thickLineStrokeWidth;

    x1 = (thumbX + trackStartX) / 2;
    y1 = height / 2;
    x2 = x1;
    y2 = mThumbY;

    path.moveTo(trackStartX, height / 2);
    path.cubicTo(x1, y1, x2, y2, thumbX - circleRadius, mThumbY);
    if (thumbX - circleRadius >= trackStartX) canvas.drawPath(path, painter);

    // Default line
    painter = Paint()
      ..color = thinLineColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = thinLineStrokeWidth;

    path.reset();
    path.moveTo(thumbX + circleRadius, mThumbY);

    x1 = (thumbX + trackEndX) / 2;
    y1 = mThumbY;
    x2 = x1;
    y2 = height / 2;

    path.cubicTo(x1, y1, x2, y2, trackEndX, trackY);

    if (thumbX + circleRadius <= trackEndX) canvas.drawPath(path, painter);

    // Circle inside
    painter = Paint()
      ..color = thickLineColor.withOpacity(touched ? 0.9 : 0.4)
      ..style = PaintingStyle.fill;

    path.reset();
    canvas.drawCircle(Offset(thumbX, mThumbY),
        circleRadius - thickLineStrokeWidth / 2, painter);

    // Circle border
    painter = Paint()
      ..color = thickLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickLineStrokeWidth;

    canvas.drawCircle(Offset(thumbX, mThumbY), circleRadius, painter);

    path.reset();
  }

  @override
  bool shouldRepaint(CustomPainter oldPainter) {
    return oldPainter != this;
  }
}
