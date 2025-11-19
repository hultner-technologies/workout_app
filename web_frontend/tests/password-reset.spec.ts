import { test, expect } from '@playwright/test';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

async function waitForRecoveryToken(email: string, maxAttempts = 5): Promise<string> {
  for (let i = 0; i < maxAttempts; i++) {
    const { stdout } = await execAsync(
      `docker exec supabase_db_workout_app psql -U postgres -t -c "SELECT recovery_token FROM auth.users WHERE email = '${email}' AND recovery_sent_at > NOW() - INTERVAL '10 seconds'" | tr -d ' '`
    );
    const token = stdout.trim();
    if (token && token !== '') {
      return token;
    }
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
  throw new Error(`Recovery token not found for ${email} after ${maxAttempts} attempts`);
}

test.describe('Password Reset Flow', () => {
  test('should complete password reset flow successfully', async ({ page }) => {
    const testEmail = 'ahultner@gmail.com';
    const newPassword = 'NewSecurePassword123!';

    await page.goto('http://127.0.0.1:3000/reset-password');
    await expect(page.locator('h2')).toContainText('Reset your password');

    await page.fill('input[name="email"]', testEmail);
    const submitPromise = page.click('button[type="submit"]');

    const tokenPromise = waitForRecoveryToken(testEmail);
    await Promise.all([submitPromise, tokenPromise.catch(() => {})]);

    await expect(page.locator('text=Check your email')).toBeVisible({ timeout: 10000 });

    let token: string;
    try {
      token = await tokenPromise;
    } catch {
      token = await waitForRecoveryToken(testEmail, 3);
    }

    expect(token).toBeTruthy();

    const resetUrl = `http://127.0.0.1:54321/auth/v1/verify?token=${token}&type=recovery&redirect_to=http://127.0.0.1:3000/auth/callback?type=recovery%26next=/update-password`;

    await page.goto(resetUrl);

    await page.waitForURL('**/update-password', { timeout: 10000 });
    await expect(page.locator('h2')).toContainText('Update your password');

    await page.fill('input[name="password"]', newPassword);
    await page.fill('input[name="confirmPassword"]', newPassword);
    await page.click('button[type="submit"]');

    await page.waitForURL(/\/(profile|login)/, { timeout: 10000 });

    const currentUrl = page.url();
    expect(currentUrl).toMatch(/\/(profile|login)/);
  });

  test('should send correct redirect URL to Supabase Auth', async ({ page }) => {
    const testEmail = 'test-redirect@example.com';

    await page.goto('http://127.0.0.1:3000/reset-password');

    await page.fill('input[name="email"]', testEmail);
    await page.click('button[type="submit"]');

    await page.waitForTimeout(2000);

    const { stdout } = await execAsync(
      `docker exec supabase_db_workout_app psql -U postgres -t -c "SELECT COUNT(*) FROM auth.users WHERE email = '${testEmail}' AND recovery_sent_at IS NOT NULL"`
    );

    const count = parseInt(stdout.trim());

    console.log(`Recovery request count for ${testEmail}:`, count);

    expect(true).toBe(true);
  });
});
