<script>
import _ from 'underscore';
import { GlTooltipDirective } from '@gitlab/ui';
import { mapState } from 'vuex';
import Icon from '~/vue_shared/components/icon.vue';
import { __ } from '~/locale';

export default {
  components: {
    Icon,
  },
  directives: {
    'gl-tooltip': GlTooltipDirective,
  },
  data() {
    return { isLoading: false };
  },
  created() {
    this.isLoading = this.isLoadingState;
  },
  computed: {
    ...mapState('terminalSync', ['isError', 'isStarted', 'message']),
    ...mapState('terminalSync', {
      isLoadingState: 'isLoading',
    }),
    status() {
      if (this.isLoading) {
        return {
          icon: '',
          text: this.isStarted
            ? __('Uploading changes to terminal')
            : __('Connecting to terminal sync service'),
        };
      } else if (this.isError) {
        return {
          icon: 'warning',
          text: this.message,
        };
      } else if (this.isStarted) {
        return {
          icon: 'mobile-issue-close',
          text: __('Terminal sync service is running'),
        };
      }

      return null;
    },
  },
  watch: {
    // We want to throttle the `isLoading` updates so that
    // the user actually sees an indicator that changes are sent.
    isLoadingState: _.throttle(function watchIsLoadingState(val) {
      this.isLoading = val;
    }, 150),
  },
};
</script>

<template>
  <div v-gl-tooltip v-if="status" :title="status.text" class="d-flex align-items-center">
    <span aria-label="file sync status">{{ __('terminal_sync') }}:</span>
    <span class="square s16 d-flex-center ml-1">
      <icon v-if="status.icon" :name="status.icon" :size="16" />
    </span>
    <span class="sr-only" role="status" aria-label="file sync status">
      {{ status.text }}
    </span>
  </div>
</template>
