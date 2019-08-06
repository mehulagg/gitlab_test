<script>
import CePanelType from '~/monitoring/components/panel_type.vue';
import CustomMetricsFormFields from 'ee/custom_metrics/components/custom_metrics_form_fields.vue';

export default {
  components: {
    CustomMetricsFormFields,
  },
  extends: CePanelType,
  props: {
    alertsEndpoint: {
      type: String,
      required: false,
      default: null,
    },
    prometheusAlertsAvailable: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      allAlerts: {},
    };
  },
};
</script>
