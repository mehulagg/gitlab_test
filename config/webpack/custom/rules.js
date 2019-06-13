const path = require('path');
const ROOT_PATH = path.resolve(__dirname, '../../../');
const CACHE_PATH = process.env.WEBPACK_CACHE_PATH || path.join(ROOT_PATH, 'tmp/cache');
const VUE_VERSION = require('vue/package.json').version;
const VUE_LOADER_VERSION = require('vue-loader/package.json').version;
const IS_DEV_SERVER = process.env.NODE_ENV === 'development';

module.exports = [
  {
    type: 'javascript/auto',
    test: /\.mjs$/,
    use: [],
  },
  {
    test: /\.js$/,
    exclude: path => /node_modules|vendor[\\/]assets/.test(path) && !/\.vue\.js/.test(path),
    loader: 'babel-loader',
    options: {
      cacheDirectory: path.join(CACHE_PATH, 'babel-loader'),
    },
  },
  {
    test: /\.vue$/,
    loader: 'vue-loader',
    options: {
      cacheDirectory: path.join(CACHE_PATH, 'vue-loader'),
      cacheIdentifier: [
        process.env.NODE_ENV || 'development',
        process.version,
        VUE_VERSION,
        VUE_LOADER_VERSION,
      ].join('|'),
    },
  },
  {
    test: /\.(graphql|gql)$/,
    exclude: /node_modules/,
    loader: 'graphql-tag/loader',
  },
  {
    test: /\.svg$/,
    loader: 'raw-loader',
  },
  {
    test: /\.(gif|png)$/,
    loader: 'url-loader',
    options: {limit: 2048},
  },
  {
    test: /\_worker\.js$/,
    use: [
      {
        loader: 'worker-loader',
        options: {
          name: '[name].[hash:8].worker.js',
          inline: IS_DEV_SERVER,
        },
      },
      'babel-loader',
    ],
  },
  {
    test: /\.(worker(\.min)?\.js|pdf|bmpr)$/,
    exclude: /node_modules/,
    loader: 'file-loader',
    options: {
      name: '[name].[hash:8].[ext]',
    },
  },
  {
    test: /.css$/,
    use: [
      'vue-style-loader',
      {
        loader: 'css-loader',
        options: {
          name: '[name].[hash:8].[ext]',
        },
      },
    ],
  },
  {
    test: /\.(eot|ttf|woff|woff2)$/,
    include: /node_modules\/katex\/dist\/fonts/,
    loader: 'file-loader',
    options: {
      name: '[name].[hash:8].[ext]',
    },
  },
];
