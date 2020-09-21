<script>
import { GlIcon, GlLink, GlTooltipDirective } from '@gitlab/ui';

export default {
  name: 'PackagePath',
  components: {
    GlIcon,
    GlLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    path: {
      type: String,
      required: true,
    },
  },
  computed: {
    pathPieces() {
      return this.path.split('/');
    },
    root() {
      return this.pathPieces[0];
    },
    leaf() {
      return this.pathPieces[this.pathPieces.length - 1];
    },
    deeplyNested() {
      return this.pathPieces.length > 2;
    },
    hasGroup() {
      return this.root !== this.leaf;
    },
  },
};
</script>

<template>
  <div
    v-gl-tooltip="{ title: path, disabled: !deeplyNested }"
    class="gl-display-flex gl-align-items-center"
  >
    <gl-icon data-testid="base-icon" name="project" class="gl-mx-3 gl-min-w-0" />

    <gl-link data-testid="root-link" class="gl-text-gray-500 gl-min-w-0" :href="`/${root}`">
      {{ root }}
    </gl-link>

    <template v-if="hasGroup">
      <gl-icon data-testid="root-chevron" name="chevron-right" class="gl-mx-2 gl-min-w-0" />

      <template v-if="deeplyNested">
        <span
          data-testid="ellipsis-icon"
          class="gl-inset-border-1-gray-200 gl-rounded-base gl-px-2 gl-min-w-0"
        >
          <gl-icon name="ellipsis_h" class="" />
        </span>
        <gl-icon data-testid="ellipsis-chevron" name="chevron-right" class="gl-mx-2 gl-min-w-0" />
      </template>

      <gl-link data-testid="leaf-link" class="gl-text-gray-500 gl-min-w-0" :href="`/${path}`">
        {{ leaf }}
      </gl-link>
    </template>
  </div>
</template>
