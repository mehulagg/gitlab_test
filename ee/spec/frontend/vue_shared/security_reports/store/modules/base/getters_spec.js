import * as getters from 'ee/vue_shared/security_reports/store/modules/base/getters';

const createReport = (config = {}) => ({
  options: {
    reportName: 'ExampleReport',
    errorMessage: 'Example Error Message',
    loadingMessage: 'Example Loading Message',
  },
  paths: [],
  newIssues: [],
  ...config,
});

describe('groupedSastText', () => {
  it("should return the error message if there's an error", () => {
    const sast = createReport({ hasError: true });
    const result = getters.groupedReportText(sast);

    expect(result).toBe('Example Error Message');
  });

  it("should return the loading message if it's still loading", () => {
    const sast = createReport({ isLoading: true });
    const result = getters.groupedReportText(sast);

    expect(result).toBe('Example Loading Message');
  });

  it('should call groupedTextBuilder if everything is fine', () => {
    const sast = createReport();
    const result = getters.groupedReportText(sast);

    expect(result).toBe('ExampleReport detected no vulnerabilities for the source branch only');
  });
});

describe('sastStatusIcon', () => {
  it("should return `loading` when we're still loading", () => {
    const sast = createReport({ isLoading: true });
    const result = getters.reportStatusIcon(sast);

    expect(result).toBe('loading');
  });

  it("should return `warning` when there's an issue", () => {
    const sast = createReport({ hasError: true });
    const result = getters.reportStatusIcon(sast);

    expect(result).toBe('warning');
  });

  it('should return `success` when nothing is wrong', () => {
    const sast = createReport();
    const result = getters.reportStatusIcon(sast);

    expect(result).toBe('success');
  });
});
