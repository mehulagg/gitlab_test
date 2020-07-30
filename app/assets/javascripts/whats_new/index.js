import Vue from 'vue';
import WhatsNewApp from './components/whats_new_app.vue';
import WhatsNewTrigger from './components/whats_new_trigger.vue';
import store from './store';

export default () => {
  new Vue({
    el: document.getElementById('whats-new-app'),
    store: store,
    components: {
      WhatsNewApp
    },

    render(createElement) {
      return createElement('whats-new-app');
    },
  });

  new Vue({
    el: document.getElementById('whats-new-trigger'),
    store: store,
    components: {
      WhatsNewTrigger
    },

    render(createElement) {
      return createElement('whats-new-trigger');
    },
  });
};
