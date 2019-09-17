<script>
import _ from 'underscore';
import { s__ } from '~/locale';
import { GlDropdown, GlDropdownItem, GlLoadingIcon } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  props: {
    title: {
      type: String,
      required: false,
      default: '',
    },
    description: {
      type: String,
      required: false,
      default: '',
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
    metricTypes: {
      type: Array,
      required: false,
      default: () => [],
    },
    selectedMetric: {
      type: String,
      required: false,
      default: '',
    },
    chartData: {
      type: [Object, Array],
      required: false,
      default: () => {},
    },
  },
  components: {
    GlDropdown,
    GlDropdownItem,
    GlLoadingIcon,
    Icon,
  },
  computed: {
    hasMetricTypes() {
      return this.metricTypes.length > 0;
    },
    metricDropdownLabel() {
      return this.selectedMetric
        ? this.metricTypes.find(m => m.key === this.selectedMetric).label
        : s__('ProductivityAnalytics|Please select a metric');
    },
    hasChartData() {
      return !_.isEmpty(this.chartData);
    },
  },
  methods: {
    isSelectedMetric(key) {
      return this.selectedMetric === key;
    },
  },
};
</script>
<template>
  <div>
    <h5 v-if="title">{{ title }}</h5>
    <p v-if="descirption" class="text-muted">{{ descriptin }}</p>
    <gl-loading-icon v-if="isLoading" size="md" class="my-4 py-4" />
    <template v-else>
      <gl-dropdown
        v-if="hasMetricTypes"
        class="mb-4 metric-dropdown"
        toggle-class="dropdown-menu-toggle w-100"
        menu-class="w-100 mw-100"
        :text="metricDropdownLabel"
      >
        <gl-dropdown-item
          v-for="metric in metricTypes"
          :key="metric.key"
          active-class="is-active"
          class="w-100"
          @click="$emit('metricTypeChange', metric.key)"
        >
          <span class="d-flex">
            <icon
              class="flex-shrink-0 append-right-4"
              :class="{
                invisible: !isSelectedMetric(metric.key),
              }"
              name="mobile-issue-close"
            />
            {{ metric.label }}
          </span>
        </gl-dropdown-item>
      </gl-dropdown>
      <div class="js-metric-chart">
        <slot v-if="hasChartData"></slot>
      </div>
      <div v-if="!hasChartData" class="mt-2 mb-8 text-secondary">
        {{
          s__('ProductivityAnalytics|There is no data for the selected metric available available.')
        }}
      </div>
    </template>
  </div>
</template>
