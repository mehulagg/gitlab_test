import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import SASTConfigurationApp from './components/app.vue';

export default function init() {
  const el = document.querySelector('.js-sast-configuration');

  if (!el) {
    return undefined;
  }

  Vue.use(VueApollo);

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  const {
    securityConfigurationPath,
    createSastMergeRequestPath,
    projectPath,
    sastAnalyzersDocumentationPath,
    sastDocumentationPath,
  } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    provide: {
      securityConfigurationPath,
      createSastMergeRequestPath,
      projectPath,
      sastAnalyzersDocumentationPath,
      sastDocumentationPath,
    },
    render(createElement) {
      return createElement(SASTConfigurationApp);
    },
  });
}
