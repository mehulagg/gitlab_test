<script>
import { mapActions, mapState } from 'vuex';
import { GlLoadingIcon } from '@gitlab/ui';
import NavigationTabs from '~/vue_shared/components/navigation_tabs.vue';
import InsightsPage from './insights_page.vue';

export default {
  components: {
    GlLoadingIcon,
    NavigationTabs,
    InsightsPage,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
    queryEndpoint: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState('insights', ['configData', 'configLoading', 'activeTab', 'activePage']),
    navigationTabs() {
      const { configData, activeTab } = this;

      if (!configData) {
        return [];
      }

      if (!activeTab) {
        this.setActiveTab(Object.keys(configData)[0]);
      }

      return Object.keys(configData).map(key => ({
        name: configData[key].title,
        scope: key,
        isActive: this.activeTab === key,
      }));
    },
  },
  mounted() {
    this.fetchConfigData(this.endpoint);
  },
  methods: {
    ...mapActions('insights', ['fetchConfigData', 'setActiveTab']),
    onChangeTab(scope) {
      this.setActiveTab(scope);
    },
  },
};
</script>
<template>
  <div class="insights-container">
    <div v-if="configLoading" class="insights-config-loading text-center">
      <gl-loading-icon :inline="true" :size="4" />
    </div>
    <div v-else class="insights-wrapper">
      <div class="top-area scrolling-tabs-container inner-page-scroll-tabs">
        <navigation-tabs :tabs="navigationTabs" @onChangeTab="onChangeTab" />
      </div>
      <insights-page :query-endpoint="queryEndpoint" :page-config="activePage" />
    </div>
  </div>
</template>
