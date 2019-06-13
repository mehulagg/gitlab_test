const { environment } = require('@rails/webpacker');
const webpack = require('webpack');

// custom webpack Plugins
const { VueLoaderPlugin } = require('vue-loader');
const { StatsWriterPlugin } = require('webpack-stats-plugin');
const MonacoEditorPlugin = require('monaco-editor-webpack-plugin');

const customRules = require('./custom/rules');

// plugin initialization
environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin());
environment.loaders = customRules; // webpacker use 'loaders' as key for 'rules'

environment.plugins.append('StatsWriterPlugin', new StatsWriterPlugin({
      // manifest filename must match config.webpack.manifest_filename
      // webpack-rails only needs assetsByChunkName to function properly
      filename: 'manifest.json',
      transform: function (data, opts) {
        const stats = opts.compiler.getStats().toJson({
          chunkModules: false,
          source: false,
          chunks: false,
          modules: false,
          assets: true,
        });
        return JSON.stringify(stats, null, 2);
      },
    })
);

environment.plugins.append('MonacoEditorPlugin', new MonacoEditorPlugin());

environment.plugins.append('IgnorePlugin',
  // prevent pikaday from including moment.js
  new webpack.IgnorePlugin(/moment/, /pikaday/)
);

// custom GitLab config
const gitlabConfig = require('./gitlab');
environment.config.merge(gitlabConfig);

module.exports = environment;
