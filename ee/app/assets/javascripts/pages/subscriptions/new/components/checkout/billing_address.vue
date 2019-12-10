<script>
import _ from 'underscore';
import { GlFormGroup, GlFormInput, GlFormSelect, GlButton } from '@gitlab/ui';
import { s__ } from '~/locale';
import Flash from '~/flash';
import Step from './components/step.vue';
import { loadCountries, loadStates } from '../../stores/actions';

export default {
  components: {
    Step,
    GlFormGroup,
    GlFormInput,
    GlFormSelect,
    GlButton,
  },
  props: {
    store: {
      type: Object,
      required: true,
    },
  },
  data() {
    const initialStateData = [
      {
        text: this.$options.i18n.stateSelectPrompt,
        value: null,
      },
    ];

    return {
      initialStateData,
      stateOptions: [...initialStateData],
      state: this.store.state.billingAddress,
      countryOptions: [
        {
          text: this.$options.i18n.countrySelectPrompt,
          value: null,
        },
      ],
    };
  },
  computed: {
    isValid() {
      return (
        !_.isEmpty(this.state.country) &&
        !_.isEmpty(this.state.streetAddressLine1) &&
        !_.isEmpty(this.state.city) &&
        !_.isEmpty(this.state.zipCode)
      );
    },
  },
  mounted() {
    this.setupCountries();
  },
  methods: {
    setupCountries() {
      loadCountries()
        .then(countries => {
          countries.forEach(country => {
            this.countryOptions.push({ text: country[0], value: country[1] });
          });
        })
        .catch(() => Flash(this.$options.i18n.countryLoadingFailedMessage));
    },
    resetStates() {
      this.state.state = null;
      this.stateOptions = [...this.initialStateData];
    },
    countryChanged() {
      this.resetStates();
      loadStates(this.state.country)
        .then(states => {
          Object.keys(states).forEach(state => {
            this.stateOptions.push({ text: state, value: states[state] });
          });
        })
        .catch(() => Flash(this.$options.i18n.stateLoadingFailedMessage));
    },
  },
  i18n: {
    stepTitle: s__('Checkout|Billing address'),
    nextStepButtonText: s__('Checkout|Continue to payment'),
    countrySelectPrompt: s__('Checkout|Please select a country'),
    countryLabel: s__('Checkout|Country'),
    countryLoadingFailedMessage: s__('Checkout|Failed to load countries. Please try again.'),
    streetAddressLabel: s__('Checkout|Street address'),
    cityLabel: s__('Checkout|City'),
    stateLabel: s__('Checkout|State'),
    stateSelectPrompt: s__('Checkout|Please select a state'),
    stateLoadingFailedMessage: s__('Checkout|Failed to load states. Please try again.'),
    zipCodeLabel: s__('Checkout|Zip code'),
  },
};
</script>
<template>
  <step
    step="billingAddress"
    :store="store"
    :title="$options.i18n.stepTitle"
    :is-valid="isValid"
    :next-step-button-text="$options.i18n.nextStepButtonText"
  >
    <template #body>
      <gl-form-group
        :label="$options.i18n.countryLabel"
        label-size="sm"
        label-for="country"
        class="append-bottom-default"
      >
        <gl-form-select
          id="country"
          v-model="state.country"
          :options="countryOptions"
          @change="countryChanged"
        />
      </gl-form-group>
      <gl-form-group
        :label="$options.i18n.streetAddressLabel"
        label-size="sm"
        label-for="streetAddressLine1"
        class="append-bottom-default"
      >
        <gl-form-input id="streetAddressLine1" v-model="state.streetAddressLine1" type="text" />
        <gl-form-input
          id="streetAddressLine2"
          v-model="state.streetAddressLine2"
          type="text"
          class="prepend-top-8"
        />
      </gl-form-group>
      <gl-form-group
        :label="$options.i18n.cityLabel"
        label-size="sm"
        label-for="city"
        class="append-bottom-default"
      >
        <gl-form-input id="city" v-model="state.city" type="text" />
      </gl-form-group>
      <div class="combined d-flex">
        <gl-form-group
          :label="$options.i18n.stateLabel"
          label-size="sm"
          label-for="state"
          class="append-right-default"
        >
          <gl-form-select id="state" v-model="state.state" :options="stateOptions" />
        </gl-form-group>
        <gl-form-group :label="$options.i18n.zipCodeLabel" label-size="sm" label-for="zipCode">
          <gl-form-input id="zipCode" v-model="state.zipCode" type="text" />
        </gl-form-group>
      </div>
    </template>
    <template #summary>
      <div>{{ state.streetAddressLine1 }}</div>
      <div>{{ state.streetAddressLine2 }}</div>
      <div>{{ state.city }}, {{ state.state }} {{ state.zipCode }}</div>
    </template>
  </step>
</template>
