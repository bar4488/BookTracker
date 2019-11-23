import 'package:flutter/material.dart';

class PressEffect extends StatefulWidget {
  PressEffect({
    Key key,
    this.builder,
    this.child,
    @required this.shape,
    @required this.color,
    pressedColor
  }) : pressedColor = pressedColor ?? Color.lerp(color, Colors.black, 0.2), super(key: key){
    //use a builder or a child
    assert((builder == null) != (child == null));
  }

  final Function<Widget>(double value) builder;
  final Widget child;
  final ShapeBorder shape;
  final Color color;
  final Color pressedColor;

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
      margin: EdgeInsets.symmetric(
          horizontal: 16 + (_animationTween.value - 1) * -10,
          vertical: 16 + (_animationTween.value - 1) * -10),
      child: Material(
        elevation: isPressed ? 5 : 25,
        shape: widget.shape,
        color: Color.lerp(
            widget.color, widget.pressedColor, -(_animationTween.value - 1)),
        child: GestureDetector(
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
