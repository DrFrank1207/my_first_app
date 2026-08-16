import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primer_app/core/json.dart';
import 'package:mi_primer_app/features/pedidos/domain/direccion.dart';
import 'package:mi_primer_app/features/pedidos/domain/estado_pedido.dart';
import 'package:mi_primer_app/features/pedidos/domain/monto.dart';
import 'package:mi_primer_app/features/pedidos/domain/pedido.dart';

Pedido ejemplo({EstadoPedido? estado, List<String>? extras}) => Pedido(
  id: 'ped-001',
  cliente: 'Ana Gómez',
  direccion: const Direccion(barrio: 'Centro', calle: 'Carrera 19 #16-24'),
  monto: const Monto(cantidad: 38500, moneda: 'COP'),
  creadoEn: DateTime.utc(2026, 8, 14, 18, 40),
  estado: estado ?? const Recibido(),
  extras: extras ?? const <String>[],
);

void main() {
  group('serialización', () {
    test('un pedido sobrevive la ida y vuelta a JSON sin perder nada', () {
      final original = ejemplo(
        estado: Entregado(DateTime.utc(2026, 8, 14, 19, 22), 'Ana Gómez'),
        extras: const ['sin cebolla'],
      );

      // Pasa por TEXTO, no solo por Map: así también se prueba que las fechas
      // y las listas sobreviven a jsonEncode.
      final texto = jsonEncode(original.toJson());
      final vuelta = Pedido.fromJson(jsonDecode(texto) as Map<String, dynamic>);

      expect(vuelta, equals(original));
    });

    test('un pedido sin la clave extras se lee con la lista vacía', () {
      final json = ejemplo().toJson()..remove('extras');
      expect(Pedido.fromJson(json).extras, isEmpty);
    });

    test('un pedido sin cliente dice QUÉ campo falló, no solo que falló', () {
      final json = ejemplo().toJson()..remove('cliente');

      expect(
        () => Pedido.fromJson(json),
        throwsA(
          isA<CampoInvalido>().having((e) => e.campo, 'campo', 'cliente'),
        ),
      );
    });

    test('una fecha que no es ISO 8601 se rechaza', () {
      final json = ejemplo().toJson()..['creadoEn'] = '14 de agosto';
      expect(() => Pedido.fromJson(json), throwsA(isA<CampoInvalido>()));
    });

    test('la hora se conserva en UTC y no se corre cinco horas', () {
      final json = ejemplo().toJson();
      expect(json['creadoEn'], '2026-08-14T18:40:00.000Z');
    });
  });

  group('igualdad', () {
    test('dos pedidos con los mismos datos son iguales', () {
      expect(ejemplo(), equals(ejemplo()));
    });

    test('dos pedidos con los mismos datos comparten hashCode', () {
      // Sin esto, meterlos en un Set daría dos elementos donde debería haber uno.
      expect(ejemplo().hashCode, equals(ejemplo().hashCode));
      expect({ejemplo(), ejemplo()}.length, 1);
    });

    test('dos pedidos con extras distintos NO son iguales', () {
      expect(
        ejemplo(extras: const ['a']),
        isNot(equals(ejemplo(extras: const ['b']))),
      );
    });

    test('copyWith cambia solo lo que se le pasa', () {
      final original = ejemplo();
      final copia = original.copyWith(cliente: 'Otro cliente');

      expect(copia.cliente, 'Otro cliente');
      expect(copia.id, original.id);
      expect(copia.creadoEn, original.creadoEn);
    });
  });

  group('reglas de negocio', () {
    test('un pedido en camino no se puede cancelar', () {
      expect(
        ejemplo(estado: const EnCamino('Carlos')).sePuedeCancelar,
        isFalse,
      );
    });

    test('un pedido recién recibido sí se puede cancelar', () {
      expect(ejemplo(estado: const Recibido()).sePuedeCancelar, isTrue);
    });

    test('un pedido de hace 50 minutos está demorado', () {
      final ahora = DateTime.utc(2026, 8, 14, 19, 30);
      expect(ejemplo().estaDemorado(ahora), isTrue);
    });

    test('un pedido de hace 10 minutos no está demorado', () {
      final ahora = DateTime.utc(2026, 8, 14, 18, 50);
      expect(ejemplo().estaDemorado(ahora), isFalse);
    });

    test('la etiqueta de una cancelación incluye el motivo', () {
      expect(
        const Cancelado('el restaurante cerró').etiqueta,
        contains('el restaurante cerró'),
      );
    });
  });
}
