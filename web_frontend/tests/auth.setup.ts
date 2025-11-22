import { test as setup } from '@playwright/test';
import { createClient } from '@supabase/supabase-js';

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

/**
 * Test Data Seeding for E2E Tests
 *
 * This setup script runs after authentication to ensure the test user has workout data.
 * It creates sample performed_session records for the test user.
 */
setup('seed test workout data', async () => {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'http://127.0.0.1:54321';
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

  const testEmail = process.env.TEST_USER_EMAIL || 'test@example.com';
  const testPassword = process.env.TEST_USER_PASSWORD || 'TestPassword123!';

  // Create Supabase client
  const supabase = createClient(supabaseUrl, supabaseAnonKey);

  // Authenticate as test user
  const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
    email: testEmail,
    password: testPassword,
  });

  if (authError || !authData.user) {
    console.error('Failed to authenticate test user:', authError);
    throw new Error('Test user authentication failed - cannot seed data');
  }

  const userId = authData.user.id;

  // Check if test user already has workout data
  const { data: existingSessions, error: checkError } = await supabase
    .from('performed_session')
    .select('performed_session_id')
    .eq('app_user_id', userId)
    .limit(1);

  if (checkError) {
    console.error('Failed to check existing workout data:', checkError);
    throw new Error('Failed to check existing workout data');
  }

  // If data already exists, skip seeding
  if (existingSessions && existingSessions.length > 0) {
    console.log('Test workout data already exists, skipping seed');
    return;
  }

  // Get available session schedules to use for test data
  const { data: sessionSchedules, error: scheduleError } = await supabase
    .from('session_schedule')
    .select('session_schedule_id, name')
    .limit(5);

  if (scheduleError || !sessionSchedules || sessionSchedules.length === 0) {
    console.error('Failed to fetch session schedules:', scheduleError);
    throw new Error('No session schedules available for test data');
  }

  // Create test workout sessions
  const now = new Date();
  const testSessions = [
    {
      session_schedule_id: sessionSchedules[0].session_schedule_id,
      app_user_id: userId,
      started_at: new Date(now.getTime() - 1 * 24 * 60 * 60 * 1000).toISOString(), // 1 day ago
      completed_at: new Date(now.getTime() - 1 * 24 * 60 * 60 * 1000 + 60 * 60 * 1000).toISOString(), // +1 hour
      note: 'Test Leg Day - Great workout',
    },
    {
      session_schedule_id: sessionSchedules[1] ? sessionSchedules[1].session_schedule_id : sessionSchedules[0].session_schedule_id,
      app_user_id: userId,
      started_at: new Date(now.getTime() - 2 * 24 * 60 * 60 * 1000).toISOString(), // 2 days ago
      completed_at: new Date(now.getTime() - 2 * 24 * 60 * 60 * 1000 + 90 * 60 * 1000).toISOString(), // +1.5 hours
      note: 'Test Upper Body - Felt strong',
    },
    {
      session_schedule_id: sessionSchedules[2] ? sessionSchedules[2].session_schedule_id : sessionSchedules[0].session_schedule_id,
      app_user_id: userId,
      started_at: new Date(now.getTime() - 4 * 24 * 60 * 60 * 1000).toISOString(), // 4 days ago
      completed_at: new Date(now.getTime() - 4 * 24 * 60 * 60 * 1000 + 75 * 60 * 1000).toISOString(), // +1 hour 15 min
      note: 'Test Pull Day - Good session',
    },
    {
      session_schedule_id: sessionSchedules[3] ? sessionSchedules[3].session_schedule_id : sessionSchedules[0].session_schedule_id,
      app_user_id: userId,
      started_at: new Date(now.getTime() - 6 * 24 * 60 * 60 * 1000).toISOString(), // 6 days ago
      completed_at: new Date(now.getTime() - 6 * 24 * 60 * 60 * 1000 + 50 * 60 * 1000).toISOString(), // +50 min
      note: 'Test Arms - Quick workout',
    },
    {
      session_schedule_id: sessionSchedules[4] ? sessionSchedules[4].session_schedule_id : sessionSchedules[0].session_schedule_id,
      app_user_id: userId,
      started_at: new Date(now.getTime() - 8 * 24 * 60 * 60 * 1000).toISOString(), // 8 days ago
      completed_at: new Date(now.getTime() - 8 * 24 * 60 * 60 * 1000 + 80 * 60 * 1000).toISOString(), // +1 hour 20 min
      note: 'Test Push - Solid performance',
    },
  ];

  const { data: insertedSessions, error: insertError } = await supabase
    .from('performed_session')
    .insert(testSessions)
    .select();

  if (insertError) {
    console.error('Failed to insert test workout data:', insertError);
    throw new Error('Failed to seed test workout data');
  }

  console.log(`✅ Successfully seeded ${insertedSessions?.length || 0} test workout sessions`);
});
