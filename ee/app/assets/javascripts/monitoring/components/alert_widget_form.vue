<script>
import _ from 'underscore';
import Vue from 'vue';
import {
  GlLink,
  GlButton,
  GlButtonGroup,
  GlFormGroup,
  GlFormInput,
  GlDropdown,
  GlDropdownItem,
  GlModal,
  GlTooltipDirective,
} from '@gitlab/ui';
import { __, s__ } from '~/locale';
import Translate from '~/vue_shared/translate';
import TrackEventDirective from '~/vue_shared/directives/track_event';
import Icon from '~/vue_shared/components/icon.vue';
import { alertsValidator, queriesValidator } from '../validators';
import AlertWidgetFormGroupTemplate from './alert_widget_form_group_template.vue';

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
    GlModal,
    GlLink,
    Icon,
    AlertWidgetFormGroupTemplate,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
    TrackEvent: TrackEventDirective,
  },
  props: {
    disabled: {
      type: Boolean,
      required: true,
    },
    errorMessage: {
      type: String,
      required: false,
      default: '',
    },
    alertsToManage: {
      type: Object,
      required: false,
      default: () => ({}),
      validator: alertsValidator,
    },
    relevantQueries: {
      type: Array,
      required: true,
      validator: queriesValidator,
    },
    modalId: {
      type: String,
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
      alertQuery: '',
      alerts: [
        {
          operator: null,
          threshold: null,
          alert: {},
          prometheus_metric_id: null,
        },
      ],
    };
  },
  computed: {
    isValidQuery() {
      // TODO: Add query validation check (most likely via http request)
      return this.alertQuery.length ? true : null;
    },
    currentQuery() {
      return this.relevantQueries.find(query => query.metricId === this.prometheusMetricId) || {};
    },
    formDisabled() {
      // We need a prometheusMetricId to determine whether we're
      // creating/updating/deleting
      return this.disabled || !(this.prometheusMetricId || this.isValidQuery);
    },
    supportsComputedAlerts() {
      return gon.features && gon.features.prometheusComputedAlerts;
    },
    queryDropdownLabel() {
      return this.currentQuery.label || s__('PrometheusAlerts|Select query');
    },
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
    dropdownTitle() {
      return this.submitAction === 'create'
        ? s__('PrometheusAlerts|Add alert')
        : s__('PrometheusAlerts|Edit alert');
    },
  },
  watch: {
    alertsToManage() {
      this.resetAlertData();
    },
    submitAction() {
      this.$emit('setAction', this.submitAction);
    },
  },
  methods: {
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
    },
    handleHidden() {
      this.resetAlertData();
      this.$emit('cancel');
    },
    handleSubmit(e) {
      e.preventDefault();
      this.$emit(this.submitAction, {
        alert: this.selectedAlert.alert_path,
        operator: this.operator,
        threshold: this.threshold,
        prometheus_metric_id: this.prometheusMetricId,
      });
    },
    resetAlertData() {
      this.operator = null;
      this.threshold = null;
      this.prometheusMetricId = null;
      this.selectedAlert = {};
    },
    getAlertFormActionTrackingOption() {
      const label = `${this.submitAction}_alert`;
      return {
        category: document.body.dataset.page,
        action: 'click_button',
        label,
      };
    },
    addMetricGroup() {
      this.alerts.push({
        alert: {},
        operator: null,
        threshold: null,
        prometheus_metric_id: null,
      });
    },
    deleteMetricGroup() {
      this.alerts.pop();
    },
    handleOperator({ operator = '', groupId = null }) {
      this.alerts[groupId].operator = operator;
    },
    handleThreshold({ threshold = null, groupId = null }) {
      this.alerts[groupId].threshold = threshold;
    },
    handleAlertData({ data = {}, groupId = null }) {
      this.alerts[groupId] = {
        ...this.alerts[groupId],
        prometheus_metric_id: data.prometheusMetricId,
        alert: data.alert,
      };
    },
    handleAllAlertsSubmit() {
      this.$emit('createMultiple', this.alerts);
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
  <gl-modal
    ref="alertModal"
    :title="dropdownTitle"
    :modal-id="modalId"
    :ok-variant="submitAction === 'delete' ? 'danger' : 'success'"
    :ok-disabled="formDisabled"
    @ok="handleSubmit"
    @hidden="handleHidden"
  >
    <div class="container">
      <div v-if="errorMessage" class="alert-modal-message danger_message">{{ errorMessage }}</div>
      <div class="row">
        <div class="col-9">
          <div>New implementation</div>
          <alert-widget-form-group-template
            v-for="(alert, index) in alerts"
            :key="index"
            :disabled="disabled"
            :template-id="index"
            :alerts-to-manage="alertsToManage"
            :relevant-queries="relevantQueries"
            @update-operator="handleOperator"
            @update-threshold="handleThreshold"
            @update-alert-data="handleAlertData"
          />
          <div>Current implementation</div>
          <div class="alert-form">
            <gl-form-group
              v-if="supportsComputedAlerts"
              :label="$options.alertQueryText.label"
              label-for="alert-query-input"
              :valid-feedback="$options.alertQueryText.validFeedback"
              :invalid-feedback="$options.alertQueryText.invalidFeedback"
              :state="isValidQuery"
            >
              <gl-form-input
                id="alert-query-input"
                v-model.trim="alertQuery"
                :state="isValidQuery"
              />
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
            <gl-form-group
              v-else
              label-for="alert-query-dropdown"
              :label="$options.alertQueryText.label"
            >
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
                @click="operator = operators.greaterThan"
              >
                {{ operators.greaterThan }}
              </gl-button>
              <gl-button
                :class="{ active: operator === operators.equalTo }"
                :disabled="formDisabled"
                type="button"
                @click="operator = operators.equalTo"
              >
                {{ operators.equalTo }}
              </gl-button>
              <gl-button
                :class="{ active: operator === operators.lessThan }"
                :disabled="formDisabled"
                type="button"
                @click="operator = operators.lessThan"
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
              />
            </gl-form-group>
          </div>
          <gl-button id="another-metric-group" @click="addMetricGroup">
            <icon name="plus" />
            {{ __('Add another metric group') }}
          </gl-button>
          <gl-button id="create-all-alerts" @click="handleAllAlertsSubmit">
            Create all alerts
          </gl-button>
        </div>
        <div class="col-3">
          <gl-button id="delete-metric-group" variant="danger" @click="deleteMetricGroup">
            <icon name="remove" />
          </gl-button>
        </div>
      </div>
    </div>
    <template #modal-ok>
      <gl-link
        v-track-event="getAlertFormActionTrackingOption()"
        class="text-reset text-decoration-none"
      >
        {{ submitActionText }}
      </gl-link>
    </template>
  </gl-modal>
</template>
