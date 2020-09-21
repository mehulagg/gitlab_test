import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import pipelineGraph from './components/graph/graph_component.vue';

Vue.use(VueApollo);

const mockStatus = {
  icon: 'status_canceled',
  action: {
    button_title: 'Retry this job',
    icon: 'retry',
    method: 'post',
    path: '/example/example-project/-/jobs/id/retry',
    title: 'Retry',
  }
}

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient({
    CiJob: {
      status() {
        return mockStatus;
      }
    },
    CiGroup: {
      status() {
        return mockStatus;
      }
    },
    CiStage: {
      status() {
        return {
          action: { }
        }
      }
    },
  }),
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
