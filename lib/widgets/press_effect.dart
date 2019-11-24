import 'package:flutter/material.dart';

class PressEffect extends StatefulWidget {
  PressEffect(
      {Key key,
      this.builder,
      this.child,
      @required this.shape,
      this.color,
      this.height,
      this.width,
      this.onTap,
      pressedColor})
      : pressedColor = pressedColor ?? Color.lerp(color, Colors.black, 0.2),
        super(key: key) {
    //use a builder or a child
    assert((builder == null) != (child == null));
  }

  final Widget Function(double value) builder;
  final Function() onTap;
  final Widget child;
  final ShapeBorder shape;
  final Color color;
  final Color pressedColor;
  final double height;
  final double width;

  @override
  _PressEffectState createState() => _PressEffectState();
}

class _PressEffectState extends State<PressEffect>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animationTween;

  bool isPressed = false;
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _animationController.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          if (!isPressed) _animationController.reverse();
          break;
        default:
          break;
      }
    });
    _animationTween = Tween(begin: 1.0, end: 0.0).animate(_animationController);
    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16 + (_animationTween.value - 1) * -10,
        vertical: 16 + (_animationTween.value - 1) * -10,
      ),
      width: widget.width != null ? widget.width + 32 : null,
      height: widget.height != null ?widget.height + 32 : null,
      child: Material(
        elevation: _animationController.isAnimating ? 5 : 25,
        shape: widget.shape,
        color: Color.lerp(
            widget.color, widget.pressedColor, -(_animationTween.value - 1)),
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: widget.child ?? widget.builder(_animationController.value),
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
    isPressed = true;
  }

  void _onTapUp(TapUpDetails details) {
    isPressed = false;
    if (_animationController.isCompleted) _animationController.reverse();
  }

  void _onTapCancel() {
    isPressed = false;
    if (_animationController.isCompleted) _animationController.reverse();
  }
}
