export default () => ({
  /**
   * Current project path
   */
  projectPath: '',

  /**
   * Environments list information
   */
  selectedCluster: '',

  filters: {
    data: [],
    isLoading: false,
  },

  /**
   * Logs including trace
   */
  logs: {
    lines: [],
    isLoading: false,
    isComplete: true,
  },

  /**
   * Pods list information
   */
  pods: {
    options: [],
    current: null,
  },
});
