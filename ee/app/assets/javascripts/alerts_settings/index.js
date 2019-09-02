import Vue from 'vue';
import ResetKey from './components/reset_key.vue';

export default (el) => {
  if (el) {
    // eslint-disable-next-line no-new
    new Vue({
      el,
      render(createElement) {
        return createElement(ResetKey, {
          props: {
            changeKeyUrl: el.closest('form').action,
          },
        });
      },
    });
  }
};
