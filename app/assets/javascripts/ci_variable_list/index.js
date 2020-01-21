import Vue from 'vue';
import CiVariableSettings from './components/ci_variable_settings.vue';
import store from './store';

export default () => {
  const el = document.getElementById('js-ci-project-variables');
  return new Vue({
    el,
    store,
    components: {
      CiVariableSettings,
    },
    data() {
      const { dataset } = this.$options.el;
      return {
        endpoint: dataset.endpoint,
        projectId: dataset.projectId,
        isGroup: dataset.group,
      };
    },
    render(createElement) {
      if (this.isGroup === undefined) {
        this.isGroup = false;
      }
      return createElement('ci-variable-settings', {
        props: {
          endpoint: this.endpoint,
          projectId: this.projectId,
          isGroup: this.isGroup,
        },
      });
    },
  });
};
