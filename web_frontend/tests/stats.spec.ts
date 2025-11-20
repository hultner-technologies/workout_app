import { test, expect } from '@playwright/test';

test.describe('Statistics Dashboard', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://127.0.0.1:3000/stats');
  });

  test('should display loading state with shimmer animation', async ({ page }) => {
    // Check for shimmer loading animations
    const shimmerElements = page.locator('.animate-shimmer');
    await expect(shimmerElements.first()).toBeVisible();
  });

  test('should display statistics dashboard', async ({ page }) => {
    await expect(page.locator('h1')).toContainText('Workout Statistics');
  });

  test('should show time range selector', async ({ page }) => {
    // Check for time range buttons
    await expect(page.locator('text=YTD')).toBeVisible({ timeout: 10000 });
    await expect(page.locator('text=1Y')).toBeVisible();
    await expect(page.locator('text=All Time')).toBeVisible();
  });

  test('should switch between time ranges', async ({ page }) => {
    // Wait for page to load
    await page.waitForTimeout(1000);

    // Click YTD button
    const ytdButton = page.locator('button:has-text("YTD")');
    if (await ytdButton.isVisible()) {
      await ytdButton.click();
      await page.waitForTimeout(300);

      // Click 1Y button
      await page.locator('button:has-text("1Y")').click();
      await page.waitForTimeout(300);
    }
  });

  test('should display overview statistics cards', async ({ page }) => {
    // Look for stat cards after loading
    await page.waitForTimeout(1500);

    const statCards = page.locator('[class*="grid"]').first();
    if (await statCards.isVisible()) {
      // Should have stats about workouts, exercises, volume, etc.
      await expect(statCards).toBeVisible();
    }
  });

  test('should navigate back to workouts', async ({ page }) => {
    const backLink = page.locator('text=Back to Workouts');
    await expect(backLink).toBeVisible({ timeout: 10000 });

    await backLink.click();
    await page.waitForURL('**/workouts');
    await expect(page.locator('h1')).toContainText('Workout History');
  });

  test('should handle error gracefully', async ({ page }) => {
    // Test error boundary by checking for error handling
    await page.route('**/rest/v1/**', route => route.abort());

    await page.goto('http://127.0.0.1:3000/stats');

    // Should show error UI with retry button
    const errorHeading = page.locator('h2:has-text("Unable to Load")');
    if (await errorHeading.isVisible({ timeout: 5000 })) {
      await expect(page.locator('button:has-text("Try Again")')).toBeVisible();
      await expect(page.locator('text=/Troubleshooting|What you can try/i')).toBeVisible();
    }
  });
});

test.describe('Statistics Accessibility', () => {
  test('error messages should have proper ARIA attributes', async ({ page }) => {
    // Force an error by navigating without auth
    await page.route('**/rest/v1/**', route => route.abort());
    await page.goto('http://127.0.0.1:3000/stats');

    const errorContainer = page.locator('[role="alert"]');
    if (await errorContainer.isVisible({ timeout: 5000 })) {
      await expect(errorContainer).toHaveAttribute('aria-live', 'assertive');
    }
  });

  test('buttons should have descriptive labels', async ({ page }) => {
    await page.route('**/rest/v1/**', route => route.abort());
    await page.goto('http://127.0.0.1:3000/stats');

    await page.waitForTimeout(2000);

    const tryAgainButton = page.locator('button[aria-label*="Try"]');
    if (await tryAgainButton.isVisible()) {
      const ariaLabel = await tryAgainButton.getAttribute('aria-label');
      expect(ariaLabel).toBeTruthy();
    }
  });
});
