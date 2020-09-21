import Vue from 'vue';
import { deprecatedCreateFlash as Flash } from '~/flash';
import Translate from '~/vue_shared/translate';
import { __ } from '~/locale';
import { setUrlFragment, redirectTo } from '~/lib/utils/url_utility';
import pipelineGraphLegacy from './components/graph/graph_component_legacy.vue';
import createDagApp from './pipeline_details_dag';
import createPipelinesDetailApp from './pipeline_details_graph';
import GraphBundleMixin from './mixins/graph_pipeline_bundle_mixin';
import PipelinesMediator from './pipeline_details_mediator';
import pipelineHeader from './components/header_component.vue';
import eventHub from './event_hub';
import TestReports from './components/test_reports/test_reports.vue';
import createTestReportsStore from './stores/test_reports';

Vue.use(Translate);

// Replace with actual feature flag check
const showNewGraph = true;

const legacyCreatePipelinesDetailApp = mediator => {
  // eslint-disable-next-line no-new
  new Vue({
    el: '#js-pipeline-graph-vue',
    components: {
      pipelineGraphLegacy,
    },
    mixins: [GraphBundleMixin],
    data() {
      return {
        mediator,
      };
    },
    render(createElement) {
      return createElement('pipeline-graph-legacy', {
        props: {
          isLoading: this.mediator.state.isLoading,
          pipeline: this.mediator.store.state.pipeline,
          mediator: this.mediator,
        },
        on: {
          refreshPipelineGraph: this.requestRefreshPipelineGraph,
          onResetTriggered: (parentPipeline, pipeline) =>
            this.resetTriggeredPipelines(parentPipeline, pipeline),
          onClickTriggeredBy: pipeline => this.clickTriggeredByPipeline(pipeline),
          onClickTriggered: pipeline => this.clickTriggeredPipeline(pipeline),
        },
      });
    },
  });
};

const createPipelineHeaderApp = mediator => {
  // eslint-disable-next-line no-new
  new Vue({
    el: '#js-pipeline-header-vue',
    components: {
      pipelineHeader,
    },
    data() {
      return {
        mediator,
      };
    },
    created() {
      eventHub.$on('headerPostAction', this.postAction);
      eventHub.$on('headerDeleteAction', this.deleteAction);
    },
    beforeDestroy() {
      eventHub.$off('headerPostAction', this.postAction);
      eventHub.$off('headerDeleteAction', this.deleteAction);
    },
    methods: {
      postAction(path) {
        this.mediator.service
          .postAction(path)
          .then(() => this.mediator.refreshPipeline())
          .catch(() => Flash(__('An error occurred while making the request.')));
      },
      deleteAction(path) {
        this.mediator.stopPipelinePoll();
        this.mediator.service
          .deleteAction(path)
          .then(({ request }) => redirectTo(setUrlFragment(request.responseURL, 'delete_success')))
          .catch(() => Flash(__('An error occurred while deleting the pipeline.')));
      },
    },
    render(createElement) {
      return createElement('pipeline-header', {
        props: {
          isLoading: this.mediator.state.isLoading,
          pipeline: this.mediator.store.state.pipeline,
        },
      });
    },
  });
};

const createTestDetails = () => {
  const el = document.querySelector('#js-pipeline-tests-detail');
  const { summaryEndpoint, suiteEndpoint } = el?.dataset || {};

  const testReportsStore = createTestReportsStore({
    summaryEndpoint,
    suiteEndpoint,
  });

  // eslint-disable-next-line no-new
  new Vue({
    el,
    components: {
      TestReports,
    },
    store: testReportsStore,
    render(createElement) {
      return createElement('test-reports');
    },
  });
};

export default () => {
  const { dataset } = document.querySelector('.js-pipeline-details-vue');
  const mediator = new PipelinesMediator({ endpoint: dataset.endpoint });
  mediator.fetchPipeline();

  if (showNewGraph) {
    const { pipelineProjectPath, pipelineIid } = dataset;
    createPipelinesDetailApp(pipelineProjectPath, pipelineIid);
  } else {
    legacyCreatePipelinesDetailApp(mediator);
  }

  createPipelineHeaderApp(mediator);
  createTestDetails();
  createDagApp();
};
