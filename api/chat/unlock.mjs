import { handlePortfolioRequest } from '../../server/chat-core.mjs';

export default async function handler(request) {
  const url = new URL(request.url);
  url.pathname = '/api/chat/unlock';

  return handlePortfolioRequest(
    new Request(url, request),
    process.env,
  );
}
