class Food {
  String id;
  String name;
  String description;
  String category;
  String? imagePath;

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.imagePath,
  });

  // AÑADIDO: Para convertir la respuesta de la API/Historial a objeto Food
  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      imagePath: json['imagePath'],
    );
  }
}

// Tus datos de prueba se mantienen igual
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