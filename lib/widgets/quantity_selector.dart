import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget chọn số lượng với nút [+] và [-]. Không cho phép giảm xuống dưới 1.
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrement = quantity > min;
    final canIncrement = quantity < max;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QtyButton(
          icon: Icons.remove,
          enabled: canDecrement,
          onTap: () {
            if (!canDecrement) return;
            HapticFeedback.lightImpact();
            onChanged(quantity - 1);
          },
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        _QtyButton(
          icon: Icons.add,
          enabled: canIncrement,
          onTap: () {
            if (!canIncrement) return;
            HapticFeedback.lightImpact();
            onChanged(quantity + 1);
          },
        ),
      ],
    );
  }
}

class _QtyButton extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_QtyButton> createState() => _QtyButtonState();
}

class _QtyButtonState extends State<_QtyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.enabled ? widget.onTap : null,
      onHighlightChanged: (value) => setState(() => _pressed = value),
      borderRadius: BorderRadius.circular(6),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.9 : 1,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.enabled
                  ? Colors.grey.shade400
                  : Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(6),
            color: widget.enabled ? Colors.white : Colors.grey.shade50,
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: widget.enabled ? Colors.black87 : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}
