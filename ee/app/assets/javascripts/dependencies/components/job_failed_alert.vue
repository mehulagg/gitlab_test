<script>
import { GlButton } from '@gitlab/ui';

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
    <p>
      {{
        __(
          'The dependency_list job has failed and cannot generate the list. Please ensure the job is running properly and run the pipeline again.',
        )
      }}
    </p>
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
