# E2E Test Suite Documentation

## Overview

This directory contains Playwright E2E tests for the workout app's web frontend.

**Test Coverage:**
- Authentication flows (login, signup, password reset)
- Workout history (list, filtering, sorting, detail views)
- Statistics dashboard
- Navigation between pages

## Running Tests

### Run all tests
```bash
npx playwright test
```

### Run specific test file
```bash
npx playwright test tests/workouts.spec.ts
```

### Run in headed mode (see browser)
```bash
npx playwright test --headed
```

### Run with UI mode (interactive debugging)
```bash
npx playwright test --ui
```

## Test Patterns

### Authentication Setup
Tests requiring authentication use the `auth.setup.ts` fixture which:
1. Logs in as test user
2. Saves authenticated state to `.auth/user.json`
3. Reuses state across tests for speed

### Data-Dependent Tests
Some tests require workout data to exist. These use `test.skip()`:

```typescript
const hasData = await element.isVisible().catch(() => false);
test.skip(!hasData, 'Requires workout data');
```

This is Playwright best practice - test is marked as skipped rather than silently passing.

### Selectors
All selectors use `data-testid` attributes for stability:

```typescript
// Good
page.getByTestId('workout-list')

// Avoid
page.locator('.workout-list')
```

### Assertions
Always use deterministic waits, never arbitrary timeouts:

```typescript
// Good
await expect(element).toBeVisible()

// Bad
await page.waitForTimeout(2000)
```

## Test Files

### auth.setup.ts
Authentication fixture for tests requiring login.

### navigation.spec.ts
Tests for navigation between pages, menu functionality.

### password-reset.spec.ts
- Password reset request flow
- Update password form validation
- Email format validation
- Password matching validation
- Empty form submission validation
- Error message display capability

### workouts.spec.ts
- Workout list display
- Search/filter functionality
- Sort order toggle
- Navigation to workout details
- Empty state handling
- Mutually exclusive state validation (XOR)

### stats.spec.ts
- Statistics dashboard display
- Chart rendering
- Time range filtering
- Personal records display

## Code Quality

### ESLint
```bash
npm run lint
```

### TypeScript
```bash
npx tsc --noEmit
```

## Best Practices

1. **Test UI behavior, not implementation details**
2. **Use data-testid for selectors**
3. **Avoid arbitrary timeouts**
4. **Use test.skip() for data-dependent tests**
5. **Write deterministic tests that can't flake**
6. **Keep tests focused - one behavior per test**
7. **Use descriptive test names**
8. **Use XOR logic for mutually exclusive states**
9. **Verify error display mechanisms exist**

## Troubleshooting

### Tests fail locally but pass in CI
- Check that Supabase local instance is running
- Verify test database has seed data
- Check environment variables

### Flaky tests
- Remove any `waitForTimeout()` calls
- Use `expect().toBeVisible()` instead
- Check for race conditions in component rendering

### Tests skip unexpectedly
- Some tests require workout data to exist
- Check test.skip() messages for requirements
- Seed test database if needed
