import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

class OpenFoodService {
  static const _mealBase = 'https://www.themealdb.com/api/json/v1/1';
  static const _foodBase = 'https://world.openfoodfacts.org';

  Future<List<RecipeModel>> searchByIngredients(
    List<String> ingredients,
  ) async {
    List<RecipeModel> allResults = [];

    for (final ingredient in ingredients.take(2)) {
      final url = Uri.parse('$_mealBase/filter.php?i=$ingredient');
      print('Calling: $url');

      try {
        final response = await http
            .get(url)
            .timeout(const Duration(seconds: 10));
        print('Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final meals = data['meals'] as List? ?? [];
          print('Meals found: ${meals.length}');

          for (final meal in meals.take(10)) {
            final detail = await _getMealDetail(meal['idMeal']);
            if (detail != null) allResults.add(detail);
          }
        }
      } catch (e) {
        print('ERROR: $e');
      }
    }

    return allResults;
  }

  Future<RecipeModel?> _getMealDetail(String id) async {
    final url = Uri.parse('$_mealBase/lookup.php?i=$id');
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meals = data['meals'] as List?;
      if (meals != null && meals.isNotEmpty) {
        return RecipeModel.fromMealDb(meals[0]);
      }
    }
    return null;
  }

  Future<RecipeModel?> getProductByBarcode(String barcode) async {
    try {
      final url = Uri.parse('$_foodBase/api/v0/product/$barcode.json');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1) {
          final product = data['product'];
          final name = product['product_name']?.toString() ?? '';
          if (name.isNotEmpty) {
            return RecipeModel(
              id: barcode,
              name: name,
              imageUrl: product['image_url'] ?? '',
              category: '',
              ingredients: [],
              calories: 0,
              protein: 0,
              carbs: 0,
              fat: 0,
            );
          }
        }
      }
    } catch (e) {
      print('Barcode error: $e');
    }
    return null;
  }
}
