const path = require('path');
const webpack = require('webpack');
const VueLoaderPlugin = require('vue-loader/lib/plugin');

const ROOT_PATH = path.resolve(__dirname, '..');

module.exports = {
  target: 'node',
  output: {
    path: path.join(ROOT_PATH, 'dist'),
    filename: 'hypernova.js',
    globalObject: 'this',
  },
  entry: path.join(ROOT_PATH, 'hypernova.js'),
  resolve: {
    alias: {
      '~': path.join(ROOT_PATH, 'app/assets/javascripts'),
      images: path.join(ROOT_PATH, 'app/assets/images'),
      '@gitlab/svgs/dist/icons.svg': path.join(
        ROOT_PATH,
        'app/assets/javascripts/lib/utils/icons_path.js',
      ),
    },
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: 'babel-loader',
      },
      {
        test: /\.vue$/,
        exclude: /node_modules/,
        use: 'vue-loader',
      },
      {
        test: /\.(gif|png|mp4)$/,
        loader: 'url-loader',
        options: { limit: 2048 },
      },
    ],
  },
  plugins: [
    new VueLoaderPlugin(),
    new webpack.IgnorePlugin(/^(canvas)$/),
    new webpack.DefinePlugin({ gon: 'window.gon', IS_SERVER: JSON.stringify(true) }),
  ],
};
