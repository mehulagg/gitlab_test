import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import store from './store';
import geoDesignsApp from './components/app.vue';

Vue.use(Translate);

export default () => {
  const el = document.getElementById('js-geo-designs');

  if (!el) {
    return false;
  }

  return new Vue({
    el,
    store,
    components: {
      geoDesignsApp,
    },
    render(createElement) {
      return createElement('geo-designs-app', {
      });
    },
  });
};
