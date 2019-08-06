<script>
import CeChartActions from '~/monitoring/components/chart_actions.vue';
import AlertWidget from './alert_widget.vue';

export default {
  components: {
    AlertWidget,
  },
  extends: CeChartActions,
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
  methods: {
    setAlerts(alertPath, alertAttributes) {
      if (alertAttributes) {
        this.$set(this.allAlerts, alertPath, alertAttributes);
      } else {
        this.$delete(this.allAlerts, alertPath);
      }
    },
  },
};
</script>
