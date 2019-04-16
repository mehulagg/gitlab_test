import Visibility from 'visibilityjs';
import * as types from './mutation_types';
import axios from '~/lib/utils/axios_utils';
import Poll from '~/lib/utils/poll';
import { setFaviconOverlay, resetFavicon } from '~/lib/utils/common_utils';
import flash from '~/flash';
import { __ } from '~/locale';
import {
  canScroll,
  isScrolledToBottom,
  isScrolledToTop,
  isScrolledToMiddle,
  scrollDown,
  scrollUp,
} from '~/lib/utils/scroll_utils';

let eTagPoll;
let traceTimeout;

export default {
  setJobEndpoint: ({ commit }, endpoint) => commit(types.SET_JOB_ENDPOINT, endpoint),
  setTraceOptions: ({ commit }, options) => commit(types.SET_TRACE_OPTIONS, options),

  hideSidebar: ({ commit }) => commit(types.HIDE_SIDEBAR),
  showSidebar: ({ commit }) => commit(types.SHOW_SIDEBAR),

  toggleSidebar: ({ dispatch, state }) => {
    if (state.isSidebarOpen) {
      dispatch('hideSidebar');
    } else {
      dispatch('showSidebar');
    }
  },

  clearEtagPoll: () => {
    eTagPoll = null;
  },

  stopPolling: () => {
    if (eTagPoll) eTagPoll.stop();
  },

  restartPolling: () => {
    if (eTagPoll) eTagPoll.restart();
  },

  requestJob: ({ commit }) => commit(types.REQUEST_JOB),

  fetchJob: ({ state, dispatch }) => {
    dispatch('requestJob');

    eTagPoll = new Poll({
      resource: {
        getJob(endpoint) {
          return axios.get(endpoint);
        },
      },
      data: state.jobEndpoint,
      method: 'getJob',
      successCallback: ({ data }) => dispatch('receiveJobSuccess', data),
      errorCallback: () => dispatch('receiveJobError'),
    });

    if (!Visibility.hidden()) {
      eTagPoll.makeRequest();
    } else {
      axios
        .get(state.jobEndpoint)
        .then(({ data }) => dispatch('receiveJobSuccess', data))
        .catch(() => dispatch('receiveJobError'));
    }

    Visibility.change(() => {
      if (!Visibility.hidden()) {
        dispatch('restartPolling');
      } else {
        dispatch('stopPolling');
      }
    });
  },

  receiveJobSuccess: ({ commit }, data = {}) => {
    commit(types.RECEIVE_JOB_SUCCESS, data);

    if (data.status && data.status.favicon) {
      setFaviconOverlay(data.status.favicon);
    } else {
      resetFavicon();
    }
  },
  receiveJobError: ({ commit }) => {
    commit(types.RECEIVE_JOB_ERROR);
    flash(__('An error occurred while fetching the job.'));
    resetFavicon();
  },

  /**
   * Job's Trace
   */
  scrollTop: ({ dispatch }) => {
    scrollUp();
    dispatch('toggleScrollButtons');
  },

  scrollBottom: ({ dispatch }) => {
    scrollDown();
    dispatch('toggleScrollButtons');
  },

  /**
   * Responsible for toggling the disabled state of the scroll buttons
   */
  toggleScrollButtons: ({ dispatch }) => {
    if (canScroll()) {
      if (isScrolledToMiddle()) {
        dispatch('enableScrollTop');
        dispatch('enableScrollBottom');
      } else if (isScrolledToTop()) {
        dispatch('disableScrollTop');
        dispatch('enableScrollBottom');
      } else if (isScrolledToBottom()) {
        dispatch('disableScrollBottom');
        dispatch('enableScrollTop');
      }
    } else {
      dispatch('disableScrollBottom');
      dispatch('disableScrollTop');
    }
  },

  disableScrollBottom: ({ commit }) => commit(types.DISABLE_SCROLL_BOTTOM),
  disableScrollTop: ({ commit }) => commit(types.DISABLE_SCROLL_TOP),
  enableScrollBottom: ({ commit }) => commit(types.ENABLE_SCROLL_BOTTOM),
  enableScrollTop: ({ commit }) => commit(types.ENABLE_SCROLL_TOP),

  /**
   * While the automatic scroll down is active,
   * we show the scroll down button with an animation
   */
  toggleScrollAnimation: ({ commit }, toggle) => commit(types.TOGGLE_SCROLL_ANIMATION, toggle),

  /**
   * Responsible to handle automatic scroll
   */
  toggleScrollisInBottom: ({ commit }, toggle) => {
    commit(types.TOGGLE_IS_SCROLL_IN_BOTTOM_BEFORE_UPDATING_TRACE, toggle);
  },

  requestTrace: ({ commit }) => commit(types.REQUEST_TRACE),

  fetchTrace: ({ dispatch, state }) =>
    axios
      .get(`${state.traceEndpoint}/trace.json`, {
        params: { state: state.traceState },
      })
      .then(({ data }) => {
        dispatch('toggleScrollisInBottom', isScrolledToBottom());
        dispatch('receiveTraceSuccess', data);

        if (!data.complete) {
          traceTimeout = setTimeout(() => {
            dispatch('fetchTrace');
          }, 4000);
        } else {
          dispatch('stopPollingTrace');
        }
      })
      .catch(() => dispatch('receiveTraceError')),

  stopPollingTrace: ({ commit }) => {
    commit(types.STOP_POLLING_TRACE);
    clearTimeout(traceTimeout);
  },
  receiveTraceSuccess: ({ commit }, log) => commit(types.RECEIVE_TRACE_SUCCESS, log),
  receiveTraceError: ({ commit }) => {
    commit(types.RECEIVE_TRACE_ERROR);
    clearTimeout(traceTimeout);
    flash(__('An error occurred while fetching the job log.'));
  },

  /**
   * Stages dropdown on sidebar
   */
  requestStages: ({ commit }) => commit(types.REQUEST_STAGES),
  fetchStages: ({ state, dispatch }) => {
    dispatch('requestStages');

    axios
      .get(`${state.job.pipeline.path}.json`)
      .then(({ data }) => {
        // Set selected stage
        dispatch('receiveStagesSuccess', data.details.stages);
        const selectedStage = data.details.stages.find(stage => stage.name === state.selectedStage);
        dispatch('fetchJobsForStage', selectedStage);
      })
      .catch(() => dispatch('receiveStagesError'));
  },
  receiveStagesSuccess: ({ commit }, data) => commit(types.RECEIVE_STAGES_SUCCESS, data),
  receiveStagesError: ({ commit }) => {
    commit(types.RECEIVE_STAGES_ERROR);
    flash(__('An error occurred while fetching stages.'));
  },

  /**
   * Jobs list on sidebar - depend on stages dropdown
   */
  requestJobsForStage: ({ commit }, stage) => commit(types.REQUEST_JOBS_FOR_STAGE, stage),

  // On stage click, set selected stage + fetch job
  fetchJobsForStage: ({ dispatch }, stage) => {
    dispatch('requestJobsForStage', stage);

    axios
      .get(stage.dropdown_path, {
        params: {
          retried: 1,
        },
      })
      .then(({ data }) => {
        const retriedJobs = data.retried.map(job => Object.assign({}, job, { retried: true }));
        const jobs = data.latest_statuses.concat(retriedJobs);

        dispatch('receiveJobsForStageSuccess', jobs);
      })
      .catch(() => dispatch('receiveJobsForStageError'));
  },
  receiveJobsForStageSuccess: ({ commit }, data) =>
    commit(types.RECEIVE_JOBS_FOR_STAGE_SUCCESS, data),
  receiveJobsForStageError: ({ commit }) => {
    commit(types.RECEIVE_JOBS_FOR_STAGE_ERROR);
    flash(__('An error occurred while fetching the jobs.'));
  },
};
