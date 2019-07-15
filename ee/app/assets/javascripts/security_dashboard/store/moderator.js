import * as filtersMutationTypes from './modules/filters/mutation_types';
import * as projectsMutationTypes from './modules/projects/mutation_types';
import * as vulnerabilitiesMutationTypes from './modules/vulnerabilities/mutation_types';
import { BASE_FILTERS } from './modules/filters/constants';

export default function configureModerator(store) {
  store.subscribe(({ type, payload }) => {
    switch (type) {
      case `projects/${projectsMutationTypes.RECEIVE_PROJECTS_SUCCESS}`:
        store.dispatch('filters/setFilterOptions', {
          filterId: 'project_id',
          options: [
            BASE_FILTERS.project_id,
            ...payload.projects.map(project => ({
              name: project.name,
              id: project.id.toString(),
            })),
          ],
        });
        break;
      case `filters/${filtersMutationTypes.SET_ALL_FILTERS}`:
      case `filters/${filtersMutationTypes.SET_FILTER}`: {
        const activeFilters = store.getters['filters/activeFilters'];
        store.dispatch('vulnerabilities/fetchVulnerabilities', activeFilters);
        store.dispatch('vulnerabilities/fetchVulnerabilitiesCount', activeFilters);
        store.dispatch('vulnerabilities/fetchVulnerabilitiesHistory', activeFilters);
        break;
      }
      case `vulnerabilities/${vulnerabilitiesMutationTypes.REQUEST_CREATE_ISSUE}`:
      case `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_CREATE_ISSUE_ERROR}`:
      case `vulnerabilities/${vulnerabilitiesMutationTypes.REQUEST_DISMISS_VULNERABILITY}`:
      case `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_DISMISS_VULNERABILITY_SUCCESS}`:
      case `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_DISMISS_VULNERABILITY_ERROR}`:
      case `vulnerabilities/${vulnerabilitiesMutationTypes.REQUEST_ADD_DISMISSAL_COMMENT}`:
      case `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_ADD_DISMISSAL_COMMENT_SUCCESS}`:
      case `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_ADD_DISMISSAL_COMMENT_ERROR}`:
      case `vulnerabilities/${vulnerabilitiesMutationTypes.REQUEST_DELETE_DISMISSAL_COMMENT}`:
      case `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_DELETE_DISMISSAL_COMMENT_SUCCESS}`:
      case `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_DELETE_DISMISSAL_COMMENT_ERROR}`:
      case `vulnerabilities/${vulnerabilitiesMutationTypes.REQUEST_REVERT_DISMISSAL}`:
      case `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_REVERT_DISMISSAL_SUCCESS}`:
      case `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_REVERT_DISMISSAL_ERROR}`:
      case `vulnerabilities/${vulnerabilitiesMutationTypes.REQUEST_CREATE_MERGE_REQUEST}`:
      case `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_CREATE_MERGE_REQUEST_ERROR}`: {
        const vulnerabilityModalMutation = `vulnerabilityModal/${type.substring(16)}`;
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
