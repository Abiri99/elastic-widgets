import 'package:elastic_widgets/src/range_picker/range_picker_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../util/utils.dart';

// ignore: must_be_immutable
class ElasticRangePicker extends StatefulWidget {
  // Size of widget
  final Size size;

  // A function passed from parent which notifies itself from the current value of range picker
  final Function(double firstVal, double secVal) valueListener;
  final double minValue;
  final double maxValue;

  // How much seek bar stretches in vertical axis
  double stretchRange;

  // Thickness of progress line and thumb
  final double thickLineStrokeWidth;

  // Thickness of default line
  final double thinLineStrokeWidth;

  // Radius of thumb
  final double circleRadius;

  // Color of progress line and thumb
  Color thickLineColor;

  // Color of default line
  Color thinLineColor;

  // Speed of bouncing animation
  final Duration bounceDuration;

  // Stiffness of slider while animating
  final double stiffness;

  // Damping ratio of slider while animating
  final double dampingRatio;

  ElasticRangePicker({
    this.size,
    this.valueListener,
    this.stretchRange,
    this.minValue = 0,
    this.maxValue = 100,
    this.circleRadius = 12,
    this.thickLineStrokeWidth = 4,
    this.thinLineStrokeWidth = 3,
    this.thickLineColor,
    this.thinLineColor,
    this.bounceDuration,
    this.stiffness = 300,
    this.dampingRatio = 8,
  }) {
    if (thickLineColor == null) thickLineColor = Color(0xff1f3453);
    if (thinLineColor == null) thinLineColor = Colors.blueGrey;
    if (stretchRange == null)
      stretchRange = size.height / 2 - circleRadius - thickLineStrokeWidth / 2;
  }

  @override
  _ElasticRangePickerState createState() => _ElasticRangePickerState();
}

class _ElasticRangePickerState extends State<ElasticRangePicker>
    with TickerProviderStateMixin {
  double firstThumbY;
  double firstThumbX;
  double secThumbY;
  double secThumbX;

  double trackStartX;
  double trackEndX;
  double trackY;

  double firstValue;
  double secondValue;

  bool firstNodeTouched;
  bool secNodeTouched;

  AnimationController _firstController;
  AnimationController _secondController;

  Animation<double> _firstAnimation;
  Animation<double> _secondAnimation;

  @override
  void initState() {
    _firstController = AnimationController(vsync: this, upperBound: 500);
    _secondController = AnimationController(vsync: this, upperBound: 500);

    _firstController.addListener(firstControllerListener);
    _secondController.addListener(secondControllerListener);

    firstNodeTouched = false;
    secNodeTouched = false;
    firstValue = (widget.maxValue - widget.minValue) / 3;
    secondValue = 2 * (widget.maxValue - widget.minValue) / 3;
    firstThumbY = 0;
    secThumbY = 0;
    firstThumbX = widget.size.width / 3;
    secThumbX = 2 * widget.size.width / 3;
    trackEndX = widget.size.width -
        widget.circleRadius -
        widget.thickLineStrokeWidth / 2;
    trackStartX = widget.circleRadius + widget.thickLineStrokeWidth / 2;
    super.initState();
  }

  firstControllerListener() {
    setState(() {
      firstThumbY = _firstAnimation.value;
    });
  }

  secondControllerListener() {
    setState(() {
      secThumbY = _secondAnimation.value;
    });
  }

  double getFirstValue() {
    if (firstThumbX <= trackStartX) return widget.minValue;
    if (firstThumbX >= trackEndX) return widget.maxValue;
    return (((firstThumbX - trackStartX) / (trackEndX - trackStartX)) *
        (widget.maxValue - widget.minValue));
  }

  double getSecValue() {
    if (secThumbX <= trackStartX) return widget.minValue;
    if (secThumbX >= trackEndX) return widget.maxValue;
    return (((secThumbX - trackStartX) / (trackEndX - trackStartX)) *
        (widget.maxValue - widget.minValue));
  }

  runFirstThumbAnimation(Offset pixelsPerSecond, Size size) {
    _firstAnimation = _firstController.drive(Tween<double>(
      begin: firstThumbY,
      end: 0.0,
    ));
    var spring = SpringDescription(
      mass: 1.0,
      stiffness: widget.stiffness,
      damping: widget.dampingRatio,
    );

    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _firstController.animateWith(simulation);
  }

  runSecondThumbAnimation(Offset pixelsPerSecond, Size size) {
    _secondAnimation = _secondController.drive(Tween<double>(
      begin: secThumbY,
      end: 0.0,
    ));
    var spring = SpringDescription(
      mass: 1.0,
      stiffness: widget.stiffness,
      damping: widget.dampingRatio,
    );

    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _secondController.animateWith(simulation);
  }

  int detectNodeByTouchpoint(var touchpoint) {
    if (firstNodeTouched) return 0;
    if (secNodeTouched) return 1;
    if (touchpoint.dy >=
            widget.size.height / 2 -
                widget.circleRadius -
                widget.thickLineStrokeWidth / 2 &&
        touchpoint.dy <=
            widget.size.height / 2 +
                widget.circleRadius +
                widget.thickLineStrokeWidth / 2 &&
        touchpoint.dx >=
            firstThumbX -
                widget.circleRadius -
                widget.thickLineStrokeWidth / 2 &&
        touchpoint.dx <=
            firstThumbX +
                widget.circleRadius +
                widget.thickLineStrokeWidth / 2) {
      return 0;
    } else if (touchpoint.dy >=
//            trackY -
            widget.size.height / 2 -
                widget.circleRadius -
                widget.thickLineStrokeWidth / 2 &&
        touchpoint.dy <=
//            trackY -
            widget.size.height / 2 +
                widget.circleRadius +
                widget.thickLineStrokeWidth / 2 &&
        touchpoint.dx >=
            secThumbX - widget.circleRadius - widget.thickLineStrokeWidth / 2 &&
        touchpoint.dx <=
            secThumbX + widget.circleRadius + widget.thickLineStrokeWidth / 2) {
      return 1;
    }
    return -1;
  }

  int detectNode(var gestureDetectorDetails) {
    if (firstNodeTouched) return 0;
    if (secNodeTouched) return 1;
    if (gestureDetectorDetails.localPosition.dy >=
//            trackY -
            widget.size.height / 2 -
                widget.circleRadius -
                widget.thickLineStrokeWidth / 2 &&
        gestureDetectorDetails.localPosition.dy <=
//            trackY -
            widget.size.height / 2 +
                widget.circleRadius +
                widget.thickLineStrokeWidth / 2 &&
        gestureDetectorDetails.localPosition.dx >=
            firstThumbX -
                widget.circleRadius -
                widget.thickLineStrokeWidth / 2 &&
        gestureDetectorDetails.localPosition.dx <=
            firstThumbX +
                widget.circleRadius +
                widget.thickLineStrokeWidth / 2) {
      return 0;
    } else if (gestureDetectorDetails.localPosition.dy >=
//            trackY -
            widget.size.height / 2 -
                widget.circleRadius -
                widget.thickLineStrokeWidth / 2 &&
        gestureDetectorDetails.localPosition.dy <=
//            trackY -
            widget.size.height / 2 +
                widget.circleRadius +
                widget.thickLineStrokeWidth / 2 &&
        gestureDetectorDetails.localPosition.dx >=
            secThumbX - widget.circleRadius - widget.thickLineStrokeWidth / 2 &&
        gestureDetectorDetails.localPosition.dx <=
            secThumbX + widget.circleRadius + widget.thickLineStrokeWidth / 2) {
      return 1;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: widget.size.height,
      width: widget.size.width,
      child: GestureDetector(
        onPanDown: (details) {
          var node = detectNode(details);
          if (node == 0) {
            setState(() {
              firstNodeTouched = true;
            });
            _firstController.stop();
          }
          if (node == 1) {
            setState(() {
              secNodeTouched = true;
            });
            _secondController.stop();
          }
        },
        onPanUpdate: (DragUpdateDetails dragUpdateDetails) {
          RenderBox box = context.findRenderObject();
          var touchPoint = box.globalToLocal(dragUpdateDetails.globalPosition);
          if (touchPoint.dx <= 0) {
            touchPoint = new Offset(0, 0.0);
          }
          if (touchPoint.dx >= trackEndX) {
            touchPoint = new Offset(trackEndX, 0);
          }
          if (touchPoint.dy <= 0) {
            touchPoint = new Offset(touchPoint.dx, 0.0);
          }
          if (touchPoint.dy >= context.size.height) {
            touchPoint = new Offset(touchPoint.dx, context.size.height);
          }
          var node = detectNodeByTouchpoint(touchPoint);
          if (node == 0) {
            firstNodeTouched = true;
            setState(
              () {
                firstThumbX = touchPoint.dx.coerceHorizontal(
                  trackStartX,
                  trackEndX -
                      2 *
                          (widget.circleRadius +
                              widget.thickLineStrokeWidth / 2),
                );
                if (firstThumbX >=
                    secThumbX -
                        2 *
                            (widget.circleRadius +
                                widget.thickLineStrokeWidth / 2)) {
                  secThumbX = (firstThumbX +
                          2 *
                              (widget.circleRadius +
                                  widget.thickLineStrokeWidth / 2))
                      .coerceHorizontal(
                    trackStartX +
                        2 *
                            (widget.circleRadius +
                                widget.thickLineStrokeWidth / 2),
                    trackEndX,
                  );
                }
                firstThumbY = (touchPoint.dy - widget.size.height / 2)
                    .coerceVertical(
                      0,
                      widget.size.height / 2 -
                          widget.circleRadius -
                          widget.thickLineStrokeWidth / 2,
                    )
                    .coerceToStretchRange(
                      firstThumbX,
                      widget.size.height,
                      secThumbX,
                      widget.stretchRange,
                      trackStartX,
                      secThumbX -
                          widget.circleRadius -
                          widget.thickLineStrokeWidth / 2,
                    );
              },
            );
            widget.valueListener(
              getFirstValue(),
              getSecValue(),
            );
          } else if (node == 1) {
            secNodeTouched = true;
            setState(
              () {
                secThumbX = touchPoint.dx.coerceHorizontal(
                  trackStartX +
                      2 *
                          (widget.circleRadius +
                              widget.thickLineStrokeWidth / 2),
                  trackEndX,
                );
                if (secThumbX <=
                    firstThumbX +
                        2 *
                            (widget.circleRadius +
                                widget.thickLineStrokeWidth / 2)) {
                  firstThumbX = (secThumbX -
                          2 *
                              (widget.circleRadius +
                                  widget.thickLineStrokeWidth / 2))
                      .coerceHorizontal(
                    trackStartX,
                    trackEndX -
                        2 *
                            (widget.circleRadius +
                                widget.thickLineStrokeWidth / 2),
                  );
                }
                secThumbY = (touchPoint.dy - widget.size.height / 2)
                    .coerceVertical(
                        0,
                        widget.size.height / 2 -
                            widget.circleRadius -
                            widget.thickLineStrokeWidth / 2)
                    .coerceToStretchRangeWithPivotAtTheMiddle(
                      secThumbX,
                      widget.stretchRange,
                      widget.size.height,
                      firstThumbX,
                      trackEndX,
                    );
              },
            );
            widget.valueListener(getFirstValue(), getSecValue());
          }
        },
        onPanEnd: (DragEndDetails dragEndDetails) {
          runFirstThumbAnimation(dragEndDetails.velocity.pixelsPerSecond, size);
          runSecondThumbAnimation(
              dragEndDetails.velocity.pixelsPerSecond, size);
          setState(
            () {
              firstNodeTouched = false;
              secNodeTouched = false;
            },
          );
        },
        child: CustomPaint(
          size: Size(
            widget.size.width,
            widget.size.height,
          ),
          painter: RangePickerPainter(
            firstThumbX: firstThumbX,
            firstThumbY: firstThumbY,
            secThumbX: secThumbX,
            secThumbY: secThumbY,
            circleRadius: widget.circleRadius,
            thickLineStrokeWidth: widget.thickLineStrokeWidth,
            thinLineStrokeWidth: widget.thinLineStrokeWidth,
            thickLineColor: widget.thickLineColor,
            thinLineColor: widget.thinLineColor,
            width: widget.size.width,
            height: widget.size.height,
            firstNodeTouched: firstNodeTouched,
            secNodeTouched: secNodeTouched,
          ),
        ),
      ),
    );
  }
}
