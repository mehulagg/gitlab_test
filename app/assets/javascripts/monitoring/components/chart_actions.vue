<script>
import { mapState } from 'vuex';
import _ from 'underscore';
import { GlDropdown, GlDropdownItem, GlModal, GlModalDirective } from '@gitlab/ui';
import MonitorAreaChart from './charts/area.vue';
import MonitorSingleStatChart from './charts/single_stat.vue';
import MonitorEmptyChart from './charts/empty_chart.vue';

export default {
  components: {
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
    index: {
      type: String,
      required: false,
      default: '',
    },
    alertsEndpoint: {
      type: String,
      required: false,
      default: null,
    },
    prometheusAlertsAvailable: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    ...mapState('monitoringDashboard', ['deploymentData', 'projectPath']),
    alertWidgetAvailable() {
      return IS_EE && this.prometheusAlertsAvailable && this.alertsEndpoint && this.graphData;
    },
    graphDataHasMetrics() {
      return this.graphData.queries[0].result.length > 0;
    },
  },
  methods: {
    getGraphAlerts(queries) {
      if (!this.allAlerts) return {};
      const metricIdsForChart = queries.map(q => q.metricId);
      return _.pick(this.allAlerts, alert => metricIdsForChart.includes(alert.metricId));
    },
    getGraphAlertValues(queries) {
      return Object.values(this.getGraphAlerts(queries));
    },
    isPanelType(type) {
      return this.graphData.type && this.graphData.type === type;
    },
  },
  
};
</script>

<template>
  <div class="d-flex align-items-center">
    <alert-widget
      v-if="alertWidgetAvailable && graphData"
      :modal-id="`alert-modal-${index}`"
      :alerts-endpoint="alertsEndpoint"
      :relevant-queries="graphData.queries"
      :alerts-to-manage="getGraphAlerts(graphData.queries)"
      @setAlerts="setAlerts"
    />
    <gl-dropdown
      v-if="alertWidgetAvailable"
      v-gl-tooltip
      class="mx-2"
      toggle-class="btn btn-transparent border-0"
      :right="true"
      :no-caret="true"
      :title="__('More actions')"
    >
      <template slot="button-content">
        <icon name="ellipsis_v" class="text-secondary" />
      </template>
      <gl-dropdown-item v-if="alertWidgetAvailable" v-gl-modal="`alert-modal-${index}`">
        {{ __('Alerts') }}
      </gl-dropdown-item>
    </gl-dropdown>
  </div>
</template>
