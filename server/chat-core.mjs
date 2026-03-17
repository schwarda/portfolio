import crypto from 'node:crypto';

const DEFAULT_SYSTEM_PROMPT =
  'Si hlas majitela tohto portfolia. Odpovedaj vzdy o majitelovi portfolia a v jeho mene v 1. osobe (napr. "mam", "robim"). ' +
  'Nikdy o sebe nehovor ako o AI, asistentovi alebo modeli. Nikdy nepouzivaj metakomenty, interny postup ani uvahy; vrat len finalnu odpoved. ' +
  'Ak udaj nie je v profile (napr. vek), povedz presne: "Tuto informaciu zatial nemam uvedenu v profile." ' +
  'Nikdy netvrd, ze si nieco doplnil, upravil, pridal alebo zmenil v profile. Nikdy sa nepytaj, ci mas nieco doplnit alebo zmenit. ' +
  'Odpovedaj strucne, vecne a po slovensky, pokial si pouzivatel nevyziada iny jazyk.';

function providerConfig(env) {
  const openAiKey = (env.OPENAI_API_KEY ?? '').trim();
  const groqKey = (env.GROQ_API_KEY ?? '').trim();
  const configuredBaseUrl = (env.OPENAI_BASE_URL ?? '').trim();
  const configuredModel = (env.OPENAI_MODEL ?? '').trim();
  const providerHint = (env.AI_PROVIDER ?? 'auto').trim().toLowerCase();
  const baseHint = configuredBaseUrl.toLowerCase();
  const baseSuggestsGroq = baseHint.includes('groq.com');
  const baseSuggestsOpenAi = baseHint.includes('openai.com');

  let provider = 'openai';
  if (providerHint === 'groq') {
    provider = 'groq';
  } else if (providerHint === 'openai') {
    provider = 'openai';
  } else if (baseSuggestsGroq) {
    provider = 'groq';
  } else if (baseSuggestsOpenAi) {
    provider = 'openai';
  } else if (groqKey.length > 0) {
    provider = 'groq';
  }

  const apiKey = provider === 'groq' ? groqKey || openAiKey : openAiKey || groqKey;
  const baseUrl =
    configuredBaseUrl ||
    (provider === 'groq' ? 'https://api.groq.com/openai/v1' : 'https://api.openai.com/v1');
  const model =
    configuredModel ||
    (provider === 'groq' ? 'llama-3.3-70b-versatile' : 'gpt-4.1-mini');
  return { apiKey, baseUrl, model, provider };
}

function buildCorsHeaders(env) {
  return {
    'Access-Control-Allow-Origin': env.CORS_ORIGIN ?? '*',
    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };
}

function jsonResponse(status, body, env, headers = {}) {
  return Response.json(body, {
    status,
    headers: {
      ...buildCorsHeaders(env),
      ...headers,
    },
  });
}

function extractReplyText(responsePayload) {
  if (
    typeof responsePayload.output_text === 'string' &&
    responsePayload.output_text.trim().length > 0
  ) {
    return responsePayload.output_text.trim();
  }

  if (Array.isArray(responsePayload.output)) {
    for (const item of responsePayload.output) {
      if (!item || typeof item !== 'object' || !Array.isArray(item.content)) {
        continue;
      }
      for (const part of item.content) {
        if (part && typeof part.text === 'string' && part.text.trim().length > 0) {
          return part.text.trim();
        }
      }
    }
  }

  return '';
}

function sanitizeReply(reply) {
  const lower = reply.toLowerCase();
  const disallowedPatterns = [
    /chces?\s*,?\s*aby\s*som/,
    /mozem\s+to\s+(doplni|upravi|prida|zmeni)/,
    /\b(doplnil|upravil|pridal|zmenil|nastavil|ulozil)\s+som\b/,
    /\bteraz\s+mam\b.*\bv\s+profile\b/,
    /\bsom\s+(ai|asistent|assistant|model)\b/,
  ];

  if (disallowedPatterns.some((pattern) => pattern.test(lower))) {
    return 'Tuto informaciu zatial nemam uvedenu v profile.';
  }

  return reply;
}

function normalizeMessages(messages) {
  if (!Array.isArray(messages)) {
    return [];
  }

  return messages
    .filter((message) => message && typeof message === 'object')
    .map((message) => {
      const role =
        message.role === 'assistant'
          ? 'assistant'
          : message.role === 'user'
            ? 'user'
            : null;
      const text = typeof message.text === 'string' ? message.text.trim() : '';
      if (!role || text.length === 0) {
        return null;
      }
      return {
        type: 'message',
        role,
        content: [
          {
            type: role === 'user' ? 'input_text' : 'output_text',
            text,
          },
        ],
      };
    })
    .filter(Boolean);
}

async function parseJsonBody(request) {
  const raw = await request.text();
  if (!raw) {
    return {};
  }

  if (raw.length > 1_000_000) {
    throw new Error('Payload is too large.');
  }

  try {
    return JSON.parse(raw);
  } catch {
    throw new Error('Invalid JSON payload.');
  }
}

function parseIntegerEnv(value, fallback) {
  const parsed = Number.parseInt(`${value ?? ''}`, 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

function normalizeHostname(value) {
  return `${value ?? ''}`
    .trim()
    .toLowerCase()
    .replace(/\.$/, '')
    .replace(/:\d+$/, '');
}

function hostnameVariants(hostname) {
  const normalized = normalizeHostname(hostname);
  if (!normalized) {
    return [];
  }

  if (normalized.startsWith('www.')) {
    return [normalized, normalized.slice(4)];
  }

  return [normalized, `www.${normalized}`];
}

function configuredTurnstileHostnames(env) {
  const raw = `${env.TURNSTILE_ALLOWED_HOSTNAMES ?? env.TURNSTILE_ALLOWED_HOSTNAME ?? ''}`.trim();
  if (!raw) {
    return [];
  }

  return raw
    .split(',')
    .map((item) => normalizeHostname(item))
    .filter(Boolean);
}

function isChatUnlockEnforced(env) {
  const explicit = `${env.CHAT_UNLOCK_ENFORCED ?? ''}`.trim().toLowerCase();
  if (explicit) {
    return explicit === 'true';
  }

  return `${env.TURNSTILE_SECRET_KEY ?? ''}`.trim().length > 0;
}

const UNLOCK_COOKIE_NAME = 'portfolio_chat_unlock';

function signingSecret(env) {
  return (
    `${env.CHAT_UNLOCK_SECRET ?? ''}`.trim() ||
    `${env.TURNSTILE_SECRET_KEY ?? ''}`.trim()
  );
}

function signUnlockPayload(payload, env) {
  const secret = signingSecret(env);
  if (!secret) {
    return '';
  }

  return crypto.createHmac('sha256', secret).update(payload).digest('base64url');
}

function createUnlockCookie(env) {
  const maxAge = parseIntegerEnv(env.CHAT_UNLOCK_TTL_SECONDS, 60 * 60 * 12);
  const payload = Buffer.from(
    JSON.stringify({
      exp: Date.now() + maxAge * 1000,
    }),
  ).toString('base64url');
  const signature = signUnlockPayload(payload, env);
  return `${UNLOCK_COOKIE_NAME}=${payload}.${signature}; Max-Age=${maxAge}; Path=/; HttpOnly; SameSite=Lax; Secure`;
}

function parseCookies(request) {
  const cookieHeader = request.headers.get('cookie') ?? '';
  const cookies = {};

  for (const chunk of cookieHeader.split(';')) {
    const [rawKey, ...rawValue] = chunk.split('=');
    const key = rawKey?.trim();
    if (!key) {
      continue;
    }
    cookies[key] = rawValue.join('=').trim();
  }

  return cookies;
}

function hasValidUnlockCookie(request, env) {
  const token = parseCookies(request)[UNLOCK_COOKIE_NAME] ?? '';
  if (!token) {
    return false;
  }

  const [payload, signature] = token.split('.');
  if (!payload || !signature) {
    return false;
  }

  const expectedSignature = signUnlockPayload(payload, env);
  if (!expectedSignature) {
    return false;
  }

  const expectedBuffer = Buffer.from(expectedSignature);
  const providedBuffer = Buffer.from(signature);
  if (expectedBuffer.length !== providedBuffer.length) {
    return false;
  }

  if (!crypto.timingSafeEqual(expectedBuffer, providedBuffer)) {
    return false;
  }

  try {
    const decoded = JSON.parse(
      Buffer.from(payload, 'base64url').toString('utf8'),
    );
    return typeof decoded.exp === 'number' && decoded.exp > Date.now();
  } catch {
    return false;
  }
}

function normalizeHost(host) {
  return `${host ?? ''}`.trim().toLowerCase();
}

function isLocalHost(host) {
  return host === 'localhost' || host === '127.0.0.1';
}

function isLocalRequest(request) {
  const url = new URL(request.url);
  const host = normalizeHost(url.hostname);
  if (isLocalHost(host)) {
    return true;
  }

  const forwardedHostHeader = request.headers.get('x-forwarded-host');
  if (!forwardedHostHeader) {
    return false;
  }

  const forwardedHost = normalizeHost(forwardedHostHeader.split(',')[0]);
  return isLocalHost(forwardedHost);
}

function allowsLocalSecurityBypass(env, request) {
  return isLocalRequest(request) && `${env.ALLOW_INSECURE_LOCALHOST ?? 'true'}` !== 'false';
}

function getClientIp(request) {
  const forwardedFor = request.headers.get('x-forwarded-for');
  if (forwardedFor) {
    return forwardedFor.split(',')[0].trim();
  }

  return (
    request.headers.get('x-real-ip') ??
    request.headers.get('cf-connecting-ip') ??
    'unknown'
  ).trim();
}

async function verifyTurnstileToken({ token, request, env }) {
  const secretKey = `${env.TURNSTILE_SECRET_KEY ?? ''}`.trim();
  if (!secretKey) {
    return {
      ok: false,
      status: 500,
      message:
        'Missing TURNSTILE_SECRET_KEY on server. Configure Cloudflare Turnstile before deploying chat.',
    };
  }

  if (!token) {
    return {
      ok: false,
      status: 400,
      message: 'Chýba bezpečnostný token. Obnov stránku a skús to znova.',
    };
  }

  const payload = new URLSearchParams({
    secret: secretKey,
    response: token,
  });

  const clientIp = getClientIp(request);
  if (clientIp && clientIp !== 'unknown') {
    payload.set('remoteip', clientIp);
  }

  const response = await fetch(
    'https://challenges.cloudflare.com/turnstile/v0/siteverify',
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: payload.toString(),
    },
  );

  let verification = {};
  try {
    verification = await response.json();
  } catch {
    verification = {};
  }

  if (!response.ok) {
    return {
      ok: false,
      status: 502,
      message: 'Nepodarilo sa overiť bezpečnostný token. Skús to prosím znova.',
    };
  }

  if (!verification.success) {
    return {
      ok: false,
      status: 403,
      message: 'Bezpečnostná kontrola zlyhala. Skús to prosím ešte raz.',
    };
  }

  const expectedHostnames = configuredTurnstileHostnames(env);
  if (expectedHostnames.length > 0) {
    const actualHostname = normalizeHostname(verification.hostname);
    if (!actualHostname) {
      return {
        ok: false,
        status: 403,
        message: 'Bezpečnostný token neobsahuje hostname.',
      };
    }

    const allowed = new Set(
      expectedHostnames.flatMap((hostname) => hostnameVariants(hostname)),
    );
    if (!allowed.has(actualHostname)) {
      return {
        ok: false,
        status: 403,
        message: 'Bezpečnostný token nepatrí tejto doméne.',
      };
    }
  }

  return { ok: true };
}

async function runRedisTransaction(env, commands) {
  const restUrl = `${env.UPSTASH_REDIS_REST_URL ?? ''}`.trim();
  const restToken = `${env.UPSTASH_REDIS_REST_TOKEN ?? ''}`.trim();

  if (!restUrl || !restToken) {
    return null;
  }

  const normalizedBase = restUrl.endsWith('/') ? restUrl.slice(0, -1) : restUrl;
  const response = await fetch(`${normalizedBase}/multi-exec`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${restToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(commands),
  });

  if (!response.ok) {
    throw new Error('Upstash Redis rate limit request failed.');
  }

  const payload = await response.json();
  return Array.isArray(payload) ? payload : [];
}

async function incrementBucket(env, key, ttlSeconds) {
  const results = await runRedisTransaction(env, [
    ['INCR', key],
    ['EXPIRE', key, ttlSeconds],
  ]);

  if (!results) {
    return null;
  }

  const count = Number(results[0]?.result ?? 0);
  return Number.isFinite(count) ? count : 0;
}

async function enforceRateLimit(env, request) {
  const clientIp = getClientIp(request);
  const perMinute = parseIntegerEnv(env.RATE_LIMIT_CHAT_PER_MINUTE, 6);
  const perHour = parseIntegerEnv(env.RATE_LIMIT_CHAT_PER_HOUR, 40);
  const now = Date.now();
  const minuteBucket = Math.floor(now / 60_000);
  const hourBucket = Math.floor(now / 3_600_000);
  const identity = clientIp || 'unknown';

  const minuteKey = `chat:rate:${identity}:minute:${minuteBucket}`;
  const minuteCount = await incrementBucket(env, minuteKey, 120);
  if (minuteCount == null) {
    return {
      ok: false,
      status: 500,
      message:
        'Missing Upstash Redis configuration. Set UPSTASH_REDIS_REST_URL and UPSTASH_REDIS_REST_TOKEN.',
    };
  }

  if (minuteCount > perMinute) {
    return {
      ok: false,
      status: 429,
      message: 'Príliš veľa správ za krátky čas. Skús to znovu o chvíľu.',
    };
  }

  const hourKey = `chat:rate:${identity}:hour:${hourBucket}`;
  const hourCount = await incrementBucket(env, hourKey, 7_200);
  if (hourCount == null) {
    return {
      ok: false,
      status: 500,
      message:
        'Missing Upstash Redis configuration. Set UPSTASH_REDIS_REST_URL and UPSTASH_REDIS_REST_TOKEN.',
    };
  }

  if (hourCount > perHour) {
    return {
      ok: false,
      status: 429,
      message: 'Hodinový limit správ pre túto adresu je dočasne vyčerpaný.',
    };
  }

  return { ok: true };
}

export async function handlePortfolioRequest(request, env = process.env) {
  const url = new URL(request.url);
  const localSecurityBypass = allowsLocalSecurityBypass(env, request);
  const chatUnlockEnforced = isChatUnlockEnforced(env);

  if (request.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: buildCorsHeaders(env),
    });
  }

  if (url.pathname === '/health' && request.method === 'GET') {
    const cfg = providerConfig(env);
    return jsonResponse(
      200,
      {
        ok: true,
        provider: cfg.provider,
        hasApiKey: cfg.apiKey.length > 0,
        botProtectionConfigured:
          localSecurityBypass ||
          !chatUnlockEnforced ||
          `${env.TURNSTILE_SECRET_KEY ?? ''}`.trim().length > 0,
        rateLimitConfigured:
          localSecurityBypass ||
          (`${env.UPSTASH_REDIS_REST_URL ?? ''}`.trim().length > 0 &&
            `${env.UPSTASH_REDIS_REST_TOKEN ?? ''}`.trim().length > 0),
        chatUnlocked:
          localSecurityBypass ||
          !chatUnlockEnforced ||
          hasValidUnlockCookie(request, env),
      },
      env,
    );
  }

  if (url.pathname === '/api/chat/unlock' && request.method === 'GET') {
    return jsonResponse(
      200,
      {
        unlocked:
          localSecurityBypass ||
          !chatUnlockEnforced ||
          hasValidUnlockCookie(request, env),
      },
      env,
    );
  }

  if (url.pathname === '/api/chat/unlock' && request.method === 'POST') {
    if (localSecurityBypass || !chatUnlockEnforced) {
      return jsonResponse(200, { unlocked: true }, env);
    }

    try {
      const body = await parseJsonBody(request);
      const turnstileToken =
        typeof body.turnstileToken === 'string' ? body.turnstileToken.trim() : '';

      const turnstileResult = await verifyTurnstileToken({
        token: turnstileToken,
        request,
        env,
      });
      if (!turnstileResult.ok) {
        return jsonResponse(
          turnstileResult.status,
          { error: turnstileResult.message },
          env,
        );
      }

      return jsonResponse(
        200,
        { unlocked: true },
        env,
        {
          'Set-Cookie': createUnlockCookie(env),
        },
      );
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Unexpected server error.';
      return jsonResponse(500, { error: message }, env);
    }
  }

  if (url.pathname !== '/api/chat' || request.method !== 'POST') {
    return jsonResponse(404, { error: 'Not found.' }, env);
  }

  const cfg = providerConfig(env);
  if (!cfg.apiKey) {
    return jsonResponse(
      500,
      {
        error: 'Missing API key on server. Set GROQ_API_KEY or OPENAI_API_KEY.',
      },
      env,
    );
  }

  try {
    const body = await parseJsonBody(request);
    const input = normalizeMessages(body.messages);
    const profileContext =
      typeof body.profileContext === 'string' ? body.profileContext.trim() : '';

    if (input.length === 0) {
      return jsonResponse(
        400,
        {
          error:
            'messages must contain at least one valid user or assistant message.',
        },
        env,
      );
    }

    if (!localSecurityBypass) {
      if (chatUnlockEnforced && !hasValidUnlockCookie(request, env)) {
        return jsonResponse(
          403,
          {
            error:
              'Chat je zamknutý. Najprv dokonči bezpečnostné overenie.',
          },
          env,
        );
      }

      const rateLimitResult = await enforceRateLimit(env, request);
      if (!rateLimitResult.ok) {
        return jsonResponse(
          rateLimitResult.status,
          { error: rateLimitResult.message },
          env,
        );
      }
    }

    const systemPromptBase = env.SYSTEM_PROMPT || DEFAULT_SYSTEM_PROMPT;
    const systemPrompt =
      profileContext.length > 0
        ? `${systemPromptBase}\n\nKONTEXT O MAJITELOVI:\n${profileContext}`
        : systemPromptBase;

    const normalizedBase = cfg.baseUrl.endsWith('/')
      ? cfg.baseUrl.slice(0, -1)
      : cfg.baseUrl;

    const upstreamResponse = await fetch(`${normalizedBase}/responses`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${cfg.apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: cfg.model,
        instructions: systemPrompt,
        input,
        max_output_tokens: 280,
        temperature: 0.7,
      }),
    });

    const rawText = await upstreamResponse.text();
    let upstreamPayload = {};
    try {
      upstreamPayload = JSON.parse(rawText);
    } catch {
      upstreamPayload = {};
    }

    if (!upstreamResponse.ok) {
      const message =
        (upstreamPayload &&
          typeof upstreamPayload === 'object' &&
          upstreamPayload.error &&
          typeof upstreamPayload.error.message === 'string' &&
          upstreamPayload.error.message) ||
        `Upstream provider error (${upstreamResponse.status}).`;
      return jsonResponse(upstreamResponse.status, { error: message }, env);
    }

    const reply = extractReplyText(upstreamPayload);
    if (!reply) {
      return jsonResponse(
        502,
        { error: 'Provider returned no text response.' },
        env,
      );
    }

    return jsonResponse(200, { reply: sanitizeReply(reply) }, env);
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'Unexpected server error.';
    return jsonResponse(500, { error: message }, env);
  }
}
