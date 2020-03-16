<script>
import Icon from '~/vue_shared/components/icon.vue';
import { n__, __, sprintf, s__ } from '~/locale';
import { getParameterByName, parseBoolean } from '~/lib/utils/common_utils';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import { DIFF_BASE_INDEX, DIFF_HEAD_INDEX } from '../constants';

export default {
  components: {
    Icon,
    TimeAgo,
  },
  props: {
    otherVersions: {
      type: Array,
      required: false,
      default: () => [],
    },
    mergeRequestVersion: {
      type: Object,
      required: false,
      default: null,
    },
    startVersion: {
      type: Object,
      required: false,
      default: null,
    },
    targetBranch: {
      type: Object,
      required: false,
      default: null,
    },
    showCommitCount: {
      type: Boolean,
      required: false,
      default: false,
    },
    baseVersionPath: {
      type: String,
      required: false,
      default: null,
    },
    headVersionPath: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    targetBranchVersions() {
      if (this.mergeRequestVersion) {
        return [];
      }

      const versions = [
        {
          ...this.targetBranch,
          id: '_target_base',
          version_index: DIFF_BASE_INDEX,
          targetHref: this.baseVersionPath,
          targetName: sprintf(s__('DiffsCompareBaseBranch|%{branchName} (base)'), {
            branchName: this.targetBranch.branchName,
          }),
        },
      ];

      if (this.headVersionPath) {
        versions.push({
          ...this.targetBranch,
          id: '_target_head',
          version_index: DIFF_HEAD_INDEX,
          targetHref: this.headVersionPath,
          targetName: sprintf(s__('DiffsCompareBaseBranch|%{branchName} (HEAD)'), {
            branchName: this.targetBranch.branchName,
          }),
        });
      }

      return versions;
    },
    targetVersions() {
      return [...this.otherVersions, ...this.targetBranchVersions];
    },
    selectedVersionIndex() {
      if (this.mergeRequestVersion) {
        return this.mergeRequestVersion.version_index;
      }

      if (this.startVersion) {
        return this.startVersion.version_index;
      }

      const diffHead = parseBoolean(getParameterByName('diff_head'));

      return diffHead ? DIFF_HEAD_INDEX : DIFF_BASE_INDEX;
    },
    selectedVersionName() {
      const selectedVersion = this.targetVersions.find(x => this.isActive(x));

      return this.versionName(selectedVersion);
    },
  },
  methods: {
    commitsText(version) {
      return n__(`%d commit,`, `%d commits,`, version.commits_count);
    },
    href(version) {
      if (version.targetHref) {
        return version.targetHref;
      }
      if (this.showCommitCount) {
        return version.version_path;
      }
      return version.compare_path;
    },
    versionName(version) {
      if (!version) {
        return '';
      } else if (this.isLatest(version)) {
        return __('latest version');
      } else if (version.targetName) {
        return version.targetName;
      }

      return sprintf(__(`version %{versionIndex}`), { versionIndex: version.version_index });
    },
    isActive(version) {
      if (!version) {
        return false;
      }

      return version.version_index === this.selectedVersionIndex;
    },
    isLatest(version) {
      return (
        this.mergeRequestVersion && version.version_index === this.targetVersions[0].version_index
      );
    },
  },
};
</script>

<template>
  <span class="dropdown inline">
    <a
      class="dropdown-menu-toggle btn btn-default w-100"
      data-toggle="dropdown"
      aria-expanded="false"
    >
      <span> {{ selectedVersionName }} </span>
      <icon :size="12" name="angle-down" class="position-absolute" />
    </a>
    <div class="dropdown-menu dropdown-select dropdown-menu-selectable">
      <div class="dropdown-content">
        <ul>
          <li v-for="version in targetVersions" :key="version.id">
            <a :class="{ 'is-active': isActive(version) }" :href="href(version)">
              <div>
                <strong>
                  {{ versionName(version) }}
                </strong>
              </div>
              <div>
                <small class="commit-sha"> {{ version.short_commit_sha }} </small>
              </div>
              <div>
                <small>
                  <template v-if="showCommitCount">
                    {{ commitsText(version) }}
                  </template>
                  <time-ago
                    v-if="version.created_at"
                    :time="version.created_at"
                    class="js-timeago"
                  />
                </small>
              </div>
            </a>
          </li>
        </ul>
      </div>
    </div>
  </span>
</template>

<style>
.dropdown {
  min-width: 0;
  max-height: 170px;
}
</style>
