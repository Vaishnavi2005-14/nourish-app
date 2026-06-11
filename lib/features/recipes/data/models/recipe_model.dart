class RecipeModel {
  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final List<String> ingredients;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String instructions;
  final bool isSaved;

  RecipeModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.ingredients,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.instructions = '',
    this.isSaved = false,
  });

  factory RecipeModel.fromMealDb(Map<String, dynamic> json) {
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i']?.toString().trim() ?? '';
      final measure = json['strMeasure$i']?.toString().trim() ?? '';
      if (ingredient.isNotEmpty) {
        ingredients.add('$measure $ingredient'.trim());
      }
    }

    return RecipeModel(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal'] ?? 'Unknown',
      imageUrl: json['strMealThumb'] ?? '',
      category: json['strCategory'] ?? 'General',
      ingredients: ingredients,
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      instructions: json['strInstructions'] ?? '',
    );
  }

  RecipeModel copyWith({bool? isSaved}) {
    return RecipeModel(
      id: id,
      name: name,
      imageUrl: imageUrl,
      category: category,
      ingredients: ingredients,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      instructions: instructions,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
