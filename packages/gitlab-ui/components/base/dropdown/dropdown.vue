<script>
import { isVisible, selectAll } from 'bootstrap-vue/es/utils/dom';
import BDropdown from 'bootstrap-vue/es/components/dropdown/dropdown';

// Return an Array of visible items
function filterVisible(els) {
  return (els || []).filter(isVisible);
}

const Selector = {
  ITEM_SELECTOR:
    '.dropdown-item:not(.disabled):not([disabled]),.form-control:not(.disabled):not([disabled])',
};

// see https://gitlab.com/gitlab-org/gitlab-ui/merge_requests/130#note_126406721
const ExtendedBDropdown = {
  extends: BDropdown,
  methods: {
    getItems() {
      return filterVisible(selectAll(Selector.ITEM_SELECTOR, this.$refs.menu));
    },
  },
};

export default {
  components: {
    BDropdown: ExtendedBDropdown,
  },
  inheritAttrs: false,
  props: {
    text: {
      type: String,
      required: false,
      default: '',
    },
    noCaret: {
      type: Boolean,
      required: false,
      default: false,
    },
    split: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    renderCaret() {
      if (this.split || this.noCaret) {
        return false;
      }
      return true;
    },
  },
};
</script>

<template>
  <b-dropdown
    v-bind="$attrs"
    v-on="$listeners"
    :split="split"
  >
    <slot></slot>
    <slot
      slot="button-content"
      name="button-content"
    >
      {{ text }}
      <i
        v-if="renderCaret"
        class="fa fa-chevron-down"
        aria-hidden="true"
      ></i>
    </slot>
  </b-dropdown>
</template>

<style>
/* This is temporary till we can properly support the split dropdown caret */
/* https://gitlab.com/gitlab-org/gitlab-ui/issues/185 */
.dropdown-toggle-split:after {
  display: block;
}
</style>
