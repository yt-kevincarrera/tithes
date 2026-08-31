# Diezmo

App de Android para calcular cuánto diezmo toca pagar, con ingresos en CUP, USD,
EUR y MLC convertidos con las tasas del mercado informal.

No rastrea gastos, no hace presupuestos, no categoriza nada. Registra lo que
entra, calcula el 10 %, y lleva la cuenta de qué ya se pagó.

## Cómo funciona

**Un ingreso puede tener varias monedas.** El salario que llega como 200 USD en
efectivo más 5 000 CUP en la tarjeta es **un** registro con dos líneas, no dos
registros.

**No hay períodos de calendario.** Un ingreso está pendiente o está pagado. Al
registrar un pago con fecha D se saldan todos los pendientes con fecha ≤ D, y el
siguiente período empieza solo. Si más tarde aparece un ingreso viejo, entra como
pendiente y se cobra en el próximo pago: nada se pierde y nada se cuenta dos
veces.

**La deuda se valora con la tasa del día en que se paga**, así que el número de
la pantalla de inicio flota con el mercado. Al confirmar un pago, las tasas de
ese día quedan congeladas dentro del pago y el historial ya no se mueve.

**Las ofrendas van aparte.** No se calculan ni se deben; solo se registran.

## Importar el slip de nómina

Copia el slip en Telegram y toca **Pegar slip** en la pantalla de inicio. El
formulario llega relleno con `Final Pay (CUP)`, `Salario Tropipay USD` y `Bono`
si lo hay, como un solo ingreso de varias monedas.

Es copiar y pegar, no compartir, porque Telegram no ofrece "compartir" para los
mensajes de un canal: da *Reenviar*, que es interno suyo, y *Copiar*. La app
acepta igualmente texto compartido desde cualquier otra app, por si el slip
llega por otra vía.

Tampoco se leen las notificaciones de Telegram: un slip es un mensaje largo que
Android puede truncar justo antes de la línea que importa, y esa lectura exige
permiso sobre **todas** las notificaciones del teléfono.

### Qué se toma y qué no

Solo esas tres líneas son dinero cobrado. Los desgloses (`Salario Quincenal
CUP`, `Base Impositiva`) y las deducciones son de dónde sale el Final Pay:

```
33.250,00 − 4.693,50 − 2.950,00 = 25.606,50  = Final Pay
33.750,00 − 4.793,50 − 3.000,00 = 25.956,50  = Final Pay
```

Sumarlos contaría el mismo dinero dos veces. Y esa misma cuenta muestra que el
Final Pay **no** incluye ni los USD de Tropipay ni el Bono, así que esos dos sí
se suman aparte.

**La fecha del ingreso es el día en que llega el slip**, no el cierre de la
quincena. Los slips llegan con días de retraso —el de la primera quincena sobre
el 20, el de la segunda a principios del mes siguiente— y fecharlos al cierre
haría que entraran marcados como atrasados cada vez que se hubiera pagado el
diezmo entre medias. El período va en el concepto (`Salario 1–15 ago`) y en la
clave que identifica el slip, así que reenviar el mismo se reconoce y se pregunta
en vez de duplicar un salario en silencio.

La `Payment Rate` que trae el slip se ignora a propósito: es la tasa interna de
la nómina, y el diezmo se calcula con la de elTOQUE del día en que se paga.

## Avisar a otra app

Opcional y apagado por defecto. Con ello activado, cada ingreso registrado emite
una notificación por monto —título el concepto, cuerpo `25606.50 CUP`— para que
[Cashew](https://github.com/jameskokoska/Cashew) la capture y cree la
transacción. Ajustes enseña el formato exacto para poder configurar Cashew
mirándolo.

## Correr y compilar

```bash
flutter pub get
dart run build_runner build        # genera el código de Drift
flutter test
flutter run
```

APK instalable:

```bash
flutter build apk --release
```

El APK sale en `build/app/outputs/flutter-apk/app-release.apk`.

Si el proxy de tasas ya está desplegado, se puede dejar puesta su dirección al
compilar; si no, se configura desde Ajustes dentro de la app:

```bash
flutter build apk --release --dart-define=RATES_ENDPOINT=https://tu-proxy.vercel.app/api/rates
```

## Actualizaciones

La app no está en Play Store: se actualiza sola desde las releases de este
repositorio. Al abrirla comprueba si hay una versión nueva y, si la hay, enseña
una barra con un botón que descarga el APK y lanza el instalador de Android.
También hay un botón manual en Ajustes y en el menú de la pantalla principal.

La descarga corre en el servicio del sistema, así que **no se corta al apagar la
pantalla ni al salir de la app**, y al terminar basta con tocar su notificación
para instalar.

Publicar una versión es empujar una etiqueta `v*`; el resto lo hace CI. Ver
[docs/RELEASES.md](docs/RELEASES.md).

## Estructura

```
lib/
  domain/    entidades y el cálculo del diezmo. Dart puro: ni Flutter ni SQL.
  data/      Drift/SQLite, repositorio, cliente del proxy, respaldos
  ui/        pantallas (Riverpod)
proxy/       la función serverless que consulta elTOQUE — ver proxy/README.md
```

`domain` es la única parte donde un fallo cuesta dinero real, así que no depende
de nada y se prueba entera en milisegundos.

Los montos se guardan como **enteros en centésimas**, nunca como `double`: la
coma flotante acumula errores de céntimos al sumar dinero repetidamente.

## Tasas de cambio

Vienen de la API TRMI de [elTOQUE](https://eltoque.com) a través de un proxy
propio, porque desde Cuba ETECSA bloquea el acceso directo y porque el token no
debe vivir dentro del APK. Los detalles están en [proxy/README.md](proxy/README.md).

La app degrada en tres escalones y nunca se queda inservible:

1. tasas frescas del proxy,
2. la última copia guardada en el teléfono, mostrando su fecha,
3. la tasa que escribas a mano, que manda sobre todo lo anterior.

## Datos

Todo vive en SQLite dentro del teléfono. Sin cuentas, sin nube, sin sincronizar.
El respaldo es manual desde Ajustes: exporta un JSON legible que se puede volver
a importar.

## Créditos

Tasas del mercado informal de [elTOQUE](https://eltoque.com). Son valores
referenciales.
