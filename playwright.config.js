// @ts-check
const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests',
  timeout: 60000,
  expect: { timeout: 10000 },
  fullyParallel: false, // Tests must run serially (login first)
  retries: 0,
  outputDir: 'test-results/pw-output',
  reporter: [
    ['list'],
    ['html', { open: 'never', outputFolder: 'test-results/html-report' }],
    ['json', { outputFile: 'test-results/api-results.json' }],
  ],
  use: {
    baseURL: 'http://183.83.216.66:8882',
    extraHTTPHeaders: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
  },
});
