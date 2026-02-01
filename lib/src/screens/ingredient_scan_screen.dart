// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/authentication_provider.dart';
import '../providers/ingredient_scan_provider.dart';

/// Pantalla para escanear ingredientes
class IngredientScanScreen extends StatefulWidget {
  const IngredientScanScreen({super.key});

  @override
  State<IngredientScanScreen> createState() => _IngredientScanScreenState();
}

class _IngredientScanScreenState extends State<IngredientScanScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _descriptionController;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _descriptionController = TextEditingController();

    Future.microtask(() {
      final authProvider = context.read<AuthenticationProvider>();
      final scanProvider = context.read<IngredientScanProvider>();

      if (authProvider.currentUser != null) {
        scanProvider.loadScanHistory(authProvider.currentUser!.id);
        scanProvider.loadSavedScans(authProvider.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Escanear Ingredientes'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.deepPurple,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Escanear'),
              Tab(text: 'Historial'),
              Tab(text: 'Guardados'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildScanTab(),
            _buildHistoryTab(),
            _buildSavedTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildScanTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedImage != null)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.grey[100],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Selecciona una imagen',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImageFromCamera(),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImageFromGallery(),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Ej: Desayuno del día',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Consumer<IngredientScanProvider>(
              builder: (context, scanProvider, _) {
                return ElevatedButton.icon(
                  onPressed:
                      _selectedImage != null && !scanProvider.isScanning
                          ? () => _handleScan(context)
                          : null,
                  icon: scanProvider.isScanning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.search),
                  label: Text(
                    scanProvider.isScanning ? 'Escaneando...' : 'Escanear',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<IngredientScanProvider>(
              builder: (context, scanProvider, _) {
                if (scanProvider.error.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            scanProvider.error,
                            style: TextStyle(color: Colors.red[900]),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
            Consumer<IngredientScanProvider>(
              builder: (context, scanProvider, _) {
                if (scanProvider.lastScan != null &&
                    scanProvider.state == ScanState.success) {
                  return _buildScanResultCard(scanProvider.lastScan!);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<IngredientScanProvider>(
      builder: (context, scanProvider, _) {
        if (scanProvider.scanHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Sin historial de escaneos',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: scanProvider.scanHistory.length,
          itemBuilder: (context, index) {
            final scan = scanProvider.scanHistory[index];
            return _buildScanCard(context, scan, scanProvider);
          },
        );
      },
    );
  }

  Widget _buildSavedTab() {
    return Consumer<IngredientScanProvider>(
      builder: (context, scanProvider, _) {
        if (scanProvider.savedScans.isEmpty) {
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
                Text(
                  'Sin escaneos guardados',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: scanProvider.savedScans.length,
          itemBuilder: (context, index) {
            final scan = scanProvider.savedScans[index];
            return _buildScanCard(context, scan, scanProvider);
          },
        );
      },
    );
  }

  Widget _buildScanCard(BuildContext context, dynamic scan, IngredientScanProvider scanProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
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
                        'Escaneo del ${scan.scannedAt.day}/${scan.scannedAt.month}/${scan.scannedAt.year}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Confianza: ${(scan.confidenceScore * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    scanProvider.deleteScan(scan.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: scan.ingredients
                  .map<Widget>((ingredient) => Chip(
                        label: Text(ingredient),
                        backgroundColor: Colors.deepPurple.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          color: Colors.deepPurple,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanResultCard(dynamic scan) {
    return Card(
      elevation: 4,
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingredientes Detectados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: scan.ingredients
                  .map<Widget>((ingredient) => Chip(
                        label: Text(ingredient),
                        backgroundColor: Colors.green.withOpacity(0.2),
                        labelStyle: const TextStyle(
                          color: Colors.green,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _handleScan(BuildContext context) {
    final authProvider = context.read<AuthenticationProvider>();
    final scanProvider = context.read<IngredientScanProvider>();

    if (authProvider.currentUser == null || _selectedImage == null) {
      return;
    }

    scanProvider.scanIngredients(
      imageFile: _selectedImage!,
      userId: authProvider.currentUser!.id,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
    );
  }
}

enum ScanState { idle, scanning, success, error }
