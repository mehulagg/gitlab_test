import Vue from 'vue';
import { getParameterValues } from '~/lib/utils/url_utility';
import LogViewer from './components/environment_logs.vue';
import store from './stores';

export default (props = {}) => {
  const el = document.getElementById('environment-logs');
  const [defaultPodName] = getParameterValues('pod_name');

  // eslint-disable-next-line no-new
  new Vue({
    el,
    store,
    render(createElement) {
      let clusters = JSON.parse(el.dataset.clusters);
      delete el.dataset.clusters;

      return createElement(LogViewer, {
        props: {
          ...el.dataset,
          clusters,
          defaultPodName,
          ...props,
        },
      });
    },
  });
};
