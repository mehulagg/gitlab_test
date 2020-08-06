import Vue from 'vue';
import DagEditorContainer from './editor/components/dag_editor_container.vue';

const createDagPreviewApp = () => {
  const el = document.querySelector('#js-dag-preview');

  // eslint-disable-next-line no-new
  new Vue({
    el,
    render(createElement) {
      return createElement(DagEditorContainer);
    },
  });
};

document.addEventListener('DOMContentLoaded', () => {
  createDagPreviewApp();
});
