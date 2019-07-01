import Vue from 'vue';
import createStore from './store';
import ProductivityAnalyticsApp from './components/app.vue';

export default function(el) {
  if (!el) {
    return false;
  }

  const { endpoint, emptyStateSvgPath } = el.dataset;
  const store = createStore();

  return new Vue({
    el,
    store,
    components: {
      ProductivityAnalyticsApp,
    },
    render(h) {
      return h(ProductivityAnalyticsApp, {
        props: {
          endpoint,
          emptyStateSvgPath,
        },
      });
    },
  });
}
