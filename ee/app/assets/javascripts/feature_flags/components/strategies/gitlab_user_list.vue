<script>
import { GlFormGroup, GlFormSelect } from '@gitlab/ui';
import { s__ } from '~/locale';
import { ROLLOUT_STRATEGY_GITLAB_USER_LIST } from '../../constants';
import { strategyComponent } from '../../utils';

export default {
  mixins: [
    strategyComponent((strategy, value) => ({
      ...strategy,
      name: ROLLOUT_STRATEGY_GITLAB_USER_LIST,
      parameters: {},
      userListId: value,
    })),
  ],
  components: {
    GlFormGroup,
    GlFormSelect,
  },
  translations: {
    rolloutUserListLabel: s__('FeatureFlag|List'),
    rolloutUserListDescription: s__('FeatureFlag|Select a user list'),
    rolloutUserListNoListError: s__('FeatureFlag|There are no configured user lists'),
  },
  data() {
    return {
      formUserListId: this.strategy?.userListId ?? '',
    };
  },
  computed: {
    userListOptions() {
      return this.userLists.map(({ name, id }) => ({ value: id, text: name }));
    },
    hasUserLists() {
      return this.userListOptions.length > 0;
    },
    strategyUserListId() {
      return `strategy-user-list-${this.index}`;
    },
  },
};
</script>
<template>
  <gl-form-group
    :state="hasUserLists"
    :invalid-feedback="$options.translations.rolloutUserListNoListError"
    :label="$options.translations.rolloutUserListLabel"
    :description="$options.translations.rolloutUserListDescription"
    :label-for="strategyUserListId"
  >
    <gl-form-select
      :id="strategyUserListId"
      :value="formUserListId"
      :options="userListOptions"
      @change="onParameterChange"
    />
  </gl-form-group>
</template>
