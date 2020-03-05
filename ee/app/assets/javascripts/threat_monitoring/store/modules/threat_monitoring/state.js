import { defaultTimeRange } from '~/vue_shared/constants';

export default () => ({
  environmentsEndpoint: '',
  environments: [],
  isLoadingEnvironments: false,
  errorLoadingEnvironments: false,
  currentEnvironmentId: -1,
  currentTimeWindow: defaultTimeRange.name,
  wafStatisticsEndpoint: '',
  wafStatistics: {
    totalTraffic: 0,
    anomalousTraffic: 0,
    history: {
      nominal: [],
      anomalous: [],
    },
  },
  isLoadingWafStatistics: false,
  errorLoadingWafStatistics: false,
});
