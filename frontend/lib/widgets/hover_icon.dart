import 'package:flutter/material.dart';

class HoverIconWidget extends StatefulWidget {
  final IconData icon;
  final double? size;
  final Color color;
  final String? tooltip;

  const HoverIconWidget(
      {super.key,
      required this.icon,
      required this.color,
      this.size,
      this.tooltip});

  @override
  HoverIconWidgetState createState() => HoverIconWidgetState();
}

class HoverIconWidgetState extends State<HoverIconWidget> {
  @override
  Widget build(BuildContext context) {
    Icon iconWidget = Icon(
      widget.icon,
      color: widget.color,
      size: widget.size ?? 30,
    );

    return HoverWidget(
      icon: iconWidget,
      color: widget.color,
      tooltip: widget.tooltip,
    );
  }
}

class HoverWidget extends StatefulWidget {
  final Widget icon;
  final Color color;
  final String? tooltip;

  const HoverWidget(
      {super.key, required this.icon, required this.color, this.tooltip});

  @override
  HoverWidgetState createState() => HoverWidgetState();
}

class HoverWidgetState extends State<HoverWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = AnimatedBuilder(
      animation: _scaleAnimation!,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation!.value,
        child: widget.icon,
      ),
    );

    if (widget.tooltip != null) {
      icon = Tooltip(
        message: widget.tooltip!,
        child: icon,
      );
    }

    return MouseRegion(
      onEnter: (event) => _animationController?.forward(),
      onExit: (event) => _animationController?.reverse(),
      child: icon,
    );
  }
}
