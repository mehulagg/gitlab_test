export default () => ({
  milestonePath: '',
  labelsPath: '',
  authorPath: '',
  assigneesPath: '',
  milestones: {
    isLoading: false,
    data: [],
    errorCode: null,
    selected: null,
  },
  labels: {
    isLoading: false,
    data: [],
    errorCode: null,
    selected: [],
  },
});
