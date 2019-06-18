import Vue from 'vue';
import RelatedIssuableInput from 'ee/related_issues/components/related_issuable_input.vue';
import { n__ } from '~/locale';

const getRefs = el => {
  const { hiddenBlockingMrsCount, visibleBlockingMrRefs } = el.dataset;
  const parsedVisibleBlockingMrRefs = JSON.parse(visibleBlockingMrRefs);

  return hiddenBlockingMrsCount > 0
    ? [
        ...parsedVisibleBlockingMrRefs,
        n__(
          '%n inaccessible merge request',
          '%n inaccessible merge requests',
          hiddenBlockingMrsCount,
        ),
      ]
    : parsedVisibleBlockingMrRefs;
};

export default el => {
  if (!el) {
    return null;
  }
  const references = getRefs(el);

  return new Vue({
    el,
    render(h) {
      return h(RelatedIssuableInput, {
        props: {
          references,
          pathIdSeparator: '!',
        },
      });
    },
  });
};
