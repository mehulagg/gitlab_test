<script>
import projectFeatureToggle from '~/vue_shared/components/toggle_button.vue';

export default {
  components: {
    projectFeatureToggle,
  },

  model: {
    prop: 'value',
    event: 'change',
  },

  props: {
    name: {
      type: String,
      required: false,
      default: '',
    },
    label: {
      type: String,
      required: true,
    },
    value: {
      type: Boolean,
      required: false,
      default: true,
    },
    disabledInput: {
      type: Boolean,
      required: false,
      default: false,
    },
    helpPath: {
      type: String,
      required: false,
      default: '',
    },
  },

  computed: {
    featureEnabled() {
      return this.value;
    },
  },

  methods: {
    toggleFeature(featureEnabled) {
      this.$emit('change', featureEnabled);
    },
  },
};
</script>

<template>
  <div :data-for="name" class="project-feature-controls">
    <input v-if="name" :name="name" :value="value" type="hidden" />
    <project-feature-toggle
      :value="featureEnabled"
      :disabled-input="disabledInput"
      @change="toggleFeature"
    />
    <div class="label">
      <span class="form-text text-muted">
        {{ label }}
      </span>
    </div>
    <a v-if="helpPath" :href="helpPath" target="_blank">
      <i aria-hidden="true" data-hidden="true" class="fa fa-question-circle"> </i>
    </a>
  </div>
</template>
