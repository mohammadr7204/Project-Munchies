import 'package:flutter/material.dart';

class DraggableBottomSheet extends StatefulWidget {
  final Widget child;
  final double minHeight;
  final double maxHeight;
  final bool isExpanded;
  final ValueChanged<bool>? onExpandedChanged;

  const DraggableBottomSheet({
    Key? key,
    required this.child,
    this.minHeight = 100,
    this.maxHeight = 500,
    this.isExpanded = false,
    this.onExpandedChanged,
  }) : super(key: key);

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactorAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _heightFactorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    final currentHeight = _controller.value * (widget.maxHeight - widget.minHeight);
    final newHeight = currentHeight - delta;
    final newValue = newHeight / (widget.maxHeight - widget.minHeight);
    _controller.value = newValue.clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.value > 0.5) {
      _expand();
    } else {
      _collapse();
    }
  }

  void _expand() {
    _controller.fling(velocity: 2.0);
    setState(() {
      _isExpanded = true;
      widget.onExpandedChanged?.call(true);
    });
  }

  void _collapse() {
    _controller.fling(velocity: -2.0);
    setState(() {
      _isExpanded = false;
      widget.onExpandedChanged?.call(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final height = widget.minHeight +
            (widget.maxHeight - widget.minHeight) * _heightFactorAnimation.value;

        return GestureDetector(
          onVerticalDragUpdate: _handleDragUpdate,
          onVerticalDragEnd: _handleDragEnd,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        );
      },
    );
  }
}
