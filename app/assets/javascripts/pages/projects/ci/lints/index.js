import Vue from 'vue';
import EditorLite from './editor/dag_editor.vue';

const createDagPreviewApp = () => {
  const el = document.querySelector('#js-dag-preview');

  // eslint-disable-next-line no-new
  new Vue({
    el,
    render(createElement) {
      return createElement(EditorLite);
    },
  });
};

document.addEventListener('DOMContentLoaded', () => {
  createDagPreviewApp();
});
