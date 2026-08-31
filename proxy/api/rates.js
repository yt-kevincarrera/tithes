// Proxy de tasas de cambio entre la app y la API TRMI de elTOQUE.
//
// Existe por dos razones:
//
//   1. Desde Cuba, ETECSA bloquea el acceso a elTOQUE, así que el teléfono no
//      puede llamar a la API directamente sin VPN. Este servidor sí puede.
//   2. El token no puede vivir dentro del APK, donde cualquiera lo extraería.
//      Los términos de elTOQUE prohíben expresamente compartir la clave.
//
// Datos de tasas de cambio: elTOQUE (https://eltoque.com).

const ELTOQUE_URL = 'https://tasas.eltoque.com/v1/trmi';

/// Cómo llama elTOQUE a cada moneda frente a cómo la llamamos nosotros.
/// El euro viene como `ECU` en la API, no como `EUR`.
const CURRENCY_ALIASES = {
  USD: 'USD',
  ECU: 'EUR',
  EUR: 'EUR',
  MLC: 'MLC',
};

/// Última respuesta buena. Vive mientras la instancia esté caliente y sirve
/// para no devolver un error cuando elTOQUE falla puntualmente.
let lastGood = null;

export default async function handler(request, response) {
  const token = process.env.ELTOQUE_TOKEN;

  if (!token) {
    return response
      .status(500)
      .json({ error: 'ELTOQUE_TOKEN no está configurado en el servidor' });
  }

  try {
    const payload = await fetchRates(token);
    lastGood = payload;

    // La CDN de Vercel guarda la respuesta una hora y sigue sirviendo la copia
    // vieja hasta un día mientras revalida por detrás. Con esto la app casi
    // nunca toca elTOQUE de verdad y el límite de 60 req/min queda lejísimos.
    response.setHeader(
      'Cache-Control',
      's-maxage=3600, stale-while-revalidate=86400',
    );
    return response.status(200).json(payload);
  } catch (error) {
    if (lastGood) {
      response.setHeader('Cache-Control', 'no-store');
      return response.status(200).json({
        ...lastGood,
        stale: true,
        staleReason: String(error.message ?? error),
      });
    }

    const status = error.status === 429 ? 429 : 502;
    response.setHeader('Cache-Control', 'no-store');
    return response.status(status).json({ error: String(error.message ?? error) });
  }
}

async function fetchRates(token) {
  const upstream = await fetch(ELTOQUE_URL, {
    headers: { Authorization: `Bearer ${token}` },
    signal: AbortSignal.timeout(15000),
  });

  if (!upstream.ok) {
    const body = await upstream.text().catch(() => '');
    const error = new Error(
      `elTOQUE respondió ${upstream.status}${body ? `: ${body.slice(0, 200)}` : ''}`,
    );
    error.status = upstream.status;
    throw error;
  }

  const raw = await upstream.json();
  const rates = normalizeRates(raw);

  if (Object.keys(rates).length === 0) {
    throw new Error(
      `No se reconoció ninguna moneda en la respuesta de elTOQUE: ${JSON.stringify(raw).slice(0, 300)}`,
    );
  }

  return {
    date: extractDate(raw),
    rates: { CUP: 100, ...rates },
    fetchedAt: new Date().toISOString(),
    source: 'eltoque',
  };
}

/// Saca las tasas de la respuesta sin depender de su forma exacta.
///
/// El OpenAPI de elTOQUE no documenta el cuerpo del 200, así que en vez de
/// codificar una estructura concreta buscamos recursivamente cualquier objeto
/// con claves de moneda conocidas y valores numéricos. Si mañana envuelven la
/// respuesta en otra capa, esto sigue funcionando.
function normalizeRates(raw) {
  const found = {};

  const visit = (node, depth) => {
    if (depth > 4 || node === null || typeof node !== 'object') return;

    for (const [key, value] of Object.entries(node)) {
      const currency = CURRENCY_ALIASES[key.toUpperCase()];
      if (currency && typeof value === 'number' && Number.isFinite(value)) {
        // Se guarda en centavos de CUP por unidad, como enteros: la app hace
        // toda la aritmética de dinero con enteros para no acumular errores de
        // céntimos.
        found[currency] = Math.round(value * 100);
      } else {
        visit(value, depth + 1);
      }
    }
  };

  visit(raw, 0);
  return found;
}

function extractDate(raw) {
  const candidate =
    raw?.date ?? raw?.fecha ?? raw?.tasas?.date ?? raw?.data?.date;

  if (typeof candidate === 'string') {
    const parsed = new Date(candidate.replace(' ', 'T'));
    if (!Number.isNaN(parsed.getTime())) {
      return parsed.toISOString().slice(0, 10);
    }
  }

  return new Date().toISOString().slice(0, 10);
}
