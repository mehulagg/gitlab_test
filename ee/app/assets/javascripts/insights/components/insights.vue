<script>
import { mapActions, mapState } from 'vuex';
import { GlLoadingIcon } from '@gitlab/ui';
import NavigationTabs from '~/vue_shared/components/navigation_tabs.vue';
import InsightsPage from './insights_page.vue';
import InsightsConfigWarning from './insights_config_warning.vue';

export default {
  components: {
    GlLoadingIcon,
    NavigationTabs,
    InsightsPage,
    InsightsConfigWarning,
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
    configPresent() {
      return this.configData != null;
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
    <div v-else-if="configPresent" class="insights-wrapper">
      <div class="top-area scrolling-tabs-container inner-page-scroll-tabs">
        <navigation-tabs :tabs="navigationTabs" @onChangeTab="onChangeTab" />
      </div>
      <insights-page :query-endpoint="queryEndpoint" :page-config="activePage" />
    </div>
    <insights-config-warning
      v-else
      :title="__('Invalid Insights config file detected')"
      :summary="
        __(
          'Please check the configuration file to ensure that it is available and the YAML is valid',
        )
      "
      image="illustrations/monitoring/getting_started.svg"
    />
  </div>
</template>
