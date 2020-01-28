import { statusIcon, groupedReportText as groupedReportTextHelper } from '../../utils';

export const groupedReportText = state =>
  groupedReportTextHelper(
    state,
    state.options.reportName,
    state.options.errorMessage,
    state.options.loadingMessage,
  );

export const reportStatusIcon = ({ isLoading, hasError, newIssues }) =>
  statusIcon(isLoading, hasError, newIssues.length);

export default () => {};
