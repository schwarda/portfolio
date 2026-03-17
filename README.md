# about_me_portfolio

Flutter "About me" portfolio page with an AI chat panel running through a backend proxy.

## 1) Start backend proxy

Set your API key only on the server side.

```bash
export GROQ_API_KEY='gsk_...'
export AI_PROVIDER='groq'
npm --prefix server start
```

Optional provider settings:
```bash
export OPENAI_API_KEY='sk-...'
export OPENAI_BASE_URL='https://api.openai.com/v1'
export OPENAI_MODEL='gpt-4.1-mini'
```

Optional local bot-protection bypass control:
```bash
export ALLOW_INSECURE_LOCALHOST='true'
```

Defaults when only `GROQ_API_KEY` is set:
- base URL: `https://api.groq.com/openai/v1`
- model: `llama-3.3-70b-versatile`

Tip: ak máš v shelli aj `OPENAI_API_KEY`, ponechaj `AI_PROVIDER=groq`, aby proxy nepoužila OpenAI.

## 2) Start Flutter web app

```bash
flutter pub get
flutter run -d chrome --web-port 7357
```

Frontend default chat endpoint:
- lokálne na `localhost`: `http://127.0.0.1:8787/api/chat`
- na nasadenom webe bez `CHAT_API_URL`: relatívne `/api/chat`

If your backend runs elsewhere:
```bash
flutter run -d chrome --dart-define=CHAT_API_URL=http://127.0.0.1:8787/api/chat
```

## Local proxy files

- [server/index.mjs](/Users/lopkart/Documents/portfolio/server/index.mjs)
- [server/.env.example](/Users/lopkart/Documents/portfolio/server/.env.example)

Health check:
```bash
curl http://127.0.0.1:8787/health
```

## Deploy on Vercel

This repo is prepared for a single-domain Vercel deploy:
- Flutter web is built to `build/web`
- Vercel serves serverless functions from `api/chat.mjs`, `api/chat/unlock.mjs`, and `api/health.mjs`
- On production, frontend calls relative `/api/chat`, so do not set `CHAT_API_URL` for same-domain deploys
- Chat on production requires one-time Cloudflare Turnstile unlock plus Upstash Redis rate limiting before the model call

Required Vercel environment variables:
```bash
TURNSTILE_SITE_KEY=0x4AAAA...
TURNSTILE_SECRET_KEY=0x4AAAA...
UPSTASH_REDIS_REST_URL=https://...
UPSTASH_REDIS_REST_TOKEN=...
GROQ_API_KEY=gsk_...
AI_PROVIDER=groq
```

Optional Vercel environment variables:
```bash
TURNSTILE_ALLOWED_HOSTNAME=your-domain.com
CHAT_UNLOCK_SECRET=replace-with-random-secret
CHAT_UNLOCK_TTL_SECONDS=43200
RATE_LIMIT_CHAT_PER_MINUTE=6
RATE_LIMIT_CHAT_PER_HOUR=40
OPENAI_API_KEY=sk-...
OPENAI_BASE_URL=https://api.openai.com/v1
OPENAI_MODEL=gpt-4.1-mini
SYSTEM_PROMPT=...
FLUTTER_VERSION=3.29.2
```

Vercel config lives in [vercel.json](/Users/lopkart/Documents/portfolio/vercel.json) and the build script in [scripts/vercel-build.sh](/Users/lopkart/Documents/portfolio/scripts/vercel-build.sh).

Recommended dashboard step after deploy:
- enable Vercel Firewall Bot Protection in challenge mode for the site

## Notes

- Client no longer needs API key.
- In production, keep keys only in server environment variables.
- Turnstile runs once per browser session and unlocks chat through a signed cookie set by `/api/chat/unlock`.
- Interny AI kontext o majitelovi portfolia sa sklada v [lib/main.dart](/Users/lopkart/Documents/portfolio/lib/main.dart) cez `internalProfileNotes` a neposiela sa do UI, iba do chat promptu.
