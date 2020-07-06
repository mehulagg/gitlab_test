<script>
import Vue from 'vue';
import { isNumber } from 'lodash';
import {
  GlFormSelect,
  GlFormInput,
  GlFormTextarea,
  GlFormGroup,
  GlToken,
  GlDeprecatedButton,
  GlIcon,
} from '@gitlab/ui';
import { s__, __ } from '~/locale';
import {
  ROLLOUT_STRATEGY_ALL_USERS,
  ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
  ROLLOUT_STRATEGY_USER_ID,
  ROLLOUT_STRATEGY_GITLAB_USER_LIST,
} from '../constants';

import NewEnvironmentsDropdown from './new_environments_dropdown.vue';
import Default from './strategies/default.vue';
import PercentRollout from './strategies/percent_rollout.vue';
import UsersWithId from './strategies/users_with_id.vue';
import GitlabUserList from './strategies/gitlab_user_list.vue';

const STRATEGIES = Object.freeze({
  [ROLLOUT_STRATEGY_ALL_USERS]: Default,
  [ROLLOUT_STRATEGY_PERCENT_ROLLOUT]: PercentRollout,
  [ROLLOUT_STRATEGY_USER_ID]: UsersWithId,
  [ROLLOUT_STRATEGY_GITLAB_USER_LIST]: GitlabUserList,
});

export default {
  components: {
    GlFormGroup,
    GlFormInput,
    GlFormTextarea,
    GlFormSelect,
    GlToken,
    GlDeprecatedButton,
    GlIcon,
    NewEnvironmentsDropdown,
  },
  model: {
    prop: 'strategy',
    event: 'change',
  },
  props: {
    strategy: {
      type: Object,
      required: true,
    },
    index: {
      type: Number,
      required: true,
    },
    endpoint: {
      type: String,
      required: false,
      default: '',
    },
    userLists: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  ROLLOUT_STRATEGY_ALL_USERS,
  ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
  ROLLOUT_STRATEGY_USER_ID,
  ROLLOUT_STRATEGY_GITLAB_USER_LIST,

  translations: {
    allEnvironments: __('All environments'),
    environmentsLabel: __('Environments'),
    removeLabel: s__('FeatureFlag|Delete strategy'),
    rolloutUserListLabel: s__('FeatureFlag|List'),
    rolloutUserListDescription: s__('FeatureFlag|Select a user list'),
    rolloutUserListNoListError: s__('FeatureFlag|There are no configured user lists'),
    strategyTypeDescription: __('Select strategy activation method'),
    strategyTypeLabel: s__('FeatureFlag|Type'),
  },

  data() {
    return {
      environments: this.strategy.scopes || [],
      formStrategy: { ...this.strategy },
      strategies: [
        {
          value: ROLLOUT_STRATEGY_ALL_USERS,
          text: __('All users'),
        },
        {
          value: ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
          text: __('Percent of users'),
        },
        {
          value: ROLLOUT_STRATEGY_USER_ID,
          text: __('User IDs'),
        },
        {
          value: ROLLOUT_STRATEGY_GITLAB_USER_LIST,
          text: __('User List'),
        },
      ],
    };
  },
  computed: {
    strategyTypeId() {
      return `strategy-type-${this.index}`;
    },
    environmentsDropdownId() {
      return `environments-dropdown-${this.index}`;
    },
    appliesToAllEnvironments() {
      return (
        this.filteredEnvironments.length === 0 ||
        (this.filteredEnvironments.length === 1 &&
          this.filteredEnvironments[0].environmentScope === '*')
      );
    },
    filteredEnvironments() {
      return this.environments.filter(e => !e.shouldBeDestroyed);
    },
    strategyComponent() {
      return STRATEGIES[this.formStrategy.name];
    },
  },
  methods: {
    addEnvironment(environment) {
      const allEnvironmentsScope = this.environments.find(scope => scope.environmentScope === '*');
      if (allEnvironmentsScope) {
        allEnvironmentsScope.shouldBeDestroyed = true;
      }
      this.environments.push({ environmentScope: environment });
      this.onStrategyChange({ ...this.formStrategy, scopes: this.environments });
    },
    onStrategyChange(s) {
      this.$emit('change', s);
      this.formStrategy = s;
    },
    removeScope(environment) {
      if (isNumber(environment.id)) {
        Vue.set(environment, 'shouldBeDestroyed', true);
      } else {
        this.environments = this.environments.filter(e => e !== environment);
      }
      this.onStrategyChange({ ...this.formStrategy, scopes: this.environments });
    },
  },
};
</script>
<template>
  <div class="border-top py-4">
    <div class="flex flex-column flex-md-row flex-md-wrap">
      <div class="mr-5">
        <gl-form-group
          :label="$options.translations.strategyTypeLabel"
          :description="$options.translations.strategyTypeDescription"
          :label-for="strategyTypeId"
        >
          <gl-form-select :id="strategyTypeId" v-model="formStrategy.name" :options="strategies" />
        </gl-form-group>
      </div>

      <div data-testid="strategy">
        <component
          :is="strategyComponent"
          v-if="strategyComponent"
          :index="index"
          :strategy="strategy"
          :user-lists="userLists"
          @change="onStrategyChange"
        />
      </div>

      <div class="align-self-end align-self-md-stretch order-first offset-md-0 order-md-0 ml-auto">
        <gl-deprecated-button
          data-testid="delete-strategy-button"
          variant="danger"
          @click="$emit('delete')"
        >
          <span class="d-md-none">
            {{ $options.translations.removeLabel }}
          </span>
          <gl-icon class="d-none d-md-inline-flex" name="remove" />
        </gl-deprecated-button>
      </div>
    </div>
    <div class="flex flex-column">
      <label :for="environmentsDropdownId">{{ $options.translations.environmentsLabel }}</label>
      <div class="flex flex-column flex-md-row align-items-start align-items-md-center">
        <new-environments-dropdown
          :id="environmentsDropdownId"
          :endpoint="endpoint"
          class="mr-2"
          @add="addEnvironment"
        />
        <span v-if="appliesToAllEnvironments" class="text-secondary mt-2 mt-md-0 ml-md-3">
          {{ $options.translations.allEnvironments }}
        </span>
        <div v-else class="flex align-items-center">
          <gl-token
            v-for="environment in filteredEnvironments"
            :key="environment.id"
            class="mt-2 mr-2 mt-md-0 mr-md-0 ml-md-2 rounded-pill"
            @close="removeScope(environment)"
          >
            {{ environment.environmentScope }}
          </gl-token>
        </div>
      </div>
    </div>
  </div>
</template>
