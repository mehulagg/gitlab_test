import Vue from 'vue';
import App from './components/app.vue';

export default () => {
  const el = document.getElementById('js-code-navigation');
  const { projectPath, commitId, path } = el.dataset;

  return new Vue({
    el,
    render(h) {
      return h(App, { props: { projectPath, commitId, path } });
    },
  });
};
