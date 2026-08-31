# Diseño: app de diezmo multi-moneda

Fecha: 2026-08-31

## Propósito

Calcular cuánto diezmo hay que pagar. No es una app de finanzas personales: no
rastrea gastos, no hace presupuestos, no categoriza nada. Registra ingresos en
varias monedas, los convierte a CUP con las tasas del mercado informal, aplica
el 10 % y lleva la cuenta de qué ya se pagó.

El usuario cobra por quincena en monedas mezcladas (USD efectivo + CUP tarjeta)
y paga el diezmo cuando cobra. La app tiene que ser rapidísima de usar: la
fricción es el enemigo principal del producto.

## Restricciones

- Android únicamente. Flutter.
- Datos solo en el teléfono. Sin cuentas, sin login, sin sincronización.
- Debe funcionar sin internet. La red es una mejora, nunca un requisito.
- Monedas: CUP, USD, EUR, MLC.

## Reglas de negocio

### Diezmo

`diezmo = 10 % del ingreso bruto`. El porcentaje es configurable pero por
defecto es 10.

### Conversión

Todo ingreso se valora en CUP usando **la tasa vigente el día en que se paga**,
no la del día en que se recibió el ingreso. Es decir, la deuda pendiente flota
con el mercado.

Al registrar un pago, las tasas usadas se copian dentro del pago. El historial
es inmutable: un pago del 15 de agosto muestra para siempre las tasas del 15 de
agosto, aunque la tasa de hoy sea otra.

CUP tiene tasa fija 1.

### Períodos

No existen períodos de calendario. Un ingreso está pendiente o está pagado.

Al registrar un pago con fecha D, se marcan como saldados **todos** los ingresos
pendientes con fecha ≤ D. El siguiente período empieza implícitamente después de
D.

Consecuencia deliberada: un ingreso registrado tarde con fecha retroactiva
anterior al último pago sigue estando pendiente y entra en el próximo pago. La
app lo marca visualmente como atrasado. Nunca se pierde ni se cuenta dos veces —
la garantía viene del flag de pagado, no de un rango de fechas.

Las vistas de "mes" o "quincena" son solo un filtro de lectura sobre el
historial.

### Pago

El monto propuesto es el calculado redondeado hacia arriba al CUP entero. El
usuario puede editarlo. Se guardan los dos: lo calculado y lo realmente
entregado.

Si el monto real difiere del calculado, la diferencia **se ignora**. No se
arrastran saldos. Los ingresos quedan saldados igual.

### Ofrendas

Entidad independiente: `{fecha, monto, moneda, nota}`. No se calculan, no se
deben, no afectan el diezmo. Solo se registran y aparecen en el historial.

## Modelo de datos

```
Income
  id, date, concept, note, paymentId?     -- null = pendiente
  IncomeLine[]  { amount, currency }      -- 1..n líneas por ingreso

Payment
  id, date
  ratesUsed: { USD: r, EUR: r, MLC: r }   -- snapshot inmutable
  computedAmountCup, actualAmountCup
  tithePercent                            -- snapshot, por si cambia después

Offering
  id, date, amount, currency, note

Template
  id, name, concept
  TemplateLine[] { amount, currency }

RateSnapshot                              -- cache local de tasas
  date, currency, value, source           -- source: api | manual
```

Un ingreso con varias líneas es un solo registro. El salario quincenal
(200 USD + 5000 CUP) se captura una vez, no dos.

**Los montos se guardan como enteros** en centésimas de la unidad monetaria.
Nunca `double`: la aritmética de coma flotante acumula errores de céntimos en
sumas repetidas de dinero.

## Arquitectura

```
lib/
  domain/    entidades + cálculo. Dart puro, sin dependencias de Flutter.
  data/      Drift/SQLite, repositorio de tasas, cliente HTTP, cache
  ui/        pantallas (Riverpod)
proxy/       función serverless: un endpoint
```

`domain` no importa nada de Flutter ni de la base de datos. Es la única parte
donde un bug cuesta dinero real, así que se escribe con tests primero y se
ejecuta sin emulador.

- Estado: Riverpod
- Persistencia: Drift sobre SQLite (tipado, con migraciones)
- HTTP: `http`

## Tasas de cambio

### Fuente

API TRMI de elTOQUE:

- `GET https://tasas.eltoque.com/v1/trmi`
- Cabecera `Authorization: Bearer <token>`
- Query opcional `date_from` / `date_to`, formato `2022-10-27 00:00:01`.
  El rango no puede exceder 24 h o responde 400. Sin fechas devuelve la tasa de
  las últimas 24 h.
- Límites: 60 req/min, 10 req/s. Excederlos da 429 con `Retry-After`.
- El token se solicita en https://tasas-token.eltoque.com/ y tarda 2–3 días.
- Los términos exigen citar a elTOQUE como fuente de los datos y prohíben
  compartir la clave API.

El cuerpo de la respuesta no está documentado en el OpenAPI. El proxy lo
normaliza y tolera variantes en los nombres de moneda (el euro puede venir como
`ECU` o `EUR`).

### Por qué hay un proxy

Desde Cuba, ETECSA bloquea el acceso a elTOQUE: la app en el teléfono no puede
llamar a la API directamente sin VPN. Un servidor fuera de Cuba sí puede.

Se verificó empíricamente que `*.vercel.app` es alcanzable desde la conexión del
usuario sin VPN, así que el proxy va en Vercel.

El proxy además mantiene el token fuera del APK, donde sería extraíble.

### Contrato del proxy

```
GET /api/rates  ->  200
{
  "date": "2026-08-31",
  "rates": { "USD": 440.0, "EUR": 480.0, "MLC": 190.0, "CUP": 1.0 },
  "fetchedAt": "2026-08-31T12:00:00Z",
  "source": "eltoque"
}
```

Cachea 1 hora. Ante fallo de elTOQUE devuelve la última respuesta buena que
tenga, marcada como tal, en vez de un error.

### Degradación

La app nunca depende de la red para ser útil:

1. Tasas frescas del proxy.
2. Si no hay red: última tasa cacheada localmente, mostrando su fecha de forma
   visible ("tasa del 28 ago").
3. Siempre: el usuario puede escribir la tasa a mano, y esa tiene prioridad.

## Pantallas

**Inicio.** Lo único grande: `Debes 4 873 CUP`. Debajo el desglose por línea
(`200 USD × 440 = 88 000`) y la fecha de la tasa aplicada. Botón primario
*Pagar*. Botones de plantilla (*Salario*) y un `+` para ingreso libre. Lista de
pendientes abajo.

**Nuevo ingreso.** Hoja inferior: fecha (hoy por defecto), concepto, nota, y las
líneas monto+moneda con `+ añadir moneda`. Desde plantilla llega relleno; solo
se confirma.

**Pagar.** Resumen, tasas usadas, monto propuesto editable, confirmar.

**Historial.** Pagos y ofrendas en una línea de tiempo, con filtro por rango de
fechas.

**Ajustes.** Plantillas, tasas (ver y sobrescribir a mano), % del diezmo,
exportar/importar JSON.

## Testing

El dominio se prueba exhaustivamente con tests unitarios: cálculo del diezmo,
conversión multi-moneda, redondeo, qué ingresos entran en un pago, ingresos
retroactivos.

La capa de datos se prueba con SQLite en memoria.

La UI no se prueba automáticamente; se verifica a mano en el dispositivo.

## Fuera de alcance

Seguimiento de gastos, presupuestos, categorías, gráficos, múltiples usuarios,
sincronización en la nube, notificaciones, iOS, arrastre de saldos entre
períodos.
