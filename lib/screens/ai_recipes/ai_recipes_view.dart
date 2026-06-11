import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'ai_recipes_model.dart';
import '../../features/recipes/presentation/widgets/recipe_card_widget.dart';

class AiRecipesView extends StatelessWidget {
  const AiRecipesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AiRecipesViewModel(),
      child: Consumer<AiRecipesViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(),
                    const SizedBox(height: 20),
                    _FilterRow(model: model),
                    const SizedBox(height: 16),
                    _SearchBar(model: model),
                    const SizedBox(height: 16),
                    _IngredientChips(model: model),
                    const SizedBox(height: 24),
                    _GenerateButton(model: model),
                    const SizedBox(height: 24),
                    if (model.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ...model.recipes.asMap().entries.map(
                        (entry) => RecipeCard(
                          recipe: entry.value,
                          onSave: () => model.toggleSave(entry.key),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'AI Recipes',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => context.go('/saved_recipes'),
              child: const Icon(Icons.favorite_border, size: 24),
            ),
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
}

class _FilterRow extends StatelessWidget {
  final AiRecipesViewModel model;
  const _FilterRow({required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create delicious recipes from ingredients!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'Add ingredients that you have, and our AI will generate a seasonal Indian recipe!',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _FilterDropdown(
                label: 'Cooking Style',
                items: model.cookingStyles,
                selected: model.selectedCookingStyle,
                onChanged: model.setCookingStyle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterDropdown(
                label: 'Meal Type',
                items: model.mealTypes,
                selected: model.selectedMealType,
                onChanged: model.setMealType,
              ),
            ),
          ],
        ),
      ],
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

class _SearchBar extends StatefulWidget {
  final AiRecipesViewModel model;
  const _SearchBar({required this.model});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                controller: _controller,
                onSubmitted: (val) {
                  widget.model.addIngredient(val);
                  _controller.clear();
                },
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
              onTap: () async {
                final barcode = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const _BarcodeScannerScreen(),
                  ),
                );
                if (barcode != null && context.mounted) {
                  widget.model.addIngredientByBarcode(barcode);
                }
              },
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
}

class _IngredientChips extends StatelessWidget {
  final AiRecipesViewModel model;
  const _IngredientChips({required this.model});

  @override
  Widget build(BuildContext context) {
    if (model.ingredients.isEmpty) return const SizedBox.shrink();
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
                model.ingredients.map((ing) {
                  return Chip(
                    label: Text(ing),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => model.removeIngredient(ing),
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
}

class _GenerateButton extends StatelessWidget {
  final AiRecipesViewModel model;
  const _GenerateButton({required this.model});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: model.isLoading ? null : model.generateRecipes,
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

class _BarcodeScannerScreen extends StatefulWidget {
  const _BarcodeScannerScreen();

  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (_scanned) return;
          final barcode = capture.barcodes.first.rawValue;
          if (barcode != null) {
            _scanned = true;
            _controller.stop();
            Navigator.pop(context, barcode);
          }
        },
      ),
    );
  }
}
