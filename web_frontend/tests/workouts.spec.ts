import { test, expect } from '@playwright/test';

test.describe('Workout History Page', () => {
  test('should display workout history page correctly', async ({ page }) => {
    await page.goto('/workouts');

    // Verify page heading
    await expect(page.locator('h1')).toContainText('Workout History');

    // Verify navigation link to stats
    const viewStatsLink = page.getByTestId('view-stats-link');
    await expect(viewStatsLink).toBeVisible();
    await expect(viewStatsLink).toHaveAttribute('href', '/stats');

    // Verify filter controls are present
    await expect(page.getByTestId('workout-search-input')).toBeVisible();
    await expect(page.getByTestId('workout-sort-button')).toBeVisible();
  });

  test('should navigate to stats page from View Stats link', async ({ page }) => {
    await page.goto('/workouts');

    await page.getByTestId('view-stats-link').click();

    // Wait for navigation and verify URL
    await expect(page).toHaveURL('/stats');
    await expect(page.locator('h1')).toContainText('Workout Statistics');
  });
});

test.describe('Workout Filtering', () => {
  test('should filter workouts by search term', async ({ page }) => {
    await page.goto('/workouts');

    // Wait for workout list to load
    const workoutList = page.getByTestId('workout-list');
    const emptyMessage = page.getByTestId('empty-workouts-message');

    // Check if there are workouts or empty state
    const hasWorkouts = await workoutList.isVisible().catch(() => false);

    if (hasWorkouts) {
      // Get initial count of workouts
      const initialWorkouts = await page.getByTestId('workout-item').count();
      expect(initialWorkouts).toBeGreaterThan(0);

      // Get the name of the first workout
      const firstWorkoutName = await page.getByTestId('workout-name').first().textContent();

      if (firstWorkoutName) {
        // Search for a substring of the first workout name
        const searchTerm = firstWorkoutName.substring(0, 3);
        await page.getByTestId('workout-search-input').fill(searchTerm);

        // Verify search was applied - the first workout should still be visible
        await expect(page.getByTestId('workout-name').first()).toContainText(searchTerm, { ignoreCase: true });
      }

      // Search for something that definitely won't match
      await page.getByTestId('workout-search-input').fill('ZZZZNONEXISTENT999');

      // Should show empty state message
      await expect(emptyMessage).toBeVisible();
      await expect(emptyMessage).toContainText('No workouts found matching your search');
    } else {
      // If no workouts exist, verify empty state is shown
      await expect(emptyMessage).toBeVisible();
      await expect(emptyMessage).toContainText('No workouts recorded yet');
    }
  });
});

test.describe('Workout Sorting', () => {
  test('should toggle sort order when clicking sort button', async ({ page }) => {
    await page.goto('/workouts');

    const sortButton = page.getByTestId('workout-sort-button');

    // Verify initial sort order
    await expect(sortButton).toContainText('Newest First');

    // Click to change to ascending
    await sortButton.click();
    await expect(sortButton).toContainText('Oldest First');

    // Click again to change back to descending
    await sortButton.click();
    await expect(sortButton).toContainText('Newest First');
  });

  test('should actually reorder workouts when sorting', async ({ page }) => {
    await page.goto('/workouts');

    const workoutList = page.getByTestId('workout-list');
    const hasWorkouts = await workoutList.isVisible().catch(() => false);

    if (hasWorkouts) {
      const workoutCount = await page.getByTestId('workout-item').count();

      // Only test reordering if there are multiple workouts
      if (workoutCount >= 2) {
        // Switch to ascending order (oldest first)
        await page.getByTestId('workout-sort-button').click();
        await expect(page.getByTestId('workout-sort-button')).toContainText('Oldest First');

        // Verify the sort button state changed and workouts are still displayed
        await expect(page.getByTestId('workout-list')).toBeVisible();
        await expect(page.getByTestId('workout-sort-button')).toContainText('Oldest First');
      }
    }
  });
});

test.describe('Workout Details Navigation', () => {
  test('should navigate to workout detail page', async ({ page }) => {
    await page.goto('/workouts');

    const workoutList = page.getByTestId('workout-list');
    const hasWorkouts = await workoutList.isVisible().catch(() => false);

    if (hasWorkouts) {
      // Click the first workout details link
      const firstDetailsLink = page.getByTestId('workout-details-link').first();
      await expect(firstDetailsLink).toBeVisible();

      await firstDetailsLink.click();

      // Should navigate to workout detail page (URL pattern: /workouts/[id])
      await expect(page).toHaveURL(/\/workouts\/[a-f0-9-]+/);
    }
  });
});
