import Vue from 'vue';
import ProductivityAnalyticsApp from './components/app.vue';
import FilteredSearchProductivityAnalytics from './filtered_search_productivity_analytics';

export default function(el) {
  if (!el) {
    return false;
  }

  return new Vue({
    el,
    components: {
      ProductivityAnalyticsApp,
    },
    mounted() {
      /*
      this.filterManager = new FilteredSearchProductivityAnalytics(
        store.state.productivityAnalytics.filters,
      );
      */
      this.filterManager = new FilteredSearchProductivityAnalytics([]);
      this.filterManager.setup();
    },
    render(h) {
      return h(ProductivityAnalyticsApp, {
        props: {},
      });
    },
  });
}
