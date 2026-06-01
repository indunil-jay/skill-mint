import tseslint from 'typescript-eslint';
import { baseConfig } from './index.js';

export default tseslint.config(...baseConfig, {
  rules: {
    '@typescript-eslint/no-require-imports': 'warn',
  },
});
