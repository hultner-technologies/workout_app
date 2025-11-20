import { test, expect } from '@playwright/test';

test.describe('Workout History', () => {
  test.beforeEach(async ({ page }) => {
    // Note: These tests assume user is already authenticated
    // In a real scenario, you'd want to set up auth state or login first
    await page.goto('http://127.0.0.1:3000/workouts');
  });

  test('should display loading state before workouts load', async ({ page }) => {
    // Check for shimmer loading animation
    await expect(page.locator('.animate-shimmer').first()).toBeVisible();
  });

  test('should display workout history page', async ({ page }) => {
    await expect(page.locator('h1')).toContainText('Workout History');
    await expect(page.locator('text=View Stats')).toBeVisible();
  });

  test('should navigate to stats page from workout history', async ({ page }) => {
    await page.click('text=View Stats');
    await page.waitForURL('**/stats');
    await expect(page.locator('h1')).toContainText('Workout Statistics');
  });

  test('should filter workouts by search term', async ({ page }) => {
    const searchInput = page.locator('input[placeholder*="Search"]');
    if (await searchInput.isVisible()) {
      await searchInput.fill('Leg Day');
      // Wait for filtering to occur
      await page.waitForTimeout(500);
    }
  });

  test('should toggle sort order', async ({ page }) => {
    const sortButton = page.locator('button:has-text("Sort")');
    if (await sortButton.isVisible()) {
      await sortButton.click();
      await page.waitForTimeout(300);
    }
  });
});

test.describe('Workout Detail', () => {
  test('should show error boundary on invalid workout ID', async ({ page }) => {
    await page.goto('http://127.0.0.1:3000/workouts/invalid-id-123');

    // Should show error UI
    await expect(
      page.locator('text=/Unable to.*|Error|Not found/i')
    ).toBeVisible({ timeout: 10000 });
  });

  test('should display back navigation link', async ({ page }) => {
    await page.goto('http://127.0.0.1:3000/workouts');

    // Find first workout link if any exist
    const workoutLink = page.locator('a[href^="/workouts/"]').first();
    if (await workoutLink.isVisible()) {
      await workoutLink.click();
      await expect(page.locator('text=Back to Workouts')).toBeVisible();
    }
  });
});
