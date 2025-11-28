---
applyTo: frontend/**/*
---

# Frontend Instructions

Quirky, offbeat React 18 + Vite interface for underground travel planning. Chat interface, Debug View, and transparent troubleshooting.

## Language & Syntax

ES2020+ with ES6 syntax. TypeScript is present and fine to maintain, but prefer duck typing. Keep type annotations minimal.

## Tech Stack

- React 18, Vite, Tailwind CSS, Node 24+.
- Source: `frontend/src/` (App.tsx, main.tsx, components/*.tsx)

## Security

### Application

- Never expose API keys or secrets in frontend code
- Sanitize all user inputs before rendering
- Use environment variables via `VITE_` prefix
- Validate external data sources
- CSP headers and HTTPS-only in production

### User Privacy

- **Zero logging** of user queries, locations, or personal data
- **Zero storage** beyond session memory
- **Zero tracking** without explicit consent
- All geolocation data is ephemeral
- No third-party tracking by default

### Data Handling

- Keep user interactions in-memory only
- Clear sensitive data on unmount
- Never persist location data to localStorage without consent
- Redact API keys from debug panels

## Design Philosophy

Follow KISS, YAGNI, and maintain modularity. One component, one responsibility. Build what's needed, not what might be needed. Keep coupling loose, cohesion high.

## Code Standards

```javascript
// Imports: external first, internal second
import { useState } from 'react';
import { CustomHook } from '../hooks/useCustom';

export function Component({ prop1, prop2 }) {
  const [state, setState] = useState();
  const handleEvent = () => {};
  return <div />;
}
```

### Naming

- Components: PascalCase
- Hooks: camelCase with `use` prefix
- Utils/Services: camelCase
- Constants: `UPPER_SNAKE_CASE`

### Linting & Formatting

- ESLint and Prettier enforced via lefthook pre-commit hooks.
- All code/markdown must pass before commit.

## Testing

Test value, not lines. Focus on critical paths and user interactions, not implementation details.

### Coverage Targets

- Critical features (auth, payment, data submission): 90%+
- User flows (navigation, forms, interactions): 80%+
- UI components (rendering, props, states): 60%+
- Utils/Services (business logic): 80%+

### Unit Testing

- Vitest + React Testing Library + jsdom.
- Tests: `frontend/test/unit/` (unit), `frontend/test/integration/` (integration)
- Coverage: lines/statements/functions ≥85%, branches ≥80% (enforced in CI).
- Run: `npm run test` (runs unit tests with coverage).
- UI: `npm run test:ui`.
- Coverage prints to console by default.

### End-to-End Testing

- Playwright (Chromium).
- Tests: `frontend/test/e2e/`
- Config: `frontend/playwright.config.ts` (builds and serves dist, uses 127.0.0.1:5173).
- Reporter: list + HTML (auto-opens on failure locally).
- Trace/video/screenshots on failure.
- Run: `npm run test:e2e` (headless), `npx playwright test --headed` (headed), `npx playwright test --ui` (UI runner).

### E2E Test Environment

- Playwright builds frontend and serves via static server.
- CI workflow passes VITE_GOOGLE_MAPS_API_KEY and VITE_API_BASE as environment variables.
- Tests do not require real Google Maps API key or backend.

## Dependencies

Before adding:

1. Solvable with existing dependencies?
2. Value vs. code size?
3. Actively maintained (commits in last 6 months)?
4. Known vulnerabilities?
5. Can we write it in under 100 lines?

Justify all additions.

## Performance

- Bundle under 200KB (gzipped)
- Initial load under 2s (3G)
- Interactive in under 3s
- Lighthouse score above 90

Lazy load, debounce, cache, batch. Memo only when profiled.

## Accessibility

- Keyboard navigable
- ARIA labels on custom controls
- WCAG AA contrast ratios
- Visible focus indicators
- Screen reader tested
- Respect motion preferences

## Code Changes

- Must be reviewed in playwright before commit
- Ensure unit tests exist with adequate coverage that makes sense
- Avoid coding tests just to add numbers
- Document a ../docs/user_guide with screenshots using the playwright MCP
- Review these screenshots to make sure they are accurate and clear
- If anything looks off, then you should fix it first and then update
- It is not enough to simply lazy load the default home page. You need to send messages, click map controls, look at debug info, switch the view, and verify all interactive elements function correctly.

## Code Review

- [ ] No secrets exposed
- [ ] No user data logged/stored
- [ ] Security addressed
- [ ] Accessibility met
- [ ] Tests add value
- [ ] Dependencies justified
- [ ] Performance measured
- [ ] KISS/YAGNI followed

## Anti-Patterns

- Storing user data without consent
- Logging sensitive information
- Premature optimization
- Testing implementation details
- Over-engineering
- Unnecessary dependencies
- Breaking accessibility for aesthetics

## CI/CD

- Workflows: `.github/workflows/build-and-test.yml` (frontend), `.github/workflows/python-backend.yml` (backend).
- Node 24+, npm ci, format, lint, typecheck, unit tests (coverage upload), Playwright e2e, Playwright report artifact.

## Local Dev Quick Reference

```bash
# Install all deps (repo root)
npm install

# Run unit/integration tests with coverage (frontend)
cd frontend
npm run test

# Run e2e tests (frontend)
npx playwright install --with-deps chromium
npm run test:e2e

# Run e2e tests with test env (uses .env.test):
# Option 1: Pass env vars
VITE_GOOGLE_MAPS_API_KEY=test-key-placeholder VITE_API_BASE=http://localhost:8000 npm run test:e2e

# Interactive test runners
npm run test:ui
npx playwright test --ui
```

## Conventions

- All new code must pass lint, format, spell, and test coverage gates.
- Use Conventional Commits for all commit messages.
- If you change Vite base, update Playwright config baseURL.
- For more e2e coverage, add tests to `frontend/tests-e2e/` and mock backend as needed.
