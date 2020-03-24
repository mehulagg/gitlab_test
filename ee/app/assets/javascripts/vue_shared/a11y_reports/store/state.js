export default () => ({
  endpoint: null,

  isLoading: false,
  hasError: false,

  /**
   * Report will have the following format:
   * {
   *   name: {String},
   *   status: {String},
   *   summary: {
   *     total: {Number},
   *     notes: {Number},
   *     warnings: {Number},
   *     errors: {Number},
   *   },
   *   new_warnings: {Array.<Object>},
   *   resolved_warnings: {Array.<Object>},
   *   existing_warnings: {Array.<Object>},
   *   new_errors: {Array.<Object>},
   *   resolved_errors: {Array.<Object>},
   *   existing_errors: {Array.<Object>},
   *   new_notes: {Array.<Object>},
   *   resolved_notes: {Array.<Object>},
   *   existing_notes: {Array.<Object>},
   * }
   */
  report: {},
});
