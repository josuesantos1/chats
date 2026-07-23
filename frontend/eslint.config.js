import js from '@eslint/js'
import pluginVue from 'eslint-plugin-vue'
import tseslint from '@typescript-eslint/eslint-plugin'
import tsparser from '@typescript-eslint/parser'
import prettier from 'eslint-config-prettier'

const browserGlobals = {
  window: 'readonly',
  document: 'readonly',
  console: 'readonly',
  localStorage: 'readonly',
  sessionStorage: 'readonly',
  HTMLElement: 'readonly',
  HTMLInputElement: 'readonly',
  Event: 'readonly',
  setTimeout: 'readonly',
  clearTimeout: 'readonly',
  setInterval: 'readonly',
  clearInterval: 'readonly',
  fetch: 'readonly',
  URL: 'readonly',
  URLSearchParams: 'readonly',
  FormData: 'readonly',
  File: 'readonly',
  Blob: 'readonly',
  Request: 'readonly',
  Response: 'readonly',
  Headers: 'readonly',
  AbortController: 'readonly',
  AbortSignal: 'readonly',
  Promise: 'readonly',
  Map: 'readonly',
  Set: 'readonly',
  WeakMap: 'readonly',
  WeakSet: 'readonly',
  Symbol: 'readonly',
  Proxy: 'readonly',
  Reflect: 'readonly',
  crypto: 'readonly',
  navigator: 'readonly',
  location: 'readonly',
  history: 'readonly',
  performance: 'readonly',
  requestAnimationFrame: 'readonly',
  cancelAnimationFrame: 'readonly',
  MutationObserver: 'readonly',
  IntersectionObserver: 'readonly',
  ResizeObserver: 'readonly',
  CustomEvent: 'readonly',
  EventTarget: 'readonly',
  Node: 'readonly',
  Element: 'readonly',
  NodeList: 'readonly',
  FileReader: 'readonly',
}

export default [
  js.configs.recommended,
  ...pluginVue.configs['flat/recommended'],
  prettier,

  // TypeScript source files
  {
    files: ['**/*.ts'],
    languageOptions: {
      parser: tsparser,
      globals: browserGlobals,
    },
    plugins: {
      '@typescript-eslint': tseslint,
    },
    rules: {
      'no-undef': 'off', // TypeScript covers this
      'no-useless-assignment': 'off',
      '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
    },
  },

  // Vue SFCs — vue-eslint-parser as outer parser, tsparser for <script>
  {
    files: ['**/*.vue'],
    languageOptions: {
      parserOptions: {
        parser: tsparser,
        extraFileExtensions: ['.vue'],
      },
      globals: browserGlobals,
    },
    plugins: {
      '@typescript-eslint': tseslint,
    },
    rules: {
      'no-undef': 'off', // TypeScript covers this
      'no-useless-assignment': 'off',
      'vue/multi-word-component-names': 'off',
      'vue/component-definition-name-casing': 'off',
      '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
    },
  },

  {
    ignores: ['dist/**', 'node_modules/**'],
  },
]
