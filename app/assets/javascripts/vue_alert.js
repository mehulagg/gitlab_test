import Vue from 'vue';
import VueAlert from '~/vue_shared/components/alert.vue';

export default () => {
  const el = document.querySelector('#js-vue-alert');

  if (!el) {
    return false;
  }

  return new Vue({
    el,
    components: {
      VueAlert,
    },
    render(createElement) {
      return createElement('vue-alert', {
        props: {
          ...el.dataset,
          dismissable: el.dataset.dismissable !== 'false',
        },
      });
    },
  });
};
