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
  },
};
</script>

<template>
  <gl-label
    :background-color="label.color"
    :title="label.title"
    :description="label.description"
    size="sm"
    scoped
    :scoped-labels-documentation-link="scopedLabelsDocumentationLink"
    @click="$emit('scoped-label-click', label)"
  />
</template>
