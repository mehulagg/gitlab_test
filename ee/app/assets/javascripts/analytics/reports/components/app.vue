<script>
import { GlBreadcrumb, GlIcon, GlLoadingIcon } from '@gitlab/ui';
import { mapState, mapActions, mapGetters } from 'vuex';
import { s__ } from '~/locale';
import ReportsChart from './reports_chart.vue';

export default {
  name: 'ReportsApp',
  components: {
    GlBreadcrumb,
    GlIcon,
    GlLoadingIcon,
    ReportsChart,
  },
  computed: {
    ...mapState('page', ['config', 'groupName', 'groupPath', 'isLoading']),
    ...mapGetters('page', ['displayChart', 'chartYAxisTitle']),
    breadcrumbs() {
      const {
        groupName = null,
        groupPath = null,
        config: { title },
      } = this;

      return [
        groupName && groupPath ? { text: groupName, href: `/${groupPath}` } : null,
        { text: title, href: '' },
      ].filter(Boolean);
    },
  },
  mounted() {
    this.fetchPageConfigData();
  },
  methods: {
    ...mapActions('page', ['fetchPageConfigData']),
  },
  CHART_X_AXIS_TITLE: s__('ReportPage|Last 90 days'),
};
</script>
<template>
  <div>
    <gl-loading-icon v-if="isLoading" size="md" class="gl-mt-5" />
    <gl-breadcrumb v-else :items="breadcrumbs">
      <template #separator>
        <gl-icon name="angle-right" :size="8" />
      </template>
    </gl-breadcrumb>
    <template v-if="displayChart">
      <h4>{{ config.title }}</h4>
      <reports-chart :x-axis-title="$options.CHART_X_AXIS_TITLE" :y-axis-title="chartYAxisTitle" />
    </template>
  </div>
</template>
