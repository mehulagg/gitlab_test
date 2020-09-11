import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import pipelineGraph from './components/graph/graph_component.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});


const createPipelinesDetailApp = () => {
  // eslint-disable-next-line no-new
  new Vue({
    el: '#js-pipeline-graph-vue',
    components: {
      pipelineGraph,
    },
    apolloProvider,
    render(createElement) {
      return createElement('pipeline-graph')
    }
  });
};

export default createPipelinesDetailApp;
