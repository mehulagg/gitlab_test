export default () => ({
  milestonesEndpoint: '',
  labelsEndpoint: '',
  groupEndpoint: '',
  projectEndpoint: '',
  milestones: {
    isLoading: false,
    errorCode: null,
    data: [],
    selected: null,
    selectedList: [],
  },
  labels: {
    isLoading: false,
    errorCode: null,
    data: [],
    selected: null,
    selectedList: [],
  },
  authors: {
    isLoading: false,
    errorCode: null,
    data: [],
    selected: null,
    selectedList: [],
  },
  assignees: {
    isLoading: false,
    errorCode: null,
    data: [],
    selected: null,
    selectedList: [],
  },
});
