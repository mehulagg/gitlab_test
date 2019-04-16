import _ from 'underscore';
import { isScrolledToBottom } from '~/lib/utils/scroll_utils';

export default {
  headerTime: state => (state.job.started ? state.job.started : state.job.created_at),

  hasUnmetPrerequisitesFailure: state =>
    state.job && state.job.failure_reason && state.job.failure_reason === 'unmet_prerequisites',

  shouldRenderCalloutMessage: state =>
    !_.isEmpty(state.job.status) && !_.isEmpty(state.job.callout_message),

  /**
   * When job has not started the key will be null
   * When job started the key will be a string with a date.
   */
  shouldRenderTriggeredLabel: state => _.isString(state.job.started),

  hasEnvironment: state => !_.isEmpty(state.job.deployment_status),

  /**
   * Checks if it the job has trace.
   * Used to check if it should render the job log or the empty state
   * @returns {Boolean}
   */
  hasTrace: state =>
    state.job.has_trace || (!_.isEmpty(state.job.status) && state.job.status.group === 'running'),

  emptyStateIllustration: state =>
    (state.job && state.job.status && state.job.status.illustration) || {},

  emptyStateAction: state => (state.job && state.job.status && state.job.status.action) || null,

  /**
   * Shared runners limit is only rendered when
   * used quota is bigger or equal than the limit
   *
   * @returns {Boolean}
   */
  shouldRenderSharedRunnerLimitWarning: state =>
    !_.isEmpty(state.job.runners) &&
    !_.isEmpty(state.job.runners.quota) &&
    state.job.runners.quota.used >= state.job.runners.quota.limit,

  isScrollingDown: state => isScrolledToBottom() && !state.isTraceComplete,

  hasRunnersForProject: state => state.job.runners.available && !state.job.runners.online,
};
