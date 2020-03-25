<script>
import { sprintf, s__, __ } from '~/locale';
import { getParameterByName, parseBoolean } from '~/lib/utils/common_utils';
import { DIFF_BASE_INDEX, DIFF_HEAD_INDEX } from '../constants';
import CompareDropdownTemplate from './compare_dropdown_template.vue';

export default {
  components: {
    CompareDropdownTemplate,
  },
  props: {
    versions: {
      type: Array,
      required: true,
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
    targetVersions() {
      const versions = [
        {
          ...this.targetBranch,
          id: '_target_base',
          version_index: DIFF_BASE_INDEX,
          href: this.baseVersionPath,
          versionName: sprintf(s__('DiffsCompareBaseBranch|%{branchName} (base)'), {
            branchName: this.targetBranch.branchName,
          }),
        },
      ];

      if (this.headVersionPath) {
        versions.push({
          ...this.targetBranch,
          id: '_target_head',
          version_index: DIFF_HEAD_INDEX,
          href: this.headVersionPath,
          versionName: sprintf(s__('DiffsCompareBaseBranch|%{branchName} (HEAD)'), {
            branchName: this.targetBranch.branchName,
          }),
        });
      }

      return [
        ...this.versions.map(v => ({
          ...v,
          href: v.compare_path,
          versionName: sprintf(__(`version %{versionIndex}`), { versionIndex: v.version_index }),
        })),
        ...versions,
      ];
    },
    selectedVersionIndex() {
      if (this.startVersion) {
        return this.startVersion.version_index;
      }

      const diffHead = parseBoolean(getParameterByName('diff_head'));

      return diffHead ? DIFF_HEAD_INDEX : DIFF_BASE_INDEX;
    },
  },
  methods: {
    isActive(version) {
      return version.version_index === this.selectedVersionIndex;
    },
  },
};
</script>

<template>
  <compare-dropdown-template :versions="targetVersions" :is-active="isActive" />
</template>
