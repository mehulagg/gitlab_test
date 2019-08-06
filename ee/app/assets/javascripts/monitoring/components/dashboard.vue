<script>
import CeDashboard from '~/monitoring/components/dashboard.vue';
import CustomMetricsFormFields from 'ee/custom_metrics/components/custom_metrics_form_fields.vue';

export default {
  components: {
    CustomMetricsFormFields,
  },
  extends: CeDashboard,
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
};
</script>
