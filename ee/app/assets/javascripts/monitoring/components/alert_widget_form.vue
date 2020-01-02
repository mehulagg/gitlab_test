<script>
import _ from 'underscore';
import Vue from 'vue';
import { mapActions, mapState } from 'vuex';
import { GlButton, GlModal, GlTooltipDirective, GlLink } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import Translate from '~/vue_shared/translate';
import TrackEventDirective from '~/vue_shared/directives/track_event';
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

export default {
  components: {
    GlButton,
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
    // currentQuery() {
    //   return this.relevantQueries.find(query => query.metricId === this.prometheusMetricId) || {};
    // },
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
    submitAction() {
      this.$emit('setAction', this.submitAction);
    },
  },
  created() {
    this.resetAlertForm();
  },
  methods: {
    ...mapActions('monitoringDashboard', ['createAlerts', 'addAlertToCreate', 'resetAlertForm']),
    handleHidden() {
      // this.resetAlertData();
      this.$emit('cancel');
    },
    handleSubmit(e) {
      e.preventDefault();
      // this.$emit(this.submitAction, {
      //   alert: this.selectedAlert.alert_path,
      //   operator: this.operator,
      //   threshold: this.threshold,
      //   prometheus_metric_id: this.prometheusMetricId,
      // });
      this.createAlerts();
    },
    getAlertFormActionTrackingOption() {
      const label = `${this.submitAction}_alert`;
      return {
        category: document.body.dataset.page,
        action: 'click_button',
        label,
      };
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
    @ok="handleSubmit"
    @hidden="handleHidden"
  >
    <div class="container">
      <div v-if="errorMessage" class="alert-modal-message danger_message">{{ errorMessage }}</div>
      <alert-widget-form-group-template
        v-for="(alert, index) in alertsVuex"
        :key="index"
        :disabled="disabled"
        :template-id="index"
        :alerts-to-manage="alertsToManage"
        :relevant-queries="relevantQueries"
      />
      <div class="row">
        <gl-button id="another-metric-group" @click="addAlertToCreate">
          <icon name="plus" />
          {{ __('Add another metric group') }}
        </gl-button>
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
