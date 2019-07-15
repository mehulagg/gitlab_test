import * as types from './mutation_types';

const updateIssueActionsMap = {
  sast: 'sast/updateVulnerability',
  dependency_scanning: 'updateDependencyScanningIssue',
  container_scanning: 'updateContainerScanningIssue',
  dast: 'updateDastIssue',
};

export default function configureMediator(store) {
  store.subscribe(({ type, payload }) => {
    switch (type) {
      case types.RECEIVE_DISMISS_VULNERABILITY_SUCCESS:
      case `vulnerabilityModal/${types.RECEIVE_DISMISS_VULNERABILITY_SUCCESS}`:
        if (updateIssueActionsMap[payload.category]) {
          store.dispatch(updateIssueActionsMap[payload.category], payload);
        }
        break;
      case types.REQUEST_ADD_DISMISSAL_COMMENT:
      case types.RECEIVE_ADD_DISMISSAL_COMMENT_SUCCESS:
      case types.RECEIVE_ADD_DISMISSAL_COMMENT_ERROR:
      case types.REQUEST_DELETE_DISMISSAL_COMMENT:
      case types.RECEIVE_DELETE_DISMISSAL_COMMENT_SUCCESS:
      case types.RECEIVE_DELETE_DISMISSAL_COMMENT_ERROR:
      case types.REQUEST_CREATE_MERGE_REQUEST:
      case types.RECEIVE_CREATE_MERGE_REQUEST_ERROR: {
        const vulnerabilityModalMutation = `vulnerabilityModal/${type}`;
        if (typeof payload !== 'undefined') {
          store.commit(vulnerabilityModalMutation, payload);
        } else {
          store.commit(vulnerabilityModalMutation);
        }
        break;
      }
      default:
    }
  });
}
