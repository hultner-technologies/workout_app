import { test, expect } from '@playwright/test';

test.describe('Landing Page', () => {
  test('should render landing page correctly', async ({ page }) => {
    await page.goto('/');

    // Verify main heading with GymR8 branding
    await expect(page.locator('h1')).toContainText('GymR8');

    // Verify primary CTA buttons are present
    const startFreeButton = page.locator('a:has-text("Start Free Today")');
    await expect(startFreeButton).toBeVisible();
    await expect(startFreeButton).toHaveAttribute('href', '/signup');

    const signInButton = page.locator('a:has-text("Sign In")').first();
    await expect(signInButton).toBeVisible();
    await expect(signInButton).toHaveAttribute('href', '/login');
  });

  test('should navigate to signup page from CTA', async ({ page }) => {
    await page.goto('/');

    await page.click('text=Start Free Today');

    // Wait for navigation and verify URL
    await expect(page).toHaveURL('/signup');

    // Verify we're on the signup page
    await expect(page.locator('h2')).toContainText(/sign up|create.*account/i);
  });

  test('should navigate to login page from CTA', async ({ page }) => {
    await page.goto('/');

    await page.locator('a:has-text("Sign In")').first().click();

    // Wait for navigation and verify URL
    await expect(page).toHaveURL('/login');

    // Verify we're on the login page
    await expect(page.locator('h2')).toContainText(/sign in/i);
  });
});

test.describe('Authentication Redirects', () => {
  test('should redirect to login when accessing protected route without auth', async ({ page, context }) => {
    // Clear any existing auth state
    await context.clearCookies();

    await page.goto('/workouts');

    // Should redirect to login
    await expect(page).toHaveURL(/.*\/login/);
  });

  test('should redirect to login from stats without auth', async ({ page, context }) => {
    await context.clearCookies();

    await page.goto('/stats');

    await expect(page).toHaveURL(/.*\/login/);
  });

  test('should redirect to login from profile without auth', async ({ page, context }) => {
    await context.clearCookies();

    await page.goto('/profile');

    await expect(page).toHaveURL(/.*\/login/);
  });
});

test.describe('Authenticated Navigation', () => {
  test('should access workouts page when authenticated', async ({ page }) => {
    await page.goto('/workouts');

    // Should NOT redirect to login
    await expect(page).toHaveURL('/workouts');

    // Verify page loaded
    await expect(page.locator('h1')).toContainText('Workout History');
  });

  test('should access stats page when authenticated', async ({ page }) => {
    await page.goto('/stats');

    await expect(page).toHaveURL('/stats');
    await expect(page.locator('h1')).toContainText('Workout Statistics');
  });

  test('should access profile page when authenticated', async ({ page }) => {
    await page.goto('/profile');

    await expect(page).toHaveURL('/profile');
    await expect(page.locator('h1')).toContainText('Profile');
  });
});
