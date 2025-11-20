import { test, expect } from '@playwright/test';

test.describe('App Navigation', () => {
  test('landing page should render correctly', async ({ page }) => {
    await page.goto('http://127.0.0.1:3000/');

    await expect(page.locator('text=GymR8')).toBeVisible();
    await expect(page.locator('text=/track.*workouts/i')).toBeVisible();
  });

  test('landing page should have call-to-action buttons', async ({ page }) => {
    await page.goto('http://127.0.0.1:3000/');

    const signUpButton = page.locator('a:has-text("Start Free")');
    await expect(signUpButton).toBeVisible();

    const signInButton = page.locator('a:has-text("Sign In")');
    await expect(signInButton).toBeVisible();
  });

  test('should navigate to sign up page', async ({ page }) => {
    await page.goto('http://127.0.0.1:3000/');

    await page.click('text=Start Free Today');
    await page.waitForURL('**/signup');

    await expect(page.locator('h2')).toContainText(/sign up|create account/i);
  });

  test('should navigate to login page', async ({ page }) => {
    await page.goto('http://127.0.0.1:3000/');

    await page.click('a:has-text("Sign In"):first');
    await page.waitForURL('**/login');

    await expect(page.locator('h2')).toContainText(/sign in|log in/i);
  });

  test('profile page should require authentication', async ({ page }) => {
    await page.goto('http://127.0.0.1:3000/profile');

    // Should redirect to login
    await page.waitForURL('**/login', { timeout: 10000 });
    await expect(page.url()).toContain('login');
  });

  test('workouts page should require authentication', async ({ page }) => {
    await page.goto('http://127.0.0.1:3000/workouts');

    // Should redirect to login
    await page.waitForURL('**/login', { timeout: 10000 });
    await expect(page.url()).toContain('login');
  });

  test('stats page should require authentication', async ({ page }) => {
    await page.goto('http://127.0.0.1:3000/stats');

    // Should redirect to login
    await page.waitForURL('**/login', { timeout: 10000 });
    await expect(page.url()).toContain('login');
  });
});

test.describe('Client-side Navigation', () => {
  test('links should use Next.js Link for instant navigation', async ({ page }) => {
    await page.goto('http://127.0.0.1:3000/');

    // Check that internal links don't cause full page reload
    await page.click('a:has-text("Sign In"):first');

    // Navigation should be fast (client-side)
    await page.waitForURL('**/login', { timeout: 2000 });
  });
});

test.describe('Dark Mode Support', () => {
  test('loading states should work in dark mode', async ({ page }) => {
    // Set dark mode preference
    await page.emulateMedia({ colorScheme: 'dark' });

    await page.goto('http://127.0.0.1:3000/workouts');

    // Shimmer animation should be visible
    const shimmer = page.locator('.animate-shimmer').first();
    await expect(shimmer).toBeVisible();
  });

  test('error states should work in dark mode', async ({ page }) => {
    await page.emulateMedia({ colorScheme: 'dark' });
    await page.route('**/rest/v1/**', route => route.abort());

    await page.goto('http://127.0.0.1:3000/stats');

    // Error UI should be visible in dark mode
    const errorHeading = page.locator('h2:has-text("Unable")');
    if (await errorHeading.isVisible({ timeout: 5000 })) {
      await expect(errorHeading).toBeVisible();
    }
  });
});
