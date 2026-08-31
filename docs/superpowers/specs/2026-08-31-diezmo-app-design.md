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

**El número grande de la pantalla de inicio es el exacto, no el redondeado**, y
el redondeo aparece debajo con su etiqueta. Enseñar solo el redondeo escondería
cuál es el mínimo de verdad, y algún mes puede no alcanzar para redondear hacia
arriba. Por la misma razón, la pantalla de pago ofrece los dos importes como
atajos de un toque en vez de obligar a teclear.

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

## Importar el slip de nómina

El slip llega por un canal de Telegram al que el usuario no tiene permisos de
administrador, así que un bot propio dentro del canal queda descartado, y una
sesión MTProto en un servidor daría acceso a todo su Telegram para leer un solo
canal. Queda el teléfono.

De las dos formas de leerlo en el teléfono, la lectura de notificaciones se
descartó: un slip es un mensaje largo que Android puede truncar justo antes de
`Final Pay (CUP)`, y esa lectura exige permiso sobre **todas** las
notificaciones.

Quedaba compartir, pero **Telegram no ofrece "compartir" para los mensajes de un
canal**: da *Reenviar*, que es interno suyo, y *Copiar*. Así que el camino
principal es copiar y pegar, con un botón visible en la pantalla de inicio. El
intent de compartir se deja declarado para cuando el slip llegue por otra vía.

Del mensaje se toman `Final Pay (CUP)`, `Salario Tropipay USD` y `Bono`. Los
desgloses (`Salario Quincenal CUP`, `Base Impositiva`) y las deducciones son de
donde sale el Final Pay, y sumarlos contaría el mismo dinero dos veces. La
aritmética de los slips reales lo confirma en las dos direcciones:

```
33.250,00 − 4.693,50 − 2.950,00 = 25.606,50  = Final Pay
33.750,00 − 4.793,50 − 3.000,00 = 25.956,50  = Final Pay
```

El Final Pay **no** incluye los USD de Tropipay ni el Bono, así que esos sí se
suman aparte. El slip no dice la moneda del Bono, a diferencia de los campos en
CUP, que la llevan en la etiqueta; el usuario confirmó que es USD.

`Pago Vacaciones` se ignora por ahora: tampoco está dentro del Final Pay, pero
no está claro que sea dinero cobrado y las cifras vistas son de céntimos.

Los números del slip usan siempre coma para los miles y punto para los
decimales, a veces con tres cifras decimales. Tienen su propio conversor: el de
la entrada del usuario tiene que **adivinar** cuál de los dos separadores es el
decimal, y aquí adivinar solo introduciría errores.

### La fecha

El ingreso se fecha **el día en que llega el slip**, no al cierre del período.
Los slips llegan con retraso —el de la primera quincena sobre el día 20, el de
la segunda a principios del mes siguiente— y fecharlos al cierre haría que
entraran marcados como atrasados cada vez que se hubiera pagado el diezmo entre
medias.

El período vive en dos sitios: en el concepto (`Salario 1–15 ago`), que lo hace
legible, y en la clave de origen (`slip:2026-08-01_2026-08-15`), que identifica
el slip. Reenviar el mismo slip se reconoce y se pregunta, en vez de duplicar un
salario en silencio.

Consecuencia aceptada: en el historial filtrado por mes, el salario de la
segunda quincena de agosto aparece bajo septiembre. Es correcto —el diezmo es
sobre lo que se recibe cuando se recibe— y el concepto lo desambigua.

La `Payment Rate` del slip se ignora: es la tasa interna de la nómina, y el
diezmo se valora con la de elTOQUE del día en que se paga.

### Registrar el salario a mano

El concepto de una plantilla admite `{quincena}`, que se resuelve al usarla.
Pone la quincena **que acaba de cerrar**, no la en curso, porque el salario
siempre llega después del período que paga.

## Avisar a otra app

Opcional, apagado por defecto. Cada ingreso registrado emite una notificación
por monto —título el concepto, cuerpo `25606.50 CUP`— para que Cashew la capture
y cree la transacción. El cuerpo es deliberadamente pobre, sin separador de
miles, porque cuanto más simple sea menos se equivoca el extractor de Cashew.
Ajustes enseña el formato para poder configurarlo sin adivinar.

Solo se emite al **crear** un ingreso: reeditarlo duplicaría la transacción en
la otra app.

## Distribución y actualizaciones

La app no va a Play Store. Se distribuye como APK desde las releases de
`yt-kevincarrera/tithes`, y se actualiza sola: al abrirse consulta
`/releases/latest`, compara la etiqueta con la versión instalada y, si hay una
más nueva, enseña una barra con un botón que descarga el APK y llama al
instalador de Android.

El fallo es silencioso a propósito: sin internet, o con GitHub caído, no se
avisa de nada. La app se abre para registrar un cobro, no para actualizarse.

Dos restricciones mandan aquí:

- **El repositorio es público.** Los assets de una release privada exigen
  autenticación, y un token dentro del APK es un secreto extraíble.
- **La firma tiene que ser estable.** Android solo permite actualizar una app en
  sitio si el APK nuevo lleva la misma clave que el instalado. Por eso hay una
  clave de release propia, fuera de git, y CI firma con ella desde los secrets
  del repositorio. La clave de debug que Flutter pone por defecto habría hecho
  imposible actualizar, porque difiere entre máquinas.

Las versiones se comparan como números, no como texto: `1.10.0` tiene que salir
posterior a `1.9.0`.

La descarga la hace el **servicio de descargas de Android**, no una petición
HTTP dentro de la app. Un APK son decenas de megas sobre una conexión lenta, y
una descarga que vive en el proceso de la app se corta en cuanto se apaga la
pantalla o se cambia de aplicación. De paso, el sistema pone su propia
notificación con barra de progreso y, al terminar, tocarla abre el instalador
aunque la app ya no esté delante.

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
