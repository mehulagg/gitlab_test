import Vue from 'vue';
import EmbedGroup from '~/monitoring/components/embeds/embed_group.vue';
import { createStore } from '~/monitoring/stores/embed_group/';

// TODO: Handle copy-pasting - https://gitlab.com/gitlab-org/gitlab-foss/issues/64369.
export default function renderMetrics(elements) {
  if (!elements.length) {
    return;
  }

  const MetricsComponent = Vue.extend(EmbedGroup);
  const wrapperList = [];

  elements.forEach(element => {
    let wrapper;
    const { previousSibling } = element;
    const isFirstElementInGroup = !previousSibling?.urls;

    if (isFirstElementInGroup) {
      wrapper = document.createElement('div');
      wrapper.urls = [element.dataset.dashboardUrl];
      element.parentNode.insertBefore(wrapper, element);
      wrapperList.push(wrapper);
    } else {
      wrapper = previousSibling;
      wrapper.urls.push(element.dataset.dashboardUrl);
    }

    // Clean up processed element
    element.parentNode.removeChild(element);
  });

  wrapperList.forEach(wrapper => {
    // eslint-disable-next-line no-new
    new MetricsComponent({
      el: wrapper,
      store: createStore(),
      propsData: {
        urls: wrapper.urls,
      },
    });
  });
}
