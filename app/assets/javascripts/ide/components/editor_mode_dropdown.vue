<script>
import { __, sprintf } from '~/locale';
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { viewerTypes } from '../constants';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
  },
  props: {
    viewer: {
      type: String,
      required: true,
    },
    mergeRequestId: {
      type: Number,
      required: true,
    },
  },
  computed: {
    selectedText() {
      return this.viewer === viewerTypes.mr ? __('Compare Merge Request') : __('Compare changes');
    },
    mergeReviewLine() {
      return sprintf(__('Reviewing (merge request !%{mergeRequestId})'), {
        mergeRequestId: this.mergeRequestId,
      });
    },
  },
  methods: {
    changeMode(mode) {
      this.$emit('click', mode);
    },
  },
  viewerTypes,
};
</script>

<template>
  <gl-dropdown
    size="sm"
    :text="selectedText"
    variant="link"
    toggle-class="border-0 p-0 bg-transparent"
    no-caret
  >
    <gl-dropdown-item
      :class="{
        'is-active': viewer === $options.viewerTypes.mr,
      }"
      @click.prevent="changeMode($options.viewerTypes.mr)"
    >
      <strong class="dropdown-menu-inner-title"> {{ __('Compare Merge Request') }} </strong>
      <span class="dropdown-menu-inner-content">
        {{ __('Compare changes with the merge request base') }}
      </span>
    </gl-dropdown-item>
    <gl-dropdown-item
      :class="{
        'is-active': viewer === $options.viewerTypes.diff,
      }"
      @click.prevent="changeMode($options.viewerTypes.diff)"
    >
      <strong class="dropdown-menu-inner-title">{{ __('Compare changes') }}</strong>
      <span class="dropdown-menu-inner-content">
        {{ __('Compare changes with the last commit') }}
      </span>
    </gl-dropdown-item>
  </gl-dropdown>
</template>
