const pug = require('pug');
const path = require('path');
const fs = require('fs');

const compile = pug.compileFile(path.resolve(__dirname, 'preview-head.pug'));
const cssUrl = process.env.CSS_URL || 'https://gitlab-org.gitlab.io/gitlab-ce/application.css';

fs.writeFile(
  path.resolve(__dirname, 'preview-head.html'),
  compile({
    cssUrl,
  }),
  function(err) {
    if (err) {
      return console.log(err);
    }
    console.log(`The file was saved using CSS_URL=${cssUrl}`);
  }
);
