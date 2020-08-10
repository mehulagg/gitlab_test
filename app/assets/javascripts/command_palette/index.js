import Vue from 'vue';
import App from './components/app.vue';
import store from './store';

export default () => {
  const el = document.getElementById('js-command-palette');

  return new Vue({
    el,
    store,
    render(h) {
      return h(App);
    },
  });
};
