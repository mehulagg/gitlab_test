<script>
import GlSearchBoxByType from './search_box_by_type.vue';
import GlSearchBoxByClick from './search_box_by_click.vue';

export default {
  components: {
    GlSearchBoxByType,
    GlSearchBoxByClick,
  },
  inheritAttrs: false,
  props: {
    value: {
      type: String,
      required: false,
      default: '',
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
    searchOnInput: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  computed: {
    inputAttributes() {
      const attributes = Object.assign(
        {
          type: 'text',
          placeholder: 'Search',
        },
        this.$attrs
      );

      if (!attributes['aria-label']) {
        attributes['aria-label'] = attributes.placeholder;
      }

      return attributes;
    },
  },
};
</script>

<template>
  <gl-search-box-by-type
    v-if="searchOnInput"
    v-bind="inputAttributes"
    :value="value"
    :is-loading="isLoading"
  />
  <gl-search-box-by-click
    v-else
    v-bind="inputAttributes"
    :value="value"
  />
</template>
