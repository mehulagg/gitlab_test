import Vue from 'vue';

import Translate from '~/vue_shared/translate';

// import GeoDesignsStore from './store/geo_designs_store';
// import GeoDesignsService from './service/geo_designs_service';

import geoDesignsApp from './components/app.vue';

Vue.use(Translate);

export default () => {
  const el = document.getElementById('js-geo-designs');

  if (!el) {
    return false;
  }

  return new Vue({
    el,
    components: {
      geoDesignsApp,
    },
    data() {
      // const { dataset } = this.$options.el;
      // const store = new GeoDesignsStore();
      // const service = new GeoDesignsService();

      return {
        // store,
        // service,
      };
    },
    render(createElement) {
      return createElement('geo-designs-app', {
        props: {
          // store: this.store,
          // service: this.service,
        },
      });
    },
  });
};
