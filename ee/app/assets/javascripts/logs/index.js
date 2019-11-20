import Vue from 'vue';
import { getParameterValues } from '~/lib/utils/url_utility';
import LogViewer from './components/environment_logs.vue';
import LogSearch from './components/log_search.vue';
import store from './stores';

export default (props = {}) => {
  const el = document.getElementById('environment-logs');
  const [currentPodName] = getParameterValues('pod_name');

  // eslint-disable-next-line no-new
  new Vue({
    el,
    store,
    // TODO Add switching from BE config
    // render(createElement) {
    //   return createElement(LogViewer, {
    //     props: {
    //       ...el.dataset,
    //       currentPodName,
    //       ...props,
    //     },
    //   });
    // },
    render(createElement) {
      return createElement(LogSearch, {
        props: {
          ...el.dataset,
          currentPodName,
          ...props,
        },
      });
    },
  });
};
