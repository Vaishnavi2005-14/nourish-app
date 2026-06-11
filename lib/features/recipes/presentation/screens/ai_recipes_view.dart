import 'package:flutter/material.dart';
import '../../data/models/recipe_model.dart';
import '../../data/services/open_food_service.dart';
import '../../data/services/ai_recipe_service.dart';
import '../widgets/recipe_card_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AIRecipesView extends StatefulWidget {
  const AIRecipesView({super.key});

  @override
  State<AIRecipesView> createState() => _AIRecipesViewState();
}

class _AIRecipesViewState extends State<AIRecipesView> {
  final _foodService = OpenFoodService();
  final _aiService = AIRecipeService();
  final _searchController = TextEditingController();

  List<String> _userIngredients = [];
  List<RecipeModel> _recipes = [];
  bool _loading = false;
  String? _selectedCookingStyle;
  String? _selectedMealType;

  final _cookingStyles = ['Vegan', 'Grilled', 'Baked', 'Fried', 'Steamed'];
  final _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Dessert'];

  void _addIngredient(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !_userIngredients.contains(trimmed)) {
      setState(() => _userIngredients.add(trimmed));
      _searchController.clear();
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() => _userIngredients.remove(ingredient));
  }

  Future<void> _generateRecipes() async {
    if (_userIngredients.isEmpty) return;
    setState(() => _loading = true);
    try {
      _aiService.setFilters(
        cookingStyle: _selectedCookingStyle,
        mealType: _selectedMealType,
      );
      final results = await _foodService.searchByIngredients(_userIngredients);
      final ranked = _aiService.generateRecipes(
        allRecipes: results,
        userIngredients: _userIngredients,
      );
      setState(() => _recipes = ranked);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Try again!')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _scanBarcode() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _BarcodeScannerScreen()),
    );
    if (barcode != null) {
      final product = await _foodService.getProductByBarcode(barcode);
      if (product != null && product.name != 'Unknown') {
        _addIngredient(product.name);
      }
    }
  }

  Future<void> _toggleSave(int index) async {
    setState(() {
      _recipes[index] = _recipes[index].copyWith(
        isSaved: !_recipes[index].isSaved,
      );
    });
  }

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
              _buildHeader(),
              const SizedBox(height: 20),
              _buildFilterRow(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildIngredientChips(),
              const SizedBox(height: 24),
              _buildGenerateButton(),
              const SizedBox(height: 24),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                ..._recipes.asMap().entries.map(
                  (entry) => RecipeCard(
                    recipe: entry.value,
                    onSave: () => _toggleSave(entry.key),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'AI Recipes',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            const Icon(Icons.favorite_border, size: 24),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.purple.shade100,
              child: const Icon(Icons.person, color: Colors.purple),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: _FilterDropdown(
            label: 'Cooking Style',
            items: _cookingStyles,
            selected: _selectedCookingStyle,
            onChanged: (val) => setState(() => _selectedCookingStyle = val),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FilterDropdown(
            label: 'Meal Type',
            items: _mealTypes,
            selected: _selectedMealType,
            onChanged: (val) => setState(() => _selectedMealType = val),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type the name of the ingredient or scan the bar code on the back of the packet',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onSubmitted: _addIngredient,
                decoration: InputDecoration(
                  hintText: 'Start typing',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _scanBarcode,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6FCD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.barcode_reader,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIngredientChips() {
    if (_userIngredients.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Ingredients:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _userIngredients.map((ing) {
                  return Chip(
                    label: Text(ing),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeIngredient(ing),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : _generateRecipes,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C6FCD),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Generate Recipe',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(label, style: const TextStyle(fontSize: 13)),
          value: selected,
          items:
              items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: const TextStyle(fontSize: 13)),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _BarcodeScannerScreen extends StatelessWidget {
  const _BarcodeScannerScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first.rawValue;
          if (barcode != null) {
            Navigator.pop(context, barcode);
          }
        },
      ),
    );
  }
}
