<script>
import { mapActions, mapState } from 'vuex';
import { GlDropdown, GlDropdownItem, GlLoadingIcon } from '@gitlab/ui';
import InsightsPage from './insights_page.vue';

export default {
  components: {
    GlLoadingIcon,
    InsightsPage,
    GlDropdown,
    GlDropdownItem,
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
    pages() {
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
    onChangePage(page) {
      this.setActiveTab(page);
    },
  },
};
</script>
<template>
  <div class="insights-container prepend-top-default">
    <div v-if="configLoading" class="insights-config-loading text-center">
      <gl-loading-icon :inline="true" :size="4" />
    </div>
    <div v-else class="insights-wrapper">
      <gl-dropdown
        id="insights-dropdown"
        class="col-8 col-md-9 gl-pr-0"
        menu-class="w-100 mw-100"
        toggle-class="dropdown-menu-toggle w-100 gl-field-error-outline"
        :text="__('Select Page')"
      >
        <gl-dropdown-item
          v-for="page in pages"
          :key="page.scope"
          class="w-100"
          @click="onChangePage(page.scope)"
          >{{ page.name }}</gl-dropdown-item
        >
      </gl-dropdown>
      <insights-page :query-endpoint="queryEndpoint" :page-config="activePage" />
    </div>
  </div>
</template>
