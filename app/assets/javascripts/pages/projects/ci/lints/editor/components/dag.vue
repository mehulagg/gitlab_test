<script>
import { GlAlert, GlSprintf } from '@gitlab/ui';
import { isEmpty } from 'lodash';
import { __ } from '~/locale';
import DagGraph from './dag_graph.vue';
import DagAnnotations from './dag_annotations.vue';
import {
  DEFAULT,
  PARSE_FAILURE,
  UNSUPPORTED_DATA,
  ADD_NOTE,
  REMOVE_NOTE,
  REPLACE_NOTES,
} from '../utils/constants';
import { parseData } from '../utils/parsing_utils';

export default {
  // eslint-disable-next-line @gitlab/require-i18n-strings
  name: 'Dag',
  components: {
    DagAnnotations,
    DagGraph,
    GlAlert,
    GlSprintf,
  },
  props: {
    graphData: {
      type: Object,
      required: true,
      default: () => {},
    },
  },
  data() {
    return {
      parsedGraphData: {},
      annotationsMap: {},
      failureType: null,
      showFailureAlert: false,
      showBetaInfo: true,
      hasNoDependentJobs: false,
    };
  },
  errorTexts: {
    [PARSE_FAILURE]: __('There was an error parsing the data for this graph.'),
    [UNSUPPORTED_DATA]: __('DAG visualization requires at least 3 dependent jobs.'),
    [DEFAULT]: __('An unknown error occurred while loading this graph.'),
  },
  computed: {
    failure() {
      switch (this.failureType) {
        case PARSE_FAILURE:
          return {
            text: this.$options.errorTexts[PARSE_FAILURE],
            variant: 'danger',
          };
        case UNSUPPORTED_DATA:
          return {
            text: this.$options.errorTexts[UNSUPPORTED_DATA],
            variant: 'info',
          };
        default:
          return {
            text: this.$options.errorTexts[DEFAULT],
            vatiant: 'danger',
          };
      }
    },
    shouldDisplayAnnotations() {
      return !isEmpty(this.annotationsMap);
    },
    shouldDisplayGraph() {
      return Boolean(!this.showFailureAlert && this.parsedGraphData);
    },
  },
  created() {
    this.processGraphData(this.graphData);
  },
  methods: {
    addAnnotationToMap({ uid, source, target }) {
      this.$set(this.annotationsMap, uid, { source, target });
    },
    processGraphData(data) {
      let parsed;

      try {
        parsed = parseData(data.stages);
        this.resetFailure();
      } catch {
        this.reportFailure(PARSE_FAILURE);
        return;
      }

      if (parsed.links.length === 1) {
        this.reportFailure(UNSUPPORTED_DATA);
        return;
      }

      // If there are no links, we don't report failure
      // as it simply means the user does not use job dependencies
      if (parsed.links.length === 0) {
        this.hasNoDependentJobs = true;
        return;
      }

      this.parsedGraphData = parsed;
    },
    hideAlert() {
      this.showFailureAlert = false;
    },
    hideBetaInfo() {
      this.showBetaInfo = false;
    },
    removeAnnotationFromMap({ uid }) {
      this.$delete(this.annotationsMap, uid);
    },
    reportFailure(type) {
      this.showFailureAlert = true;
      this.failureType = type;
    },
    resetFailure() {
      this.showFailureAlert = false;
      this.failureType = null;
    },
    updateAnnotation({ type, data }) {
      switch (type) {
        case ADD_NOTE:
          this.addAnnotationToMap(data);
          break;
        case REMOVE_NOTE:
          this.removeAnnotationFromMap(data);
          break;
        case REPLACE_NOTES:
          this.annotationsMap = data;
          break;
        default:
          break;
      }
    },
  },
  watch: {
    graphData(val) {
      this.processGraphData(val);
    },
  },
};
</script>
<template>
  <div>
    <gl-alert v-if="showFailureAlert" :variant="failure.variant" @dismiss="hideAlert">
      {{ failure.text }}
    </gl-alert>
    <div class="gl-relative">
      <dag-annotations v-if="shouldDisplayAnnotations" :annotations="annotationsMap" />
      <dag-graph
        v-if="shouldDisplayGraph"
        :graph-data="parsedGraphData"
        @onFailure="reportFailure"
        @update-annotation="updateAnnotation"
      />
      <gl-sprintf message="Nothing to show yet" />
    </div>
  </div>
</template>
