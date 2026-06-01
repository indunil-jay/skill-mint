import type { Config } from 'prettier';

const config: Config = {
  // Quotes
  singleQuote: true,
  jsxSingleQuote: false, // JSX always uses double quotes (React convention)

  // Semicolons
  semi: true,

  // Trailing commas
  trailingComma: 'all',

  // Line length
  printWidth: 100,

  // Indentation
  tabWidth: 2,
  useTabs: false,

  // Brackets
  bracketSpacing: true,
  bracketSameLine: false,

  // Arrow functions
  arrowParens: 'always',

  // End of line
  endOfLine: 'lf',

  // File-specific overrides
  overrides: [
    {
      // JSON files use double quotes (JSON spec)
      files: ['*.json', '*.jsonc'],
      options: {
        singleQuote: false,
      },
    },
    {
      // Markdown — don't wrap prose (preserve manual line breaks)
      files: ['*.md', '*.mdx'],
      options: {
        proseWrap: 'preserve',
        printWidth: 120,
      },
    },
  ],
};

export default config;
