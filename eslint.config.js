import { defineConfig, globalIgnores } from 'eslint/config';
import js from '@eslint/js';
import globals from 'globals';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';
import react from 'eslint-plugin-react';

export default defineConfig([
  globalIgnores([
    '**/dist/**',
    '**/node_modules/**',
    '**/.venv/**',
    '**/htmlcov/**',
    '**/*.md',
    '**/*.mmd',
    '**/.env*',
    '.gitignore',
    'package.json',
    'package-lock.json',
    'frontend/coverage/**',
    'frontend/playwright-report/**',
    'frontend/test-results/**',
    'supabase/functions/**',
    '.worktrees/**',
    '**/.worktrees/**',
    'frontend/screenshot.js',
    'frontend/vitest.setup.js',
    // Frontend has its own eslint config (.eslintrc.json)
    'frontend/**',
  ]),
  js.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: 2024,
      sourceType: 'module',
    },
    rules: {
      // Additional base rules beyond js.configs.recommended
      curly: ['error', 'all'],
      'func-style': ['error', 'expression', { allowArrowFunctions: true }],
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    },
  },
  {
    files: ['scripts/**/*'],
    languageOptions: {
      globals: {
        ...globals.node,
      },
    },
  },
  {
    files: ['cloudflare-worker/**/*.js'],
    languageOptions: {
      globals: {
        ...globals.serviceworker,
        crypto: 'readonly',
        fetch: 'readonly',
        Response: 'readonly',
        Request: 'readonly',
        URL: 'readonly',
        URLSearchParams: 'readonly',
        TextEncoder: 'readonly',
        TextDecoder: 'readonly',
        TransformStream: 'readonly',
        ReadableStream: 'readonly',
        WritableStream: 'readonly',
        setInterval: 'readonly',
        clearInterval: 'readonly',
        setTimeout: 'readonly',
        clearTimeout: 'readonly',
      },
    },
  },
  {
    files: ['backend/**/*.js'],
    languageOptions: {
      globals: {
        ...globals.node,
      },
    },
  },
  {
    files: ['backend/test/**/*.js'],
    languageOptions: {
      globals: {
        ...globals.node,
        ...globals.vitest,
        global: 'writable',
      },
    },
  },
  {
    files: ['scripts/**/*.js'],
    rules: {
      'no-warning-comments': ['error', { terms: ['eslint-disable'], location: 'anywhere' }],
    },
  },
]);
