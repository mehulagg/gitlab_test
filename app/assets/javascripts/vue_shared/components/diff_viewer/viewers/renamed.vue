<script>
import { mapActions } from 'vuex';
import { GlAlert, GlLink, GlLoadingIcon, GlSprintf } from '@gitlab/ui';

import { __ } from '~/locale';
import {
  TRANSITION_LOAD_START,
  TRANSITION_LOAD_ERROR,
  TRANSITION_LOAD_SUCCEED,
  TRANSITION_ACKNOWLEDGE_ERROR,
  STATE_IDLING,
  STATE_LOADING,
  STATE_ERRORED,
  getStateMachine,
} from './renamed/state_machine';
import { truncateSha } from '~/lib/utils/text_utility';

export default {
  STATE_LOADING,
  STATE_ERRORED,
  state: getStateMachine(),
  uiText: {
    showLink: __('Show file contents'),
    commitLink: __('View file @ %{commitSha}'),
    description: __('File renamed with no changes.'),
    loadError: __('Unable to load file contents. Try again later.'),
  },
  components: {
    GlAlert,
    GlLink,
    GlLoadingIcon,
    GlSprintf,
  },
  props: {
    diffFile: {
      type: Object,
      required: true,
    },
  },
  data: () => ({
    state: STATE_IDLING,
  }),
  computed: {
    shortSha() {
      return truncateSha(this.diffFile.content_sha);
    },
    canLoadFullDiff() {
      return this.diffFile.alternate_viewer.name === 'text';
    },
  },
  methods: {
    ...mapActions('diffs', ['switchToFullDiffFromRenamedFile']),
    switchToFull() {
      this.$options.state.transition(TRANSITION_LOAD_START);

      this.switchToFullDiffFromRenamedFile({ diffFile: this.diffFile })
        .then(() => {
          this.$options.state.transition(TRANSITION_LOAD_SUCCEED);
        })
        .catch(() => {
          this.$options.state.transition(TRANSITION_LOAD_ERROR);
        });
    },
    clickLink(event) {
      if (this.canLoadFullDiff) {
        event.preventDefault();

        this.switchToFull();
      }
    },
    dismissError() {
      this.$options.state.transition(TRANSITION_ACKNOWLEDGE_ERROR);
    },
  },
};
</script>

<template>
  <div class="nothing-here-block">
    <gl-loading-icon v-if="$options.state.is($options.STATE_LOADING)" />
    <template v-else>
      <gl-alert
        v-show="$options.state.is($options.STATE_ERRORED)"
        class="gl-mb-5 gl-text-left"
        variant="danger"
        @dismiss="dismissError"
        >{{ $options.uiText.loadError }}</gl-alert
      >
      <span test-id="plaintext">{{ $options.uiText.description }}</span>
      <gl-link :href="diffFile.view_path" @click="clickLink">
        <span v-if="canLoadFullDiff">{{ $options.uiText.showLink }}</span>
        <gl-sprintf v-else :message="$options.uiText.commitLink">
          <template #commitSha>{{ shortSha }}</template>
        </gl-sprintf>
      </gl-link>
    </template>
  </div>
</template>
