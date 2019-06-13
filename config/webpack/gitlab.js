const path = require('path');

const ROOT_PATH = path.resolve(__dirname, '../..');
const IS_EE = require('./../helpers/is_ee_env');

const alias = {
  '~': path.join(ROOT_PATH, 'app/assets/javascripts'),
  emojis: path.join(ROOT_PATH, 'fixtures/emojis'),
  empty_states: path.join(ROOT_PATH, 'app/views/shared/empty_states'),
  icons: path.join(ROOT_PATH, 'app/views/shared/icons'),
  images: path.join(ROOT_PATH, 'app/assets/images'),
  vendor: path.join(ROOT_PATH, 'vendor/assets/javascripts'),
  vue$: 'vue/dist/vue.esm.js',
  spec: path.join(ROOT_PATH, 'spec/javascripts'),

  // the following resolves files which are different between CE and EE
  ee_else_ce: path.join(ROOT_PATH, 'app/assets/javascripts'),
};

if (IS_EE) {
  Object.assign(alias, {
    ee: path.join(ROOT_PATH, 'ee/app/assets/javascripts'),
    ee_empty_states: path.join(ROOT_PATH, 'ee/app/views/shared/empty_states'),
    ee_icons: path.join(ROOT_PATH, 'ee/app/views/shared/icons'),
    ee_images: path.join(ROOT_PATH, 'ee/app/assets/images'),
    ee_spec: path.join(ROOT_PATH, 'ee/spec/javascripts'),
    ee_else_ce: path.join(ROOT_PATH, 'ee/app/assets/javascripts'),
  });
}

module.exports = {
  // resolve
  resolve: {
    alias,
  },

  // module
  module: {
    strictExportPresence: true,
  },

  // optimization
  // optimization: {
  //   runtimeChunk: 'single',
  //   splitChunks: {
  //     maxInitialRequests: 4,
  //     cacheGroups: {
  //       default: false,
  //       common: () => ({
  //         priority: 20,
  //         name: 'main',
  //         chunks: 'initial',
  //         minChunks: autoEntriesCount * 0.9,
  //       }),
  //       vendors: {
  //         priority: 10,
  //         chunks: 'async',
  //         test: /[\\/](node_modules|vendor[\\/]assets[\\/]javascripts)[\\/]/,
  //       },
  //       commons: {
  //         chunks: 'all',
  //         minChunks: 2,
  //         reuseExistingChunk: true,
  //       },
  //     },
  //   },
  // },
};
