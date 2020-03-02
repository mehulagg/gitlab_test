export default () => ({
  isLoadingVulnerabilities: true,
  errorLoadingVulnerabilities: false,
  loadingVulnerabilitiesErrorCode: null,
  vulnerabilities: [],
  isLoadingVulnerabilitiesCount: true,
  errorLoadingVulnerabilitiesCount: false,
  vulnerabilitiesCount: {},
  isLoadingVulnerabilitiesHistory: true,
  errorLoadingVulnerabilitiesHistory: false,
  vulnerabilitiesHistory: {},
  vulnerabilitiesHistoryDayRange: 90,
  vulnerabilitiesHistoryMaxDayInterval: 7,
  pageInfo: {},
  pipelineId: null,
  vulnerabilitiesCountEndpoint: null,
  vulnerabilitiesHistoryEndpoint: null,
  vulnerabilitiesEndpoint: null,
  activeVulnerability: null,
  sourceBranch: null,
  modal: {
    vulnerability: {},
    project: {},
    isCreatingNewIssue: false,
    isCreatingMergeRequest: false,
    isDismissingVulnerability: false,
    isCommentingOnDismissal: false,
    isShowingDeleteButtons: false,
  },
  isDismissingVulnerabilities: false,
  selectedVulnerabilities: {},
  isCreatingIssue: false,
  isCreatingMergeRequest: false,
});
