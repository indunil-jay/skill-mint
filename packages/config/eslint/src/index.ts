import js from '@eslint/js';
import tseslint from 'typescript-eslint';

export const baseConfig = tseslint.config(js.configs.recommended, ...tseslint.configs.recommended, {
  rules: {
    '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/consistent-type-imports': 'error',
  },
});
