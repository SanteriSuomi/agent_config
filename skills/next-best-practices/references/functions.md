# Functions

Next.js function APIs.

Reference: https://nextjs.org/docs/app/api-reference/functions

## Navigation Hooks (Client)

| Hook | Purpose |
|------|---------|
| `useRouter` | Programmatic navigation (`push`, `replace`, `back`, `refresh`) |
| `usePathname` | Get current pathname |
| `useSearchParams` | Read URL search parameters |
| `useParams` | Access dynamic route parameters |
| `useSelectedLayoutSegment` | Active child segment (one level) |
| `useSelectedLayoutSegments` | All active segments below layout |

## Server Functions

| Function | Purpose |
|----------|---------|
| `cookies` | Read/write cookies |
| `headers` | Read request headers |
| `draftMode` | Enable preview of unpublished CMS content |
| `after` | Run code after response finishes streaming |
| `connection` | Wait for connection before dynamic rendering |

## Generate Functions

| Function | Purpose |
|----------|---------|
| `generateStaticParams` | Pre-render dynamic routes at build time |
| `generateMetadata` | Dynamic metadata |
| `generateViewport` | Dynamic viewport config |
| `generateSitemaps` | Multiple sitemaps for large sites |

## Common Examples

### Navigation

Use `next/link` for internal navigation instead of `<a>` tags.

```tsx
// Bad: Plain anchor tag
<a href="/about">About</a>

// Good: Next.js Link
import Link from 'next/link'

<Link href="/about">About</Link>
```

Active link styling:

```tsx
'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'

export function NavLink({ href, children }) {
  const pathname = usePathname()

  return (
    <Link href={href} className={pathname === href ? 'active' : ''}>
      {children}
    </Link>
  )
}
```

### Static Generation

```tsx
// app/blog/[slug]/page.tsx
export async function generateStaticParams() {
  const posts = await getPosts()
  return posts.map((post) => ({ slug: post.slug }))
}
```

### After Response

```tsx
import { after } from 'next/server'

export async function POST(request: Request) {
  const data = await processRequest(request)

  after(async () => {
    await logAnalytics(data)
  })

  return Response.json({ success: true })
}
```
