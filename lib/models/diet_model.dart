class DietModel {
  final String name;
  final String iconPath; // Usaremos iconos nativos o rutas de assets
  final String level;
  final String duration;
  final String calorie;
  final bool viewIsSelected;

  DietModel({
    required this.name,
    required this.iconPath,
    required this.level,
    required this.duration,
    required this.calorie,
    required this.viewIsSelected,
  });

  // Datos de ejemplo para que la app no salga vacía
  static List<DietModel> getDiets() {
    return [
      DietModel(
        name: 'Desayuno',
        iconPath: 'assets/icons/breakfast.png', // Ojo: Si no tienes iconos, el código usará un Icono por defecto (ver paso 2)
        level: 'Fácil',
        duration: '30mins',
        calorie: '180kCal',
        viewIsSelected: true,
      ),
      DietModel(
        name: 'Almuerzo',
        iconPath: 'assets/icons/lunch.png',
        level: 'Medio',
        duration: '45mins',
        calorie: '450kCal',
        viewIsSelected: false,
      ),
    ];
  }
}