import Vue from 'vue';
import NewDeployToken from './components/new_deploy_token.vue';

export default () => {
  const el = document.getElementById('js-new-deploy-token');

  const { createNewTokenPath, containerRegistryEnabled } = el.dataset;
  return new Vue({
    el,
    components: {
      NewDeployToken,
    },
    render(createElement) {
      return createElement(NewDeployToken, {
        props: {
          createNewTokenPath,
          containerRegistryEnabled: Boolean(containerRegistryEnabled),
        },
      });
    },
  });
};
