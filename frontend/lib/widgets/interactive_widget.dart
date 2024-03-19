import 'package:flutter/material.dart';

class InteractiveWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableHoverTilt;

  const InteractiveWidget({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enableHoverTilt = false, // Default value is false
  }) : super(key: key);

  @override
  InteractiveWidgetState createState() => InteractiveWidgetState();
}

class InteractiveWidgetState extends State<InteractiveWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _tiltController;
  late Animation<double> _tiltAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.enableHoverTilt) {
      _tiltController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      );
      _tiltAnimation =
          Tween<double>(begin: 0, end: 0.785398) // 45 degrees in radians
              .animate(
        CurvedAnimation(
          parent: _tiltController,
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    if (widget.enableHoverTilt) {
      _tiltController.dispose();
    }
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) async {
    await _scaleController.animateTo(1.0,
        duration: const Duration(milliseconds: 100));
    await _scaleController.animateTo(0.0,
        duration: const Duration(milliseconds: 100));
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        if (widget.enableHoverTilt) {
          _tiltController.forward();
        }
      },
      onExit: (event) {
        if (widget.enableHoverTilt) {
          _tiltController.reverse();
        }
      },
      child: GestureDetector(
        onTap: () => Future.delayed(const Duration(milliseconds: 100), () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        }),
        onLongPress: widget.onLongPress,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            if (widget.enableHoverTilt) _tiltAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.enableHoverTilt
                  ? Transform.rotate(
                      angle: _tiltAnimation.value,
                      child: widget.child,
                    )
                  : widget.child,
            );
          },
        ),
      ),
    );
  }
}
