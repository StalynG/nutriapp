import 'package:flutter/material.dart';
import 'widgets/resumen_nutricional_card.dart';
import 'widgets/macro_card.dart';
import 'widgets/calorias_card.dart';

class ResultadosPage extends StatelessWidget {
  const ResultadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados Nutricionales'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            ResumenNutricionalCard(),
            SizedBox(height: 16),
            CaloriasCard(),
            SizedBox(height: 16),
            MacroCard(),
          ],
        ),
      ),
    );
  }
}
