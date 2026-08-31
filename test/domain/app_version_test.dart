import 'package:flutter_test/flutter_test.dart';
import 'package:thites/domain/app_version.dart';

void main() {
  group('lectura', () {
    test('formato normal', () {
      expect(AppVersion.tryParse('1.2.3'), const AppVersion(1, 2, 3));
    });

    test('con la v de la etiqueta de GitHub', () {
      expect(AppVersion.tryParse('v1.2.3'), const AppVersion(1, 2, 3));
    });

    test('con el número de build de pubspec', () {
      expect(AppVersion.tryParse('1.2.3+7'), const AppVersion(1, 2, 3));
    });

    test('incompleta: lo que falta es cero', () {
      expect(AppVersion.tryParse('1.2'), const AppVersion(1, 2, 0));
      expect(AppVersion.tryParse('2'), const AppVersion(2, 0, 0));
    });

    test('con espacios alrededor', () {
      expect(AppVersion.tryParse('  1.0.0 '), const AppVersion(1, 0, 0));
    });

    test('null si no hay ningún número', () {
      expect(AppVersion.tryParse(null), isNull);
      expect(AppVersion.tryParse(''), isNull);
      expect(AppVersion.tryParse('ultima'), isNull);
    });
  });

  group('comparación', () {
    test('una versión no es más nueva que ella misma', () {
      expect(
        const AppVersion(1, 0, 0).isNewerThan(const AppVersion(1, 0, 0)),
        isFalse,
      );
    });

    test('manda el número mayor', () {
      expect(
        const AppVersion(2, 0, 0).isNewerThan(const AppVersion(1, 9, 9)),
        isTrue,
      );
    });

    test('el menor desempata', () {
      expect(
        const AppVersion(1, 2, 0).isNewerThan(const AppVersion(1, 1, 9)),
        isTrue,
      );
    });

    test('el parche desempata', () {
      expect(
        const AppVersion(1, 0, 2).isNewerThan(const AppVersion(1, 0, 1)),
        isTrue,
      );
    });

    test(
      '1.10.0 es más nueva que 1.9.0, que es donde falla comparar como texto',
      () {
        expect(
          const AppVersion(1, 10, 0).isNewerThan(const AppVersion(1, 9, 0)),
          isTrue,
        );
      },
    );

    test('no ofrece volver atrás', () {
      expect(
        const AppVersion(1, 0, 0).isNewerThan(const AppVersion(1, 1, 0)),
        isFalse,
      );
    });
  });
}
