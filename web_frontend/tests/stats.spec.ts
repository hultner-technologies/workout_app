import { test, expect } from '@playwright/test';

test.describe('Statistics Dashboard Page', () => {
  test('should display statistics dashboard correctly', async ({ page }) => {
    await page.goto('/stats');

    // Verify page heading
    await expect(page.locator('h1')).toContainText('Workout Statistics');

    // Verify back navigation link
    const backLink = page.getByTestId('back-to-workouts-link');
    await expect(backLink).toBeVisible();
    await expect(backLink).toHaveAttribute('href', '/workouts');

    // Verify time range selector is present
    await expect(page.getByTestId('time-range-selector')).toBeVisible();

    // Verify overview stats are displayed
    await expect(page.getByTestId('overview-stats')).toBeVisible();
    await expect(page.getByTestId('total-workouts-card')).toBeVisible();
    await expect(page.getByTestId('total-exercises-card')).toBeVisible();
    await expect(page.getByTestId('total-volume-card')).toBeVisible();
  });

  test('should navigate back to workouts page', async ({ page }) => {
    await page.goto('/stats');

    await page.getByTestId('back-to-workouts-link').click();

    // Wait for navigation and verify URL
    await expect(page).toHaveURL('/workouts');
    await expect(page.locator('h1')).toContainText('Workout History');
  });
});

test.describe('Time Range Filtering', () => {
  test('should display all time range options', async ({ page }) => {
    await page.goto('/stats');

    // Verify all time range buttons are visible
    await expect(page.getByTestId('time-range-ytd')).toBeVisible();
    await expect(page.getByTestId('time-range-1y')).toBeVisible();
    await expect(page.getByTestId('time-range-3y')).toBeVisible();
    await expect(page.getByTestId('time-range-5y')).toBeVisible();
    await expect(page.getByTestId('time-range-all')).toBeVisible();

    // Verify default selection is 1 Year
    const oneYearButton = page.getByTestId('time-range-1y');
    await expect(oneYearButton).toHaveClass(/bg-blue-600/);
  });

  test('should switch between time ranges', async ({ page }) => {
    await page.goto('/stats');

    // Click YTD button
    const ytdButton = page.getByTestId('time-range-ytd');
    await ytdButton.click();

    // Verify YTD is now selected
    await expect(ytdButton).toHaveClass(/bg-blue-600/);

    // Click All Time button
    const allTimeButton = page.getByTestId('time-range-all');
    await allTimeButton.click();

    // Verify All Time is now selected
    await expect(allTimeButton).toHaveClass(/bg-blue-600/);

    // Click 1Y button
    const oneYearButton = page.getByTestId('time-range-1y');
    await oneYearButton.click();

    // Verify 1Y is now selected
    await expect(oneYearButton).toHaveClass(/bg-blue-600/);
  });

  test('should update stats when changing time range', async ({ page }) => {
    await page.goto('/stats');

    // Get initial stats values for 1 Year (default)
    const initialWorkouts = await page.getByTestId('total-workouts-value').textContent();

    // Switch to All Time - should potentially show more data
    await page.getByTestId('time-range-all').click();

    // Get All Time stats values
    const allTimeWorkouts = await page.getByTestId('total-workouts-value').textContent();

    // All Time should have >= stats compared to 1 Year
    const initial = parseInt(initialWorkouts || '0');
    const allTime = parseInt(allTimeWorkouts || '0');
    expect(allTime).toBeGreaterThanOrEqual(initial);

    // Switch to YTD - should potentially show less data
    await page.getByTestId('time-range-ytd').click();

    // Verify stats are still displayed (values will depend on data)
    const ytdWorkouts = await page.getByTestId('total-workouts-value').textContent();
    expect(ytdWorkouts).toBeTruthy();
  });
});

test.describe('Statistics Content', () => {
  test('should display stat values as numbers', async ({ page }) => {
    await page.goto('/stats');

    // Verify all stat cards display numeric values
    const totalWorkouts = await page.getByTestId('total-workouts-value').textContent();
    const totalExercises = await page.getByTestId('total-exercises-value').textContent();
    const totalVolume = await page.getByTestId('total-volume-value').textContent();

    // Check that values are numeric (0 or positive integers)
    expect(totalWorkouts).toMatch(/^\d+$/);
    expect(totalExercises).toMatch(/^\d+$/);
    expect(totalVolume).toMatch(/^\d+\s*kg$/); // Format: "123 kg"
  });

  test('should display stat cards with correct labels', async ({ page }) => {
    await page.goto('/stats');

    // Verify stat card labels
    const workoutsCard = page.getByTestId('total-workouts-card');
    await expect(workoutsCard).toContainText('Total Workouts');

    const exercisesCard = page.getByTestId('total-exercises-card');
    await expect(exercisesCard).toContainText('Total Exercises');

    const volumeCard = page.getByTestId('total-volume-card');
    await expect(volumeCard).toContainText('Total Volume');
  });
});
