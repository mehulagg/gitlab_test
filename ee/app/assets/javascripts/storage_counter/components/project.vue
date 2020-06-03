<script>
import { GlDeprecatedButton, GlLink } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';
import { numberToHumanSize, isOdd } from '~/lib/utils/number_utils';
import { s__ } from '~/locale';
import StorageRow from './storage_row.vue';

export default {
  components: {
    Icon,
    GlDeprecatedButton,
    GlLink,
    ProjectAvatar,
    StorageRow,
  },
  props: {
    project: {
      required: true,
      type: Object,
    },
  },
  data() {
    return {
      isOpen: false,
    };
  },
  computed: {
    name() {
      return this.project.nameWithNamespace;
    },
    storageSize() {
      return numberToHumanSize(this.project.statistics.storageSize);
    },
    toggleIconName() {
      return this.isOpen ? 'angle-down' : 'angle-right';
    },
    folderIconName() {
      return this.isOpen ? 'folder-open' : 'folder';
    },
    statistics() {
      const statisticsCopy = { ...this.project.statistics };
      delete statisticsCopy.storageSize;
      // eslint-disable-next-line no-underscore-dangle
      delete statisticsCopy.__typename;
      delete statisticsCopy.commitCount;

      return statisticsCopy;
    },
    projectName() {
      return this.project.name;
    },
    namespacePath() {
      return this.project.nameWithNamespace
        .split(' /')
        .slice(0, -1)
        .join(' /');
    },
  },
  methods: {
    toggleProject() {
      this.isOpen = !this.isOpen;
    },
    getFormattedName(name) {
      return this.$options.i18nStatisticsMap[name].name;
    },
    getFormattedDescription(name) {
      return this.$options.i18nStatisticsMap[name].description;
    },
    getStorageTypeIcon(name) {
      return this.$options.storageTypeIconsMap[name];
    },
    isOdd(num) {
      return isOdd(num);
    },
    /**
     * Some values can be `nil`
     * for those, we send 0 instead
     */
    getValue(val) {
      return val || 0;
    },
  },
  i18nStatisticsMap: {
    repositorySize: {
      name: s__('UsageQuota|Repository'),
      description: s__('UsageQuota|Open source software to collaborate on code'),
    },
    lfsObjectsSize: {
      name: s__('UsageQuota|LFS Storage'),
      description: s__('UsageQuota|All projects’ code files, branches, commits...'),
    },
    buildArtifactsSize: {
      name: s__('UsageQuota|Artifacts'),
      description: s__('UsageQuota|Large files such as audio, video, graphics'),
    },
    packagesSize: {
      name: s__('UsageQuota|Packages'),
      description: s__('UsageQuota|All packages built and published'),
    },
    wikiSize: {
      name: s__('UsageQuota|Wiki'),
      description: s__('UsageQuota|All wiki content on how your organization and projects work'),
    },
  },
  storageTypeIconsMap: {
    repositorySize: 'doc-text',
    lfsObjectsSize: 'doc-image',
    buildArtifactsSize: 'doc-versions',
    packagesSize: 'package',
    wikiSize: 'book',
  },
};
</script>
<template>
  <div>
    <div class="gl-responsive-table-row border-bottom" role="row">
      <div class="table-section section-wrap section-70 text-truncate" role="gridcell">
        <div class="table-mobile-content d-flex align-items-center">
          <gl-deprecated-button
            class="btn-transparent float-left p-0 gl-mr-3"
            :aria-label="__('Toggle project')"
            @click="toggleProject"
          >
            <icon :name="toggleIconName" class="folder-icon" />
          </gl-deprecated-button>

          <icon :name="folderIconName" class="gl-mr-3" />

          <project-avatar :project="project" :size="32" />

          <gl-link :href="project.webUrl" class="text-plain">
            {{ namespacePath }} / <span class="font-weight-bold">{{ projectName }}</span></gl-link
          >
        </div>
      </div>
      <div class="table-section section-wrap section-30 text-truncate" role="gridcell">
        <div class="table-mobile-content d-flex align-items-center">
          <icon name="disk" class="gl-mr-2" />
          {{ storageSize }}
        </div>
      </div>
    </div>

    <template v-if="isOpen">
      <div class="ml-5">
        <storage-row
          v-for="(value, statisticsName, index) in statistics"
          :key="index"
          :name="getFormattedName(statisticsName)"
          :description="getFormattedDescription(statisticsName)"
          :value="getValue(value)"
          :icon="getStorageTypeIcon(statisticsName)"
        />
      </div>
    </template>
  </div>
</template>
