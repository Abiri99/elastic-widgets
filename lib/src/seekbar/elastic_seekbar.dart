import 'package:elastic_widgets/src/seekbar/seekbar_painter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../util/utils.dart';

// ignore: must_be_immutable
class ElasticSeekBar extends StatefulWidget {
  // Notifies parent of the current value
  final Function(String value) valueListener;

  // Size of seek bar
  final Size size;

  // Minimum value of seek bar
  final double minValue;

  // Maximum value of seek bar
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

  final double stiffness;

  final double dampingRatio;

  ElasticSeekBar({
    Key key,
    @required this.valueListener,
    @required this.size,
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
  }) : super(key: key) {
    if (thickLineColor == null) thickLineColor = Color(0xff1f3453);
    if (thinLineColor == null) thinLineColor = Color(0xff1f3453).withAlpha(80);
    if (stretchRange == null)
      stretchRange = size.height / 2 - circleRadius - thickLineStrokeWidth / 2;
  }

  @override
  _ElasticSeekBarState createState() => _ElasticSeekBarState();
}

class _ElasticSeekBarState extends State<ElasticSeekBar>
    with SingleTickerProviderStateMixin {
  double value;

  double thumbY;
  double thumbX;

  double trackStartX;
  double trackEndX;
  double trackY;

  AnimationController _controller;

  Animation<double> _animation;

  bool touched;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, upperBound: 500);

    _controller.addListener(controllerListener);

    touched = false;
    value = (widget.maxValue - widget.minValue) / 2;
    thumbY = 0;
    thumbX = widget.size.width / 2;
    trackY = widget.size.height / 2;
    trackEndX = widget.size.width -
        widget.circleRadius -
        widget.thickLineStrokeWidth / 2;
    trackStartX = widget.circleRadius + widget.thickLineStrokeWidth / 2;
    super.initState();
  }

  controllerListener() {
    setState(() {
      thumbY = _animation.value;
    });
  }

  String getCurrentValue() {
    if (thumbX <= trackStartX) return widget.minValue.toString();
    if (thumbX >= trackEndX) return widget.maxValue.toString();
    return (((thumbX - trackStartX) / (trackEndX - trackStartX)) *
        (widget.maxValue - widget.minValue))
        .toString();
  }

  runAnimation(Offset pixelsPerSecond, Size size) {
    _animation = _controller.drive(Tween<double>(
      begin: thumbY,
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

    _controller.animateWith(simulation);
  }

  int detectNode(var gestureDetectorDetails) {
    if (touched) return 0;
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
            thumbX -
                widget.circleRadius -
                widget.thickLineStrokeWidth / 2 &&
        gestureDetectorDetails.localPosition.dx <=
            thumbX +
                widget.circleRadius +
                widget.thickLineStrokeWidth / 2) {
      return 0;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.size.height,
      width: widget.size.width,
      child: GestureDetector(
        onPanDown: (details) {
          var node = detectNode(details);
          if (node == 0) {
            setState(() {
              touched = true;
            });
            _controller.stop();
          }
        },
        onPanUpdate: (DragUpdateDetails dragUpdateDetails) {
          var node = detectNode(dragUpdateDetails);
          if (node == 0 || touched) {
            touched = true;
            RenderBox box = context.findRenderObject();
            var touchPoint = box.globalToLocal(dragUpdateDetails.globalPosition);
            if (dragUpdateDetails.localPosition.dx <= 0) {
              touchPoint = new Offset(0, 0.0);
            }
            if (touchPoint.dx >= context.size.width) {
              touchPoint = new Offset(context.size.width, 0);
            }
            if (touchPoint.dy <= 0) {
              touchPoint = new Offset(touchPoint.dx, 0.0);
            }
            if (touchPoint.dy >= context.size.height) {
              touchPoint = new Offset(touchPoint.dx, context.size.height);
            }
            setState(() {
              thumbX = touchPoint.dx.coerceHorizontal(trackStartX, trackEndX);
              thumbY = (touchPoint.dy - widget.size.height / 2)
                  .coerceVertical(
                  0,
                  widget.size.height / 2 -
                      widget.circleRadius -
                      widget.thickLineStrokeWidth / 2)
                  .coerceToStretchRange(
                  thumbX,
                  widget.size.height,
                  widget.size.width,
                  widget.stretchRange,
                  trackStartX,
                  trackEndX);
            });
            widget.valueListener(getCurrentValue());
          }
        },
        onPanEnd: (DragEndDetails dragEndDetails) {
          touched = false;
          runAnimation(dragEndDetails.velocity.pixelsPerSecond, widget.size);
        },
        child: Container(
          height: widget.size.height,
          width: widget.size.width,
          color: Colors.grey,
          child: CustomPaint(
            size: Size(widget.size.width, widget.size.height),
            painter: SeekBarPainter(
              thumbX: thumbX,
              thumbY: thumbY,
              width: widget.size.width,
              height: widget.size.height,
              touched: touched,
              thickLineColor: widget.thickLineColor,
              thickLineStrokeWidth: widget.thickLineStrokeWidth,
              thinLineColor: widget.thinLineColor,
              thinLineStrokeWidth: widget.thinLineStrokeWidth,
              circleRadius: widget.circleRadius,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(controllerListener);
    _controller.dispose();
    super.dispose();
  }
}