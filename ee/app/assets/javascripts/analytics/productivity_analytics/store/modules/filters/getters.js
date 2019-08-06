import { urlParamsToObject } from '~/lib/utils/common_utils';

export const getCommonFilterParams = (state, getters) => {
  const { groupNamespace, projectPath, filters } = state;
  const { author_username, milestone_title, label_name } = urlParamsToObject(filters);

  return {
    group_id: groupNamespace,
    project_id: projectPath,
    author_username,
    milestone_title,
    label_name,
    merged_at_after: getters.mergedOnAfterDate,
  };
};

export const mergedOnAfterDate = state => {
  const d = new Date();
  return new Date(d.setTime(d.getTime() - state.daysInPast * 24 * 60 * 60 * 1000)).toISOString();
};

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
