export default () => ({
  /**
   * Current project path
   */
  projectPath: '',
  filtersPath: '',

  /**
   * Search query term
   */
  search: '',

  /**
   * Clusters list information
   */
  clusters: {
    options: [],
    current: null,
  },

  /**
   * Filters list information
   */
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
