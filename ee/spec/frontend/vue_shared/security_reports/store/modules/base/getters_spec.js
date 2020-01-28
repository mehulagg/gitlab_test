import * as getters from 'ee/vue_shared/security_reports/store/modules/base/getters';

const createReport = (config = {}) => ({
  reportType: 'Example Report',
  paths: [],
  newIssues: [],
  ...config,
});

describe('groupedReportText', () => {
  it("should return the error message if there's an error", () => {
    const state = createReport({ hasError: true });
    const result = getters.groupedReportText(state);

    expect(result).toBe('Example Report: Loading resulted in an error');
  });

  it("should return the loading message if it's still loading", () => {
    const state = createReport({ isLoading: true });
    const result = getters.groupedReportText(state);

    expect(result).toBe('Example Report is loading');
  });

  it('should call groupedTextBuilder if everything is fine', () => {
    const state = createReport();
    const result = getters.groupedReportText(state);

    expect(result).toBe('Example Report detected no vulnerabilities for the source branch only');
  });
});

describe('reportStatusIcon', () => {
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

  it("should return `warning` when there's a new issue", () => {
    const sast = createReport({ hasError: true, newIssues: [{}] });
    const result = getters.reportStatusIcon(sast);

    expect(result).toBe('warning');
  });

  it('should return `success` when nothing is wrong', () => {
    const sast = createReport();
    const result = getters.reportStatusIcon(sast);

    expect(result).toBe('success');
  });
});
