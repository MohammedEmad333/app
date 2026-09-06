import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

enum NodeStatus { locked, current, completed }

/// A single node on the skill-tree path. Shows a pulsing ring when it is the
/// current lesson, a golden star when completed, and a padlock when locked.
class LessonNode extends StatefulWidget {
  const LessonNode({
    super.key,
    required this.title,
    required this.icon,
    required this.status,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String icon;
  final NodeStatus status;
  final Color color;
  final VoidCallback onTap;

  @override
  State<LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<LessonNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.status == NodeStatus.current) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant LessonNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == NodeStatus.current && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (widget.status != NodeStatus.current && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locked = widget.status == NodeStatus.locked;
    final completed = widget.status == NodeStatus.completed;

    final faceColor = locked
        ? AppColors.disabled
        : (completed ? AppColors.yellow : widget.color);
    final shadowColor = locked
        ? AppColors.borderDark
        : (completed ? AppColors.yellowDark : _darken(widget.color));

    return Semantics(
      button: !locked,
      label: '${widget.title}, ${widget.status.name}',
      child: Column(
        children: [
          GestureDetector(
            onTap: locked ? null : widget.onTap,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) {
                return SizedBox(
                  width: 104,
                  height: 104,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (widget.status == NodeStatus.current)
                        Container(
                          width: 84 + _pulse.value * 20,
                          height: 84 + _pulse.value * 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.color.withValues(
                                alpha: 0.35 * (1 - _pulse.value)),
                          ),
                        ),
                      child!,
                    ],
                  ),
                );
              },
              child: _nodeFace(faceColor, shadowColor, locked, completed),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.title,
            style: AppTextStyles.caption.copyWith(
              color: locked ? AppColors.disabledText : AppColors.ink,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nodeFace(
      Color faceColor, Color shadowColor, bool locked, bool completed) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: faceColor,
        shape: BoxShape.circle,
        border: Border(
          bottom: BorderSide(color: shadowColor, width: 6),
        ),
      ),
      child: Center(
        child: locked
            ? const Icon(Icons.lock_rounded,
                color: AppColors.disabledText, size: 32)
            : completed
                ? const Icon(Icons.star_rounded,
                    color: Colors.white, size: 44)
                : Text(widget.icon, style: const TextStyle(fontSize: 36)),
      ),
    );
  }

  static Color _darken(Color c, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
