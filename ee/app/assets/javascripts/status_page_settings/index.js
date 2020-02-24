import Vue from 'vue';
import StatusPageSettings from './components/settings_form.vue';
import createStore from './store';

export default () => {
  const el = document.querySelector('.js-status-page-settings');
  return new Vue({
    el,
    store: createStore(el.dataset),
    render(createElement) {
      return createElement(StatusPageSettings);
    },
  });
};
