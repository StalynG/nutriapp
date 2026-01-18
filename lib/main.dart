import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'domain/repositories/ai_repository_impl.dart';
import 'infrastructure/repositories/nutrition_catalog_repository_impl.dart';
import 'infrastructure/services/openai_service.dart';
import 'providers/ai_provider.dart';
import 'providers/nutrition_catalog_provider.dart';
import 'src/screens/ai_chat_screen.dart';
import 'src/screens/nutrition_catalog_screen.dart';

Future<void> main() async {
  await dotenv.load();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
        Provider(
          create: (_) => NutritionCatalogRepositoryImpl(prefs),
        ),
        ChangeNotifierProxyProvider<NutritionCatalogRepositoryImpl, NutritionCatalogProvider>(
          create: (context) =>
              NutritionCatalogProvider(context.read<NutritionCatalogRepositoryImpl>()),
          update: (context, repository, previous) =>
              NutritionCatalogProvider(repository),
        ),
      ],
      child: MaterialApp(
        title: 'Nutrify - IA Nutricional',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Nutrify - Análisis Nutricional'),
        debugShowCheckedModeBanner: false,
      ),
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
    final titles = ['Inicio', 'Chat Nutricional', 'Catálogo'];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
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
      default:
        return _buildHome();
    }
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
            const SizedBox(height: 32),
            // Call to action buttons
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
