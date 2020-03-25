<script>
import { __, sprintf } from '~/locale';
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
    mergeRequestVersion: {
      type: Object,
      required: true,
    },
  },
  computed: {
    sourceVersions() {
      return this.versions.map((v, i) => ({
        ...v,
        href: v.version_path,
        versionName: i
          ? sprintf(__(`version %{versionIndex}`), { versionIndex: v.version_index })
          : __('latest version'),
      }));
    },
  },
  methods: {
    isActive(version) {
      return version.version_index === this.mergeRequestVersion.version_index;
    },
  },
};
</script>

<template>
  <compare-dropdown-template :versions="sourceVersions" :is-active="isActive" />
</template>
