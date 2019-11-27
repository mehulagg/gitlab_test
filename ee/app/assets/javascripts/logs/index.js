import Vue from 'vue';
import { getParameterValues } from '~/lib/utils/url_utility';
import LogViewer from './components/environment_logs.vue';
import store from './stores';

export default (props = {}) => {
  const el = document.getElementById('environment-logs');
  const [defaultSearch] = getParameterValues('search');
  const [defaultPodName] = getParameterValues('pod');

  // eslint-disable-next-line no-new
  new Vue({
    el,
    store,
    render(createElement) {
      let defaultClusters = JSON.parse(el.dataset.defaultClusters);
      delete el.dataset.clusters;

      return createElement(LogViewer, {
        props: {
          ...el.dataset,
          defaultClusters,
          defaultSearch,
          defaultPodName,
          ...props,
        },
      });
    },
  });
};
