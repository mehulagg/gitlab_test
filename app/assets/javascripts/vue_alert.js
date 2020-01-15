import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import VueAlert from '~/vue_shared/components/alert.vue';

Vue.use(Translate);

export default () => {
  const el = document.getElementById('js-vue-alert');

  if (!el) {
    return false;
  }

  return new Vue({
    el,
    components: {
      VueAlert,
    },
    data() {
      const {
        dataset: {
          message,
          variant,
          title,
          dismissible,
          primaryButtonLink,
          primaryButtonText,
          secondaryButtonLink,
          secondaryButtonText,
        },
      } = this.$options.el;

      return {
        message,
        variant,
        title,
        dismissible,
        primaryButtonLink,
        primaryButtonText,
        secondaryButtonLink,
        secondaryButtonText,
      };
    },

    render(createElement) {
      return createElement('vue-alert', {
        props: {
          message: this.message,
          variant: this.variant,
          title: this.title,
          dismissible: this.dismissible,
          primaryButtonLink: this.primaryButtonLink,
          primaryButtonText: this.primaryButtonText,
          secondaryButtonLink: this.secondaryButtonLink,
          secondaryButtonText: this.secondaryButtonText,
        },
      });
    },
  });
};
