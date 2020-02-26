import { TASKS_BY_TYPE_SUBJECT_ISSUE } from '../constants';

export default () => ({
  featureFlags: {},

  startDate: null,
  endDate: null,

  isLoading: false,
  isLoadingStage: false,
  isLoadingTasksByTypeChart: false,
  isLoadingDurationChart: false,
  isLoadingDurationChartMedianData: false,

  isEmptyStage: false,
  errorCode: null,

  isSavingCustomStage: false,
  isCreatingCustomStage: false,
  isEditingCustomStage: false,

  selectedGroup: null,
  selectedProjects: [],
  selectedStage: null,

  currentStageEvents: [],

  stages: [],
  summary: [],
  labels: [],
  medians: {},

  customStageFormEvents: [],
  customStageFormErrors: null,
  customStageFormInitialData: null,

  tasksByType: {
    subject: TASKS_BY_TYPE_SUBJECT_ISSUE,
    labelIds: [],
    data: [],
  },

  durationData: [],
  durationMedianData: [],
});
