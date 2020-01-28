import { sprintf } from '~/locale';
import { statusIcon, groupedTextBuilder, countIssues } from '../../utils';
import messages from '../../messages';

const { TRANSLATION_IS_LOADING, TRANSLATION_HAS_ERROR } = messages;

/**
 * Generates a report message based on some of the report parameters and supplied messages.
 *
 * @param {Object} state The report to generate the text for
 * @returns {String}
 */
export const groupedReportText = state => {
  const { paths, reportType } = state;

  if (state.hasError) {
    return sprintf(TRANSLATION_HAS_ERROR, { reportType });
  }

  if (state.isLoading) {
    return sprintf(TRANSLATION_IS_LOADING, { reportType });
  }

  return groupedTextBuilder({
    ...countIssues(state),
    reportType,
    paths,
  });
};

export const reportStatusIcon = ({ isLoading, hasError, newIssues }) =>
  statusIcon(isLoading, hasError, newIssues.length);

export default () => {};
