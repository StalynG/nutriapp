import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/entities/nutritional_result.dart';
import '../providers/ingredient_scan_provider.dart';
import '../providers/authentication_provider.dart';

/// Screen to display and manage nutritional analysis results
class NutritionalResultsScreen extends StatefulWidget {
  final String? resultIdToDisplay;

  const NutritionalResultsScreen({
    super.key,
    this.resultIdToDisplay,
  });

  @override
  State<NutritionalResultsScreen> createState() =>
      _NutritionalResultsScreenState();
}

class _NutritionalResultsScreenState extends State<NutritionalResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _summary = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSummary();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSummary() async {
    final authProvider = context.read<AuthenticationProvider>();
    if (authProvider.currentUser != null) {
      final scanProvider = context.read<IngredientScanProvider>();
      final summary =
          await scanProvider.getNutritionalSummary(authProvider.currentUser!.id);
      setState(() {
        _summary = summary;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Análisis Nutricional'),
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(icon: Icon(Icons.analytics), text: 'Resumen'),
              Tab(icon: Icon(Icons.history), text: 'Historial'),
              Tab(icon: Icon(Icons.bookmark), text: 'Guardados'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSummaryTab(),
            _buildHistoryTab(),
            _buildSavedTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    return _summary.isEmpty
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 24),
                _buildMacronutrientChart(),
                const SizedBox(height: 24),
                _buildStatisticsGrid(),
              ],
            ),
          );
  }

  Widget _buildSummaryCard() {
    final totalScans = _summary['totalScans'] as int? ?? 0;
    final totalCalories = _summary['totalCalories'] as double? ?? 0.0;
    final averageCalories = _summary['averageCalories'] as double? ?? 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryMetric(
                  label: 'Total de Escaneos',
                  value: totalScans.toString(),
                  icon: Icons.scanner,
                  color: Colors.blue,
                ),
                _buildSummaryMetric(
                  label: 'Calorías Totales',
                  value: '${totalCalories.toStringAsFixed(0)} kcal',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryMetric(
              label: 'Promedio de Calorías',
              value: '${averageCalories.toStringAsFixed(0)} kcal',
              icon: Icons.trending_up,
              color: Colors.green,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
  }) {
    final child = Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (fullWidth) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }

  Widget _buildMacronutrientChart() {
    final totalProtein = _summary['totalProtein'] as double? ?? 0.0;
    final totalFat = _summary['totalFat'] as double? ?? 0.0;
    final totalCarbs = _summary['totalCarbs'] as double? ?? 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Macronutrientes Totales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMacroRow(
              label: 'Proteínas',
              value: '${totalProtein.toStringAsFixed(1)}g',
              color: Colors.red,
              maxValue: (totalProtein + totalFat + totalCarbs) / 3 * 1.5,
            ),
            const SizedBox(height: 12),
            _buildMacroRow(
              label: 'Grasas',
              value: '${totalFat.toStringAsFixed(1)}g',
              color: Colors.orange,
              maxValue: (totalProtein + totalFat + totalCarbs) / 3 * 1.5,
            ),
            const SizedBox(height: 12),
            _buildMacroRow(
              label: 'Carbohidratos',
              value: '${totalCarbs.toStringAsFixed(1)}g',
              color: Colors.blue,
              maxValue: (totalProtein + totalFat + totalCarbs) / 3 * 1.5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow({
    required String label,
    required String value,
    required Color color,
    required double maxValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: double.parse(value.split('g')[0]) / maxValue,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsGrid() {
    final averageProtein = _summary['averageProtein'] as double? ?? 0.0;
    final averageFat = _summary['averageFat'] as double? ?? 0.0;
    final averageCarbs = _summary['averageCarbs'] as double? ?? 0.0;
    final averageFiber = _summary['averageFiber'] as double? ?? 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Promedio por Escaneo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildStatCard('Proteína', '${averageProtein.toStringAsFixed(1)}g', Colors.red),
                _buildStatCard('Grasa', '${averageFat.toStringAsFixed(1)}g', Colors.orange),
                _buildStatCard('Carbos', '${averageCarbs.toStringAsFixed(1)}g', Colors.blue),
                _buildStatCard('Fibra', '${averageFiber.toStringAsFixed(1)}g', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<IngredientScanProvider>(
      builder: (context, scanProvider, _) {
        final results = scanProvider.nutritionalResults;

        if (results.isEmpty) {
          return const Center(
            child: Text('No hay resultados de análisis aún'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            return _buildResultCard(results[index], context);
          },
        );
      },
    );
  }

  Widget _buildSavedTab() {
    return Consumer<IngredientScanProvider>(
      builder: (context, scanProvider, _) {
        final results = scanProvider.savedNutritionalResults;

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay resultados guardados',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            return _buildResultCard(results[index], context);
          },
        );
      },
    );
  }

  Widget _buildResultCard(NutritionalResult result, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showResultDetail(result),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Escaneo del ${result.calculatedAt.day}/${result.calculatedAt.month}/${result.calculatedAt.year}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.ingredients.join(', '),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      result.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      context.read<IngredientScanProvider>()
                          .toggleSaveNutritionalResult(result.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNutrientBadge(
                    label: 'Calorías',
                    value: result.formattedCalories,
                    color: Colors.orange,
                  ),
                  _buildNutrientBadge(
                    label: 'Proteína',
                    value: result.formattedProtein,
                    color: Colors.red,
                  ),
                  _buildNutrientBadge(
                    label: 'Grasa',
                    value: result.formattedFat,
                    color: Colors.yellow,
                  ),
                  _buildNutrientBadge(
                    label: 'Carbos',
                    value: result.formattedCarbs,
                    color: Colors.blue,
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
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showResultDetail(NutritionalResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detalles del Análisis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      result.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      context.read<IngredientScanProvider>()
                          .toggleSaveNutritionalResult(result.id);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailSection('Ingredientes Detectados', result),
              const SizedBox(height: 16),
              _buildDetailSection('Información Nutricional', result),
              const SizedBox(height: 16),
              _buildDetailSection('Desglose Calórico', result),
              const SizedBox(height: 16),
              _buildDetailSection('Porcentaje de Macronutrientes', result),
              if (result.notes != null && result.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailSection('Notas', result),
              ],
              const SizedBox(height: 20),
              if (!result.validateNutritionalData())
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Advertencia: Los datos nutricionales no pasaron la validación',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, NutritionalResult result) {
    late Widget content;

    switch (title) {
      case 'Ingredientes Detectados':
        content = Wrap(
          spacing: 8,
          children: result.ingredients
              .map(
                (ingredient) => Chip(
                  label: Text(ingredient),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  labelStyle: const TextStyle(fontSize: 12),
                ),
              )
              .toList(),
        );
        break;
      case 'Información Nutricional':
        content = Column(
          children: [
            _buildDetailRow('Calorías', result.formattedCalories),
            _buildDetailRow('Proteína', result.formattedProtein),
            _buildDetailRow('Grasa', result.formattedFat),
            _buildDetailRow('Carbohidratos', result.formattedCarbs),
            _buildDetailRow('Fibra', result.formattedFiber),
          ],
        );
        break;
      case 'Desglose Calórico':
        content = Column(
          children: [
            _buildDetailRow(
              'Calorías de Proteína',
              '${result.calorieBreakdown['protein']?.toStringAsFixed(1) ?? '0'} kcal',
            ),
            _buildDetailRow(
              'Calorías de Grasa',
              '${result.calorieBreakdown['fat']?.toStringAsFixed(1) ?? '0'} kcal',
            ),
            _buildDetailRow(
              'Calorías de Carbohidratos',
              '${result.calorieBreakdown['carbs']?.toStringAsFixed(1) ?? '0'} kcal',
            ),
          ],
        );
        break;
      case 'Porcentaje de Macronutrientes':
        content = Column(
          children: [
            _buildDetailRow(
              'Proteína',
              '${result.macroPercentages['protein']?.toStringAsFixed(1) ?? '0'}%',
            ),
            _buildDetailRow(
              'Grasa',
              '${result.macroPercentages['fat']?.toStringAsFixed(1) ?? '0'}%',
            ),
            _buildDetailRow(
              'Carbohidratos',
              '${result.macroPercentages['carbs']?.toStringAsFixed(1) ?? '0'}%',
            ),
          ],
        );
        break;
      case 'Notas':
        content = Text(
          result.notes ?? '',
          style: const TextStyle(fontSize: 12),
        );
        break;
      default:
        content = const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
