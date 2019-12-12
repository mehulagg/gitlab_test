import { __ } from '~/locale';

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

  modal: {
    title: null,

    // Dynamic data rendered for each issue
    data: {
      description: {
        value: null,
        text: __('Description'),
        isLink: false,
      },
      url: {
        value: null,
        url: null,
        text: __('URL'),
        isLink: true,
      },
      file: {
        value: null,
        url: null,
        text: __('File'),
        isLink: true,
      },
      identifiers: {
        value: [],
        text: __('Identifiers'),
        isLink: false,
      },
      severity: {
        value: null,
        text: __('Severity'),
        isLink: false,
      },
      confidence: {
        value: null,
        text: __('Confidence'),
        isLink: false,
      },
      className: {
        value: null,
        text: __('Class'),
        isLink: false,
      },
      methodName: {
        value: null,
        text: __('Method'),
        isLink: false,
      },
      image: {
        value: null,
        text: __('Image'),
        isLink: false,
      },
      namespace: {
        value: null,
        text: __('Namespace'),
        isLink: false,
      },
      links: {
        value: [],
        text: __('Links'),
        isLink: false,
      },
      instances: {
        value: [],
        text: __('Instances'),
        isLink: false,
      },
    },
    learnMoreUrl: null,

    vulnerability: {
      isDismissed: false,
      hasIssue: false,
      hasMergeRequest: false,
    },

    isCreatingNewIssue: false,
    isDismissingVulnerability: false,
    isShowingDeleteButtons: false,
    isCommentingOnDismissal: false,
    error: null,
  },
});
