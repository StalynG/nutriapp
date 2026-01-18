# Catálogo Nutricional - Documentación

## 📋 Descripción General

El catálogo nutricional es una característica que proporciona una base de datos mínima pero completa de alimentos comunes con información nutricional detallada. Los usuarios pueden:

- Explorar alimentos por categoría
- Buscar alimentos específicos
- Ver información nutricional completa
- Marcar favoritos para acceso rápido
- Consultar valores nutricionales por 100g

## 🏗️ Arquitectura

### Estructura de Capas

```
Domain Layer
├── Entities
│   └── nutritional_food.dart (NutritionalFood, NutritionalValues)
└── Repositories
    └── nutrition_catalog_repository.dart (Interface)

Infrastructure Layer
└── Repositories
    └── nutrition_catalog_repository_impl.dart (Implementation)

Presentation Layer
├── Providers
│   └── nutrition_catalog_provider.dart (State Management)
└── Screens
    └── nutrition_catalog_screen.dart (UI)
```

## 📦 Componentes Principales

### NutritionalFood Entity

```dart
class NutritionalFood {
  final String id;
  final String name;
  final String category;
  final double caloriesPer100g;
  final double proteinsPer100g;
  final double fatsPer100g;
  final double carbsPer100g;
  final double fiberPer100g;
  final String? imageUrl;
  final String? description;
  
  // Calcula valores nutricionales para una porción específica
  NutritionalValues calculateForPortion(double grams) { ... }
}
```

### NutritionCatalogRepository Interface

Define las operaciones disponibles:
- `getAllFoods()` - Obtiene todos los alimentos
- `getFoodsByCategory(String)` - Filtra por categoría
- `searchFoodsByName(String)` - Búsqueda por nombre
- `getFoodById(String)` - Obtiene un alimento específico
- `getCategories()` - Lista todas las categorías
- `addFavorite(String)` - Marca como favorito
- `removeFavorite(String)` - Desmarcar favorito
- `getFavorites()` - Obtiene favoritos guardados

### NutritionCatalogRepositoryImpl

Implementación con:
- **Base de datos mínima en memoria**: 17 alimentos predefinidos
- **Almacenamiento persistente**: Usa SharedPreferences para favoritos
- **Categorías**: Frutas, Verduras, Proteínas, Granos, Lácteos, Frutos Secos

### NutritionCatalogProvider

ChangeNotifier que gestiona:
- Estado de carga (`CatalogLoadingState`)
- Lista de alimentos actuales
- Alimentos favoritos
- Búsquedas activas
- Categoría seleccionada
- Manejo de errores

### NutritionCatalogScreen

Interfaz con:
- **Pestaña de Alimentos**: 
  - Buscador en tiempo real
  - Chips de categorías
  - Vista de tarjetas con valores nutricionales resumidos
  
- **Pestaña de Favoritos**:
  - Lista de alimentos guardados como favoritos
  - Acceso rápido a detalles

- **Modal de Detalles**:
  - Información completa del alimento
  - Toggle de favorito
  - Botón para agregar a recetas (futura extensión)

## 📊 Catálogo Mínimo Incluido

### Frutas (3 alimentos)
- Manzana (52 kcal)
- Plátano (89 kcal)
- Naranja (47 kcal)

### Verduras (3 alimentos)
- Brócoli (34 kcal)
- Zanahoria (41 kcal)
- Espinaca (23 kcal)

### Proteínas (3 alimentos)
- Pechuga de Pollo (165 kcal)
- Huevo (155 kcal)
- Salmón (208 kcal)

### Granos (3 alimentos)
- Arroz Integral (112 kcal)
- Avena (389 kcal)
- Pan Integral (265 kcal)

### Lácteos (3 alimentos)
- Yogur Griego (59 kcal)
- Leche Desnatada (35 kcal)
- Queso Fresco (98 kcal)

### Frutos Secos (2 alimentos)
- Almendras (579 kcal)
- Nueces (654 kcal)

## 🔄 Flujos de Uso

### Explorar Alimentos
```dart
// 1. Cargar categorías
provider.loadCategories();

// 2. Seleccionar categoría
provider.loadFoodsByCategory('Frutas');

// 3. Ver resultado en lista
```

### Buscar Alimentos
```dart
// 1. Usuario escribe en buscador
provider.searchFoods('manzana');

// 2. Se muestran resultados filtrados
```

### Marcar Favorito
```dart
// 1. Usuario toca el icono de corazón
provider.addFavorite(foodId);

// 2. Se guarda en SharedPreferences
// 3. Se recarga lista de favoritos
```

### Ver Detalles
```dart
// 1. Usuario toca una tarjeta de alimento
// 2. Se abre modal con información completa
// 3. Se muestra:
//    - Nombre y descripción
//    - Calorías, proteínas, grasas, carbohidratos, fibra
//    - Botón para marcar/desmarcar favorito
```

## 💾 Persistencia

Los favoritos se almacenan en `SharedPreferences` con la clave `nutrition_favorites`.

**Ejemplo de almacenamiento:**
```json
{
  "nutrition_favorites": ["food_001", "food_004", "food_007"]
}
```

## 🚀 Extensiones Futuras

1. **Sincronización con API**
   - Cargar alimentos desde backend
   - Actualizar catálogo dinámicamente

2. **Historial de Búsquedas**
   - Guardar búsquedas frecuentes
   - Sugerencias automáticas

3. **Porciones Personalizadas**
   - Calcular macros para porciones específicas
   - Unidades de medida (g, oz, tazas)

4. **Inteligencia Artificial**
   - Recomendaciones basadas en favoritos
   - Sugerencias de alimentos similares

5. **Exportación**
   - Guardar lista de compras
   - Exportar como PDF

6. **Imágenes**
   - Agregar fotos a cada alimento
   - Galería visual de alimentos

## 📝 Códigos de Error

| Error | Causa | Solución |
|-------|-------|----------|
| No hay alimentos | Catálogo vacío | Verificar datos iniciales |
| No hay favoritos | Lista vacía | Agregar favoritos |
| Fallo al guardar | SharedPreferences falla | Reiniciar app |

## 🔒 Seguridad y Performance

- ✅ Datos en memoria para acceso rápido
- ✅ Favoritos cifrados por SharedPreferences
- ✅ Sin llamadas de API externas (mínimo)
- ✅ Búsqueda O(n) optimizada con índices

## 🎨 Interfaz de Usuario

- **Material Design 3** compatible
- **Tema cohesivo** con el resto de la app (morado)
- **Responsivo** a diferentes tamaños de pantalla
- **Accesibilidad** con etiquetas y contraste adecuado

---

**Versión**: 1.0  
**Última actualización**: Enero 2026
