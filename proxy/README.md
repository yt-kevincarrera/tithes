# Proxy de tasas

Un endpoint. Consulta la API TRMI de elTOQUE, normaliza la respuesta y la
cachea.

## Por qué existe

Desde Cuba, ETECSA bloquea elTOQUE: la app en el teléfono no llega a la API sin
VPN. Este servidor, fuera de Cuba, sí llega. Además mantiene el token fuera del
APK — los términos de elTOQUE prohíben compartir la clave, y cualquiera puede
extraer un secreto de un APK.

## Desplegar

```bash
npm i -g vercel
cd proxy
vercel                      # crea el proyecto, "root directory" es esta carpeta
vercel env add ELTOQUE_TOKEN production
vercel --prod
```

Anota la URL que devuelve y ponla en `lib/data/rates_api.dart`
(`kRatesEndpoint`).

## Probar

```bash
curl https://<tu-proyecto>.vercel.app/api/rates
```

## Respuesta

```json
{
  "date": "2026-08-31",
  "rates": { "CUP": 100, "USD": 44000, "EUR": 48000, "MLC": 19000 },
  "fetchedAt": "2026-08-31T12:00:00.000Z",
  "source": "eltoque"
}
```

Los valores son **centavos de CUP por una unidad** de la moneda: `44000` son
440,00 CUP por 1 USD. Enteros a propósito, para que ni el servidor ni la app
hagan aritmética de dinero en coma flotante.

Si elTOQUE falla y hay una respuesta buena anterior en memoria, se devuelve esa
con `"stale": true` en vez de un error. La app también sabe caer a su propia
copia local y a las tasas escritas a mano, así que un fallo aquí nunca la deja
inservible.

## Caché

`s-maxage=3600` más `stale-while-revalidate=86400`: la CDN de Vercel responde
casi siempre sin tocar elTOQUE. El límite de la API son 60 peticiones por minuto
y 10 por segundo, así que queda holgadísimo.

## Formato de la respuesta de elTOQUE

El OpenAPI de elTOQUE no documenta el cuerpo del 200. `normalizeRates` recorre
la respuesta buscando claves de moneda conocidas a cualquier profundidad, en vez
de asumir una estructura fija. El euro llega como `ECU`, no como `EUR`.

## Créditos

Los datos de tasas de cambio son de [elTOQUE](https://eltoque.com), que exige
citarlo como fuente. Son valores referenciales del mercado informal.
