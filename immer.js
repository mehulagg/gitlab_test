const express = require('express');
const path = require('path');
const fs = require('fs');
const app = express();
const GITLAB_PATH = '/Users/natalia/gitlab/gdk-new/gitlab';
app.get('*', (req, res) => {
  const assetPath = path.join(GITLAB_PATH + '/public', req.path);
  const file = fs.readFileSync(assetPath);
  return res.send(file);
});
app.listen(3808, () => {
  console.log('up');
});
