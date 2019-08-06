<script>
import { mapState } from 'vuex';
import _ from 'underscore';
import { GlDropdown, GlDropdownItem, GlModal, GlModalDirective } from '@gitlab/ui';
import ChartActions from 'ee_else_ce/monitoring/components/chart_actions.vue';
import MonitorAreaChart from './charts/area.vue';
import MonitorSingleStatChart from './charts/single_stat.vue';
import MonitorEmptyChart from './charts/empty_chart.vue';

export default {
  components: {
    ChartActions,
    MonitorAreaChart,
    MonitorSingleStatChart,
    MonitorEmptyChart,
    GlDropdown,
    GlDropdownItem,
    GlModal,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  props: {
    graphData: {
      type: Object,
      required: true,
    },
    dashboardWidth: {
      type: Number,
      required: true,
    },
    index: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    ...mapState('monitoringDashboard', ['deploymentData', 'projectPath']),
    graphDataHasMetrics() {
      return this.graphData.queries[0].result.length > 0;
    },
  },
  methods: {
    isPanelType(type) {
      return this.graphData.type && this.graphData.type === type;
    },
  },
};
</script>
<template>
  <monitor-single-stat-chart
    v-if="isPanelType('single-stat') && graphDataHasMetrics"
    :graph-data="graphData"
  />
  <monitor-area-chart
    v-else-if="graphDataHasMetrics"
    :graph-data="graphData"
    :deployment-data="deploymentData"
    :project-path="projectPath"
    :thresholds="getGraphAlertValues(graphData.queries)"
    :container-width="dashboardWidth"
    group-id="monitor-area-chart"
  >
    <chart-actions
      :index="index"
      :graph-data="graphData"
    />
  </monitor-area-chart>
  <monitor-empty-chart v-else :graph-title="graphData.title" />
</template>
