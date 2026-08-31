import 'package:flutter_test/flutter_test.dart';
import 'package:thites/data/update_service.dart';

Map<String, dynamic> _asset(String name, {int size = 1000}) => {
  'name': name,
  'size': size,
  'browser_download_url': 'https://example.test/$name',
};

void main() {
  group('elegir el APK de la release', () {
    final assets = [
      _asset('diezmo-1.2.0-arm64-v8a.apk', size: 20),
      _asset('diezmo-1.2.0-armeabi-v7a.apk', size: 18),
      _asset('diezmo-1.2.0-x86_64.apk', size: 21),
    ];

    test('coge el de la arquitectura del teléfono', () {
      expect(
        UpdateService.pickApk(assets, abi: 'arm64-v8a')?['name'],
        'diezmo-1.2.0-arm64-v8a.apk',
      );
      expect(
        UpdateService.pickApk(assets, abi: 'armeabi-v7a')?['name'],
        'diezmo-1.2.0-armeabi-v7a.apk',
      );
      expect(
        UpdateService.pickApk(assets, abi: 'x86_64')?['name'],
        'diezmo-1.2.0-x86_64.apk',
      );
    });

    test('no confunde arm64-v8a con armeabi-v7a', () {
      // Los dos empiezan por "arm": buscar solo por prefijo daría el que no es
      // y Android se negaría a instalarlo.
      final elegido = UpdateService.pickApk(assets, abi: 'arm64-v8a');
      expect(elegido?['name'], isNot(contains('armeabi')));
    });

    test('una release universal se sigue pudiendo instalar', () {
      // Las versiones antiguas publicaban un solo APK sin arquitectura en el
      // nombre. El actualizador no puede quedarse ciego ante ellas.
      final viejo = [_asset('diezmo-1.0.2.apk')];

      expect(
        UpdateService.pickApk(viejo, abi: 'arm64-v8a')?['name'],
        'diezmo-1.0.2.apk',
      );
    });

    test('sin un APK para esta arquitectura no se inventa otro', () {
      final soloX86 = [_asset('diezmo-1.2.0-x86_64.apk')];

      expect(UpdateService.pickApk(soloX86, abi: 'arm64-v8a'), isNull);
    });

    test('ignora los assets que no son APK', () {
      final mezcla = [
        _asset('notas.txt'),
        _asset('fuentes.zip'),
        _asset('diezmo-1.2.0-arm64-v8a.apk'),
      ];

      expect(
        UpdateService.pickApk(mezcla, abi: 'arm64-v8a')?['name'],
        'diezmo-1.2.0-arm64-v8a.apk',
      );
    });

    test('una release sin assets no da nada', () {
      expect(UpdateService.pickApk(const []), isNull);
      expect(UpdateService.pickApk(null), isNull);
      expect(UpdateService.pickApk([_asset('notas.txt')]), isNull);
    });

    test('el tamaño viene del asset elegido', () {
      expect(UpdateService.pickApk(assets, abi: 'arm64-v8a')?['size'], 20);
    });
  });
}
