export default () => ({
  statisticsEndpoint: '',
  statistics: {
    total: 0,
    anomalous: 0,
    history: {
      nominal: [],
      anomalous: [],
    },
  },
  isLoadingStatistics: false,
  errorLoadingStatistics: false,
});
