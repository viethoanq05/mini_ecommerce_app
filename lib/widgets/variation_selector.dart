import 'package:flutter/material.dart';

class VariationSelector extends StatelessWidget {
  final String title;
  final List<String> values;
  final String selectedValue;
  final ValueChanged<String> onSelected;
  final List<String> disabledValues;

  const VariationSelector({
    super.key,
    required this.title,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
    this.disabledValues = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((value) {
            final selected = value == selectedValue;
            final disabled = disabledValues.contains(value);
            return GestureDetector(
              onTap: disabled ? null : () => onSelected(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: disabled
                      ? Colors.grey.shade100
                      : selected
                      ? const Color(0xFFEE4D2D).withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: disabled
                        ? Colors.grey.shade300
                        : selected
                        ? const Color(0xFFEE4D2D)
                        : Colors.grey.shade400,
                    width: selected ? 1.4 : 1,
                  ),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color: disabled
                        ? Colors.grey.shade500
                        : selected
                        ? const Color(0xFFEE4D2D)
                        : Colors.black87,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
