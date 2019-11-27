<script>
import _ from 'underscore';
import { mapActions, mapState, mapGetters } from 'vuex';
import {
  GlDropdown,
  GlDropdownItem,
  GlDropdownHeader,
  GlDropdownDivider,
  GlFormGroup,
  GlSearchBoxByClick,
  GlTable,
} from '@gitlab/ui';
import { scrollDown } from '~/lib/utils/scroll_utils';
import LogControlButtons from './log_control_buttons.vue';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
    GlDropdownHeader,
    GlDropdownDivider,
    GlSearchBoxByClick,
    GlFormGroup,
    GlTable,
    LogControlButtons,
  },
  props: {
    projectFullPath: {
      type: String,
      required: true,
    },
    filtersPath: {
      type: String,
      required: true,
    },
    defaultPodName: {
      type: [String, null],
      required: false,
      default: null,
    },
    defaultClusterName: {
      type: [String, null],
      required: false,
      default: null,
    },
    defaultClusters: {
      type: Array,
      required: false,
      default: () => [],
    },
    defautlSearch: {
      type: [String],
      required: false,
      default: '',
    },
  },
  data() {
    return {
      searchModel: '',
    };
  },
  computed: {
    ...mapState('environmentLogs', ['clusters', 'filters', 'search', 'logs', 'pods']),
    ...mapGetters('environmentLogs', ['trace', 'table']),
    showLoader() {
      return this.logs.isLoading || !this.logs.isComplete;
    },
  },
  watch: {
    trace(val) {
      this.$nextTick(() => {
        if (val) {
          scrollDown();
        }
        this.$refs.scrollButtons.update();
      });
    },
  },
  mounted() {
    this.setInitData({
      projectPath: this.projectFullPath,
      filtersPath: this.filtersPath,
      clusters: this.defaultClusters,
      cluster: this.defaultClusterName,
      search: this.defautlSearch,
      pod: this.defaultPodName,
    });
  },
  methods: {
    ...mapActions('environmentLogs', [
      'setInitData',
      'showPodLogs',
      'showCluster',
      'setSearch',
      'fetchFilters',
    ]),
  },
};
</script>
<template>
  <div class="build-page-pod-logs mt-3">
    <div class="top-bar js-top-bar d-flex align-items-start">
      <div class="m-2">
        <gl-dropdown
          id="clusters-dropdown"
          :text="clusters.current"
          class="js-clusters-dropdown"
          toggle-class="dropdown-menu-toggle"
        >
          <gl-dropdown-header>{{ s__('Clusters|Cluster') }}</gl-dropdown-header>
          <gl-dropdown-item
            v-for="cluster in clusters.options"
            :key="cluster"
            @click="showCluster(cluster)"
            >{{ cluster }}</gl-dropdown-item
          >
        </gl-dropdown>
      </div>
      <div class="m-2">
        <gl-dropdown
          id="pods-dropdown"
          :text="pods.current || s__('Environments|All pods')"
          :disabled="filters.isLoading"
          class="js-pods-dropdown"
          toggle-class="dropdown-menu-toggle"
        >
          <gl-dropdown-header>{{ s__('Environments|Pods logs from') }}</gl-dropdown-header>
          <gl-dropdown-item @click="showPodLogs(null)">{{
            s__('Environments|All pods')
          }}</gl-dropdown-item>
          <gl-dropdown-divider />
          <gl-dropdown-item v-for="pod in pods.options" :key="pod" @click="showPodLogs(pod)">{{
            pod
          }}</gl-dropdown-item>
        </gl-dropdown>
      </div>
      <gl-search-box-by-click
        id="logs-search"
        placeholder="Search logs"
        v-model.trim="searchModel"
        class="m-2 flex-fill"
        @change="setSearch(searchModel)"
      />
      <log-control-buttons
        ref="scrollButtons"
        class="controllers m-2"
        @refresh="showPodLogs(pods.current)"
      />
    </div>
    <gl-table
      :items="table"
    />
  </div>
</template>
