<script>
import { mapState } from 'vuex';

import { isScopedLabel } from '~/lib/utils/common_utils';
import DropdownValueRegularLabel from '~/vue_shared/components/sidebar/labels_select/dropdown_value_regular_label.vue';
import DropdownValueScopedLabel from '~/vue_shared/components/sidebar/labels_select/dropdown_value_scoped_label.vue';

export default {
  components: {
    DropdownValueRegularLabel,
    DropdownValueScopedLabel,
  },
  computed: {
    ...mapState([
      'selectedLabels',
      'allowScopedLabels',
      'labelsFilterBasePath',
      'scopedLabelsDocumentationPath',
    ]),
  },
  methods: {
    labelFilterUrl(label) {
      return `${this.labelsFilterBasePath}?label_name[]=${encodeURIComponent(label.title)}`;
    },
    labelStyle(label) {
      return {
        color: label.textColor,
        backgroundColor: label.color,
      };
    },
    getDropdownLabelComponent(label) {
      if (this.allowScopedLabels && isScopedLabel(label)) {
        return 'dropdown-value-scoped-label';
      }
      return 'dropdown-value-regular-label';
    },
  },
};
</script>

<template>
  <div
    :class="{
      'has-labels': selectedLabels.length,
    }"
    class="hide-collapsed value issuable-show-labels js-value"
  >
    <span v-if="!selectedLabels.length" class="text-secondary">
      <slot></slot>
    </span>
    <template v-for="label in selectedLabels" v-else>
      <component
        :is="getDropdownLabelComponent(label)"
        :key="label.id"
        :label="label"
        :label-filter-url="labelFilterUrl(label)"
        :label-style="labelStyle(label)"
        :scoped-labels-documentation-link="scopedLabelsDocumentationPath"
      />
    </template>
  </div>
</template>
