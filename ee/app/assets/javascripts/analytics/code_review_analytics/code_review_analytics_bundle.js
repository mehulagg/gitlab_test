import Vue from 'vue';
import store from './store';
import CodeAnalyticsApp from './components/app.vue';

export default () => {
  const container = document.getElementById('js-code-review-analytics');
  const {
    projectId,
    projectPath,
    newMergeRequestUrl,
    emptyStateSvgPath,
    milestonePath,
    labelsPath,
  } = container.dataset;
  if (!container) return;

  // eslint-disable-next-line no-new
  new Vue({
    el: container,
    store,
    render(h) {
      return h(CodeAnalyticsApp, {
        props: {
          projectId: Number(projectId),
          projectPath,
          newMergeRequestUrl,
          emptyStateSvgPath,
          milestonePath,
          labelsPath,
        },
      });
    },
  });
};
