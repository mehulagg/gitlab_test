/* eslint-disable import/no-commonjs, filenames/match-regex */
module.exports = function(api) {
  const validEnv = ['development', 'test', 'production'];
  const currentEnv = api.env();
  const isDevelopmentEnv = api.env('development');
  const isProductionEnv = api.env('production');
  const isTestEnv = api.env('test');

  if (!validEnv.includes(currentEnv)) {
    throw new Error(
      'Please specify a valid `NODE_ENV` or ' +
        '`BABEL_ENV` environment variables. Valid values are "development", ' +
        '"test", and "production". Instead, received: ' +
        JSON.stringify(currentEnv) +
        '.'
    )
  }

  const presets = [
    [
      '@babel/preset-env',
      {
        modules: false,
        targets: {
          ie: '11',
        },
      },
    ]
  ];

  // include stage 3 proposals
  const plugins = [
    '@babel/plugin-syntax-dynamic-import',
    '@babel/plugin-syntax-import-meta',
    '@babel/plugin-proposal-class-properties',
    '@babel/plugin-proposal-json-strings',
    '@babel/plugin-proposal-private-methods',
  ];

  // add code coverage tooling if necessary
  if (isTestEnv) {
    plugins.push([
      'babel-plugin-istanbul',
      {
        exclude: ['spec/javascripts/**/*', 'app/assets/javascripts/locale/**/app.js'],
      },
    ]);
  }

  // add rewire support when running tests
  if (isTestEnv) {
    plugins.push('babel-plugin-rewire');
  }

  // Jest is running in node environment, so we need additional plugins
  if (isTestEnv) {
    plugins.push('@babel/plugin-transform-modules-commonjs');
    /*
    without the following, babel-plugin-istanbul throws an error:
    https://gitlab.com/gitlab-org/gitlab-foss/issues/58390
    */
    plugins.push('babel-plugin-dynamic-import-node');
  }

  return { presets: presets, plugins: plugins};
};
