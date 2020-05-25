import Vue from 'vue';
import RelatedMergeRequests from './components/related_merge_requests.vue';
import createStore from './store';
import ssr from './ssr';

export default function initRelatedMergeRequests() {
  const relatedMergeRequestsElement = document.querySelector('#js-related-merge-requests');

  if (window.gon?.features?.vueSsr) {
    ssr();
  } else if (relatedMergeRequestsElement) {
    const { endpoint, projectPath, projectNamespace } = relatedMergeRequestsElement.dataset;

    // eslint-disable-next-line no-new
    new Vue({
      el: relatedMergeRequestsElement,
      components: {
        RelatedMergeRequests,
      },
      store: createStore(),
      render: createElement =>
        createElement('related-merge-requests', {
          props: { endpoint, projectNamespace, projectPath },
        }),
    });
  }
}
