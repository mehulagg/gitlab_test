<script>
import { GlButton } from '@gitlab/ui';
import { sprintf } from '~/locale';

export default {
  name: 'JobFailedAlert',
  components: {
    GlButton,
  },
  props: {
    jobPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      dismissed: false,
      message: sprintf(
        'The %{jobName} job has failed and cannot generate the list. Please ensure the job is running properly and run the pipeline again.',
        {
          jobName: '<code>dependency_list</code>',
        },
        false,
      ),
    };
  },
  methods: {
    dismiss() {
      this.dismissed = true;
    },
  },
};
</script>

<template>
  <div v-if="!dismissed" class="danger_message">
    <h4>{{ __('Job failed to generate the dependency list') }}</h4>
    <p v-html="message" />
    <gl-button :href="jobPath" class="mb-2">
      {{ __('View job') }}
    </gl-button>
  </div>
</template>

<style scoped>
h4 {
  color: inherit;
}
</style>
