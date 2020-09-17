import Vue from 'vue';
import VueApollo from 'vue-apollo';
import axios from '~/lib/utils/axios_utils';
import createDefaultClient from '~/lib/graphql';
import CILint from './components/ci_lint.vue';

Vue.use(VueApollo);

const resolvers = {
  Mutation: {
    lintCI: (_, { endpoint, content, dry_run }) => {
      return axios.post(endpoint, { content, dry_run }).then(({ data }) => data);
    },
  },
};

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(resolvers),
});

export default (containerId = '#js-ci-lint') => {
  const containerEl = document.querySelector(containerId);
  const { endpoint, helpPagePath } = containerEl.dataset;

  return new Vue({
    el: containerEl,
    apolloProvider,
    render(createElement) {
      return createElement(CILint, {
        props: {
          endpoint,
          helpPagePath,
        },
      });
    },
  });
};
