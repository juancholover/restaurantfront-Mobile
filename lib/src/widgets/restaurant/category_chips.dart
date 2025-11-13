import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../theme/app_theme.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              final isSelected = provider.selectedCategory == category;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    provider.filterByCategory(category);
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: AppTheme.primaryOrange,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
