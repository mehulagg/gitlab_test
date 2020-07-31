import gettersCE from '~/boards/stores/getters';

const getIssueByEpic = (state) => {
  return state.epics[0].issues.find(issue => issue.id === state.activeId);
}

const getIssueByEpicTitle = (state) => {
  return getIssueByEpic(state).title;
}

export default {
  ...gettersCE,
  getIssueByEpicTitle,
};
