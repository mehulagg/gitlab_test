process.env.NODE_ENV = process.env.NODE_ENV || 'production';

const environment = require('./environment');

const path = require('path');
const ROOT_PATH = path.resolve(__dirname, '../..');

// custom webpack plugins - production only
const CompressionPlugin = require('compression-webpack-plugin');
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');

// plugin initialization
environment.plugins.append('CompressionPlugin', new CompressionPlugin());
environment.plugins.append('BundleAnalyzerPlugin', new BundleAnalyzerPlugin({
      analyzerMode: 'static',
      generateStatsFile: true,
      openAnalyzer: false,
      reportFilename: path.join(ROOT_PATH, 'webpack-report/index.html'),
      statsFilename: path.join(ROOT_PATH, 'webpack-report/stats.json'),
    })
);

// export final webpack configuration
module.exports = environment.toWebpackConfig();
