<script>
import { __ } from '~/locale';
import _ from 'underscore';
import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';

Vue.use(Translate);

const SUBMIT_ACTION_TEXT = {
  create: __('Add'),
  update: __('Save'),
  delete: __('Delete'),
};

const SUBMIT_BUTTON_CLASS = {
  create: 'btn-success',
  update: 'btn-success',
  delete: 'btn-remove',
};

const OPERATORS = {
  greaterThan: '>',
  equalTo: '=',
  lessThan: '<',
};

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
  },
  props: {
    disabled: {
      type: Boolean,
      required: true,
    },
    // alertsToManageExample = {
    //   '/root/autodevops-deploy/prometheus/alerts/16.json?environment_id=37': {
    //     alert_path: "/root/autodevops-deploy/prometheus/alerts/16.json?environment_id=37"
    //     id: 1
    //     operator: ">"
    //     query: "rate(http_requests_total[5m])[30m:1m]"
    //     threshold: 0.002
    //     title: "Core Usage (Total)"
    //   }
    // }
    alertsToManage: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    // queriesExample = [
    //   {
    //     id: 16,
    //     label: 'Total Cores'
    //   },
    //   {
    //     id: 17,
    //     label: 'Sub-total Cores'
    //   }
    // ]
    relevantQueries: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      operators: OPERATORS,
      operator: null,
      threshold: null,
      prometheusMetricId: null,
      selectedAlert: {},
    };
  },
  computed: {
    haveValuesChanged() {
      return (
        this.operator &&
        this.threshold === Number(this.threshold) &&
        (this.operator !== this.selectedAlert.operator ||
          this.threshold !== this.selectedAlert.threshold)
      );
    },
    submitAction() {
      if (_.isEmpty(this.selectedAlert)) return 'create';
      if (this.haveValuesChanged) return 'update';
      return 'delete';
    },
    submitActionText() {
      return SUBMIT_ACTION_TEXT[this.submitAction];
    },
    submitButtonClass() {
      return SUBMIT_BUTTON_CLASS[this.submitAction];
    },
    isSubmitDisabled() {
      return this.disabled || (this.submitAction === 'create' && !this.haveValuesChanged);
    },
  },
  watch: {
    alertsToManage() {
      this.resetAlertData();
    },
  },
  methods: {
    getCurrentQuery() {
      return this.relevantQueries.find(query => query.metricId === this.prometheusMetricId);
    },
    queryDropdownLabel() {
      const targetQuery = this.getCurrentQuery() || {};
      return targetQuery.label || s__('PrometheusAlerts|Query');
    },
    selectQuery(queryId) {
      const selectedQuery = this.relevantQueries.find(query => query.metricId === queryId);
      const existingAlert = this.alertsToManage[selectedQuery.alert_path];

      if (existingAlert) {
        this.selectedAlert = existingAlert;
        this.operator = existingAlert.operator;
        this.threshold = existingAlert.threshold;
      } else {
        this.selectedAlert = {};
        this.operator = null;
        this.threshold = null;
      }

      this.prometheusMetricId = queryId;
    },
    handleCancel() {
      this.resetAlertData();
      this.$emit('cancel');
    },
    handleSubmit() {
      this.$refs.submitButton.blur();
      this.$emit(this.submitAction, {
        alert: this.selectedAlert.alert_path,
        operator: this.operator,
        threshold: this.threshold,
        prometheusMetricId: this.prometheusMetricId,
      });
    },
    resetAlertData() {
      this.operator = null;
      this.threshold = null;
      this.prometheusMetricId = null;
      this.selectedAlert = {};
    },
  },
};
</script>

<template>
  <div class="alert-form">
    <gl-dropdown :text="queryDropdownLabel()" class="form-group alert-query-dropdown">
      <gl-dropdown-item
        v-for="query in relevantQueries"
        :key="query.metricId"
        @click="selectQuery(query.metricId)"
      >
        {{ query.label }}
      </gl-dropdown-item>
    </gl-dropdown>
    <div :aria-label="s__('PrometheusAlerts|Operator')" class="form-group btn-group" role="group">
      <button
        :class="{ active: operator === operators.greaterThan }"
        :disabled="disabled"
        type="button"
        class="btn btn-default"
        @click="operator = operators.greaterThan"
      >
        {{ operators.greaterThan }}
      </button>
      <button
        :class="{ active: operator === operators.equalTo }"
        :disabled="disabled"
        type="button"
        class="btn btn-default"
        @click="operator = operators.equalTo"
      >
        {{ operators.equalTo }}
      </button>
      <button
        :class="{ active: operator === operators.lessThan }"
        :disabled="disabled"
        type="button"
        class="btn btn-default"
        @click="operator = operators.lessThan"
      >
        {{ operators.lessThan }}
      </button>
    </div>
    <div class="form-group">
      <label>{{ s__('PrometheusAlerts|Threshold') }}</label>
      <input v-model.number="threshold" :disabled="disabled" type="number" class="form-control" />
    </div>
    <div class="action-group">
      <button
        ref="cancelButton"
        :disabled="disabled"
        type="button"
        class="btn btn-default"
        @click="handleCancel"
      >
        {{ __('Cancel') }}
      </button>
      <button
        ref="submitButton"
        :class="submitButtonClass"
        :disabled="isSubmitDisabled"
        type="button"
        class="btn btn-inverted"
        @click="handleSubmit"
      >
        {{ submitActionText }}
      </button>
    </div>
  </div>
</template>
