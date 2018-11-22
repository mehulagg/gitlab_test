<template>
  <b-button
    type="button"
    @click="submit"
  >
    Edit in JSFiddle
  </b-button>
</template>

<script>
import Vue from 'vue';

const generateHtml = source => `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <link rel="stylesheet" href="https://unpkg.com/bootstrap@4/dist/css/bootstrap.css">
  <link rel="stylesheet" href="https://gitlab-org.gitlab.io/gitlab-ce/application.css">
  <script type="module">
  import Vue from 'https://unpkg.com/vue@${Vue.version}/dist/vue.esm.browser.js';
  import * as components from 'https://unpkg.com/@gitlab/ui@latest/dist/index.js';

  new Vue({
    el: '#app',
    components: { ...components }
  })
  <${'' /* without this the parser is confused by closing tag */}/script>
</head>
<body>
<div id="app" class="m-3">

<!-- example from https://design.gitlab.com/ -->
${source}
</div>
</body>
</html>
`;

export default {
  props: {
    exampleName: {
      type: String,
      required: true,
    },
    source: {
      type: String,
      required: true,
    },
  },
  methods: {
    submit() {
      const hiddenForm = document.createElement('form');
      hiddenForm.method = 'POST';
      hiddenForm.action = 'https://jsfiddle.net/api/post/library/pure/';
      hiddenForm.classList.add('hidden');

      const titleInput = document.createElement('input');
      titleInput.name = 'title';
      titleInput.value = `@gitlab/ui – ${this.exampleName}`;
      hiddenForm.appendChild(titleInput);

      const htmlTextarea = document.createElement('textarea');
      htmlTextarea.name = 'html';
      htmlTextarea.innerHTML = generateHtml(this.source);
      hiddenForm.appendChild(htmlTextarea);

      document.body.appendChild(hiddenForm);
      hiddenForm.submit();
    },
  },
};
</script>
