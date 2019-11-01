<script>
import _ from 'underscore';
import { mapActions, mapState } from 'vuex';
import VueDraggable from 'vuedraggable';
import {
  GlDropdown,
  GlDropdownItem,
  GlModal,
  GlModalDirective,
  GlTooltipDirective,
} from '@gitlab/ui';
import { __, s__ } from '~/locale';
import createFlash from '~/flash';
import Icon from '~/vue_shared/components/icon.vue';
import { getParameterValues, mergeUrlParams } from '~/lib/utils/url_utility';
import invalidUrl from '~/lib/utils/invalid_url';
import PanelType from 'ee_else_ce/monitoring/components/panel_type.vue';
import DashboardHeader from './dashboard_header.vue';
import MonitorTimeSeriesChart from '../charts/time_series.vue';
import MonitorSingleStatChart from '../charts/single_stat.vue';
import GraphGroup from '../graph_group.vue';
import EmptyState from '../empty_state.vue';
import TrackEventDirective from '~/vue_shared/directives/track_event';
import {
  getTimeDiff,
  isValidDate,
  downloadCSVOptions,
  generateLinkToChartOptions,
} from '~/monitoring/utils';

export default {
  components: {
    VueDraggable,
    MonitorTimeSeriesChart,
    MonitorSingleStatChart,
    PanelType,
    GraphGroup,
    EmptyState,
    Icon,
    GlDropdown,
    GlDropdownItem,
    GlModal,
    DashboardHeader,
  },
  directives: {
    GlModal: GlModalDirective,
    GlTooltip: GlTooltipDirective,
    TrackEvent: TrackEventDirective,
  },
  props: {
    externalDashboardUrl: {
      type: String,
      required: false,
      default: '',
    },
    hasMetrics: {
      type: Boolean,
      required: false,
      default: true,
    },
    showPanels: {
      type: Boolean,
      required: false,
      default: true,
    },
    documentationPath: {
      type: String,
      required: true,
    },
    settingsPath: {
      type: String,
      required: true,
    },
    clustersPath: {
      type: String,
      required: true,
    },
    tagsPath: {
      type: String,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
    metricsEndpoint: {
      type: String,
      required: true,
    },
    deploymentsEndpoint: {
      type: String,
      required: false,
      default: null,
    },
    emptyGettingStartedSvgPath: {
      type: String,
      required: true,
    },
    emptyLoadingSvgPath: {
      type: String,
      required: true,
    },
    emptyNoDataSvgPath: {
      type: String,
      required: true,
    },
    emptyUnableToConnectSvgPath: {
      type: String,
      required: true,
    },
    environmentsEndpoint: {
      type: String,
      required: true,
    },
    currentEnvironmentName: {
      type: String,
      required: true,
    },
    customMetricsAvailable: {
      type: Boolean,
      required: false,
      default: false,
    },
    customMetricsPath: {
      type: String,
      required: false,
      default: invalidUrl,
    },
    validateQueryPath: {
      type: String,
      required: false,
      default: invalidUrl,
    },
    dashboardEndpoint: {
      type: String,
      required: false,
      default: invalidUrl,
    },
    currentDashboard: {
      type: String,
      required: false,
      default: '',
    },
    smallEmptyState: {
      type: Boolean,
      required: false,
      default: false,
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
  data() {
    return {
      state: 'gettingStarted',
      selectedTimeWindow: {},
    };
  },
  computed: {
    canAddMetrics() {
      return this.customMetricsAvailable && this.customMetricsPath.length;
    },
    ...mapState('monitoringDashboard', [
      'groups',
      'emptyState',
      'showEmptyState',
      'environments',
      'deploymentData',
      'metricsWithData',
      'useDashboardEndpoint',
      'allDashboards',
      'isRearrangingPanels',
      'additionalPanelTypesEnabled',
    ]),
    firstDashboard() {
      return this.allDashboards[0] || {};
    },
    selectedDashboardText() {
      return this.currentDashboard || this.firstDashboard.display_name;
    },
    alertWidgetAvailable() {
      return IS_EE && this.prometheusAlertsAvailable && this.alertsEndpoint;
    },
  },
  created() {
    this.setEndpoints({
      metricsEndpoint: this.metricsEndpoint,
      environmentsEndpoint: this.environmentsEndpoint,
      deploymentsEndpoint: this.deploymentsEndpoint,
      dashboardEndpoint: this.dashboardEndpoint,
      currentDashboard: this.currentDashboard,
      projectPath: this.projectPath,
    });
  },
  mounted() {
    if (!this.hasMetrics) {
      this.setGettingStartedEmptyState();
    } else {
      const defaultRange = getTimeDiff();
      const start = getParameterValues('start')[0] || defaultRange.start;
      const end = getParameterValues('end')[0] || defaultRange.end;

      const range = {
        start,
        end,
      };

      this.selectedTimeWindow = range;

      if (!isValidDate(start) || !isValidDate(end)) {
        this.showInvalidDateError();
      } else {
        this.fetchData(range);
      }
    }
  },
  methods: {
    ...mapActions('monitoringDashboard', [
      'fetchData',
      'setGettingStartedEmptyState',
      'setEndpoints',
      'setDashboardEnabled',
    ]),
    chartsWithData(charts) {
      if (!this.useDashboardEndpoint) {
        return charts;
      }
      return charts.filter(chart =>
        chart.metrics.some(metric => this.metricsWithData.includes(metric.metric_id)),
      );
    },
    csvText(graphData) {
      const chartData = graphData.queries[0].result[0].values;
      const yLabel = graphData.y_label;
      const header = `timestamp,${yLabel}\r\n`; // eslint-disable-line @gitlab/i18n/no-non-i18n-strings
      return chartData.reduce((csv, data) => {
        const row = data.join(',');
        return `${csv}${row}\r\n`;
      }, header);
    },
    downloadCsv(graphData) {
      const data = new Blob([this.csvText(graphData)], { type: 'text/plain' });
      return window.URL.createObjectURL(data);
    },
    // TODO: BEGIN, Duplicated code with panel_type until feature flag is removed
    // Issue number: https://gitlab.com/gitlab-org/gitlab-foss/issues/63845
    getGraphAlerts(queries) {
      if (!this.allAlerts) return {};
      const metricIdsForChart = queries.map(q => q.metricId);
      return _.pick(this.allAlerts, alert => metricIdsForChart.includes(alert.metricId));
    },
    getGraphAlertValues(queries) {
      return Object.values(this.getGraphAlerts(queries));
    },
    showToast() {
      this.$toast.show(__('Link copied'));
    },
    // TODO: END
    removeGraph(metrics, graphIndex) {
      // At present graphs will not be removed, they should removed using the vuex store
      // See https://gitlab.com/gitlab-org/gitlab/issues/27835
      metrics.splice(graphIndex, 1);
    },
    showInvalidDateError() {
      createFlash(s__('Metrics|Link contains an invalid time window.'));
    },
    generateLink(group, title, yLabel) {
      const dashboard = this.currentDashboard || this.firstDashboard.path;
      const params = _.pick({ dashboard, group, title, y_label: yLabel }, value => value != null);
      return mergeUrlParams(params, window.location.href);
    },
    groupHasData(group) {
      return this.chartsWithData(group.metrics).length > 0;
    },
    downloadCSVOptions,
    generateLinkToChartOptions,
  },
};
</script>

<template>
  <div class="prometheus-graphs">
    <dashboard-header
      :current-environment-name="currentEnvironmentName"
      :external-dashboard-url="externalDashboardUrl"
      :selected-time-window="selectedTimeWindow"
      :current-dashboard="currentDashboard"
      :custom-metrics-available="customMetricsAvailable"
      :custom-metrics-path="customMetricsPath"
      :rearrange-panels-available="isRearrangingPanels"
      :validate-query-path="validateQueryPath"
    />

    <div v-if="!showEmptyState">
      <graph-group
        v-for="(groupData, index) in groups"
        :key="`${groupData.group}.${groupData.priority}`"
        :name="groupData.group"
        :show-panels="showPanels"
        :collapse-group="groupHasData(groupData)"
      >
        <template v-if="additionalPanelTypesEnabled">
          <vue-draggable
            :list="groupData.metrics"
            group="metrics-dashboard"
            :component-data="{ attrs: { class: 'row mx-0 w-100' } }"
            :disabled="!isRearrangingPanels"
          >
            <div
              v-for="(graphData, graphIndex) in groupData.metrics"
              :key="`panel-type-${graphIndex}`"
              class="col-12 col-lg-6 px-2 mb-2 draggable"
              :class="{ 'draggable-enabled': isRearrangingPanels }"
            >
              <div class="position-relative draggable-panel js-draggable-panel">
                <div
                  v-if="isRearrangingPanels"
                  class="draggable-remove js-draggable-remove p-2 w-100 position-absolute d-flex justify-content-end"
                  @click="removeGraph(groupData.metrics, graphIndex)"
                >
                  <a class="mx-2 p-2 draggable-remove-link" :aria-label="__('Remove')"
                    ><icon name="close"
                  /></a>
                </div>

                <panel-type
                  :clipboard-text="
                    generateLink(groupData.group, graphData.title, graphData.y_label)
                  "
                  :graph-data="graphData"
                  :alerts-endpoint="alertsEndpoint"
                  :prometheus-alerts-available="prometheusAlertsAvailable"
                  :index="`${index}-${graphIndex}`"
                />
              </div>
            </div>
          </vue-draggable>
        </template>
        <template v-else>
          <monitor-time-series-chart
            v-for="(graphData, graphIndex) in chartsWithData(groupData.metrics)"
            :key="graphIndex"
            class="col-12 col-lg-6 pb-3"
            :graph-data="graphData"
            :deployment-data="deploymentData"
            :thresholds="getGraphAlertValues(graphData.queries)"
            :project-path="projectPath"
            group-id="monitor-time-series-chart"
          >
            <div
              class="d-flex align-items-center"
              :class="alertWidgetAvailable ? 'justify-content-between' : 'justify-content-end'"
            >
              <alert-widget
                v-if="alertWidgetAvailable && graphData"
                :modal-id="`alert-modal-${index}-${graphIndex}`"
                :alerts-endpoint="alertsEndpoint"
                :relevant-queries="graphData.queries"
                :alerts-to-manage="getGraphAlerts(graphData.queries)"
                @setAlerts="setAlerts"
              />
              <gl-dropdown
                v-gl-tooltip
                class="ml-2 mr-3"
                toggle-class="btn btn-transparent border-0"
                :right="true"
                :no-caret="true"
                :title="__('More actions')"
              >
                <template slot="button-content">
                  <icon name="ellipsis_v" class="text-secondary" />
                </template>
                <gl-dropdown-item
                  v-track-event="downloadCSVOptions(graphData.title)"
                  :href="downloadCsv(graphData)"
                  download="chart_metrics.csv"
                >
                  {{ __('Download CSV') }}
                </gl-dropdown-item>
                <gl-dropdown-item
                  v-track-event="
                    generateLinkToChartOptions(
                      generateLink(groupData.group, graphData.title, graphData.y_label),
                    )
                  "
                  class="js-chart-link"
                  :data-clipboard-text="
                    generateLink(groupData.group, graphData.title, graphData.y_label)
                  "
                  @click="showToast"
                >
                  {{ __('Generate link to chart') }}
                </gl-dropdown-item>
                <gl-dropdown-item
                  v-if="alertWidgetAvailable"
                  v-gl-modal="`alert-modal-${index}-${graphIndex}`"
                >
                  {{ __('Alerts') }}
                </gl-dropdown-item>
              </gl-dropdown>
            </div>
          </monitor-time-series-chart>
        </template>
      </graph-group>
    </div>
    <empty-state
      v-else
      :selected-state="emptyState"
      :documentation-path="documentationPath"
      :settings-path="settingsPath"
      :clusters-path="clustersPath"
      :empty-getting-started-svg-path="emptyGettingStartedSvgPath"
      :empty-loading-svg-path="emptyLoadingSvgPath"
      :empty-no-data-svg-path="emptyNoDataSvgPath"
      :empty-unable-to-connect-svg-path="emptyUnableToConnectSvgPath"
      :compact="smallEmptyState"
    />
  </div>
</template>
