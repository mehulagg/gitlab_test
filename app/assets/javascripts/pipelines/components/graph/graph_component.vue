<script>
import { GlLoadingIcon } from '@gitlab/ui';
import StageColumnComponent from './stage_column_component.vue';
import GraphMixin from '../../mixins/graph_component_mixin';
import GraphWidthMixin from '../../mixins/graph_width_mixin';
import LinkedPipelinesColumn from './linked_pipelines_column.vue';
import GraphBundleMixin from '../../mixins/graph_pipeline_bundle_mixin';
import getPipelineDetails from '../../graphql/queries/get_pipeline_details.query.graphql';
import { UPSTREAM, DOWNSTREAM } from './constants';

export default {
  name: 'PipelineGraph',
  components: {
    StageColumnComponent,
    GlLoadingIcon,
    // LinkedPipelinesColumn,
  },
  mixins: [
    GraphMixin,
    GraphWidthMixin,
    // GraphBundleMixin
  ],
  inject: {
    pipelineIid: {
      default: '',
    },
    pipelineProjectPath: {
      default: '',
    },
  },
//   props: {
      // will come from GraphQL
//     isLoading: {
//       type: Boolean,
//       required: true,
//     },
      // ADD WITH GRAPHQL: this.mediator.store.state.pipeline
//     pipeline: {
//       type: Object,
//       required: true,
//     },
//     isLinkedPipeline: {
//       type: Boolean,
//       required: false,
//       default: false,
//     },
//     mediator: {
//       type: Object,
//       required: true,
//     },
//     type: {
//       type: String,
//       required: false,
//       default: 'main',
//     },
//   },

  data() {
    return {
      stages: null,
      // downstreamMarginTop: null,
      jobName: null,
      // pipelineExpanded: {
      //   jobName: '',
      //   expanded: false,
      // },
    };
  },
  apollo: {
    stages: {
      query: getPipelineDetails,
      variables() {
        return {
          projectPath: this.pipelineProjectPath,
          iid: this.pipelineIid,
        };
      },
      update(data) {
        console.log('in update', data);
        const {
          stages: { nodes: stages },
        } = data.project.pipeline;

        const unwrappedNestedGroups = stages
          .map(({ name, groups: { nodes: groups } }) => {
            return { name, groups }
          });

        console.log('UNG:', unwrappedNestedGroups);

        // const nodes = unwrappedNestedGroups.map(group => {
        //   const jobs = group.jobs.nodes.map(({ name, needs }) => {
        //     return { name, needs: needs.nodes.map(need => need.name) };
        //   });
        //
        //   return { ...group, jobs };
        // });

        const nodes = unwrappedNestedGroups.map(({ name, groups }) => {
          const groupsWithJobs = groups.map((group => {
              const jobs = group.jobs.nodes.map(({ name, needs }) => {
                return { name, needs: needs.nodes.map(need => need.name) };
              });

            return { ...group, jobs };
          }));

          return { name, groups: groupsWithJobs }
        });

        console.log('nodes', nodes);

        return nodes;
      },
      error(err){
        console.error('graphQL error:', err);
      }
    }
  },
  computed: {
  },
  methods: {
    hasOnlyOneJob(stage) {
      return stage.groups.length === 1;
    },
  }
  //  USE APOLLO HERE TO POST PIPELINE TO STATE USING AXIOS + @CLIENT
//   computed: {
//     hasTriggeredBy() {
//       return (
//         this.type !== this.$options.downstream &&
//         this.triggeredByPipelines &&
//         this.pipeline.triggered_by !== null
//       );
//     },
//     triggeredByPipelines() {
//       return this.pipeline.triggered_by;
//     },
//     hasTriggered() {
//       return (
//         this.type !== this.$options.upstream &&
//         this.triggeredPipelines &&
//         this.pipeline.triggered.length > 0
//       );
//     },
//     triggeredPipelines() {
//       return this.pipeline.triggered;
//     },
//     expandedTriggeredBy() {
//       return (
//         this.pipeline.triggered_by &&
//         Array.isArray(this.pipeline.triggered_by) &&
//         this.pipeline.triggered_by.find(el => el.isExpanded)
//       );
//     },
//     expandedTriggered() {
//       return this.pipeline.triggered && this.pipeline.triggered.find(el => el.isExpanded);
//     },
//     pipelineTypeUpstream() {
//       return this.type !== this.$options.downstream && this.expandedTriggeredBy;
//     },
//     pipelineTypeDownstream() {
//       return this.type !== this.$options.upstream && this.expandedTriggered;
//     },
//     pipelineProjectId() {
//       return this.pipeline.project.id;
//     },
//   },
//   methods: {
//     handleClickedDownstream(pipeline, clickedIndex, downstreamNode) {
//       /**
//        * Calculates the margin top of the clicked downstream pipeline by
//        * subtracting the clicked downstream pipelines offsetTop by it's parent's
//        * offsetTop and then subtracting 15
//        */
//       this.downstreamMarginTop = this.calculateMarginTop(downstreamNode, 15);
//
//       /**
//        * If the expanded trigger is defined and the id is different than the
//        * pipeline we clicked, then it means we clicked on a sibling downstream link
//        * and we want to reset the pipeline store. Triggering the reset without
//        * this condition would mean not allowing downstreams of downstreams to expand
//        */
//       if (this.expandedTriggered?.id !== pipeline.id) {
//         this.$emit('onResetTriggered', this.pipeline, pipeline);
//       }
//
//       this.$emit('onClickTriggered', pipeline);
//     },
//     calculateMarginTop(downstreamNode, pixelDiff) {
//       return `${downstreamNode.offsetTop - downstreamNode.offsetParent.offsetTop - pixelDiff}px`;
//     },

//     hasUpstream(index) {
//       return index === 0 && this.hasTriggeredBy;
//     },
//     setJob(jobName) {
//       this.jobName = jobName;
//     },
//     setPipelineExpanded(jobName, expanded) {
//       if (expanded) {
//         this.pipelineExpanded = {
//           jobName,
//           expanded,
//         };
//       } else {
//         this.pipelineExpanded = {
//           expanded,
//           jobName: '',
//         };
//       }
//     },
//   },
};
</script>
<template>
  <div>
    <div id="inner-graph-buddy" :style="{paddingLeft: '400px'}">hi</div>
    <div class="build-content middle-block js-pipeline-graph" :style=" {paddingLeft: '400px'}">
      <div
        class="pipeline-visualization pipeline-graph"
      >
        <div
          :style="{
            paddingLeft: `${graphLeftPadding}px`,
            paddingRight: `${graphRightPadding}px`,
          }"
        >

        <!-- <gl-loading-icon v-if="$apollo.loading" class="m-auto" size="lg" /> -->

        <ul
            class="stage-column-list align-top"
            v-if="!$apollo.loading"
          >
          <!-- replace these below later: -->
          <!-- @refreshPipelineGraph="refreshPipelineGraph" -->
          <!-- :job-hovered="jobName" -->
            <stage-column-component
              v-for="(stage, index) in stages"
              :key="stage.name"
              :class="{
                'has-only-one-job': hasOnlyOneJob(stage),
                'gl-mr-26': shouldAddRightMargin(index),
              }"
              :title="capitalizeStageName(stage.stageName)"
              :groups="stage.groups"
              :stage-connector-class="stageConnectorClass(index, stage)"
              :is-first-column="isFirstColumn(index)"
              :action="stage.status.action"
            />
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>
