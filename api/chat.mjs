import { handleVercelRoute } from '../server/vercel-route.mjs';

export default async function handler(req, res) {
  return handleVercelRoute(req, res, '/api/chat');
}
