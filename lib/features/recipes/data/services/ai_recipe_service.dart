import '../models/recipe_model.dart';

class AIRecipeService {
  String? _cookingStyle;
  String? _mealType;

  void setFilters({String? cookingStyle, String? mealType}) {
    _cookingStyle = cookingStyle;
    _mealType = mealType;
  }

  List<RecipeModel> generateRecipes({
    required List<RecipeModel> allRecipes,
    required List<String> userIngredients,
  }) {
    if (userIngredients.isEmpty) return allRecipes;

    List<MapEntry<RecipeModel, int>> scored =
        allRecipes
            .map((recipe) {
              int score = 0;

              for (var ingredient in userIngredients) {
                final ing = ingredient.toLowerCase();
                if (recipe.name.toLowerCase().contains(ing)) score += 3;
                if (recipe.ingredients.any(
                  (i) => i.toLowerCase().contains(ing),
                ))
                  score += 2;
                if (recipe.category.toLowerCase().contains(ing)) score += 1;
              }

              if (_cookingStyle != null &&
                  recipe.category.toLowerCase().contains(
                    _cookingStyle!.toLowerCase(),
                  )) {
                score += 2;
              }

              if (_mealType != null &&
                  recipe.category.toLowerCase().contains(
                    _mealType!.toLowerCase(),
                  )) {
                score += 2;
              }

              return MapEntry(recipe, score);
            })
            .where((entry) => entry.value > 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return scored.map((e) => e.key).toList();
  }
}
