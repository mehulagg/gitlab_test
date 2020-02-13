import Vue from 'vue';
import CiVariableSettings from './components/ci_variable_settings.vue';
import createStore from './store';

export default () => {
  const el = document.getElementById('js-ci-project-variables');
  const { endpoint, projectId, group } = el.dataset;
  // get boolean value from rails passed string value
  const isGroup = group === 'true';

  const store = createStore({
    endpoint,
    projectId,
    isGroup,
  });

  return new Vue({
    el,
    store,
    components: {
      CiVariableSettings,
    },
    render(createElement) {
      return createElement('ci-variable-settings');
    },
  });
};
