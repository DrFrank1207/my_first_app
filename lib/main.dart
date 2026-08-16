import 'package:flutter/material.dart';
import 'package:mi_primer_app/features/pedidos/presentation/pantalla_pedidos.dart';

void main() => runApp(const MiApp());

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Pedidos',
    theme: ThemeData(colorSchemeSeed: Colors.orange),
    home: const PantallaPedidos(),
  );
}
