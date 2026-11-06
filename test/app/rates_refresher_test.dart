import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thites/app/providers.dart';
import 'package:thites/data/database.dart';
import 'package:thites/data/rates_api.dart';
import 'package:thites/data/tithe_repository.dart';
import 'package:thites/domain/currency.dart';

void main() {
  late AppDatabase db;
  late TitheRepository repo;
  late ProviderContainer container;
  late RatesApi api;
  var status = 200;
  DateTime? nextExpiry;
  final oldExpiry = DateTime.utc(2026, 11, 4);

  setUp(() async {
    status = 200;
    nextExpiry = null;
    db = AppDatabase(NativeDatabase.memory());
    repo = TitheRepository(db);
    await repo.setTokenExpiry(oldExpiry);
    api = RatesApi(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'date': '2026-11-06',
            'rates': {'USD': 93000, 'EUR': 101500, 'MLC': 70624},
            'tokenExpiresAt': nextExpiry?.toIso8601String(),
          }),
          status,
        ),
      ),
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        ratesApiProvider.overrideWithValue(api),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    api.close();
    await db.close();
  });

  test(
    'a successful refresh without expiry removes the old expired date',
    () async {
      expect(await repo.watchTokenExpiry().first, oldExpiry);

      await container.read(ratesRefresherProvider.notifier).refresh();

      expect(container.read(ratesRefresherProvider).error, isNull);
      expect((await repo.currentRates())!.rateFor(Currency.usd), 93000);
      expect(await repo.watchTokenExpiry().first, isNull);
    },
  );

  test('a failed refresh preserves the last known expiry', () async {
    status = 502;

    await container.read(ratesRefresherProvider.notifier).refresh();

    expect(container.read(ratesRefresherProvider).error, isNotNull);
    expect(await repo.watchTokenExpiry().first, oldExpiry);
  });

  test('a successful refresh replaces expiry when it is available', () async {
    nextExpiry = DateTime.utc(2027, 11, 6);

    await container.read(ratesRefresherProvider.notifier).refresh();

    expect(container.read(ratesRefresherProvider).error, isNull);
    expect(await repo.watchTokenExpiry().first, nextExpiry);
  });
}
