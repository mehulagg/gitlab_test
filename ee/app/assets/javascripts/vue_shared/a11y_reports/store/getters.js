import { LOADING, ERROR, SUCCESS, STATUS_FAILED } from '~/reports/constants';
import { s__ } from '~/locale';
import { summaryTextBuilder, reportTextBuilder, statusIcon } from '~/reports/store/utils';

/*
TODO
- make sure utils are shareable
*/

export const summaryStatus = state => {
  if (state.isLoading) {
    return LOADING;
  }

  if (state.hasError || state.status === STATUS_FAILED) {
    return ERROR;
  }

  return SUCCESS;
};

export const groupedSummaryText = state => {
  if (state.isLoading) {
    return s__('Reports|Accessibility scanning results are being parsed');
  }

  if (state.hasError) {
    return s__('Reports|Accessibility scanning failed loading results');
  }

  return summaryTextBuilder(() => s__('Reports|Accessibility scanning'), state.report.summary);
};

export const hasIssues = state => {
  return state.report.length > 0;
};

export const shouldRenderIssuesList = state => {
  return (
    state.report.existing_errors.length > 0 ||
    state.report.existing_warnings.length > 0 ||
    state.report.existing_notes.length > 0 ||
    state.report.resolved_errors.length > 0 ||
    state.report.resolved_warnings.length > 0 ||
    state.report.resolved_notes.length > 0 ||
    state.report.new_errors.length > 0 ||
    state.report.new_warnings.length > 0 ||
    state.report.new_notes.length > 0
  );
};

export const reportStatusIcon = state => {
  return statusIcon(state.report.status);
};

export const reportText = state => {
  return reportTextBuilder(state.report.name, state.report.summary);
};

export const unresolvedIssues = state => {
  return [
    ...state.report.existing_errors,
    ...state.report.existing_warnings,
    ...state.report.existing_notes,
  ];
};

export const resolvedIssues = state => {
  return [
    ...state.report.resolved_errors,
    ...state.report.resolved_warnings,
    ...state.report.resolved_notes,
  ];
};

export const newIssues = state => {
  return [...state.report.new_errors, ...state.report.new_warnings, ...state.report.new_notes];
};

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
