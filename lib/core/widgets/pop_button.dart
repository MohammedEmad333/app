import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A Duolingo-style 3D "pop" button. The colored face sits on top of a darker
/// shadow layer; pressing sinks the face down onto the shadow for a tactile
/// squish. Fully accessible via a large touch target.
class PopButton extends StatefulWidget {
  const PopButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.shadowColor = AppColors.primaryDark,
    this.textColor = Colors.white,
    this.icon,
    this.expand = true,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final IconData? icon;
  final bool expand;
  final bool enabled;

  @override
  State<PopButton> createState() => _PopButtonState();
}

class _PopButtonState extends State<PopButton> {
  bool _pressed = false;

  bool get _active => widget.enabled && widget.onPressed != null;

  static const double _depth = 6;

  @override
  Widget build(BuildContext context) {
    final color = _active ? widget.color : AppColors.disabled;
    final shadow = _active ? widget.shadowColor : AppColors.borderDark;
    final textColor = _active ? widget.textColor : AppColors.disabledText;
    final sunk = _pressed && _active;

    final button = GestureDetector(
      onTapDown: _active ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _active ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: _active ? () => setState(() => _pressed = false) : null,
      onTap: _active ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        padding: EdgeInsets.only(bottom: sunk ? 0 : _depth),
        decoration: BoxDecoration(
          color: shadow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          transform: Matrix4.translationValues(0, sunk ? _depth : 0, 0),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: textColor, size: 22),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label.toUpperCase(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.button.copyWith(color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: _active,
      label: widget.label,
      child: widget.expand
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}
