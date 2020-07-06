<script>
import { GlFormGroup, GlFormInput } from '@gitlab/ui';
import { s__, __ } from '~/locale';
import { ROLLOUT_STRATEGY_PERCENT_ROLLOUT, PERCENT_ROLLOUT_GROUP_ID } from '../../constants';
import { strategyComponent } from '../../utils';

export default {
  mixins: [
    strategyComponent((strategy, value) => ({
      ...strategy,
      name: ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
      parameters: {
        percentage: value,
        groupId: PERCENT_ROLLOUT_GROUP_ID,
      },
    })),
  ],
  components: {
    GlFormGroup,
    GlFormInput,
  },
  translations: {
    rolloutPercentageDescription: __('Enter a whole number between 0 and 100'),
    rolloutPercentageInvalid: s__(
      'FeatureFlags|Percent rollout must be a whole number between 0 and 100',
    ),
    rolloutPercentageLabel: s__('FeatureFlag|Percentage'),
  },
  data() {
    return {
      formPercentage: this.strategy?.parameters?.percentage ?? '',
    };
  },
  computed: {
    strategyPercentageId() {
      return `strategy-percentage-${this.index}`;
    },
    isValid() {
      return Number(this.formPercentage) >= 0 && Number(this.formPercentage) <= 100;
    },
  },
};
</script>
<template>
  <gl-form-group
    :label="$options.translations.rolloutPercentageLabel"
    :description="$options.translations.rolloutPercentageDescription"
    :label-for="strategyPercentageId"
    :invalid-feedback="$options.translations.rolloutPercentageInvalid"
  >
    <div class="flex align-items-center">
      <gl-form-input
        :id="strategyPercentageId"
        :value="formPercentage"
        :state="isValid"
        class="rollout-percentage text-right w-3rem"
        type="number"
        min="0"
        max="100"
        @input="onParameterChange"
      />
      <span class="ml-1">%</span>
    </div>
  </gl-form-group>
</template>
