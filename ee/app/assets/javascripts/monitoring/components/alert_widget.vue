<script>
import { s__ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import AlertWidgetForm from './alert_widget_form.vue';
import AlertsService from '../services/alerts_service';
import { GlLoadingIcon } from '@gitlab/ui';

export default {
  components: {
    Icon,
    AlertWidgetForm,
    GlLoadingIcon,
  },
  props: {
    alertsEndpoint: {
      type: String,
      required: true,
    },
    // { [metric_id]: { alert_attributes } }. Populated from subsequent API calls.
    // Includes only the metrics/alerts to be managed by this widget.
    alertsToManage: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    // [{ metric+query_attributes }]
    relevantQueries: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      service: null,
      errorMessage: null,
      isLoading: false,
      isOpen: false,
    };
  },
  computed: {
    alertPaths() {
      return this.relevantQueries.map(query => query.alert_path).filter(Boolean);
    },
    alertSummary() {
      return Object.keys(this.alertsToManage)
        .map(prometheusMetricId => {
          const alert = this.alertsToManage[prometheusMetricId];
          const alertQuery = this.relevantQueries.find(
            query => query.id.toString() === prometheusMetricId,
          );
          return `${alertQuery.label} ${alert.operator} ${alert.threshold}`;
        })
        .join(', ');
    },
    alertIcon() {
      return this.hasAlerts ? 'notifications' : 'notifications-off';
    },
    alertStatus() {
      return this.hasAlerts
        ? s__('PrometheusAlerts|Alert set')
        : s__('PrometheusAlerts|No alert set');
    },
    dropdownTitle() {
      return this.hasAlerts
        ? s__('PrometheusAlerts|Edit alert')
        : s__('PrometheusAlerts|Add alert');
    },
    hasAlerts() {
      return this.alertPaths.length > 0;
    },
    formDisabled() {
      return !!(this.errorMessage || this.isLoading);
    },
  },
  watch: {
    isOpen(open) {
      if (open) {
        document.addEventListener('click', this.handleOutsideClick);
      } else {
        document.removeEventListener('click', this.handleOutsideClick);
      }
    },
  },
  created() {
    this.service = new AlertsService({ alertsEndpoint: this.alertsEndpoint });
    this.fetchAlertData();
  },
  beforeDestroy() {
    // clean up external event listeners
    document.removeEventListener('click', this.handleOutsideClick);
  },
  methods: {
    fetchAlertData() {
      this.isLoading = true;
      return Promise.all(
        this.alertPaths.map(alertPath =>
          this.service.readAlert(alertPath).then(alertAttributes => {
            this.$emit('setAlerts', alertAttributes.prometheus_metric_id, alertAttributes);
          }),
        ),
      )
        .then(() => {
          this.isLoading = false;
        })
        .catch(() => {
          this.errorMessage = s__('PrometheusAlerts|Error fetching alert');
          this.isLoading = false;
        });
    },
    handleDropdownToggle() {
      this.isOpen = !this.isOpen;
    },
    handleDropdownClose() {
      this.isOpen = false;
    },
    handleOutsideClick(event) {
      if (!this.$refs.dropdownMenu.contains(event.target)) {
        this.isOpen = false;
      }
    },
    handleCreate({ operator, threshold, prometheusMetricId }) {
      const newAlert = { operator, threshold, prometheus_metric_id: prometheusMetricId };
      this.isLoading = true;
      this.service
        .createAlert(newAlert)
        .then(alertAttributes => {
          this.$emit('setAlerts', prometheusMetricId, alertAttributes);
          this.isLoading = false;
          this.handleDropdownClose();
        })
        .catch(() => {
          this.errorMessage = s__('PrometheusAlerts|Error creating alert');
          this.isLoading = false;
        });
    },
    handleUpdate({ alert, operator, threshold, prometheusMetricId }) {
      const updatedAlert = { operator, threshold };
      this.isLoading = true;
      this.service
        .updateAlert(alert, updatedAlert)
        .then(alertAttributes => {
          this.$emit('setAlerts', prometheusMetricId, alertAttributes);
          this.isLoading = false;
          this.handleDropdownClose();
        })
        .catch(() => {
          this.errorMessage = s__('PrometheusAlerts|Error saving alert');
          this.isLoading = false;
        });
    },
    handleDelete({ alert, prometheusMetricId }) {
      this.isLoading = true;
      this.service
        .deleteAlert(alert)
        .then(alertAttributes => {
          this.$emit('setAlerts', prometheusMetricId, null);
          this.isLoading = false;
          this.handleDropdownClose();
        })
        .catch(() => {
          this.errorMessage = s__('PrometheusAlerts|Error deleting alert');
          this.isLoading = false;
        });
    },
  },
};
</script>

<template>
  <div :class="{ show: isOpen }" class="prometheus-alert-widget dropdown">
    <span v-if="errorMessage" class="alert-error-message"> {{ errorMessage }} </span>
    <span v-else class="alert-current-setting">
      <gl-loading-icon v-show="isLoading" :inline="true" />
      {{ alertSummary }}
    </span>
    <button
      :aria-label="alertStatus"
      class="btn btn-sm alert-dropdown-button"
      type="button"
      @click="handleDropdownToggle"
    >
      <icon :name="alertIcon" :size="16" aria-hidden="true" />
      <icon :size="16" name="arrow-down" aria-hidden="true" class="chevron" />
    </button>
    <div
      ref="dropdownMenu"
      :class="{ 'dropdown-menu': true, 'alert-dropdown-menu': true, show: isOpen }"
    >
      <div class="dropdown-title">
        <span>{{ dropdownTitle }}</span>
        <button
          class="dropdown-title-button dropdown-menu-close"
          type="button"
          aria-label="Close"
          @click="handleDropdownClose"
        >
          <icon :size="12" name="close" aria-hidden="true" />
        </button>
      </div>
      <div class="dropdown-content">
        <alert-widget-form
          ref="widgetForm"
          :disabled="formDisabled"
          :alerts-to-manage="alertsToManage"
          :relevant-queries="relevantQueries"
          @create="handleCreate"
          @update="handleUpdate"
          @delete="handleDelete"
          @cancel="handleDropdownClose"
        />
      </div>
    </div>
  </div>
</template>
