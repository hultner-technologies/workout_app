import { test as setup } from '@playwright/test';

const authFile = 'tests/.auth/user.json';

/**
 * Authentication setup for E2E tests
 *
 * This runs once before all tests to create an authenticated session.
 * The session is saved and reused by all tests.
 *
 * NOTE: For this to work, you need:
 * 1. A test user account created in Supabase
 * 2. Email confirmation disabled for the test user OR email confirmed
 * 3. Set these environment variables:
 *    - TEST_USER_EMAIL
 *    - TEST_USER_PASSWORD
 */
setup('authenticate', async ({ page }) => {
  const testEmail = process.env.TEST_USER_EMAIL || 'test@example.com';
  const testPassword = process.env.TEST_USER_PASSWORD || 'TestPassword123!';

  // Go to login page
  await page.goto('/login');

  // Fill in credentials
  await page.fill('[data-testid="email-input"]', testEmail);
  await page.fill('[data-testid="password-input"]', testPassword);

  // Click login button
  await page.click('[data-testid="login-button"]');

  // Wait for redirect to profile or workouts page
  await page.waitForURL(/\/(profile|workouts)/);

  // Save authentication state
  await page.context().storageState({ path: authFile });
});
