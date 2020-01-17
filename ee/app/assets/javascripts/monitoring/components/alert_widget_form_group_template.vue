<script>
import {
  GlButton,
  GlButtonGroup,
  GlFormGroup,
  GlFormInput,
  GlDropdown,
  GlDropdownItem,
} from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';
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
      // prometheusMetricId: null,
      selectedAlert: {},
      alertQuery: '',
    };
  },
  computed: {
    ...mapState('monitoringDashboard', ['alertsVuex']),
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
    alert() {
      return this.alertsVuex[this.templateId];
    },
    threshold: {
      get() {
        return this.alert.threshold;
      },
      set(value) {
        this.updateAlertForm({ index: this.templateId, threshold: value });
      },
    },
    prometheusMetricId: {
      get() {
        return this.alert.prometheusMetricId;
      },
      set(value) {
        this.updateAlertForm({ index: this.templateId, prometheusMetricId: value });
      },
    },
    alertPath: {
      get() {
        return this.alert.alertPath;
      },
    },
  },
  methods: {
    ...mapActions('monitoringDashboard', ['updateAlertForm', 'addAlertToDelete']),
    selectQuery(queryId) {
      // const existingAlertPath = _.findKey(this.alertsToManage, alert => alert.metricId === queryId);
      // const existingAlert = this.alertsToManage[existingAlertPath];

      this.prometheusMetricId = queryId;
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
  <div class="row">
    <div class="col-12">
      <div class="alert-form">
        <label class="d-block col-form-label">{{ s__('Query') }}</label>
        <div v-if="supportsComputedAlerts" class="row">
          <div class="9">
            <gl-form-group
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
          </div>
        </div>
        <div v-else class="row">
          <div class="col-9">
            <gl-form-group>
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
          </div>
          <div class="col-3">
            <gl-button
              id="delete-metric-group"
              variant="danger"
              class="pull-right"
              @click="addAlertToDelete(templateId)"
            >
              <icon name="remove" />
            </gl-button>
          </div>
        </div>
        <div class="row">
          <div class="col-9">
            <gl-button-group class="mb-2" :label="s__('PrometheusAlerts|Operator')">
              <gl-button
                :class="{ active: alert.operator === operators.greaterThan }"
                :disabled="formDisabled"
                type="button"
                @click="updateAlertForm({ index: templateId, operator: operators.greaterThan })"
              >
                {{ operators.greaterThan }}
              </gl-button>
              <gl-button
                :class="{ active: alert.operator === operators.equalTo }"
                :disabled="formDisabled"
                type="button"
                @click="updateAlertForm({ index: templateId, operator: operators.equalTo })"
              >
                {{ operators.equalTo }}
              </gl-button>
              <gl-button
                :class="{ active: alert.operator === operators.lessThan }"
                :disabled="formDisabled"
                type="button"
                @click="updateAlertForm({ index: templateId, operator: operators.lessThan })"
              >
                {{ operators.lessThan }}
              </gl-button>
            </gl-button-group>
          </div>
        </div>
        <div class="row">
          <div class="col-9">
            <gl-form-group :label="s__('PrometheusAlerts|Threshold')" label-for="alerts-threshold">
              <gl-form-input
                id="alerts-threshold"
                v-model.number="threshold"
                :disabled="formDisabled"
                type="number"
              />
            </gl-form-group>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
