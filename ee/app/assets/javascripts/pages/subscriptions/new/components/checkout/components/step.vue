<script>
import { GlFormGroup, GlButton } from '@gitlab/ui';
import SubscriptionStore from '../../../stores/subscription_store';
import StepHeader from './step_header.vue';
import StepSummary from './step_summary.vue';

export default {
  components: {
    GlFormGroup,
    GlButton,
    StepHeader,
    StepSummary,
  },
  props: {
    step: {
      type: String,
      required: true,
    },
    store: {
      type: Object,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    isValid: {
      type: Boolean,
      required: true,
    },
    nextStepButtonText: {
      type: String,
      required: false,
      default: undefined,
    },
  },
  data() {
    return {
      state: this.store.state,
    };
  },
  computed: {
    isActive() {
      return this.state.currentStep === this.step;
    },
    isFinished() {
      return this.isValid && !this.isActive;
    },
    editable() {
      return (
        this.isFinished && SubscriptionStore.stepIndex(this.step) < this.store.activeStepIndex()
      );
    },
  },
  methods: {
    nextStep() {
      if (this.isValid) {
        this.store.nextStep();
      }
    },
    edit() {
      this.store.activateStep(this.step);
    },
  },
};
</script>
<template>
  <div class="step">
    <step-header :title="title" :is-finished="isFinished" />
    <div class="card">
      <div v-show="isActive" @keyup.enter="nextStep">
        <slot name="body" :active="isActive"></slot>
        <gl-form-group v-if="nextStepButtonText" class="prepend-top-8 append-bottom-0">
          <gl-button variant="success" :disabled="!isValid" @click="nextStep">
            {{ nextStepButtonText }}
          </gl-button>
        </gl-form-group>
      </div>
      <step-summary v-if="isFinished" :editable="editable" :edit="edit">
        <slot name="summary"></slot>
      </step-summary>
    </div>
  </div>
</template>
