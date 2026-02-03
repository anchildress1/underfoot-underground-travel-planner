export default {
  // The following line defines specific presets (also called shared configs) to use for commitlint.
  // This is the most common preset, which is based on the Conventional Commits specification.
  // Others are available, but this is the most widely used.
  // See: https://commitlint.js.org/reference/configuration.html#shareable-configuration
  extends: ['@commitlint/config-conventional'],
  plugins: ['@checkmarkdevtools/commitlint-plugin-rai',
    {
      rules: {
        'signed-off-by': ({ footer }) => {
          const hasSignedOff = footer?.some(line =>
            /^Signed-off-by:\s.+ <.+>/.test(line)
          );
          return [
            hasSignedOff,
            'commit message must include a Signed-off-by footer',
          ];
        },
      },
    },
  ],

  rules: {
    'header-trim': [2, 'always'],
    'type-case': [2, 'always', 'lower-case'],
    'scope-empty': [2, 'never'],
    'scope-case': [2, 'always', 'lower-case'],
    'body-leading-blank': [2, 'always'],
    'body-empty': [2, 'never'],
    'body-max-line-length': [2, 'always', 100],
    'footer-max-line-length': [2, 'always', 100],
    'signed-off-by': [1, 'always'],
    'rai-footer-exists': [2, 'always']
  },
};
