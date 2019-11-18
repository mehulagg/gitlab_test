import invalidUrl from '~/lib/utils/invalid_url';

export default () => ({
  /**
   * Current project path
   */
  projectPath: '',

  /**
   * Environments list information
   */
  environments: {
    environmentsPath: invalidUrl,
    searchTerm: '',
    options: [],
    isLoading: false,
    current: null,
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
