# Error Handling

## Error Boundaries

### error.tsx

Catches errors in a route segment and its children. Must be a Client Component.

```tsx
'use client'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={() => reset()}>Try again</button>
    </div>
  )
}
```

### global-error.tsx

Catches errors at the root layout level. Requires `<html>` and `<body>` tags.

```tsx
'use client'

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <html>
      <body>
        <h2>Something went wrong!</h2>
        <button onClick={() => reset()}>Try again</button>
      </body>
    </html>
  )
}
```

## Navigation APIs Throw Special Errors

`redirect()`, `notFound()`, `unauthorized()`, and `forbidden()` throw errors that Next.js uses internally for navigation.

### Critical: Don't Catch Navigation Errors

```tsx
// Bad: Prevents navigation from working
export async function createPost(formData: FormData) {
  try {
    await db.post.create({ data })
    redirect('/posts') // This throws - caught by try/catch!
  } catch (error) {
    // redirect never happens
  }
}

// Good: Call navigation outside try-catch
export async function createPost(formData: FormData) {
  let post
  try {
    post = await db.post.create({ data })
  } catch (error) {
    return { error: 'Failed to create post' }
  }
  redirect(`/posts/${post.id}`) // Outside try-catch
}

// Good: Use unstable_rethrow
import { unstable_rethrow } from 'next/navigation'

export async function createPost(formData: FormData) {
  try {
    await db.post.create({ data })
    redirect('/posts')
  } catch (error) {
    unstable_rethrow(error) // Re-throws navigation errors
    return { error: 'Failed to create post' }
  }
}
```

## Authentication Errors

```tsx
import { unauthorized, forbidden } from 'next/navigation'

export default async function AdminPage() {
  const user = await getUser()

  if (!user) {
    unauthorized() // 401 - renders unauthorized.tsx
  }

  if (user.role !== 'admin') {
    forbidden() // 403 - renders forbidden.tsx
  }

  return <AdminDashboard />
}
```

Create corresponding error pages:

```tsx
// app/unauthorized.tsx
export default function Unauthorized() {
  return <div>Please log in to access this page</div>
}

// app/forbidden.tsx
export default function Forbidden() {
  return <div>You don't have permission to access this page</div>
}
```

## Not Found

```tsx
import { notFound } from 'next/navigation'

export default async function PostPage({ params }) {
  const { id } = await params
  const post = await getPost(id)

  if (!post) {
    notFound() // Renders not-found.tsx
  }

  return <Post post={post} />
}
```

```tsx
// app/not-found.tsx
export default function NotFound() {
  return <div>Page not found</div>
}
```

## Redirects

```tsx
import { redirect, permanentRedirect } from 'next/navigation'

// Temporary redirect (307)
redirect('/new-page')

// Permanent redirect (308)
permanentRedirect('/new-page')
```

## Error Propagation

Errors bubble up to the nearest error boundary:

```
app/
├── layout.tsx
├── error.tsx          # Catches errors from page.tsx and children
├── page.tsx
└── dashboard/
    ├── error.tsx      # Catches errors from dashboard/page.tsx
    └── page.tsx
```

If no `error.tsx` exists in the segment, errors propagate up until they hit `global-error.tsx`.
