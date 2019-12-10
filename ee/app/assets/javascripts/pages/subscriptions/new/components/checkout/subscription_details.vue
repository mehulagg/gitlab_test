<script>
import _ from 'underscore';
import { GlFormGroup, GlFormSelect, GlFormInput, GlSprintf, GlLink } from '@gitlab/ui';
import { s__ } from '~/locale';
import Step from './components/step.vue';

export default {
  components: {
    GlFormGroup,
    GlFormSelect,
    GlFormInput,
    GlSprintf,
    GlLink,
    Step,
  },
  props: {
    store: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      state: this.store.state.subscriptionDetails,
      numberOfUsers: this.store.state.subscriptionDetails.numberOfUsers,
    };
  },
  computed: {
    isValid() {
      if (this.state.setupForCompany) {
        return (
          !_.isEmpty(this.state.selectedPlan) &&
          !_.isEmpty(this.state.organizationName) &&
          this.state.numberOfUsers > 0
        );
      }
      return !_.isEmpty(this.state.selectedPlan) && this.state.numberOfUsers === 1;
    },
    selectedPlanText() {
      return this.store.getSelectedPlan().text;
    },
  },
  watch: {
    numberOfUsers(newValue) {
      this.state.numberOfUsers = newValue || 0;
    },
  },
  methods: {
    toggleSetup() {
      this.state.setupForCompany = !this.state.setupForCompany;
    },
  },
  i18n: {
    stepTitle: s__('Checkout|Subscription details'),
    nextStepButtonText: s__('Checkout|Continue to billing'),
    selectedPlanLabel: s__('Checkout|GitLab plan'),
    organizationNameLabel: s__('Checkout|Name of company or organization using GitLab'),
    numberOfUsersLabel: s__('Checkout|Number of users'),
    needMoreUsersLink: s__('Checkout|Need more users? Purchase GitLab for your %{company}.'),
    companyOrTeam: s__('Checkout|company or team'),
    selectedPlan: s__('Checkout|%{selectedPlanText} plan'),
    group: s__('Checkout|Group'),
    users: s__('Checkout|Users'),
  },
};
</script>
<template>
  <step
    step="subscriptionDetails"
    :store="store"
    :title="$options.i18n.stepTitle"
    :is-valid="isValid"
    :next-step-button-text="$options.i18n.nextStepButtonText"
  >
    <template #body>
      <gl-form-group
        :label="$options.i18n.selectedPlanLabel"
        label-size="sm"
        label-for="selectedPlan"
        class="append-bottom-default"
      >
        <gl-form-select
          id="selectedPlan"
          v-model="state.selectedPlan"
          :options="state.availablePlans"
        />
      </gl-form-group>
      <gl-form-group
        v-if="state.setupForCompany"
        :label="$options.i18n.organizationNameLabel"
        label-size="sm"
        label-for="organizationName"
        class="append-bottom-default"
      >
        <gl-form-input id="organizationName" v-model="state.organizationName" type="text" />
      </gl-form-group>
      <div class="combined d-flex">
        <gl-form-group
          :label="$options.i18n.numberOfUsersLabel"
          label-size="sm"
          label-for="numberOfUsers"
          class="number"
        >
          <gl-form-input
            id="numberOfUsers"
            v-model.number="numberOfUsers"
            type="number"
            min="0"
            :disabled="!state.setupForCompany"
          />
        </gl-form-group>
        <gl-form-group
          v-if="!state.setupForCompany"
          class="label prepend-left-default align-self-end company-link"
        >
          <gl-sprintf :message="$options.i18n.needMoreUsersLink">
            <template #company>
              <gl-link @click="toggleSetup">{{ $options.i18n.companyOrTeam }}</gl-link>
            </template>
          </gl-sprintf>
        </gl-form-group>
      </div>
    </template>
    <template #summary>
      <strong>
        {{ sprintf($options.i18n.selectedPlan, { selectedPlanText }) }}
      </strong>
      <div v-if="state.setupForCompany">
        {{ $options.i18n.group }}: {{ state.organizationName }}
      </div>
      <div>{{ $options.i18n.users }}: {{ state.numberOfUsers }}</div>
    </template>
  </step>
</template>
