import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primer_app/core/comparaciones.dart';

void main() {
  test(
    'dos listas con el mismo contenido son iguales aunque no sean la misma',
    () {
      expect(listasIguales(const [1, 2], const [1, 2]), isTrue);
    },
  );

  test('listas de distinta longitud o distinto orden NO son iguales', () {
    expect(listasIguales(const [1, 2], const [1]), isFalse);
    expect(listasIguales(const [1, 2], const [2, 1]), isFalse);
  });

  test('listas vacías son iguales', () {
    expect(listasIguales(const <int>[], const <int>[]), isTrue);
  });
}
