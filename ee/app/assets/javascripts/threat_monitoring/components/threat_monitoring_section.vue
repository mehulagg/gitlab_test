<script>
import { mapState } from 'vuex';
import { GlEmptyState, GlInfiniteScroll } from '@gitlab/ui';
import LoadingSkeleton from './loading_skeleton.vue';
import StatisticsSummary from './statistics_summary.vue';
import StatisticsHistory from './statistics_history.vue';

export default {
  traceHeight: 600,
  components: {
    GlEmptyState,
    GlInfiniteScroll,
    LoadingSkeleton,
    StatisticsSummary,
    StatisticsHistory,
  },
  props: {
    storeNamespace: {
      type: String,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    subtitle: {
      type: String,
      required: true,
    },
    nominalTitle: {
      type: String,
      required: true,
    },
    anomalousTitle: {
      type: String,
      required: true,
    },
    yLegend: {
      type: String,
      required: true,
    },
    chartEmptyStateText: {
      type: String,
      required: true,
    },
    chartEmptyStateSvgPath: {
      type: String,
      required: true,
    },
    documentationPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState({
      isLoading(state) {
        return state[this.storeNamespace].isLoadingStatistics;
      },
      statistics(state) {
        return state[this.storeNamespace].statistics;
      },
      hasHistory(state, getters) {
        return getters[`${this.storeNamespace}/hasHistory`];
      },
      timeRange(state) {
        return state[this.storeNamespace].timeRange;
      },
    }),
    summary() {
      const { anomalous, total } = this.statistics;
      return {
        anomalous: { title: this.anomalousTitle, value: anomalous },
        nominal: { title: this.nominalTitle, value: total },
      };
    },
    chart() {
      if (!this.hasHistory) return {};

      const { anomalous, nominal } = this.statistics.history;
      return {
        anomalous: { title: this.anomalousTitle, values: anomalous },
        nominal: { title: this.nominalTitle, values: nominal },
        from: this.timeRange.from,
        to: this.timeRange.to,
      };
    },
    log() {
      return this.statistics.anomalousLog;
    },
    hasLog() {
      return this.log !== null && this.log.length > 0;
    }
  },
  methods: {
    fromUTCToLocal(time){
      return new Date(time + " UTC");
    },
  },
};
</script>

<template>
  <div class="my-3">
    <h4 class="h4">{{ title }}</h4>
    <h5 class="h5">{{ subtitle }}</h5>

    <loading-skeleton v-if="isLoading" class="mt-3" />

    <template v-else-if="hasHistory">
      <statistics-summary class="mt-3" :data="summary" />
      <statistics-history class="mt-3" :data="chart" :y-legend="yLegend" />
      <div :v-if="hasLog" class="environment-logs-viewer mt-3">
        <h5 class="h5">{{ __('Logs') }}</h5>
        <gl-infinite-scroll
          ref="infiniteScroll"
          class="build-trace"
          :style="{ height: `${$options.traceHeight}px`, whiteSpace: 'normal'}"
          :max-list-height="$options.traceHeight"
          :fetched-items="log.length"
        >
          <template #items>
            <p v-for="(item, index) in log" :key="index">
              {{fromUTCToLocal(item.time_stamp)}} : {{item.messages}}
            </p>
          </template>
          <template #default>
            <div></div>
          </template>
        </gl-infinite-scroll>
      </div>
    </template>

    <gl-empty-state
      v-else
      ref="chartEmptyState"
      :title="s__('ThreatMonitoring|No traffic to display')"
      :description="chartEmptyStateText"
      :svg-path="chartEmptyStateSvgPath"
      :primary-button-link="documentationPath"
      :primary-button-text="__('Learn More')"
    />
  </div>
</template>
