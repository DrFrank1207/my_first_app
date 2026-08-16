import 'package:flutter/material.dart';
import 'package:mi_primer_app/features/pedidos/data/pedidos_locales.dart';
import 'package:mi_primer_app/features/pedidos/domain/pedido.dart';

class PantallaPedidos extends StatefulWidget {
  const PantallaPedidos({super.key});

  @override
  State<PantallaPedidos> createState() => _PantallaPedidosState();
}

class _PantallaPedidosState extends State<PantallaPedidos> {
  // `late final` en el campo: el Future se crea UNA vez.
  // Crearlo dentro de build() lo relanza en cada reconstrucción, y esa es la
  // causa del 90 % de los FutureBuilder que parpadean sin parar.
  late final Future<List<Pedido>> _pedidos = PedidosLocales().obtenerTodos();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pedidos')),
    body: FutureBuilder<List<Pedido>>(
      future: _pedidos,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          // El mensaje de CampoInvalido dice el campo. Aquí se ve por qué
          // valió la pena escribirlo.
          return Center(child: Text('No se pudo leer:\n${snapshot.error}'));
        }

        final pedidos = snapshot.data ?? const <Pedido>[];
        return ListView.separated(
          itemCount: pedidos.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final pedido = pedidos[i];
            return ListTile(
              leading: Icon(
                pedido.sePuedeCancelar
                    ? Icons.receipt_long
                    : Icons.check_circle_outline,
              ),
              title: Text(pedido.cliente),
              subtitle: Text(
                '${pedido.direccion.barrio} · ${pedido.estado.etiqueta}',
              ),
              trailing: pedido.tieneExtras
                  ? const Icon(Icons.notes)
                  : Text(
                      '${pedido.monto.cantidad.toStringAsFixed(0)} '
                      '${pedido.monto.moneda}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
            );
          },
        );
      },
    ),
  );
}
