import 'package:flutter/material.dart';

enum PressState { pressed, hold, unpressed }

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
      this.onLongPress,
      pressedColor})
      : pressedColor = pressedColor ?? Color.lerp(color, Colors.black, 0.2),
        super(key: key) {
    //use a builder or a child
    assert((builder == null) != (child == null));
  }

  final Widget Function(double value, PressState state) builder;
  final Function() onTap;
  final Function() onLongPress;
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
  CurvedAnimation _animation;
  PressState state = PressState.unpressed;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 100),
      reverseDuration: Duration(milliseconds: 700),
      vsync: this,
    );
    _animationController.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          if (state == PressState.unpressed) _animationController.reverse();
          break;
        default:
          break;
      }
    });
    _animationTween = Tween(begin: 1.0, end: 0.0).animate(_animationController);
    _animation = CurvedAnimation(curve: Curves.easeIn, reverseCurve: Curves.elasticOut, parent: _animationTween);
    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16 + (_animation.value - 1) * -10,
        vertical: 16 + (_animation.value - 1) * -10,
      ),
      width: widget.width != null ? widget.width + 32 : null,
      height: widget.height != null ? widget.height + 32 : null,
      child: Material(
        elevation: state != PressState.unpressed ? 5 : 25,
        shape: widget.shape,
        color: Color.lerp(
            widget.color, widget.pressedColor, -(_animationTween.value - 1)),
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onLongPressStart: _onLongPressStart,
          onLongPressUp: _onTapCancel,
          onLongPress: widget.onLongPress,
          onTapCancel: _onTapCancel,
          child:
              widget.child ?? widget.builder(_animationController.value, state),
        ),
      ),
    );
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      state = PressState.hold;
      _animationController.forward();
    });
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
    setState(() {
      state = PressState.pressed;
    });
  }

  void _onTapUp(TapUpDetails details) {
    if (_animationController.isCompleted) _animationController.reverse();
    setState(() {
      state = PressState.unpressed;
    });
  }

  void _onTapCancel() {
    setState(() {
      state = PressState.unpressed;
      if (_animationController.isCompleted) _animationController.reverse();
    });
  }
}
