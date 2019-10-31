<script>
import { mapActions, mapState } from 'vuex';
import VueDraggable from 'vuedraggable';
import {
  GlButton,
  GlDropdown,
  GlDropdownItem,
  GlFormGroup,
  GlModal,
  GlModalDirective,
  GlTooltipDirective,
} from '@gitlab/ui';
import { s__ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import { mergeUrlParams, redirectTo } from '~/lib/utils/url_utility';
import invalidUrl from '~/lib/utils/invalid_url';
import CustomMetricsFormFields from 'ee/custom_metrics/components/custom_metrics_form_fields.vue';
import DateTimePicker from '../date_time_picker/date_time_picker.vue';
import TrackEventDirective from '~/vue_shared/directives/track_event';

export default {
  components: {
    VueDraggable,
    Icon,
    GlButton,
    GlDropdown,
    GlDropdownItem,
    GlFormGroup,
    GlModal,
    DateTimePicker,
    CustomMetricsFormFields,
  },
  directives: {
    GlModal: GlModalDirective,
    GlTooltip: GlTooltipDirective,
    TrackEvent: TrackEventDirective,
  },
  props: {
    currentEnvironmentName: {
      type: String,
      required: true,
    },
    externalDashboardUrl: {
      type: String,
      required: false,
      default: '',
    },
    selectedTimeWindow: {
      type: Object,
      required: false,
      default: () => {},
    },
    currentDashboard: {
      type: String,
      required: false,
      default: '',
    },
    customMetricsAvailable: {
      type: Boolean,
      required: false,
      default: false,
    },
    customMetricsPath: {
      type: String,
      required: false,
      default: invalidUrl,
    },
    validateQueryPath: {
      type: String,
      required: false,
      default: invalidUrl,
    },
  },
  data() {
    return {
      formIsValid: null,
    };
  },
  computed: {
    ...mapState('monitoringDashboard', [
      'groups',
      'emptyState',
      'showEmptyState',
      'environments',
      'deploymentData',
      'metricsWithData',
      'useDashboardEndpoint',
      'allDashboards',
      'environmentsEndpoint',
      'isRearrangingPanels',
      'additionalPanelTypesEnabled',
    ]),
    canAddMetrics() {
      return this.customMetricsAvailable && this.customMetricsPath.length;
    },
    firstDashboard() {
      return this.allDashboards[0] || {};
    },
    selectedDashboardText() {
      return this.currentDashboard || this.firstDashboard.display_name;
    },
    showRearrangePanelsBtn() {
      return !this.showEmptyState && this.isRearrangingPanels;
    },
    addingMetricsAvailable() {
      return IS_EE && this.canAddMetrics && !this.showEmptyState;
    },
    alertWidgetAvailable() {
      return IS_EE && this.prometheusAlertsAvailable && this.alertsEndpoint;
    },
  },
  methods: {
    ...mapActions('monitoringDashboard', [
      'toggleRearrangingPanels'
    ]),
    hideAddMetricModal() {
      this.$refs.addMetricModal.hide();
    },
    setFormValidity(isValid) {
      this.formIsValid = isValid;
    },
    submitCustomMetricsForm() {
      this.$refs.customMetricsForm.submit();
    },
    onDateTimePickerApply(timeWindowUrlParams) {
      return redirectTo(mergeUrlParams(timeWindowUrlParams, window.location.href));
    },
  },
  addMetric: {
    title: s__('Metrics|Add metric'),
    modalId: 'add-metric',
  },
};
</script>

<template>
  <div class="prometheus-graphs-header gl-p-3 pb-0 border-bottom bg-gray-light">
    <div class="row">
      <template v-if="environmentsEndpoint">
        <gl-form-group
          :label="__('Dashboard')"
          label-size="sm"
          label-for="monitor-dashboards-dropdown"
          class="col-sm-12 col-md-6 col-lg-2"
        >
          <gl-dropdown
            id="monitor-dashboards-dropdown"
            class="mb-0 d-flex js-dashboards-dropdown"
            toggle-class="dropdown-menu-toggle"
            :text="selectedDashboardText"
          >
            <gl-dropdown-item
              v-for="dashboard in allDashboards"
              :key="dashboard.path"
              :active="dashboard.path === currentDashboard"
              active-class="is-active"
              :href="`?dashboard=${dashboard.path}`"
              >{{ dashboard.display_name || dashboard.path }}</gl-dropdown-item
            >
          </gl-dropdown>
        </gl-form-group>

        <gl-form-group
          :label="s__('Metrics|Environment')"
          label-size="sm"
          label-for="monitor-environments-dropdown"
          class="col-sm-6 col-md-6 col-lg-2"
        >
          <gl-dropdown
            id="monitor-environments-dropdown"
            class="mb-0 d-flex js-environments-dropdown"
            toggle-class="dropdown-menu-toggle"
            :text="currentEnvironmentName"
            :disabled="environments.length === 0"
          >
            <gl-dropdown-item
              v-for="environment in environments"
              :key="environment.id"
              :active="environment.name === currentEnvironmentName"
              active-class="is-active"
              :href="environment.metrics_path"
              >{{ environment.name }}</gl-dropdown-item
            >
          </gl-dropdown>
        </gl-form-group>

        <gl-form-group
          v-if="!showEmptyState"
          :label="s__('Metrics|Show last')"
          label-size="sm"
          label-for="monitor-time-window-dropdown"
          class="col-sm-6 col-md-6 col-lg-4"
        >
          <date-time-picker
            :selected-time-window="selectedTimeWindow"
            @onApply="onDateTimePickerApply"
          />
        </gl-form-group>
      </template>

      <gl-form-group
        v-if="addingMetricsAvailable || showRearrangePanelsBtn || externalDashboardUrl.length"
        label-for="prometheus-graphs-dropdown-buttons"
        class="dropdown-buttons col-md d-md-flex col-lg d-lg-flex align-items-end"
      >
        <div id="prometheus-graphs-dropdown-buttons">
          <gl-button
            v-if="showRearrangePanelsBtn"
            :pressed="isRearrangingPanels"
            variant="default"
            class="mr-2 mt-1 js-rearrange-button"
            @click="toggleRearrangingPanels"
          >
            {{ __('Arrange charts') }}
          </gl-button>
          <gl-button
            v-if="addingMetricsAvailable"
            v-gl-modal="$options.addMetric.modalId"
            variant="outline-success"
            class="mr-2 mt-1 js-add-metric-button"
          >
            {{ $options.addMetric.title }}
          </gl-button>
          <gl-modal
            v-if="addingMetricsAvailable"
            ref="addMetricModal"
            :modal-id="$options.addMetric.modalId"
            :title="$options.addMetric.title"
          >
            <form ref="customMetricsForm" :action="customMetricsPath" method="post">
              <custom-metrics-form-fields
                :validate-query-path="validateQueryPath"
                form-operation="post"
                @formValidation="setFormValidity"
              />
            </form>
            <div slot="modal-footer">
              <gl-button @click="hideAddMetricModal">{{ __('Cancel') }}</gl-button>
              <gl-button
                :disabled="!formIsValid"
                variant="success"
                @click="submitCustomMetricsForm"
              >
                {{ __('Save changes') }}
              </gl-button>
            </div>
          </gl-modal>

          <gl-button
            v-if="externalDashboardUrl.length"
            class="mt-1 js-external-dashboard-link"
            variant="primary"
            :href="externalDashboardUrl"
            target="_blank"
            rel="noopener noreferrer"
          >
            {{ __('View full dashboard') }}
            <icon name="external-link" />
          </gl-button>
        </div>
      </gl-form-group>
    </div>
  </div>
</template>
