import Visibility from 'visibilityjs';
import axios from 'axios';
import httpStatus from '../../../../lib/utils/http_status';
import { __ } from '../../../../locale';
import Poll from '../../../../lib/utils/poll';
import service from '../../../services';
import { rightSidebarViews } from '../../../constants';
import * as types from './mutation_types';

let eTagPoll;

export default {
  clearEtagPoll: () => {
    eTagPoll = null;
  },
  stopPipelinePolling: () => {
    if (eTagPoll) eTagPoll.stop();
  },
  restartPipelinePolling: () => {
    if (eTagPoll) eTagPoll.restart();
  },
  forcePipelineRequest: () => {
    if (eTagPoll) eTagPoll.makeRequest();
  },

  requestLatestPipeline: ({ commit }) => commit(types.REQUEST_LATEST_PIPELINE),
  receiveLatestPipelineError: ({ commit, dispatch }, err) => {
    if (err.status !== httpStatus.NOT_FOUND) {
      dispatch(
        'setErrorMessage',
        {
          text: __('An error occurred whilst fetching the latest pipeline.'),
          action: () =>
            dispatch('forcePipelineRequest').then(() =>
              dispatch('setErrorMessage', null, { root: true }),
            ),
          actionText: __('Please try again'),
          actionPayload: null,
        },
        { root: true },
      );
    }
    commit(types.RECEIVE_LASTEST_PIPELINE_ERROR);
    dispatch('stopPipelinePolling');
  },
  receiveLatestPipelineSuccess: ({ rootGetters, commit }, { pipelines }) => {
    let lastCommitPipeline = false;

    if (pipelines && pipelines.length) {
      const lastCommitHash = rootGetters.lastCommit && rootGetters.lastCommit.id;
      lastCommitPipeline = pipelines.find(pipeline => pipeline.commit.id === lastCommitHash);
    }

    commit(types.RECEIVE_LASTEST_PIPELINE_SUCCESS, lastCommitPipeline);
  },

  fetchLatestPipeline: ({ dispatch, rootGetters }) => {
    if (eTagPoll) return;

    dispatch('requestLatestPipeline');

    eTagPoll = new Poll({
      resource: service,
      method: 'lastCommitPipelines',
      data: { getters: rootGetters },
      successCallback: ({ data }) => dispatch('receiveLatestPipelineSuccess', data),
      errorCallback: err => dispatch('receiveLatestPipelineError', err),
    });

    if (!Visibility.hidden()) {
      eTagPoll.makeRequest();
    }

    Visibility.change(() => {
      if (!Visibility.hidden()) {
        dispatch('restartPipelinePolling');
      } else {
        dispatch('stopPipelinePolling');
      }
    });
  },

  requestJobs: ({ commit }, id) => commit(types.REQUEST_JOBS, id),
  receiveJobsError: ({ commit, dispatch }, stage) => {
    dispatch(
      'setErrorMessage',
      {
        text: __('An error occurred whilst loading the pipelines jobs.'),
        action: payload =>
          dispatch('fetchJobs', payload).then(() =>
            dispatch('setErrorMessage', null, { root: true }),
          ),
        actionText: __('Please try again'),
        actionPayload: stage,
      },
      { root: true },
    );
    commit(types.RECEIVE_JOBS_ERROR, stage.id);
  },
  receiveJobsSuccess: ({ commit }, { id, data }) =>
    commit(types.RECEIVE_JOBS_SUCCESS, { id, data }),

  fetchJobs: ({ dispatch }, stage) => {
    dispatch('requestJobs', stage.id);

    return axios
      .get(stage.dropdownPath)
      .then(({ data }) => dispatch('receiveJobsSuccess', { id: stage.id, data }))
      .catch(() => dispatch('receiveJobsError', stage));
  },

  toggleStageCollapsed: ({ commit }, stageId) => commit(types.TOGGLE_STAGE_COLLAPSE, stageId),

  setDetailJob: ({ commit, dispatch }, job) => {
    commit(types.SET_DETAIL_JOB, job);
    dispatch('rightPane/open', job ? rightSidebarViews.jobsDetail : rightSidebarViews.pipelines, {
      root: true,
    });
  },

  requestJobTrace: ({ commit }) => commit(types.REQUEST_JOB_TRACE),
  receiveJobTraceError: ({ commit, dispatch }) => {
    dispatch(
      'setErrorMessage',
      {
        text: __('An error occurred whilst fetching the job trace.'),
        action: () =>
          dispatch('fetchJobTrace').then(() => dispatch('setErrorMessage', null, { root: true })),
        actionText: __('Please try again'),
        actionPayload: null,
      },
      { root: true },
    );
    commit(types.RECEIVE_JOB_TRACE_ERROR);
  },
  receiveJobTraceSuccess: ({ commit }, data) => commit(types.RECEIVE_JOB_TRACE_SUCCESS, data),

  fetchJobTrace: ({ dispatch, state }) => {
    dispatch('requestJobTrace');

    return axios
      .get(`${state.detailJob.path}/trace`, { params: { format: 'json' } })
      .then(({ data }) => dispatch('receiveJobTraceSuccess', data))
      .catch(() => dispatch('receiveJobTraceError'));
  },

  resetLatestPipeline: ({ commit }) => {
    commit(types.RECEIVE_LASTEST_PIPELINE_SUCCESS, null);
    commit(types.SET_DETAIL_JOB, null);
  },
};
