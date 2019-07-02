<script>
import { GlLoadingIcon, GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { mapState, mapActions, mapGetters } from 'vuex';
import { __ } from '~/locale';
import EmptyState from './empty_state.vue';
import BarChart from './bar_chart.vue';
import { chartKeys, metricTypes } from './../constants';

export default {
  components: {
    GlLoadingIcon,
    GlDropdown,
    GlDropdownItem,
    EmptyState,
    BarChart,
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
  },
  data() {
    return {
      chartKeys,
      metricTypes,
      // TODO: remove later on
      groups: [{ id: 2, label: 'Gitlab Org' }, { id: 7, label: 'Twitter' }],
    };
  },
  computed: {
    ...mapState(['globalFilters', 'charts']),
    ...mapGetters([
      'chartLoading',
      'getChartData',
      'getSelectedChartData',
      'getMetricDropdownLabel',
    ]),
  },
  methods: {
    ...mapActions(['setChartEndpoint', 'setGroupId', 'fetchChartData', 'setMetricType']),
    onMetricChange(metricType, chartKey) {
      this.setMetricType({ chartKey, metricType });
    },
    getMetricTypes(chartKey) {
      return this.metricTypes.filter(m => m.chart === chartKey);
    },
    // TODO: remove later on
    onGroupSelected(groupId) {
      console.log('onGroupSelected :: ', groupId);
      this.setGroupId(groupId);
    },
  },
  mounted() {
    this.setChartEndpoint(this.endpoint);
    // this.fetchChartData();
  },
};
</script>

<template>
  <div>
    <div class="my-2">
      <gl-dropdown
        toggle-class="dropdown-menu-toggle w-100"
        menu-class="w-100 mw-100"
        text="Select Group"
      >
        <gl-dropdown-item
          v-for="group in groups"
          :key="group.id"
          class="w-100"
          @click="onGroupSelected(group.id)"
          >{{ group.label }}</gl-dropdown-item
        >
      </gl-dropdown>
      (hard coded for now)
    </div>
    <empty-state
      v-if="!globalFilters.groupId"
      :empty-state-svg-path="emptyStateSvgPath"
    ></empty-state>
    <template v-else>
      <div class="mb-4">
        <h4>{{ __('Merge Requests') }}</h4>
        <h5>{{ __('Time to merge') }}</h5>
        <gl-loading-icon v-if="chartLoading(chartKeys.main)" size="md" class="my-4 py-4" />
        <bar-chart
          v-else
          :data="getChartData(chartKeys.main)"
          :selected="getSelectedChartData(chartKeys.main)"
          :y-axis-title="__('Merge requests')"
          :x-axis-title="__('Days')"
        ></bar-chart>
      </div>
      <div class="d-flex flex-column flex-sm-row">
        <div class="flex-grow">
          <gl-dropdown
            toggle-class="dropdown-menu-toggle w-100"
            menu-class="w-100 mw-100"
            :text="getMetricDropdownLabel(chartKeys.timeBasedHistogram)"
          >
            <gl-dropdown-item
              v-for="metric in getMetricTypes(chartKeys.timeBasedHistogram)"
              :key="metric.key"
              active-class="is-active"
              class="w-100"
              @click="onMetricChange(metric.key, chartKeys.timeBasedHistogram)"
            >
              {{ metric.label }}
            </gl-dropdown-item>
          </gl-dropdown>
          <div>left chart</div>
        </div>
        <div class="flex-grow">
          <gl-dropdown
            toggle-class="dropdown-menu-toggle w-100"
            menu-class="w-100 mw-100"
            :text="getMetricDropdownLabel(chartKeys.commitBasedHistogram)"
          >
            <gl-dropdown-item
              v-for="metric in getMetricTypes(chartKeys.commitBasedHistogram)"
              :key="metric.key"
              active-class="is-active"
              class="w-100"
              @click="onMetricChange(metric.key, chartKeys.commitBasedHistogram)"
            >
              {{ metric.label }}
            </gl-dropdown-item>
          </gl-dropdown>
          <div>right chart</div>
        </div>
      </div>
    </template>
  </div>
</template>
