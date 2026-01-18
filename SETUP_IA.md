# Nutrify - Asistente Nutricional con IA

Una aplicación Flutter que integra inteligencia artificial con OpenAI para proporcionar análisis nutricional avanzado y recomendaciones personalizadas.

## 🚀 Características

- **Análisis de Imágenes**: Toma fotos de tus comidas y obtén análisis nutricional automático con estimación de calorías y macronutrientes
- **Chat Inteligente**: Conversa con una IA especializada en nutrición para obtener consejos y respuestas a tus preguntas
- **Planes de Comidas**: Genera planes de comidas personalizados según tus objetivos calóricos y restricciones dietéticas
- **Recomendaciones Nutricionales**: Recibe recomendaciones basadas en tus análisis de comida

## 📋 Requisitos

- Flutter 3.10.3 o superior
- Dart 3.10.3 o superior
- Cuenta de OpenAI con una API Key válida

## 🔧 Configuración

### 1. Configurar la API Key de OpenAI

1. Obtén una clave API en [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Copia el archivo `.env.example` a `.env`:
   ```bash
   cp .env.example .env
   ```
3. Reemplaza `tu_clave_api_aqui` con tu clave API real:
   ```env
   OPENAI_API_KEY=sk-...
   ```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Ejecutar la aplicación

```bash
flutter run
```

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada y configuración
├── providers/
│   └── ai_provider.dart              # ChangeNotifier para gestionar estado de IA
├── domain/
│   ├── entities/
│   │   └── food_analysis.dart        # Entidad de análisis de comida
│   └── repositories/
│       ├── ai_repository.dart        # Interfaz del repositorio
│       └── ai_repository_impl.dart   # Implementación del repositorio
├── infrastructure/
│   └── services/
│       └── openai_service.dart       # Servicio de integración con OpenAI
└── src/
    └── screens/
        └── ai_chat_screen.dart       # Pantalla de chat con IA
```

## 🏗️ Arquitectura

La aplicación sigue principios de **Clean Architecture**:

- **Presentation Layer**: Widgets y Screens (con Provider para manejo de estado)
- **Domain Layer**: Entidades y Repositorios (contratos)
- **Infrastructure Layer**: Servicios y Implementaciones (OpenAI API)

## 🔌 Componentes Principales

### OpenAIService
Servicio de bajo nivel que maneja todas las comunicaciones con la API de OpenAI:
- `analyzeImage()` - Analiza imágenes de comida
- `sendMessage()` - Envía mensajes de chat
- `getNutritionRecommendations()` - Obtiene recomendaciones
- `generateMealPlan()` - Genera planes de comidas

### AiRepository
Interfaz que define las operaciones disponibles de IA, implementada por `AiRepositoryImpl`

### AiProvider
ChangeNotifier que gestiona el estado de las operaciones:
- Manejo de carga y errores
- Almacenamiento de resultados
- Historial de chat
- Análisis de comida actual

## 💬 Ejemplo de Uso - Chat

```dart
// Enviar un mensaje
context.read<AiProvider>().sendChatMessage('¿Cuántas calorías tiene una manzana?');

// Escuchar cambios
Consumer<AiProvider>(
  builder: (context, aiProvider, _) {
    if (aiProvider.isLoading) {
      return CircularProgressIndicator();
    }
    return Text(aiProvider.currentResponse);
  },
)
```

## 🖼️ Ejemplo de Uso - Análisis de Imagen

```dart
// Analizar una imagen
final imageFile = File('/path/to/food/image.jpg');
context.read<AiProvider>().analyzeFood(imageFile);

// Acceder al resultado
final analysis = context.read<AiProvider>().currentFoodAnalysis;
print('Calorías: ${analysis?.caloriasTotales}');
print('Proteínas: ${analysis?.proteinasTotalesG}g');
```

## 🍽️ Ejemplo de Uso - Plan de Comidas

```dart
context.read<AiProvider>().generateMealPlan(
  days: 7,
  dailyCalories: 2000,
  dietaryRestrictions: ['vegetariano', 'sin gluten'],
);
```

## 🛡️ Seguridad

- La API Key nunca debe ser commiteada. El `.env` está en `.gitignore`
- Se recomienda usar variables de entorno en producción
- Los tokens de sesión se gestionan automáticamente

## 📦 Dependencias

- `flutter` - Framework de UI
- `provider: ^6.0.0` - Manejo de estado
- `http: ^0.13.6` - Comunicación HTTP
- `flutter_dotenv: ^5.0.2` - Gestión de variables de entorno

## 🐛 Solución de Problemas

### "OPENAI_API_KEY no configurada"
- Asegúrate de que el archivo `.env` existe en la raíz del proyecto
- Verifica que contiene la línea `OPENAI_API_KEY=tu_clave_aqui`
- Ejecuta `flutter clean` y `flutter pub get` nuevamente

### Error de conexión con OpenAI
- Verifica que tu API Key es válida
- Comprueba tu conexión a Internet
- Revisa que tienes créditos disponibles en tu cuenta de OpenAI

### Timeout en las solicitudes
- Los análisis de imagen pueden tomar más tiempo
- Si persiste, intenta con una imagen de menor tamaño

## 📝 Notas de Desarrollo

- El modelo por defecto es `gpt-4o` (puedes cambiar en `OpenAIService`)
- La temperatura es 0.7 para respuestas balanceadas
- El token máximo es 2000 para controlar costos

## 🎯 Próximas Mejoras

- [ ] Almacenamiento persistente de análisis
- [ ] Gráficos de seguimiento nutricional
- [ ] Integración con bases de datos de alimentos
- [ ] Notificaciones de recordatorio de comidas
- [ ] Soporte para múltiples idiomas

## 📄 Licencia

Este proyecto está bajo licencia MIT.

## 👥 Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue o pull request.

---

**Desarrollado con ❤️ para tu salud nutricional**
