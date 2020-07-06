<script>
import { GlFormGroup, GlFormTextarea } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { ROLLOUT_STRATEGY_USER_ID } from '../../constants';
import { strategyComponent } from '../../utils';

export default {
  components: {
    GlFormGroup,
    GlFormTextarea,
  },
  mixins: [
    strategyComponent((strategy, value) => ({
      ...strategy,
      name: ROLLOUT_STRATEGY_USER_ID,
      parameters: {
        userIds: value,
      },
    })),
  ],
  translations: {
    rolloutUserIdsDescription: __('Enter one or more user ID separated by commas'),
    rolloutUserIdsLabel: s__('FeatureFlag|User IDs'),
  },
  data() {
    return {
      formUserIds: this.strategy?.parameters?.userIds ?? '',
    };
  },
  computed: {
    strategyUserIdsId() {
      return `strategy-user-ids-${this.index}`;
    },
  },
};
</script>
<template>
  <gl-form-group
    :label="$options.translations.rolloutUserIdsLabel"
    :description="$options.translations.rolloutUserIdsDescription"
    :label-for="strategyUserIdsId"
  >
    <gl-form-textarea :id="strategyUserIdsId" :value="formUserIds" @input="onParameterChange" />
  </gl-form-group>
</template>
