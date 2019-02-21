<script>
import { __ } from '~/locale';
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
    alert: {
      type: String,
      required: false,
      default: null,
    },
    // alertDataExample = {
    //   alert_path: "/root/autodevops-deploy/prometheus/alerts/16.json?environment_id=37"
    //   id: 1
    //   operator: ">"
    //   query: "avg(sum(rate(container_cpu_usage_seconds_total{container_name!="POD",pod_name=~"^%{ci_environment_slug}-(.*)",namespace="%{kube_namespace}"}[15m])) by (job)) without (job)"
    //   threshold: 0.002
    //   title: "Core Usage (Total)"
    //   prometheusMetricId: 16
    // }
    alertData: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    // metricsExample = [
    //   {
    //     id: 16,
    //     label: 'Total Cores'
    //   },
    //   {
    //     id: 17,
    //     label: 'Sub-total Cores'
    //   }
    // ]
    metrics: {
      type: Array,
      required: true,
    },
  },
  data() {
    console.log('AlertWidgetForm alertData on data():', this.alertData);
    return {
      operators: OPERATORS,
      metrics: this.metrics,
      operator: this.alertData.operator,
      threshold: this.alertData.threshold,
      prometheusMetricId: this.alertData.prometheusMetricId,
    };
  },
  computed: {
    haveValuesChanged() {
      return (
        this.operator &&
        this.threshold === Number(this.threshold) &&
        (this.operator !== this.alertData.operator ||
          this.threshold !== this.alertData.threshold ||
          this.prometheusMetricId !== this.alertData.prometheusMetricId)
      );
    },
    submitAction() {
      if (!this.alert) return 'create';
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
    alertData() {
      this.resetAlertData();
    },
  },
  methods: {
    getLabelFromMetrics() {
      const targetQueries = this.metrics.filter(metric => metric.id == this.prometheusMetricId);
      // TODO: Add new string in a real way I'm not sure of.
      // if (!targetQueries.length) return s__('PrometheusAlerts|Query');
      if (!targetQueries.length) return 'Query';
      return targetQueries[0].label;
    },
    handleCancel() {
      this.resetAlertData();
      this.$emit('cancel');
    },
    handleSubmit() {
      this.$refs.submitButton.blur();
      this.$emit(this.submitAction, {
        alert: this.alert,
        operator: this.operator,
        threshold: this.threshold,
        prometheusMetricId: this.prometheusMetricId,
      });
    },
    resetAlertData() {
      this.operator = this.alertData.operator;
      this.threshold = this.alertData.threshold;
      this.prometheusMetricId = this.alertData.prometheusMetricId;
    },
  },
};
</script>

<template>
  <div class="alert-form">
    <gl-dropdown :text="getLabelFromMetrics()" class="form-group">
      <gl-dropdown-item
        v-for="metric in metrics"
        :key="metric.id"
        @click="prometheusMetricId = metric.id"
      >
        {{ metric.label }}
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
