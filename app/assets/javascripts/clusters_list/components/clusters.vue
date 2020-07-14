<script>
import { mapState, mapActions } from 'vuex';
import {
  GlDeprecatedBadge as GlBadge,
  GlLink,
  GlLoadingIcon,
  GlPagination,
  GlSkeletonLoading,
  GlTable,
} from '@gitlab/ui';
import AncestorNotice from './ancestor_notice.vue';
import ClusterCpu from './cluster_cpu.vue';
import ClusterMemory from './cluster_memory.vue';
import tooltip from '~/vue_shared/directives/tooltip';
import { CLUSTER_TYPES, STATUSES } from '../constants';
import { __, sprintf } from '~/locale';

export default {
  components: {
    AncestorNotice,
    ClusterCpu,
    ClusterMemory,
    GlBadge,
    GlLink,
    GlLoadingIcon,
    GlPagination,
    GlSkeletonLoading,
    GlTable,
  },
  directives: {
    tooltip,
  },
  computed: {
    ...mapState([
      'clusters',
      'clustersPerPage',
      'loadingClusters',
      'loadingNodes',
      'page',
      'providers',
      'totalCulsters',
    ]),
    contentAlignClasses() {
      return 'gl-display-flex gl-align-items-center gl-justify-content-end gl-justify-content-md-start';
    },
    currentPage: {
      get() {
        return this.page;
      },
      set(newVal) {
        this.setPage(newVal);
        this.fetchClusters();
      },
    },
    fields() {
      return [
        {
          key: 'name',
          label: __('Kubernetes cluster'),
        },
        {
          key: 'environment_scope',
          label: __('Environment scope'),
        },
        {
          key: 'node_size',
          label: __('Nodes'),
        },
        {
          key: 'total_cpu',
          label: __('Total cores (CPUs)'),
        },
        {
          key: 'total_memory',
          label: __('Total memory (GB)'),
        },
        {
          key: 'cluster_type',
          label: __('Cluster level'),
          formatter: value => CLUSTER_TYPES[value],
        },
      ];
    },
    hasClusters() {
      return this.clustersPerPage > 0;
    },
  },
  mounted() {
    this.fetchClusters();
  },
  methods: {
    ...mapActions(['fetchClusters', 'setPage']),
    selectedProvider(provider) {
      return this.providers[provider] || this.providers.default;
    },
    statusTitle(status) {
      const iconTitle = STATUSES[status] || STATUSES.default;
      return sprintf(__('Status: %{title}'), { title: iconTitle.title }, false);
    },
  },
};
</script>

<template>
  <gl-loading-icon v-if="loadingClusters" size="md" class="gl-mt-3" />

  <section v-else>
    <ancestor-notice />

    <gl-table :items="clusters" :fields="fields" stacked="md" class="qa-clusters-table">
      <template #cell(name)="{ item }">
        <div :class="[contentAlignClasses, 'js-status']">
          <img
            :src="selectedProvider(item.provider_type).path"
            :alt="selectedProvider(item.provider_type).text"
            class="gl-w-6 gl-h-6 gl-display-flex gl-align-items-center"
          />

          <gl-link
            data-qa-selector="cluster"
            :data-qa-cluster-name="item.name"
            :href="item.path"
            class="gl-px-3"
          >
            {{ item.name }}
          </gl-link>

          <gl-loading-icon
            v-if="item.status === 'deleting' || item.status === 'creating'"
            v-tooltip
            :title="statusTitle(item.status)"
            size="sm"
          />
        </div>
      </template>

      <template #cell(node_size)="{ item }">
        <span v-if="item.nodes">{{ item.nodes.length }}</span>

        <gl-skeleton-loading v-else-if="loadingNodes" :lines="1" :class="contentAlignClasses" />

        <small v-else class="gl-font-sm gl-font-style-italic gl-text-gray-400">{{
          __('Unknown')
        }}</small>
      </template>

      <template #cell(total_cpu)="{ item }">
        <cluster-cpu v-if="item.nodes" :nodes="item.nodes" />

        <gl-skeleton-loading v-else-if="loadingNodes" :lines="1" :class="contentAlignClasses" />
      </template>

      <template #cell(total_memory)="{ item }">
        <cluster-memory v-if="item.nodes" :nodes="item.nodes" />

        <gl-skeleton-loading v-else-if="loadingNodes" :lines="1" :class="contentAlignClasses" />
      </template>

      <template #cell(cluster_type)="{value}">
        <gl-badge variant="light">
          {{ value }}
        </gl-badge>
      </template>
    </gl-table>

    <gl-pagination
      v-if="hasClusters"
      v-model="currentPage"
      :per-page="clustersPerPage"
      :total-items="totalCulsters"
      :prev-text="__('Prev')"
      :next-text="__('Next')"
      align="center"
    />
  </section>
</template>
