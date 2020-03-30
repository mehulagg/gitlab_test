import { LOADING, ERROR, SUCCESS, STATUS_FAILED } from '~/reports/constants';
import { sprintf, s__, n__, __ } from '~/locale';

const textBuilder = ({ errors, warnings }) => {
  const numberOfResults = errors + warnings;
  if (numberOfResults === 0) {
    return __('no issues for the source branch only');
  }
  return n__(
    '%d issue for the source branch only',
    '%d issues for the source branch only',
    numberOfResults,
  );
};

const reportTextBuilder = (name = '', report = {}) => {
  const summary = textBuilder(report);
  return sprintf(__('%{name} detected %{summary}'), { name, summary });
};

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

  return reportTextBuilder(s__('Reports|Accessibility scanning'), state.report.summary);
};

export const shouldRenderIssuesList = state => {
  return (
    state.report?.existing_errors?.length > 0 ||
    state.report?.existing_warnings?.length > 0 ||
    state.report?.existing_notes?.length > 0 ||
    state.report?.resolved_errors?.length > 0 ||
    state.report?.resolved_warnings?.length > 0 ||
    state.report?.resolved_notes?.length > 0 ||
    state.report?.new_errors?.length > 0 ||
    state.report?.new_warnings?.length > 0 ||
    state.report?.new_notes?.length > 0
  );
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
