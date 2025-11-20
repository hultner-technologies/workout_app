import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: 1, // Run tests sequentially to avoid race conditions
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },

  projects: [
    // Setup project - runs authentication before tests
    {
      name: 'setup',
      testMatch: /.*\.setup\.ts/,
    },
    // Unauthenticated tests - NO storageState (public pages)
    {
      name: 'unauthenticated',
      testMatch: [
        '**/password-reset.spec.ts',
      ],
      use: {
        ...devices['Desktop Chrome'],
        // NO storageState - users are not logged in
      },
    },
    // Unauthenticated navigation tests
    {
      name: 'unauthenticated-nav',
      testMatch: '**/navigation.spec.ts',
      testIgnore: /.*\.setup\.ts/,
      use: {
        ...devices['Desktop Chrome'],
        // NO storageState - users are not logged in
      },
      grep: /Landing Page|Authentication Redirects/,  // Only run Landing Page and Auth Redirects tests
    },
    // Authenticated tests - WITH storageState (protected pages)
    {
      name: 'authenticated',
      testMatch: [
        '**/workouts.spec.ts',
        '**/stats.spec.ts',
      ],
      use: {
        ...devices['Desktop Chrome'],
        storageState: 'tests/.auth/user.json',
      },
      dependencies: ['setup'],
    },
    // Authenticated navigation tests
    {
      name: 'authenticated-nav',
      testMatch: '**/navigation.spec.ts',
      use: {
        ...devices['Desktop Chrome'],
        storageState: 'tests/.auth/user.json',
      },
      dependencies: ['setup'],
      grep: /Authenticated Navigation/,  // Only run Authenticated Navigation tests
    },
  ],

  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: true,
    timeout: 120 * 1000,
  },
});
