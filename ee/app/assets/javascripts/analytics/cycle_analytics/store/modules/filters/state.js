export default () => ({
  milestonePath: '',
  labelsPath: '',
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
  authors: {
    isLoading: false,
    data: [],
    errorCode: null,
    selected: [],
  },
  assignees: {
    isLoading: false,
    data: [],
    errorCode: null,
    selected: [],
  },
});
