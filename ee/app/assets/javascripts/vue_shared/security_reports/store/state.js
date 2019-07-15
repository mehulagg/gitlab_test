export default () => ({
  blobPath: {
    head: null,
    base: null,
  },

  sourceBranch: null,
  vulnerabilityFeedbackPath: null,
  vulnerabilityFeedbackHelpPath: null,
  createVulnerabilityFeedbackIssuePath: null,
  createVulnerabilityFeedbackMergeRequestPath: null,
  createVulnerabilityFeedbackDismissalPath: null,
  pipelineId: null,
  canCreateIssuePermission: false,
  canCreateFeedbackPermission: false,

  sastContainer: {
    paths: {
      head: null,
      base: null,
      diffEndpoint: null,
    },

    isLoading: false,
    hasError: false,

    newIssues: [],
    resolvedIssues: [],
  },
  dast: {
    paths: {
      head: null,
      base: null,
      diffEndpoint: null,
    },

    isLoading: false,
    hasError: false,

    newIssues: [],
    resolvedIssues: [],
  },

  dependencyScanning: {
    paths: {
      head: null,
      base: null,
      diffEndpoint: null,
    },

    isLoading: false,
    hasError: false,

    newIssues: [],
    resolvedIssues: [],
    allIssues: [],
  },
});
