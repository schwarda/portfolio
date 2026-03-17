import { handlePortfolioRequest } from './chat-core.mjs';

function headerValue(headers, key, fallback = '') {
  const value = headers?.[key];
  if (Array.isArray(value)) {
    return value[0] ?? fallback;
  }
  return value ?? fallback;
}

async function toWebRequest(req, pathname) {
  const proto = headerValue(req.headers, 'x-forwarded-proto', 'https');
  const host = headerValue(req.headers, 'host', 'localhost');
  const url = new URL(req.url ?? '/', `${proto}://${host}`);
  url.pathname = pathname;

  const method = req.method ?? 'GET';
  const canHaveBody = method !== 'GET' && method !== 'HEAD';
  const chunks = [];

  if (canHaveBody) {
    for await (const chunk of req) {
      chunks.push(typeof chunk === 'string' ? Buffer.from(chunk) : chunk);
    }
  }

  return new Request(url, {
    method,
    headers: req.headers,
    body: canHaveBody ? Buffer.concat(chunks) : undefined,
  });
}

async function sendNodeResponse(response, res) {
  res.statusCode = response.status;
  response.headers.forEach((value, key) => {
    res.setHeader(key, value);
  });

  const body = Buffer.from(await response.arrayBuffer());
  res.end(body);
}

function isNodeRequest(req, res) {
  return (
    !!req &&
    !!res &&
    typeof req.url === 'string' &&
    typeof res.setHeader === 'function' &&
    typeof res.end === 'function'
  );
}

export async function handleVercelRoute(req, res, pathname) {
  if (isNodeRequest(req, res)) {
    const request = await toWebRequest(req, pathname);
    const response = await handlePortfolioRequest(request, process.env);
    await sendNodeResponse(response, res);
    return;
  }

  const url = new URL(req.url);
  url.pathname = pathname;
  return handlePortfolioRequest(
    new Request(url, req),
    process.env,
  );
}
