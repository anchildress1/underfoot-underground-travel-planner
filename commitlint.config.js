export default {
  // The following line defines specific presets (also called shared configs) to use for commitlint.
  // This is the most common preset, which is based on the Conventional Commits specification.
  // Others are available, but this is the most widely used.
  // See: https://commitlint.js.org/reference/configuration.html#shareable-configuration
  extends: ['@commitlint/config-conventional'],
  plugins: ['@checkmarkdevtools/commitlint-plugin-rai'],

  rules: {
    'header-trim': [2, 'always'],
    'type-case': [2, 'always', 'lower-case'],
    'scope-case': [2, 'always', 'lower-case'],
    'subject-case': [2, 'always', 'lower-case'],
    'body-leading-blank': [2, 'always'],
    'body-max-line-length': [2, 'always', 100],
    'footer-max-line-length': [2, 'always', 100],
    'rai-footer-exists': [2, 'always'],
  },
};
