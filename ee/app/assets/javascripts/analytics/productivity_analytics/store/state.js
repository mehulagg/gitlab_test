import { chartKeys, defaultMetricTypes } from './../constants';

export default () => ({
  chartEndpoint: null,
  globalFilters: {
    groupId: null,
    // groupId: 123,
    daysToMerge: [],
  },
  charts: {
    [chartKeys.main]: {
      isLoading: false,
      hasError: false,
      data: {},
      // selected: null,
      selected: ['1'],
    },
    [chartKeys.timeBasedHistogram]: {
      isLoading: false,
      hasError: false,
      data: null,
      selected: null,
      params: {
        metricType: defaultMetricTypes[chartKeys.timeBasedHistogram],
      },
    },
    [chartKeys.commitBasedHistogram]: {
      isLoading: false,
      hasError: false,
      data: null,
      selected: null,
      params: {
        metricType: defaultMetricTypes[chartKeys.commitBasedHistogram],
      },
    },
  },
});
