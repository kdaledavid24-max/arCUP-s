import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Horizontal Category Chip button matching the luxury dark pill design.
class CategoryButton extends StatelessWidget {
  final String categoryName;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.categoryName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.white : AppTheme.cardBorder,
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            categoryName.toUpperCase(),
            style: TextStyle(
              color: isSelected ? Colors.black : AppTheme.textWhite,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
