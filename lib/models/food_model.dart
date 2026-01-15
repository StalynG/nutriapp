class Food {
  String id;
  String name;
  String description;
  String category;
  String? imagePath; // Puede ser una URL o una ruta local

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.imagePath,
  });
}

// Datos de prueba (Simulando una base de datos)
List<Food> dummyFoods = [
  Food(
    id: '1',
    name: 'Hamburguesa',
    description: 'Deliciosa hamburguesa con queso y papas.',
    category: 'Carnes',
    imagePath: 'https://cdn-icons-png.flaticon.com/512/3075/3075977.png',
  ),
  Food(
    id: '2',
    name: 'Ensalada César',
    description: 'Lechuga fresca con aderezo y crutones.',
    category: 'Vegetales',
    imagePath: 'https://cdn-icons-png.flaticon.com/512/2515/2515183.png',
  ),
];