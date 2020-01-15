import invalidUrl from '~/lib/utils/invalid_url';
import { OPERATORS } from '../constants';

export default () => ({
  metricsEndpoint: null,
  environmentsEndpoint: null,
  deploymentsEndpoint: null,
  dashboardEndpoint: invalidUrl,
  emptyState: 'gettingStarted',
  showEmptyState: true,
  showErrorBanner: true,

  dashboard: {
    panel_groups: [],
  },

  deploymentData: [],
  environments: [],
  allDashboards: [],
  currentDashboard: null,
  projectPath: null,

  alertsVuex: [
    {
      alert: {},
      operator: OPERATORS.greaterThan,
      threshold: null,
      prometheus_metric_id: null,
    },
  ],
  loading: false,
  availableAlertsFromQueries: {},
  alertsEndpoint: '',
});
