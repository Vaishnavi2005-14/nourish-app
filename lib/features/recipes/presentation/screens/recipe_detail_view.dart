import 'package:flutter/material.dart';
import '../../data/models/recipe_model.dart';

class RecipeDetailView extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildNutritionCard(),
              const SizedBox(height: 24),
              _buildIngredients(),
              const SizedBox(height: 24),
              _buildInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'AI Recipes',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const Icon(Icons.favorite_border, size: 24),
      ],
    );
  }

  Widget _buildNutritionCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                recipe.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.favorite_border, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '25 mins',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EEFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NutrientBox(
                label: 'Calories',
                value: '${recipe.calories.toInt()}',
                unit: 'kcal',
              ),
              _NutrientBox(
                label: 'Protein',
                value: '${recipe.protein.toInt()}',
                unit: 'g',
              ),
              _NutrientBox(
                label: 'Carbs',
                value: '${recipe.carbs.toInt()}',
                unit: 'g',
              ),
              _NutrientBox(
                label: 'Fat',
                value: '${recipe.fat.toInt()}',
                unit: 'g',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIngredients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredients',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (recipe.ingredients.isEmpty)
          Text(
            'No ingredients found',
            style: TextStyle(color: Colors.grey.shade400),
          )
        else
          ...recipe.ingredients
              .take(8)
              .map(
                (ing) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(ing, style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildInstructions() {
    final steps = [
      'Prepare all ingredients and keep them ready.',
      'Heat oil in a pan on medium flame.',
      'Add ingredients one by one and cook as needed.',
      'Season with salt and spices to taste.',
      'Serve hot and enjoy!',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instructions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...steps.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7C6FCD),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NutrientBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _NutrientBox({
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(unit, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }
}
