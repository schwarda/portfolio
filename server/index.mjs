import http from 'node:http';

import { handlePortfolioRequest } from './chat-core.mjs';

const PORT = Number.parseInt(process.env.PORT ?? '8787', 10);

async function toNodeResponse(webResponse, res) {
  res.statusCode = webResponse.status;
  webResponse.headers.forEach((value, key) => {
    res.setHeader(key, value);
  });

  const body = await webResponse.text();
  res.end(body);
}

const server = http.createServer(async (req, res) => {
  const requestUrl = new URL(req.url ?? '/', `http://${req.headers.host ?? 'localhost'}`);
  const chunks = [];

  for await (const chunk of req) {
    chunks.push(typeof chunk === 'string' ? Buffer.from(chunk) : chunk);
  }

  const method = req.method ?? 'GET';
  const canHaveBody = method !== 'GET' && method !== 'HEAD';
  const body = canHaveBody ? Buffer.concat(chunks) : undefined;

  const request = new Request(requestUrl, {
    method,
    headers: req.headers,
    body,
  });

  const response = await handlePortfolioRequest(request);
  await toNodeResponse(response, res);
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`[chat-proxy] Listening on http://127.0.0.1:${PORT}`);
});
