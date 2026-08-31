import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/rates_api.dart';
import '../data/income_announcer.dart';
import '../data/tithe_repository.dart';
import '../domain/currency.dart';
import '../domain/exchange_rates.dart';
import '../domain/income.dart';
import '../domain/income_template.dart';
import '../domain/offering.dart';
import '../domain/payment.dart';
import '../domain/tithe_calculator.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final repositoryProvider = Provider<TitheRepository>(
  (ref) => TitheRepository(ref.watch(databaseProvider)),
);

final ratesApiProvider = Provider<RatesApi>((ref) {
  final api = RatesApi();
  ref.onDispose(api.close);
  return api;
});

final pendingIncomesProvider = StreamProvider<List<Income>>(
  (ref) => ref.watch(repositoryProvider).watchPendingIncomes(),
);

final allIncomesProvider = StreamProvider<List<Income>>(
  (ref) => ref.watch(repositoryProvider).watchAllIncomes(),
);

final paymentsProvider = StreamProvider<List<Payment>>(
  (ref) => ref.watch(repositoryProvider).watchPayments(),
);

final lastPaymentProvider = StreamProvider<Payment?>(
  (ref) => ref.watch(repositoryProvider).watchLastPayment(),
);

final incomesOfPaymentProvider = StreamProvider.family<List<Income>, String>(
  (ref, paymentId) =>
      ref.watch(repositoryProvider).watchIncomesOfPayment(paymentId),
);

final offeringsProvider = StreamProvider<List<Offering>>(
  (ref) => ref.watch(repositoryProvider).watchOfferings(),
);

final templatesProvider = StreamProvider<List<IncomeTemplate>>(
  (ref) => ref.watch(repositoryProvider).watchTemplates(),
);

final ratesProvider = StreamProvider<ExchangeRates?>(
  (ref) => ref.watch(repositoryProvider).watchRates(),
);

final titheBasisPointsProvider = StreamProvider<int>(
  (ref) => ref.watch(repositoryProvider).watchTitheBasisPoints(),
);

final ratesEndpointProvider = StreamProvider<String>(
  (ref) => ref.watch(repositoryProvider).watchRatesEndpoint(),
);

final announceIncomesProvider = StreamProvider<bool>(
  (ref) => ref.watch(repositoryProvider).watchAnnounceIncomes(),
);

final tokenExpiryProvider = StreamProvider<DateTime?>(
  (ref) => ref.watch(repositoryProvider).watchTokenExpiry(),
);

/// Días que le quedan al token de elTOQUE, o null si no se sabe.
///
/// Negativo si ya caducó. Se avisa desde 45 días antes porque pedir uno nuevo a
/// elTOQUE tarda dos o tres días y hay que dejar margen para acordarse.
final tokenDaysLeftProvider = Provider<int?>((ref) {
  final expiry = ref.watch(tokenExpiryProvider).valueOrNull;
  if (expiry == null) return null;
  return expiry.difference(DateTime.now()).inDays;
});

const kTokenWarningDays = 45;

/// Emite el aviso para la otra app de finanzas, pero solo si está activado.
///
/// La comprobación vive aquí y no en cada pantalla para que no se pueda olvidar
/// en una de ellas y acabar notificando a quien no lo pidió.
class AnnouncerGate {
  AnnouncerGate(this._repo, this._announcer);

  final TitheRepository _repo;
  final IncomeAnnouncer _announcer;

  Future<bool> requestPermission() => _announcer.requestPermission();

  Future<void> announceIfEnabled(Income income) async {
    if (!await _repo.announceIncomes()) return;
    try {
      await _announcer.announce(income);
    } catch (_) {
      // Un fallo al notificar no puede tumbar el registro del ingreso, que es
      // lo único que de verdad importa aquí.
    }
  }
}

final incomeAnnouncerProvider = Provider<AnnouncerGate>(
  (ref) => AnnouncerGate(ref.watch(repositoryProvider), IncomeAnnouncer()),
);

/// Todo lo que la pantalla de inicio necesita, ya resuelto.
class HomeSummary {
  const HomeSummary({
    required this.pending,
    required this.rates,
    required this.titheBasisPoints,
    required this.lastPayment,
    required this.missingRates,
    required this.calculation,
  });

  final List<Income> pending;
  final ExchangeRates? rates;
  final int titheBasisPoints;
  final Payment? lastPayment;

  /// Monedas que aparecen en lo pendiente y de las que no hay tasa. Mientras
  /// haya alguna no se puede calcular nada, y la UI pide la tasa a mano.
  final Set<Currency> missingRates;

  /// Null cuando falta alguna tasa.
  final TitheCalculation? calculation;

  bool get canCalculate => calculation != null;
  bool get hasPending => pending.isNotEmpty;
}

final homeSummaryProvider = Provider<AsyncValue<HomeSummary>>((ref) {
  final pending = ref.watch(pendingIncomesProvider);
  final rates = ref.watch(ratesProvider);
  final basisPoints = ref.watch(titheBasisPointsProvider);
  final lastPayment = ref.watch(lastPaymentProvider);

  // Con que uno esté cargando o haya fallado, el resumen entero lo está.
  final loading = [pending, rates, basisPoints, lastPayment]
      .firstWhere((v) => v.isLoading, orElse: () => const AsyncData(null));
  if (loading.isLoading) return const AsyncValue.loading();

  for (final value in [pending, rates, basisPoints, lastPayment]) {
    if (value.hasError) {
      return AsyncValue.error(value.error!, value.stackTrace!);
    }
  }

  final incomes = pending.requireValue;
  final currentRates = rates.requireValue;
  final needed = TitheCalculator.currenciesNeeded(incomes);
  final missing = needed
      .where((c) => currentRates == null || !currentRates.has(c))
      .toSet();

  return AsyncValue.data(
    HomeSummary(
      pending: incomes,
      rates: currentRates,
      titheBasisPoints: basisPoints.requireValue,
      lastPayment: lastPayment.requireValue,
      missingRates: missing,
      calculation: missing.isEmpty
          ? TitheCalculator.calculate(
              incomes: incomes,
              rates:
                  currentRates ??
                  ExchangeRates(
                    asOf: DateTime.now(),
                    source: RateSource.cache,
                    values: const {},
                  ),
              titheBasisPoints: basisPoints.requireValue,
            )
          : null,
    ),
  );
});

/// Estado de la última descarga de tasas.
class RatesRefreshState {
  const RatesRefreshState({
    this.isRefreshing = false,
    this.error,
    this.wasStale = false,
  });

  final bool isRefreshing;
  final String? error;

  /// El proxy respondió, pero con una copia vieja porque elTOQUE falló.
  final bool wasStale;
}

class RatesRefresher extends Notifier<RatesRefreshState> {
  @override
  RatesRefreshState build() => const RatesRefreshState();

  /// Baja las tasas del proxy y las guarda.
  ///
  /// Nunca lanza: un fallo de red deja la app con las tasas que ya tenía, que
  /// es exactamente lo que se quiere. La deuda se sigue pudiendo calcular.
  Future<void> refresh() async {
    if (state.isRefreshing) return;
    state = const RatesRefreshState(isRefreshing: true);

    final repo = ref.read(repositoryProvider);
    try {
      final endpoint = await repo.ratesEndpoint();
      final fetched = await ref.read(ratesApiProvider).fetch(endpoint);
      await repo.saveDownloadedRates(
        values: fetched.values,
        asOf: fetched.asOf,
      );
      await repo.setTokenExpiry(fetched.tokenExpiresAt);
      state = RatesRefreshState(wasStale: fetched.isStale);
    } on RatesApiException catch (error) {
      state = RatesRefreshState(error: error.message);
    } catch (error) {
      state = RatesRefreshState(error: error.toString());
    }
  }
}

final ratesRefresherProvider =
    NotifierProvider<RatesRefresher, RatesRefreshState>(RatesRefresher.new);
