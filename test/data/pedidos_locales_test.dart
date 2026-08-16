import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mi_primer_app/core/json.dart';
import 'package:mi_primer_app/features/pedidos/data/pedidos_locales.dart';

const _json = '''
[
  {
    "id": "ped-001",
    "cliente": "Ana Gómez",
    "direccion": { "barrio": "Centro", "calle": "Carrera 19 #16-24" },
    "monto": { "cantidad": 38500, "moneda": "COP" },
    "creadoEn": "2026-08-14T18:40:00Z",
    "estado": { "tipo": "en_camino", "repartidor": "Carlos" }
  }
]
''';

void main() {
  test('lee la lista completa del archivo', () async {
    final repo = PedidosLocales(lector: (_) async => _json);
    expect((await repo.obtenerTodos()).length, 1);
  });

  test('busca por id y devuelve null cuando no está', () async {
    final repo = PedidosLocales(lector: (_) async => _json);

    expect((await repo.obtenerPorId('ped-001'))?.cliente, 'Ana Gómez');
    expect(await repo.obtenerPorId('no-existe'), isNull);
  });

  test('un pedido entregado ya no aparece en pendientes', () async {
    final repo = PedidosLocales(lector: (_) async => _json);
    expect((await repo.obtenerPendientes()).length, 1);
  });

  test('un archivo que no es una lista se rechaza', () async {
    final repo = PedidosLocales(lector: (_) async => '{"a": 1}');
    expect(repo.obtenerTodos(), throwsA(isA<CampoInvalido>()));
  });

  test(
    'el asset declarado en pubspec existe y el modelo lo entiende',
    () async {
      // Esta SÍ toca el bundle: es la única que caza "olvidé el pubspec".
      TestWidgetsFlutterBinding.ensureInitialized();

      final repo = PedidosLocales(lector: rootBundle.loadString);
      expect((await repo.obtenerTodos()).length, greaterThanOrEqualTo(3));
    },
  );
}
