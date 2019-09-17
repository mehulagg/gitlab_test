<script>
import { mapState, mapActions, mapGetters } from 'vuex';
import {
  GlEmptyState,
  GlLoadingIcon,
  GlDropdown,
  GlDropdownItem,
  GlButton,
  GlTooltipDirective,
} from '@gitlab/ui';
import { GlColumnChart } from '@gitlab/ui/dist/charts';
import Icon from '~/vue_shared/components/icon.vue';
import MetricChart from './metric_chart.vue';
import MergeRequestTable from './mr_table.vue';
import { chartKeys, metricTypes } from '../constants';

export default {
  components: {
    GlEmptyState,
    GlLoadingIcon,
    MetricChart,
    GlDropdown,
    GlDropdownItem,
    GlColumnChart,
    GlButton,
    Icon,
    MergeRequestTable,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
    emptyStateSvgPath: {
      type: String,
      required: true,
    },
    noAccessSvgPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      chartKeys,
    };
  },
  computed: {
    ...mapState('filters', ['groupNamespace']),
    ...mapState('table', [
      'isLoadingTable',
      'mergeRequests',
      'pageInfo',
      'sortFields',
      'columnMetric',
    ]),
    ...mapGetters('charts', [
      'chartLoading',
      'getChartData',
      'getColumnChartDatazoomOption',
      'getMetricDropdownLabel',
      'getSelectedMetric',
      'hasNoAccessError',
      'mainChartHasNoData',
    ]),
    ...mapGetters('table', [
      'sortFieldDropdownLabel',
      'sortIcon',
      'sortTooltipTitle',
      'getColumnOptions',
      'columnMetricLabel',
      'isSelectedSortField',
    ]),
    showAppContent() {
      return this.groupNamespace && !this.hasNoAccessError;
    },
    showHasNoData() {
      return !this.chartLoading(chartKeys.main) && this.mainChartHasNoData;
    },
  },
  mounted() {
    this.setEndpoint(this.endpoint);
  },
  methods: {
    ...mapActions(['setEndpoint']),
    ...mapActions('charts', ['fetchChartData', 'setMetricType', 'chartItemClicked']),
    ...mapActions('table', [
      'setSortField',
      'setMergeRequestsPage',
      'toggleSortOrder',
      'setColumnMetric',
    ]),
    onMainChartItemClicked({ params }) {
      const itemValue = params.data.value[0];
      this.chartItemClicked({ chartKey: this.chartKeys.main, item: itemValue });
    },
    getMetricTypes(chartKey) {
      return metricTypes.filter(m => m.chart === chartKey);
    },
    getColumnChartOption(chartKey) {
      return {
        yAxis: {
          axisLabel: {
            formatter: value => value,
          },
        },
        ...this.getColumnChartDatazoomOption(chartKey),
      };
    },
  },
};
</script>

<template>
  <div>
    <gl-empty-state
      v-if="!groupNamespace"
      class="js-empty-state"
      :title="
        __('Productivity analytics can help identify the problems that are delaying your team')
      "
      :svg-path="emptyStateSvgPath"
      :description="
        __(
          'Start by choosing a group to start exploring the merge requests in that group. You can then proceed to filter by projects, labels, milestones and authors.',
        )
      "
    />
    <gl-empty-state
      v-if="hasNoAccessError"
      class="js-empty-state"
      :title="__('You don’t have acces to Productivity Analaytics in this group')"
      :svg-path="noAccessSvgPath"
      :description="
        __(
          'Only ‘Reporter’ roles and above on tiers Premium / Silver and above can see Productivity Analytics.',
        )
      "
    />
    <template v-if="showAppContent">
      <h4>{{ __('Merge Requests') }}</h4>
      <div v-if="showHasNoData" class="bs-callout bs-callout-info">
        {{
          s__(
            'ProductivityAnalytics|There is no data available for the applied filters. Please change your selection.',
          )
        }}
      </div>
      <template v-else>
        <div class="qa-time-to-merge mb-4">
          <metric-chart
            :title="__('Time to merge')"
            :description="
              __('You can filter by \'days to merge\' by clicking on the columns in the chart.')
            "
            :is-loading="chartLoading(chartKeys.main)"
            :chart-data="getChartData(chartKeys.main)"
          >
            <gl-column-chart
              :data="{ full: getChartData(chartKeys.main) }"
              :option="getColumnChartOption(chartKeys.main)"
              :y-axis-title="__('Merge requests')"
              :x-axis-title="__('Days')"
              x-axis-type="category"
              @chartItemClicked="onMainChartItemClicked"
            />
          </metric-chart>
        </div>

        <div class="row">
          <div class="qa-time-based col-lg-6 col-sm-12 mb-4">
            <metric-chart
              :is-loading="chartLoading(chartKeys.timeBasedHistogram)"
              :metric-types="getMetricTypes(chartKeys.timeBasedHistogram)"
              :selected-metric="getSelectedMetric(chartKeys.timeBasedHistogram)"
              :chart-data="getChartData(chartKeys.timeBasedHistogram)"
              @metricTypeChange="
                metric =>
                  setMetricType({ metricType: metric, chartKey: chartKeys.timeBasedHistogram })
              "
            >
              <gl-column-chart
                :data="{ full: getChartData(chartKeys.timeBasedHistogram) }"
                :option="getColumnChartOption(chartKeys.timeBasedHistogram)"
                :y-axis-title="__('Merge requests')"
                :x-axis-title="__('Hours')"
                x-axis-type="category"
              />
            </metric-chart>
          </div>

          <div class="qa-commit-based col-lg-6 col-sm-12 mb-4">
            <metric-chart
              :is-loading="chartLoading(chartKeys.commitBasedHistogram)"
              :metric-types="getMetricTypes(chartKeys.commitBasedHistogram)"
              :selected-metric="getSelectedMetric(chartKeys.commitBasedHistogram)"
              :chart-data="getChartData(chartKeys.commitBasedHistogram)"
              @metricTypeChange="
                metric =>
                  setMetricType({ metricType: metric, chartKey: chartKeys.commitBasedHistogram })
              "
            >
              <gl-column-chart
                :data="{ full: getChartData(chartKeys.commitBasedHistogram) }"
                :option="getColumnChartOption(chartKeys.commitBasedHistogram)"
                :y-axis-title="__('Merge requests')"
                :x-axis-title="__('Commits')"
                x-axis-type="category"
              />
            </metric-chart>
          </div>
        </div>

        <div
          class="qa-mr-table-sort d-flex flex-column flex-md-row align-items-md-center justify-content-between mb-2"
        >
          <h5>{{ __('List') }}</h5>
          <div v-if="mergeRequests" class="d-flex flex-column flex-md-row align-items-md-center">
            <strong class="mr-2">{{ __('Sort by') }}</strong>
            <div class="d-flex">
              <gl-dropdown
                class="mr-2 flex-grow"
                toggle-class="dropdown-menu-toggle"
                :text="sortFieldDropdownLabel"
              >
                <gl-dropdown-item
                  v-for="(value, key) in sortFields"
                  :key="key"
                  active-class="is-active"
                  class="w-100"
                  @click="setSortField(key)"
                >
                  <span class="d-flex">
                    <icon
                      class="flex-shrink-0 append-right-4"
                      :class="{
                        invisible: !isSelectedSortField(key),
                      }"
                      name="mobile-issue-close"
                    />
                    {{ value }}
                  </span>
                </gl-dropdown-item>
              </gl-dropdown>
              <gl-button v-gl-tooltip.hover :title="sortTooltipTitle" @click="toggleSortOrder">
                <icon :name="sortIcon" />
              </gl-button>
            </div>
          </div>
        </div>
        <div class="qa-mr-table">
          <gl-loading-icon v-if="isLoadingTable" size="md" class="my-4 py-4" />
          <merge-request-table
            v-else
            :merge-requests="mergeRequests"
            :page-info="pageInfo"
            :column-options="getColumnOptions"
            :metric-type="columnMetric"
            :metric-label="columnMetricLabel"
            @columnMetricChange="setColumnMetric"
            @pageChange="setMergeRequestsPage"
          />
        </div>
      </template>
    </template>
  </div>
</template>
