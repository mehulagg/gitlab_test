import Api from 'ee/api';
import { __ } from '~/locale';
import * as types from './mutation_types';
import { checkForDataError, flashErrorIfStatusNotOk } from '../../../utils';

export const setLoading = ({ commit }, loading) => commit(types.SET_LOADING, loading);

export const requestDurationData = ({ commit }) => commit(types.REQUEST_DURATION_DATA);

export const receiveDurationDataError = ({ commit }, error) => {
  flashErrorIfStatusNotOk({
    error,
    message: __('There was an error while fetching value stream analytics duration data.'),
  });
  commit(types.RECEIVE_DURATION_DATA_ERROR, error);
};

export const fetchDurationData = ({ dispatch, commit, rootGetters }) => {
  dispatch('requestDurationData');
  const {
    cycleAnalyticsRequestParams,
    activeStages,
    currentGroupPath,
    currentValueStreamId,
  } = rootGetters;
  return Promise.all(
    activeStages.map(stage => {
      const { slug } = stage;

      return Api.cycleAnalyticsDurationChart({
        groupId: currentGroupPath,
        valueStreamId: currentValueStreamId,
        stageId: slug,
        params: cycleAnalyticsRequestParams,
      })
        .then(checkForDataError)
        .then(({ data }) => ({ slug, selected: true, data }));
    }),
  )
    .then(data => commit(types.RECEIVE_DURATION_DATA_SUCCESS, data))
    .catch(error => dispatch('receiveDurationDataError', error));
};

export const updateSelectedDurationChartStages = ({ state, commit }, stages) => {
  const setSelectedPropertyOnStages = data =>
    data.map(stage => {
      const selected = stages.reduce((result, object) => {
        if (object.slug === stage.slug) return true;
        return result;
      }, false);

      return {
        ...stage,
        selected,
      };
    });

  const { durationData } = state;
  const updatedDurationStageData = setSelectedPropertyOnStages(durationData);

  commit(types.UPDATE_SELECTED_DURATION_CHART_STAGES, {
    updatedDurationStageData,
  });
};
