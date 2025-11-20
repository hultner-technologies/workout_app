# E2E Tests

This directory contains end-to-end tests for the GymR8 web application using Playwright.

## Test Coverage

### Navigation Tests (`navigation.spec.ts`)
- Landing page rendering
- Client-side navigation with Next.js Link
- Authentication redirects
- Dark mode support

### Workout Tests (`workouts.spec.ts`)
- Workout history display
- Loading states with shimmer animations
- Navigation to stats page
- Filtering and sorting functionality
- Workout detail pages
- Error boundaries

### Statistics Tests (`stats.spec.ts`)
- Stats dashboard display
- Time range filtering (YTD, 1Y, 3Y, 5Y, All Time)
- Loading states
- Error handling and recovery
- Accessibility (ARIA attributes)

### Password Reset Tests (`password-reset.spec.ts`)
- Complete password reset flow
- Email verification
- Token validation

## Running Tests

### Prerequisites
- Development server running (`npm run dev`)
- Supabase local instance running (for password reset tests)

### Commands

```bash
# Run all tests
npm test

# Run tests with visible browser
npm run test:headed

# Run tests with UI mode (interactive)
npm run test:ui

# View test report
npm run test:report
```

### Running Individual Test Files

```bash
# Run navigation tests only
npx playwright test navigation

# Run workout tests only
npx playwright test workouts

# Run stats tests only
npx playwright test stats
```

## Test Philosophy

These E2E tests focus on:

1. **Critical User Flows**: Testing the most important user journeys
2. **Error Resilience**: Verifying error boundaries and recovery
3. **Accessibility**: Checking ARIA attributes and semantic HTML
4. **Loading States**: Ensuring smooth UX during data fetching
5. **Dark Mode**: Verifying theme support

## Notes

- Tests run sequentially to avoid race conditions
- Authentication state is mocked/bypassed for most tests
- Password reset tests require Docker and Supabase
- Screenshots are captured on failure for debugging
