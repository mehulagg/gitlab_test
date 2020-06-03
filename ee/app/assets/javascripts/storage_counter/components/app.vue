<script>
import { GlLink } from '@gitlab/ui';
import Project from './project.vue';
import UsageGraph from './usage_graph.vue';
import query from '../queries/storage.graphql';
import { numberToHumanSize } from '~/lib/utils/number_utils';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    Project,
    GlLink,
    Icon,
    UsageGraph,
  },
  props: {
    namespacePath: {
      type: String,
      required: true,
    },
    helpPagePath: {
      type: String,
      required: true,
    },
  },
  apollo: {
    namespace: {
      query,
      variables() {
        return {
          fullPath: this.namespacePath,
        };
      },
      /**
       * `rootStorageStatistics` will be sent as null until an
       * event happens to trigger the storage count.
       * For that reason we have to verify if `storageSize` is sent or
       * if we should render N/A
       */
      update: data => ({
        projects: data.namespace.projects.edges.map(({ node }) => node),
        totalUsage:
          data.namespace.rootStorageStatistics && data.namespace.rootStorageStatistics.storageSize
            ? numberToHumanSize(data.namespace.rootStorageStatistics.storageSize)
            : 'N/A',
        rootStorageStatistics: data.namespace.rootStorageStatistics,
      }),
    },
  },
  data() {
    return {
      namespace: {},
    };
  },
};
</script>
<template>
  <div>
    <div class="pipeline-quota container-fluid py-4 px-2 m-0">
      <div class="row py-0">
        <div class="col-sm-12">
          <strong>{{ s__('UsageQuota|Storage usage:') }}</strong>
          <span data-testid="total-usage">
            {{ namespace.totalUsage }}
            <gl-link
              :href="helpPagePath"
              target="_blank"
              :aria-label="s__('UsageQuota|Usage quotas help link')"
            >
              <icon name="question" :size="12" />
            </gl-link>
          </span>
        </div>
      </div>
      <div class="row py-0">
        <div class="col-sm-12">
          <usage-graph
            v-if="namespace.rootStorageStatistics"
            :root-storage-statistics="namespace.rootStorageStatistics"
          />
        </div>
      </div>
    </div>
    <div class="ci-table" role="grid">
      <project v-for="project in namespace.projects" :key="project.id" :project="project" />
    </div>
  </div>
</template>
