// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/entities/nutritional_food.dart';
import '../providers/nutrition_catalog_provider.dart';

/// Pantalla principal del catálogo nutricional
class NutritionCatalogScreen extends StatefulWidget {
  const NutritionCatalogScreen({super.key});

  @override
  State<NutritionCatalogScreen> createState() => _NutritionCatalogScreenState();
}

class _NutritionCatalogScreenState extends State<NutritionCatalogScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.microtask(() {
      final provider = context.read<NutritionCatalogProvider>();
      provider.loadCategories();
      provider.loadAllFoods();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catálogo Nutricional'),
          centerTitle: true,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Alimentos'),
              Tab(text: 'Favoritos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFoodsTab(),
            _buildFavoritesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar alimentos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<NutritionCatalogProvider>().loadAllFoods();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {});
              if (value.isNotEmpty) {
                context.read<NutritionCatalogProvider>().searchFoods(value);
              }
            },
          ),
        ),
        Consumer<NutritionCatalogProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Expanded(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (provider.error.isNotEmpty) {
              return Expanded(
                child: Center(
                  child: Text(
                    provider.error,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // Mostrar categorías como chips
            if (provider.selectedCategory.isEmpty &&
                provider.searchQuery.isEmpty &&
                provider.categories.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.categories.length,
                    itemBuilder: (context, index) {
                      final category = provider.categories[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          onSelected: (selected) {
                            if (selected) {
                              context
                                  .read<NutritionCatalogProvider>()
                                  .loadFoodsByCategory(category);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            }

            if (provider.foods.isEmpty) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay alimentos disponibles',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.foods.length,
                itemBuilder: (context, index) {
                  final food = provider.foods[index];
                  return _buildFoodCard(context, food, provider);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer<NutritionCatalogProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Sin alimentos favoritos',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Agrega alimentos a favoritos para verlos aquí',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.favorites.length,
          itemBuilder: (context, index) {
            final food = provider.favorites[index];
            return _buildFoodCard(context, food, provider);
          },
        );
      },
    );
  }

  Widget _buildFoodCard(
    BuildContext context,
    NutritionalFood food,
    NutritionCatalogProvider provider,
  ) {
    return GestureDetector(
      onTap: () {
        _showFoodDetails(context, food, provider);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            food.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<NutritionCatalogProvider>(
                    builder: (context, _, __) {
                      final isFavorite = provider.isFavorite(food.id);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_outline,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          if (isFavorite) {
                            provider.removeFavorite(food.id);
                          } else {
                            provider.addFavorite(food.id);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (food.description != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    food.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              Row(
                children: [
                  _buildNutrientBadge(
                    label: 'Cal',
                    value: food.caloriesPer100g.toStringAsFixed(0),
                    unit: 'kcal',
                  ),
                  const SizedBox(width: 8),
                  _buildNutrientBadge(
                    label: 'Pro',
                    value: food.proteinsPer100g.toStringAsFixed(1),
                    unit: 'g',
                  ),
                  const SizedBox(width: 8),
                  _buildNutrientBadge(
                    label: 'Gra',
                    value: food.fatsPer100g.toStringAsFixed(1),
                    unit: 'g',
                  ),
                  const SizedBox(width: 8),
                  _buildNutrientBadge(
                    label: 'Carb',
                    value: food.carbsPer100g.toStringAsFixed(1),
                    unit: 'g',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientBadge({
    required String label,
    required String value,
    required String unit,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFoodDetails(
    BuildContext context,
    NutritionalFood food,
    NutritionCatalogProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              food.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              food.category,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Consumer<NutritionCatalogProvider>(
                          builder: (context, _, __) {
                            final isFavorite = provider.isFavorite(food.id);
                            return IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                color: isFavorite ? Colors.red : Colors.grey,
                                size: 28,
                              ),
                              onPressed: () {
                                if (isFavorite) {
                                  provider.removeFavorite(food.id);
                                } else {
                                  provider.addFavorite(food.id);
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    if (food.description != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        food.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Valores Nutricionales (por 100g)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Calorías',
                      '${food.caloriesPer100g.toStringAsFixed(1)} kcal',
                    ),
                    _buildDetailRow(
                      'Proteínas',
                      '${food.proteinsPer100g.toStringAsFixed(1)}g',
                    ),
                    _buildDetailRow(
                      'Grasas',
                      '${food.fatsPer100g.toStringAsFixed(1)}g',
                    ),
                    _buildDetailRow(
                      'Carbohidratos',
                      '${food.carbsPer100g.toStringAsFixed(1)}g',
                    ),
                    _buildDetailRow(
                      'Fibra',
                      '${food.fiberPer100g.toStringAsFixed(1)}g',
                    ),
                  ],
                ),
              );
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
