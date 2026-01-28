# Self-Hosting Next.js

Deploy Next.js applications outside Vercel's platform.

## Standalone Output

Use `output: 'standalone'` in `next.config.js` to create a minimal production folder with only necessary dependencies.

```js
// next.config.js
module.exports = {
  output: 'standalone',
}
```

## Docker

Multi-stage Dockerfile for Next.js:

```dockerfile
FROM node:20-alpine AS base

FROM base AS deps
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
```

## Critical: Multi-Instance ISR

ISR (Incremental Static Regeneration) uses filesystem caching by default. **This breaks with multiple instances** because each instance maintains separate local caches, causing inconsistent content.

### Solution: Custom Cache Handler

Next.js 14+ supports pluggable cache handlers.

```js
// next.config.js
module.exports = {
  cacheHandler: require.resolve('./cache-handler.js'),
  cacheMaxMemorySize: 0, // Disable in-memory cache
}
```

Example Redis cache handler:

```js
// cache-handler.js
const Redis = require('ioredis')
const redis = new Redis(process.env.REDIS_URL)

module.exports = class CacheHandler {
  constructor(options) {
    this.options = options
  }

  async get(key) {
    const data = await redis.get(key)
    return data ? JSON.parse(data) : null
  }

  async set(key, data, ctx) {
    const ttl = ctx.revalidate || 60
    await redis.set(key, JSON.stringify(data), 'EX', ttl)
  }

  async revalidateTag(tag) {
    // Implement tag-based invalidation
  }
}
```

## Image Optimization

Built-in optimization works but is CPU-intensive. For scaled deployments, use external loaders:

```js
// next.config.js
module.exports = {
  images: {
    loader: 'custom',
    loaderFile: './image-loader.js',
  },
}
```

```js
// image-loader.js
export default function cloudinaryLoader({ src, width, quality }) {
  return `https://res.cloudinary.com/demo/image/upload/w_${width},q_${quality || 75}/${src}`
}
```

## Pre-Deployment Checklist

- Test standalone build locally: `node .next/standalone/server.js`
- Set `HOSTNAME="0.0.0.0"` for containers
- Configure custom cache handler for multi-instance deployments
- Add health check endpoint for load balancers
- Set proper environment variables
