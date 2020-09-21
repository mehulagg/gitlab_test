import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import pipelineGraph from './components/graph/graph_component.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});


const createPipelinesDetailApp = (pipelineProjectPath, pipelineIid) => {
  // eslint-disable-next-line no-new
  new Vue({
    el: '#js-pipeline-graph-vue',
    components: {
      pipelineGraph,
    },
    apolloProvider,
    provide: {
      pipelineProjectPath,
      pipelineIid,
    },
    render(createElement) {
      return createElement('pipeline-graph')
    }
  });
};

export default createPipelinesDetailApp;
