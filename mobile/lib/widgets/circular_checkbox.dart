import 'package:flutter/material.dart';

class CircularCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final double size;

  const CircularCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = const Color(0xFF34C759), // iOS System Green
    this.size = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    // Área de toque ampliada (44x44) conforme Apple Human Interface Guidelines
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(size),
      splashColor: activeColor.withOpacity(0.15),
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value ? activeColor : Colors.transparent,
            border: Border.all(
              color: value ? activeColor : const Color(0xFFC7C7CC),
              width: 2.0,
            ),
          ),
          child: value
              ? const Icon(
                  Icons.check,
                  size: 18.0,
                  color: Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}
