import Vue from 'vue';
import CodeAnalytics from './components/app.vue';

export default () => {
  const el = document.querySelector('#js-code-analytics-app');
  const { endpoint, emptyStateSvgPath, noAccessSvgPath } = el.dataset;

  return new Vue({
    el,
    name: 'CodeAnalyticsApp',
    components: {
      CodeAnalytics,
    },
    render: createElement =>
      createElement(CodeAnalytics, {
        props: {
          emptyStateSvgPath,
          noAccessSvgPath,
          endpoint,
        },
      }),
  });
};
