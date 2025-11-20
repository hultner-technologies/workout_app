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

  test('should display either workout list or empty state', async ({ page }) => {
    await page.goto('/workouts');

    // One of these elements must be visible
    const workoutList = page.getByTestId('workout-list');
    const emptyMessage = page.getByTestId('empty-workouts-message');

    const listVisible = await workoutList.isVisible().catch(() => false);
    const emptyVisible = await emptyMessage.isVisible().catch(() => false);

    // At least one must be visible (XOR-like check)
    expect(listVisible || emptyVisible).toBe(true);
  });
});

test.describe('Workout Filtering', () => {
  test('should show "no results" message when filtering returns no matches', async ({ page }) => {
    await page.goto('/workouts');

    // Search for something that definitely won't match any workout
    await page.getByTestId('workout-search-input').fill('ZZZZNONEXISTENT999');

    // Should show empty state message with search-specific text
    const emptyMessage = page.getByTestId('empty-workouts-message');
    await expect(emptyMessage).toBeVisible();
    await expect(emptyMessage).toContainText('No workouts found matching your search');
  });

  test('should clear filter results when search input is cleared', async ({ page }) => {
    await page.goto('/workouts');

    const searchInput = page.getByTestId('workout-search-input');

    // Filter to show no results
    await searchInput.fill('ZZZZNONEXISTENT999');
    await expect(page.getByTestId('empty-workouts-message')).toBeVisible();

    // Clear the search
    await searchInput.clear();

    // Empty message should update or disappear
    const emptyMessage = page.getByTestId('empty-workouts-message');
    const stillVisible = await emptyMessage.isVisible().catch(() => false);

    if (stillVisible) {
      // If still showing empty state, text should change to default message
      await expect(emptyMessage).not.toContainText('No workouts found matching');
    }
  });
});

test.describe('Workout Sorting', () => {
  test('should toggle sort order button text', async ({ page }) => {
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

  test('should maintain workout list visibility after sorting', async ({ page }) => {
    await page.goto('/workouts');

    const sortButton = page.getByTestId('workout-sort-button');
    const workoutList = page.getByTestId('workout-list');

    // Check initial state
    const initiallyHasWorkouts = await workoutList.isVisible().catch(() => false);

    // Toggle sort order
    await sortButton.click();
    await expect(sortButton).toContainText('Oldest First');

    // If workouts were visible before, they should still be visible after sort
    const stillHasWorkouts = await workoutList.isVisible().catch(() => false);
    expect(stillHasWorkouts).toBe(initiallyHasWorkouts);
  });
});

test.describe('Workout Details Navigation', () => {
  test('should have correctly formatted detail links when workouts exist', async ({ page }) => {
    await page.goto('/workouts');

    const workoutList = page.getByTestId('workout-list');
    const workoutListExists = await workoutList.isVisible().catch(() => false);

    // Skip test if no workouts exist (test is data-dependent)
    test.skip(!workoutListExists, 'No workouts available for testing');

    // If we reach here, workouts must exist
    const firstDetailsLink = page.getByTestId('workout-details-link').first();
    await expect(firstDetailsLink).toBeVisible();

    // Verify link has correct format
    const href = await firstDetailsLink.getAttribute('href');
    expect(href).toMatch(/^\/workouts\/.+$/);
  });

  test('should navigate to detail page when clicking workout link', async ({ page }) => {
    await page.goto('/workouts');

    const workoutList = page.getByTestId('workout-list');
    const workoutListExists = await workoutList.isVisible().catch(() => false);

    // Skip test if no workouts exist (test is data-dependent)
    test.skip(!workoutListExists, 'No workouts available for testing');

    // Click the first workout details link
    const firstDetailsLink = page.getByTestId('workout-details-link').first();
    await firstDetailsLink.click();

    // Should navigate to workout detail page (URL pattern: /workouts/[uuid])
    await expect(page).toHaveURL(/\/workouts\/[a-f0-9-]+/);
  });
});
