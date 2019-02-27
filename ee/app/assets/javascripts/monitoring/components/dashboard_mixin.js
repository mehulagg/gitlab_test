import AlertWidget from './alert_widget.vue';

export default {
  components: {
    AlertWidget,
  },
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
    getGraphLabel(graphData) {
      // TODO: REVISIT THIS PLEASE
      if (!graphData.queries || !graphData.queries[0]) return undefined;
      return graphData.queries[0].label || graphData.y_label || 'Average';
    },
    setAlerts(alertPath, alertAttributes) {
      this.$set(this.allAlerts, alertPath, alertAttributes);
    },
  },
};
