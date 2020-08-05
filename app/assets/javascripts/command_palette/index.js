import Vue from 'vue';
import App from './components/app.vue';

export default () => {
  const el = document.getElementById('js-command-palette');

  return new Vue({
    el,
    render(h) {
      return h(App);
    },
  });
};
