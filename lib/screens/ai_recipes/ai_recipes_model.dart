import 'package:flutter/material.dart';
import '../../features/recipes/data/models/recipe_model.dart';
import '../../features/recipes/data/services/open_food_service.dart';
import '../../features/recipes/data/services/ai_recipe_service.dart';

class AiRecipesViewModel extends ChangeNotifier {
  final _foodService = OpenFoodService();
  final _aiService = AIRecipeService();

  List<String> ingredients = [];
  List<RecipeModel> recipes = [];
  bool isLoading = false;
  String? selectedCookingStyle;
  String? selectedMealType;

  final cookingStyles = ['Vegan', 'Grilled', 'Baked', 'Fried', 'Steamed'];
  final mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Dessert'];

  void addIngredient(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !ingredients.contains(trimmed)) {
      ingredients.add(trimmed);
      notifyListeners();
    }
  }

  void removeIngredient(String value) {
    ingredients.remove(value);
    notifyListeners();
  }

  void setCookingStyle(String? value) {
    selectedCookingStyle = value;
    notifyListeners();
  }

  void setMealType(String? value) {
    selectedMealType = value;
    notifyListeners();
  }

  void toggleSave(int index) {
    recipes[index] = recipes[index].copyWith(isSaved: !recipes[index].isSaved);
    notifyListeners();
  }

  Future<void> generateRecipes() async {
    if (ingredients.isEmpty) return;
    isLoading = true;
    notifyListeners();

    try {
      _aiService.setFilters(
        cookingStyle: selectedCookingStyle,
        mealType: selectedMealType,
      );
      final results = await _foodService.searchByIngredients(ingredients);
      recipes = _aiService.generateRecipes(
        allRecipes: results,
        userIngredients: ingredients,
      );
    } catch (e) {
      recipes = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void addIngredientByBarcode(String barcode) {
    addIngredient(barcode);
  }

  List<RecipeModel> get savedRecipes =>
      recipes.where((r) => r.isSaved).toList();
}
