import 'package:flutter/material.dart';
import '../../data/models/recipe_model.dart';
import '../screens/recipe_detail_view.dart';

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback? onSave;

  const RecipeCard({super.key, required this.recipe, this.onSave});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RecipeDetailView(recipe: recipe)),
          ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onSave,
                  child: Icon(
                    recipe.isSaved ? Icons.favorite : Icons.favorite_border,
                    color: recipe.isSaved ? Colors.purple : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '25 mins',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EEFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NutrientInfo(
                    label: 'Calories',
                    value: '${recipe.calories.toInt()}',
                    unit: 'kcal',
                  ),
                  _NutrientInfo(
                    label: 'Protein',
                    value: '${recipe.protein.toInt()}',
                    unit: 'g',
                  ),
                  _NutrientInfo(
                    label: 'Carbs',
                    value: '${recipe.carbs.toInt()}',
                    unit: 'g',
                  ),
                  _NutrientInfo(
                    label: 'Fat',
                    value: '${recipe.fat.toInt()}',
                    unit: 'g',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientInfo extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _NutrientInfo({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(unit, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }
}
