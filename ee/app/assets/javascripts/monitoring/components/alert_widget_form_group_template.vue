<script>
import {
  GlButton,
  GlButtonGroup,
  GlFormGroup,
  GlFormInput,
  GlDropdown,
  GlDropdownItem,
} from '@gitlab/ui';
import _ from 'underscore';
import { __, s__ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import { alertsValidator, queriesValidator } from '../validators';

const OPERATORS = {
  greaterThan: '>',
  equalTo: '==',
  lessThan: '<',
};

export default {
  components: {
    GlButton,
    GlButtonGroup,
    GlFormGroup,
    GlFormInput,
    GlDropdown,
    GlDropdownItem,
    Icon,
  },
  props: {
    disabled: {
      type: Boolean,
      required: true,
    },
    templateId: {
      type: Number,
      required: false,
      default: null,
    },
    relevantQueries: {
      type: Array,
      required: true,
      validator: queriesValidator,
    },
    alertsToManage: {
      type: Object,
      required: false,
      default: () => ({}),
      validator: alertsValidator,
    },
  },
  data() {
    return {
      operators: OPERATORS,
      operator: null,
      threshold: null,
      prometheusMetricId: null,
      selectedAlert: {},
      alertQuery: '',
    };
  },
  computed: {
    isValidQuery() {
      // TODO: Add query validation check (most likely via http request)
      return this.alertQuery.length ? true : null;
    },
    formDisabled() {
      return this.disabled || !(this.prometheusMetricId || this.isValidQuery);
    },
    supportsComputedAlerts() {
      return gon.features && gon.features.prometheusComputedAlerts;
    },
    queryDropdownLabel() {
      return this.currentQuery.label || s__('PrometheusAlerts|Select query');
    },
    currentQuery() {
      return this.relevantQueries.find(query => query.metricId === this.prometheusMetricId) || {};
    },
  },
  watch: {
    alertsToManage() {
      this.resetAlertData();
    },
  },
  methods: {
    updateOperator(selectedOperator) {
      this.operator = selectedOperator;
      this.$emit('update-operator', {
        operator: selectedOperator,
        groupId: this.templateId,
      });
    },
    updateThreshold() {
      this.$emit('update-threshold', {
        threshold: this.threshold,
        groupId: this.templateId,
      });
    },
    selectQuery(queryId) {
      const existingAlertPath = _.findKey(this.alertsToManage, alert => alert.metricId === queryId);
      const existingAlert = this.alertsToManage[existingAlertPath];

      if (existingAlert) {
        this.selectedAlert = existingAlert;
        this.operator = existingAlert.operator;
        this.threshold = existingAlert.threshold;
      } else {
        this.selectedAlert = {};
        this.operator = this.operators.greaterThan;
        this.threshold = null;
      }

      this.prometheusMetricId = queryId;
      this.$emit('update-alert-data', {
        data: {
          prometheusMetricId: this.prometheusMetricId,
          alert: this.selectedAlert,
        },
        groupId: this.templateId,
      });
    },
    resetAlertData() {
      this.operator = null;
      this.threshold = null;
      this.prometheusMetricId = null;
      this.selectedAlert = {};
    },
  },
  alertQueryText: {
    label: __('Query'),
    validFeedback: __('Query is valid'),
    invalidFeedback: __('Invalid query'),
    descriptionTooltip: __(
      'Example: Usage = single query. (Requested) / (Capacity) = multiple queries combined into a formula.',
    ),
  },
};
</script>
<template>
  <div class="alert-form">
    <gl-form-group
      v-if="supportsComputedAlerts"
      :label="$options.alertQueryText.label"
      label-for="alert-query-input"
      :valid-feedback="$options.alertQueryText.validFeedback"
      :invalid-feedback="$options.alertQueryText.invalidFeedback"
      :state="isValidQuery"
    >
      <gl-form-input id="alert-query-input" v-model.trim="alertQuery" :state="isValidQuery" />
      <template #description>
        <div class="d-flex align-items-center">
          {{ __('Single or combined queries') }}
          <icon
            v-gl-tooltip-directive="$options.alertQueryText.descriptionTooltip"
            name="question"
            class="prepend-left-4"
          />
        </div>
      </template>
    </gl-form-group>
    <gl-form-group v-else label-for="alert-query-dropdown" :label="$options.alertQueryText.label">
      <gl-dropdown
        id="alert-query-dropdown"
        :text="queryDropdownLabel"
        toggle-class="dropdown-menu-toggle"
      >
        <gl-dropdown-item
          v-for="query in relevantQueries"
          :key="query.metricId"
          @click="selectQuery(query.metricId)"
        >
          {{ query.label }}
        </gl-dropdown-item>
      </gl-dropdown>
    </gl-form-group>
    <gl-button-group class="mb-2" :label="s__('PrometheusAlerts|Operator')">
      <gl-button
        :class="{ active: operator === operators.greaterThan }"
        :disabled="formDisabled"
        type="button"
        @click="updateOperator(operators.greaterThan)"
      >
        {{ operators.greaterThan }}
      </gl-button>
      <gl-button
        :class="{ active: operator === operators.equalTo }"
        :disabled="formDisabled"
        type="button"
        @click="updateOperator(operators.equalTo)"
      >
        {{ operators.equalTo }}
      </gl-button>
      <gl-button
        :class="{ active: operator === operators.lessThan }"
        :disabled="formDisabled"
        type="button"
        @click="updateOperator(operators.lessThan)"
      >
        {{ operators.lessThan }}
      </gl-button>
    </gl-button-group>
    <gl-form-group :label="s__('PrometheusAlerts|Threshold')" label-for="alerts-threshold">
      <gl-form-input
        id="alerts-threshold"
        v-model.number="threshold"
        :disabled="formDisabled"
        type="number"
        @input="updateThreshold"
      />
    </gl-form-group>
  </div>
</template>
