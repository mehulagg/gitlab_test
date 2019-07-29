export default () => ({
  endpoints: {
    cycleAnalyticsAata: '',
    stageData: '',
  },

  dataTimeframe: 30,

  isLoading: false,
  isLoadingStage: false,

  isEmptyStage: false,

  selectedGroup: null,
  selectedProjectIds: [],
  selectedStageName: null,

  events: [],
  stages: [],
  summary: [],
});
