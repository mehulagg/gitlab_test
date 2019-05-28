<script>
import { GlButton } from '@gitlab/ui';
import { sprintf } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  name: 'JobFailedAlert',
  components: {
    GlButton,
    Icon,
  },
  props: {
    jobPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      closed: false,
      message: sprintf(
        'The %{jobName} job has failed and cannot generate the list. Please ensure the job is running properly and run the pipeline again.',
        { jobName: '<code>dependency_list</code>' },
        false,
      ),
    };
  },
  methods: {
    close() {
      this.closed = true;
    },
  },
};
</script>

<template>
  <div v-if="!closed" class="danger_message">
    <button
      class="btn-blank float-right mr-1 mt-1 text-danger-900"
      type="button"
      :aria-label="__('Close')"
      @click="close"
    >
      <icon name="close" aria-hidden="true" />
    </button>
    <h4 class="text-danger-900">{{ __('Job failed to generate the dependency list') }}</h4>
    <p v-html="message" />
    <gl-button :href="jobPath" class="btn-inverted btn-danger mb-2">
      {{ __('View job') }}
    </gl-button>
  </div>
</template>
