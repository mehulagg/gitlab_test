<script>
import { GlLabel } from '@gitlab/ui';

export default {
  components: {
    GlLabel,
  },
  props: {
    label: {
      type: Object,
      required: true,
    },
    scopedLabelsDocumentationLink: {
      type: String,
      required: true,
    },
    labelFilterUrl: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <gl-label
    :target="labelFilterUrl"
    :background-color="label.color"
    :title="label.title"
    :description="label.description"
    :scoped-labels-documentation-link="scopedLabelsDocumentationLink"
  />
</template>
