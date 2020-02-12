import * as types from './mutation_types';

export default {
  [types.SET_LOADING_STACKTRACE](state, data) {
    state.loadingStacktrace = data;
  },
  [types.SET_STACKTRACE_DATA](state, data) {
    state.stacktraceData = data;
  },
  [types.REQUEST_ISSUE_MARKDOWN](state) {
    state.loadingIssueMarkdown = true;
  },
  [types.RECEIVE_ISSUE_MARKDOWN_SUCCESS](state, result) {
    state.issueMarkdown = result;
    state.loadingIssueMarkdown = false;
  },
  [types.RECEIVE_ISSUE_MARKDOWN_ERROR](state) {
    state.loadingIssueMarkdown = false;
  },
};
