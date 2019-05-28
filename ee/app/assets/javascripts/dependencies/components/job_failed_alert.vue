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
};
</script>

<template>
  <div v-if="!closed" class="danger_message">
    <h4>{{ __('Job failed to generate the dependency list') }}</h4>
    <p>
      {{
        __(
          'The dependency_list job has failed and cannot generate the list. Please ensure the job is running properly and run the pipeline again.',
        )
      }}
    </p>
    <gl-button :href="jobPath">
      {{ __('View job') }}
    </gl-button>
  </div>
</template>
