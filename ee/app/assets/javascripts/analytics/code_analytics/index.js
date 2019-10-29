import Vue from 'vue';
import CodeAnalytics from './components/app.vue';
import store from './store';

export default () => {
  const el = document.querySelector('#js-code-analytics-app');
  const { emptyStateSvgPath } = el.dataset;

  return new Vue({
    el,
    store,
    name: 'CodeAnalyticsApp',
    components: {
      CodeAnalytics,
    },
    render: createElement =>
      createElement(CodeAnalytics, {
        props: {
          emptyStateSvgPath,
        },
      }),
  });
};
