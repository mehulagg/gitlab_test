<script>
import { mapActions, mapState, mapGetters } from 'vuex';
import { GlDropdown, GlDropdownItem, GlFormGroup } from '@gitlab/ui';
import { scrollDown } from '~/lib/utils/scroll_utils';
import LogControlButtons from './log_control_buttons.vue';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
    GlFormGroup,
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
    currentPodName: {
      type: [String, null],
      required: false,
      default: null,
    },
    currentClusterName: {
      type: [String, null],
      required: false,
      default: null,
    },
    currentClusters: {
      type: Array,
      required: false,
      default: [],
    },
  },
  computed: {
    ...mapState('environmentLogs', ['clusters', 'filters', 'logs', 'pods']),
    ...mapGetters('environmentLogs', ['trace']),
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
      clusters: this.currentClusters,
      cluster: this.currentClusterName,
      pod: this.currentPodName,
    });
  },
  methods: {
    ...mapActions('environmentLogs', ['setInitData', 'showPodLogs', 'showCluster', 'fetchFilters']),
  },
};
</script>
<template>
  <div class="build-page-pod-logs mt-3">
    <div class="top-bar js-top-bar d-flex">
      <div class="row">
        <gl-form-group
          id="clusters-dropdown-fg"
          :label="s__('Clusters|Cluster')"
          label-size="sm"
          label-for="clusters-dropdown"
          class="col-6"
        >
          <gl-dropdown
            id="clusters-dropdown"
            :text="clusters.current"
            class="d-flex js-clusters-dropdown"
            toggle-class="dropdown-menu-toggle"
          >
            <gl-dropdown-item
              v-for="cluster in clusters.options"
              :key="cluster"
              @click="showCluster(cluster)"
              >{{ cluster }}</gl-dropdown-item
            >
          </gl-dropdown>
        </gl-form-group>
        <gl-form-group
          id="environments-dropdown-fg"
          :label="s__('Environments|Pod logs from')"
          label-size="sm"
          label-for="pods-dropdown"
          class="col-6"
        >
          <gl-dropdown
            id="pods-dropdown"
            :text="pods.current || s__('Environments|No pods to display')"
            :disabled="filters.isLoading"
            class="d-flex js-pods-dropdown"
            toggle-class="dropdown-menu-toggle"
          >
            <gl-dropdown-item v-for="pod in pods.options" :key="pod" @click="showPodLogs(pod)">{{
              pod
            }}</gl-dropdown-item>
          </gl-dropdown>
        </gl-form-group>
      </div>

      <log-control-buttons
        ref="scrollButtons"
        class="controllers align-self-end"
        @refresh="showPodLogs(pods.current)"
      />
    </div>
    <pre class="build-trace js-log-trace"><code class="bash js-build-output">{{trace}}
      <div v-if="showLoader" class="build-loader-animation js-build-loader-animation">
        <div class="dot"></div>
        <div class="dot"></div>
        <div class="dot"></div>
      </div></code></pre>
  </div>
</template>
