# TypeScript / React modernization (2025-26)

## React

| Modern (React 19+) | Outdated |
|---|---|
| `use(promise)` for unwrapping in components | `await` in render (impossible) or `useEffect` setState dance |
| Server Components in Next.js / Remix where appropriate | "client everything" |
| `useTransition` for non-urgent updates | sync setState that blocks render |
| `useSyncExternalStore` for external state subscriptions | `useEffect` + setState |
| Suspense for async boundaries | manual `if (loading) return <Spinner/>` everywhere |
| `<form action={fn}>` server actions (Next.js / Remix) | manual fetch + onSubmit |
| `useOptimistic` for optimistic UI | manual rollback dance |

## State management

| Modern | Outdated |
|---|---|
| TanStack Query / SWR for server state | `useEffect` + `useState` for fetched data |
| Zustand / Jotai for client state | Redux + Redux Toolkit (overkill for most) |
| `useReducer` for component-local complex state | many `useState` + manual sync |
| URL state via `URLSearchParams` / TanStack Router | client-only state for shareable views |

## Validation

| Modern | Outdated |
|---|---|
| Zod or Valibot at boundaries | `as Type` casts, no runtime check |
| `z.infer<typeof Schema>` for type sync | duplicated TS types + JSON schema |
| Server actions validated via Zod | trust client input |

## TypeScript itself

| Modern | Outdated |
|---|---|
| `satisfies` operator for "does X conform but keep narrow type" | `as Type` (loses inference) |
| `const Type = { a: 1 } as const satisfies Foo` | `const Type: Foo = { a: 1 }` |
| Discriminated unions with literal types | union of optional fields |
| `unknown` with narrowing | `any` |
| Strict mode + `noUncheckedIndexedAccess` | loose tsconfig |

## Tooling

| Modern | Outdated |
|---|---|
| Vite / Turbopack | webpack (slow) for new projects |
| Vitest | Jest (still fine but Vitest is faster on Vite) |
| pnpm | npm (slow, disk-heavy) for monorepos |
| Biome (lint+format) | ESLint + Prettier (still common, but Biome is rust-fast) |

## Styling

State of CSS-in-JS: dying for new projects. Tailwind dominates. CSS Modules are the safe fallback.

| Modern | Outdated |
|---|---|
| Tailwind v4 (CSS-first config) | styled-components (runtime CSS-in-JS) |
| CSS Modules | global CSS or BEM by hand |
| `@property` for typed custom properties | hardcoded values |
| Container queries | media queries only |
| `:has()` selector | extra wrapper divs |

## Patterns rejected as cargo cult

- **Class components in new code** — gone for years, no reason
- **`useMemo` everywhere** — usually unnecessary; React 19 compiler may handle it; verify with Profiler
- **Redux for everything** — TanStack Query owns server state, Zustand owns small client state
- **`React.FC<Props>`** — typing children explicitly is clearer

## Useful patterns underused

- `useDeferredValue` for "type fast, search slow"
- `<dialog>` element with `showModal()` (no JS modal libraries needed for basic dialogs)
- View Transitions API for cross-page animations
- `flushSync` only when truly needed (rarely)

## Sources

- react.dev official docs
- Next.js docs (app router patterns)
- TanStack Query / Router docs
- TypeScript "What's New" releases
- Tailwind v4 announcement
