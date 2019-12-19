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
    // TODO: update gitlab-ui and remove style and color prop
    labelStyle: {
      type: Object,
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
  />
</template>
