<script>
import { GlTooltip, GlIcon } from '@gitlab/ui';

export default {
  name: 'IssueCardWeight',
  components: {
    GlIcon,
    GlTooltip,
  },
  props: {
    weight: {
      type: Number,
      required: true,
    },
    tagName: {
      type: String,
      required: false,
      default: 'a',
    },
  },
};
</script>

<template>
  <component
    :is="tagName"
    ref="itemWeight"
    class="board-card-info card-number board-card-weight"
    tabindex="1"
    v-on="$listeners"
  >
    <gl-icon name="weight" class="board-card-info-icon" />
    <span class="board-card-info-text"> {{ weight }} </span>
    <gl-tooltip
      :target="() => $refs.itemWeight"
      placement="bottom"
      container="body"
      class="js-item-weight"
      >{{ __('Weight') }}<br /><span class="text-tertiary">{{ weight }}</span>
    </gl-tooltip>
  </component>
</template>
