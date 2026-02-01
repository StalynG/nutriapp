import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'domain/repositories/ai_repository_impl.dart';
import 'infrastructure/repositories/nutrition_catalog_repository_impl.dart';
import 'infrastructure/services/authentication_service.dart';
import 'infrastructure/services/ingredient_scan_service.dart';
import 'infrastructure/services/openai_service.dart';
import 'providers/ai_provider.dart';
import 'providers/authentication_provider.dart';
import 'providers/ingredient_scan_provider.dart';
import 'providers/nutrition_catalog_provider.dart';
import 'src/screens/ai_chat_screen.dart';
import 'src/screens/authentication_screen.dart';
import 'src/screens/ingredient_scan_screen.dart';
import 'src/screens/nutrition_catalog_screen.dart';

Future<void> main() async {
  await dotenv.load();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  static const String apiBaseUrl = 'https://api.nutriapp.com/v1';

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AI Services
        Provider(
          create: (_) => OpenAIService(),
        ),
        ProxyProvider<OpenAIService, AiRepositoryImpl>(
          create: (context) =>
              AiRepositoryImpl(context.read<OpenAIService>()),
          update: (context, openaiService, previous) =>
              AiRepositoryImpl(openaiService),
        ),
        ChangeNotifierProxyProvider<AiRepositoryImpl, AiProvider>(
          create: (context) =>
              AiProvider(context.read<AiRepositoryImpl>()),
          update: (context, aiRepository, previous) =>
              AiProvider(aiRepository),
        ),
        // Nutrition Catalog
        Provider(
          create: (_) => NutritionCatalogRepositoryImpl(prefs),
        ),
        ChangeNotifierProxyProvider<NutritionCatalogRepositoryImpl, NutritionCatalogProvider>(
          create: (context) =>
              NutritionCatalogProvider(context.read<NutritionCatalogRepositoryImpl>()),
          update: (context, repository, previous) =>
              NutritionCatalogProvider(repository),
        ),
        // Authentication
        Provider(
          create: (_) => AuthenticationService(
            baseUrl: apiBaseUrl,
            prefs: prefs,
          ),
        ),
        ChangeNotifierProxyProvider<AuthenticationService, AuthenticationProvider>(
          create: (context) =>
              AuthenticationProvider(context.read<AuthenticationService>()),
          update: (context, authService, previous) =>
              AuthenticationProvider(authService),
        ),
        // Ingredient Scan
        ProxyProvider<AuthenticationService, IngredientScanService>(
          create: (context) => IngredientScanService(
            baseUrl: apiBaseUrl,
            getAuthToken: () {
              final authProvider = context.read<AuthenticationProvider>();
              return ''; // Token will be handled by the service
            },
          ),
          update: (context, authService, previous) => IngredientScanService(
            baseUrl: apiBaseUrl,
            getAuthToken: () {
              final authProvider = context.read<AuthenticationProvider>();
              return ''; // Token will be handled by the service
            },
          ),
        ),
        ChangeNotifierProxyProvider<IngredientScanService, IngredientScanProvider>(
          create: (context) =>
              IngredientScanProvider(context.read<IngredientScanService>()),
          update: (context, scanService, previous) =>
              IngredientScanProvider(scanService),
        ),
      ],
      child: MaterialApp(
        title: 'Nutrify - IA Nutricional',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Widget que decide qué pantalla mostrar según el estado de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          return const MyHomePage(title: 'Nutrify - Análisis Nutricional');
        }

        return const AuthenticationScreen();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final titles = ['Inicio', 'Chat IA', 'Catálogo', 'Escaneo', 'Perfil'];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: _selectedIndex == 4
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthenticationProvider>().logout();
                  },
                ),
              ]
            : null,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat IA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.scanner),
            label: 'Escaneo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHome();
      case 1:
        return const AiChatScreen();
      case 2:
        return const NutritionCatalogScreen();
      case 3:
        return const IngredientScanScreen();
      case 4:
        return _buildProfileTab();
      default:
        return _buildHome();
    }
  }

  Widget _buildProfileTab() {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;

        if (user == null) {
          return const Center(
            child: Text('No hay usuario autenticado'),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      user.name.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Información de usuario
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Información Personal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildUserInfoRow('Nombre', user.name),
                        _buildUserInfoRow('Email', user.email),
                        _buildUserInfoRow(
                          'Miembro desde',
                          '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.verified, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              user.isEmailVerified
                                  ? 'Email verificado'
                                  : 'Email no verificado',
                              style: TextStyle(
                                color: user.isEmailVerified
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AuthenticationProvider>().logout();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Bienvenido a Nutrify!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu asistente de inteligencia artificial para nutrición',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Features
            const Text(
              'Características principales',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              icon: Icons.camera_alt,
              title: 'Análisis de Imágenes',
              description:
                  'Toma fotos de tus comidas y obtén análisis nutricional automático',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.chat,
              title: 'Chat Inteligente',
              description:
                  'Conversa con nuestra IA para obtener consejos y recomendaciones',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.restaurant_menu,
              title: 'Planes de Comidas',
              description:
                  'Genera planes de comidas personalizados según tus necesidades',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.recommend,
              title: 'Recomendaciones',
              description:
                  'Recibe consejos nutricionales basados en tus análisis',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.restaurant,
              title: 'Catálogo Nutricional',
              description:
                  'Explora nuestra base de datos de alimentos con información nutricional completa',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.scanner,
              title: 'Escaneo de Ingredientes',
              description:
                  'Escanea imágenes de alimentos para detectar ingredientes automáticamente',
            ),
            const SizedBox(height: 32),
            // Call to action buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text('Chat IA'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 2;
                          });
                        },
                        icon: const Icon(Icons.restaurant),
                        label: const Text('Catálogo'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                  },
                  icon: const Icon(Icons.scanner),
                  label: const Text('Escanear Ingredientes'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Asegúrate de configurar tu API Key de OpenAI en el archivo .env',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.deepPurple),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
