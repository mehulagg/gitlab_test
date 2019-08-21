import * as types from './mutation_types';
import EMPTY_STAGE_TEXTS from '../empty_stage_texts';
import { dasherize } from '~/lib/utils/text_utility';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

export default {
  [types.SET_CYCLE_ANALYTICS_DATA_ENDPOINT](state, groupPath) {
    state.endpoints.cycleAnalyticsData = `/groups/${groupPath}/-/cycle_analytics`;
  },
  [types.SET_STAGE_DATA_ENDPOINT](state, stageSlug) {
    state.endpoints.stageData = `${state.endpoints.cycleAnalyticsData}/events/${stageSlug}.json`;
  },
  [types.SET_SELECTED_GROUP](state, group) {
    state.selectedGroup = group;
    state.selectedProjectIds = [];
  },
  [types.SET_SELECTED_PROJECTS](state, projectIds) {
    state.selectedProjectIds = projectIds;
  },
  [types.SET_SELECTED_TIMEFRAME](state, timeframe) {
    state.dataTimeframe = timeframe;
  },
  [types.SET_SELECTED_STAGE_NAME](state, stageName) {
    state.selectedStageName = stageName;
  },
  [types.REQUEST_CYCLE_ANALYTICS_DATA](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_CYCLE_ANALYTICS_DATA_SUCCESS](state, data) {
    state.summary = data.summary.map(item => ({
      ...item,
      value: item.value || '-',
    }));

    state.stages = data.stats.map(item => {
      const slug = dasherize(item.name.toLowerCase());
      return {
        ...item,
        isUserAllowed: data.permissions[slug],
        emptyStageText: EMPTY_STAGE_TEXTS[slug],
        component: `stage-${slug}-component`,
        slug,
      };
    });

    if (state.stages.length) {
      const { name } = state.stages[0];
      state.selectedStageName = name;
    }
    state.isLoading = false;
  },
  [types.RECEIVE_CYCLE_ANALYTICS_DATA_ERROR](state) {
    state.isLoading = false;
  },
  [types.REQUEST_STAGE_DATA](state) {
    state.isLoadingStage = true;
  },
  [types.RECEIVE_STAGE_DATA_SUCCESS](state, data) {
    state.events = data.events.map(item => convertObjectPropsToCamelCase(item, { deep: true }));
    // state.events = data.events.map(item => {
    //   const author = item.author
    //     ? {
    //         id: item.author.id,
    //         name: item.author.name,
    //         webUrl: item.author.web_url,
    //         avatarUrl: item.author.avatar_url,
    //       }
    //     : null;

    //   const branch = item.branch ? item.branch : null;

    //   return {
    //     id: item.id,
    //     iid: item.iid,
    //     totalTime: item.total_time,
    //     createdAt: item.created_at,
    //     shortSha: item.short_sha,
    //     commitUrl: item.commit_url,
    //     author,
    //     branch,
    //   };
    // });

    state.isEmptyStage = state.events.length === 0;
    state.isLoadingStage = false;
  },
  [types.RECEIVE_STAGE_DATA_ERROR](state) {
    state.isEmptyStage = true;
    state.isLoadingStage = false;
  },
};
