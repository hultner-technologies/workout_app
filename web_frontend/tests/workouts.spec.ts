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

  test('should display either workout list or empty state (but not both)', async ({ page }) => {
    await page.goto('/workouts');

    // One of these elements must be visible
    const workoutList = page.getByTestId('workout-list');
    const emptyMessage = page.getByTestId('empty-workouts-message');

    const listVisible = await workoutList.isVisible().catch(() => false);
    const emptyVisible = await emptyMessage.isVisible().catch(() => false);

    // Exactly one must be visible (XOR logic)
    expect(listVisible !== emptyVisible).toBe(true);

    // Additionally verify what we're showing makes sense
    if (listVisible) {
      await expect(workoutList).toBeVisible();
      await expect(emptyMessage).not.toBeVisible();
    } else {
      await expect(emptyMessage).toBeVisible();
      await expect(workoutList).not.toBeVisible();
    }
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

  test('should clear filter and show default empty message', async ({ page }) => {
    await page.goto('/workouts');

    const searchInput = page.getByTestId('workout-search-input');
    const emptyMessage = page.getByTestId('empty-workouts-message');

    // Filter to show no results
    await searchInput.fill('ZZZZNONEXISTENT999');
    await expect(emptyMessage).toBeVisible();
    await expect(emptyMessage).toContainText('No workouts found matching your search');

    // Clear the search
    await searchInput.clear();

    // Should show default empty message (not search-specific)
    await expect(emptyMessage).toBeVisible();
    await expect(emptyMessage).not.toContainText('No workouts found matching your search');
  });

  test('should restore workout list when clearing filter', async ({ page }) => {
    await page.goto('/workouts');

    const searchInput = page.getByTestId('workout-search-input');
    const workoutList = page.getByTestId('workout-list');

    // Check if workouts exist initially
    const hasWorkouts = await workoutList.isVisible().catch(() => false);
    test.skip(!hasWorkouts, 'Requires workout data');

    // Filter to hide workouts
    await searchInput.fill('ZZZZNONEXISTENT999');
    const emptyMessage = page.getByTestId('empty-workouts-message');
    await expect(emptyMessage).toBeVisible();

    // Clear search - workouts should reappear
    await searchInput.clear();
    await expect(workoutList).toBeVisible();
    await expect(emptyMessage).not.toBeVisible();
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
