import createStore from 'ee/security_dashboard/store/index';
import * as projectsMutationTypes from 'ee/security_dashboard/store/modules/projects/mutation_types';
import * as filtersMutationTypes from 'ee/security_dashboard/store/modules/filters/mutation_types';
import * as vulnerabilitiesMutationTypes from 'ee/security_dashboard/store/modules/vulnerabilities/mutation_types';
import { BASE_FILTERS } from 'ee/security_dashboard/store/modules/filters/constants';
import mockData from './vulnerabilities/data/mock_data_vulnerabilities.json';

describe('moderator', () => {
  let store;

  beforeEach(() => {
    store = createStore();
  });

  it('sets project filter options after projects have been received', () => {
    spyOn(store, 'dispatch');

    store.commit(`projects/${projectsMutationTypes.RECEIVE_PROJECTS_SUCCESS}`, {
      projects: [{ name: 'foo', id: 1, otherProp: 'foobar' }],
    });

    expect(store.dispatch).toHaveBeenCalledTimes(1);
    expect(store.dispatch).toHaveBeenCalledWith(
      'filters/setFilterOptions',
      Object({
        filterId: 'project_id',
        options: [BASE_FILTERS.project_id, { name: 'foo', id: '1' }],
      }),
    );
  });

  it('triggers fetching vulnerabilities after one filter changes', () => {
    spyOn(store, 'dispatch');

    const activeFilters = store.getters['filters/activeFilters'];

    store.commit(`filters/${filtersMutationTypes.SET_FILTER}`, {});

    expect(store.dispatch).toHaveBeenCalledTimes(3);
    expect(store.dispatch).toHaveBeenCalledWith(
      'vulnerabilities/fetchVulnerabilities',
      activeFilters,
    );

    expect(store.dispatch).toHaveBeenCalledWith(
      'vulnerabilities/fetchVulnerabilitiesCount',
      activeFilters,
    );

    expect(store.dispatch).toHaveBeenCalledWith(
      'vulnerabilities/fetchVulnerabilitiesHistory',
      activeFilters,
    );
  });

  it('triggers fetching vulnerabilities after filters change', () => {
    spyOn(store, 'dispatch');

    const activeFilters = store.getters['filters/activeFilters'];

    store.commit(`filters/${filtersMutationTypes.SET_ALL_FILTERS}`, {});

    expect(store.dispatch).toHaveBeenCalledTimes(3);
    expect(store.dispatch).toHaveBeenCalledWith(
      'vulnerabilities/fetchVulnerabilities',
      activeFilters,
    );

    expect(store.dispatch).toHaveBeenCalledWith(
      'vulnerabilities/fetchVulnerabilitiesCount',
      activeFilters,
    );

    expect(store.dispatch).toHaveBeenCalledWith(
      'vulnerabilities/fetchVulnerabilitiesHistory',
      activeFilters,
    );
  });

  describe('vulnerability modal mutations', () => {
    beforeEach(() => {
      store = createStore();
      store.state.vulnerabilities.vulnerabilities = mockData;
    });

    [
      {
        vulnerabilityMutation: `vulnerabilities/${vulnerabilitiesMutationTypes.REQUEST_CREATE_ISSUE}`,
        modalMutation: `vulnerabilityModal/${vulnerabilitiesMutationTypes.REQUEST_CREATE_ISSUE}`,
      },
      {
        vulnerabilityMutation: `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_CREATE_ISSUE_ERROR}`,
        modalMutation: `vulnerabilityModal/${vulnerabilitiesMutationTypes.RECEIVE_CREATE_ISSUE_ERROR}`,
        payload: { flashError: true },
      },
      {
        vulnerabilityMutation: `vulnerabilities/${vulnerabilitiesMutationTypes.REQUEST_DISMISS_VULNERABILITY}`,
        modalMutation: `vulnerabilityModal/${vulnerabilitiesMutationTypes.REQUEST_DISMISS_VULNERABILITY}`,
      },
      {
        vulnerabilityMutation: `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_DISMISS_VULNERABILITY_SUCCESS}`,
        modalMutation: `vulnerabilityModal/${vulnerabilitiesMutationTypes.RECEIVE_DISMISS_VULNERABILITY_SUCCESS}`,
        payload: { vulnerability: mockData[0] },
      },
      {
        vulnerabilityMutation: `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_DISMISS_VULNERABILITY_ERROR}`,
        modalMutation: `vulnerabilityModal/${vulnerabilitiesMutationTypes.RECEIVE_DISMISS_VULNERABILITY_ERROR}`,
        payload: { flashError: true },
      },
      {
        vulnerabilityMutation: `vulnerabilities/${vulnerabilitiesMutationTypes.REQUEST_ADD_DISMISSAL_COMMENT}`,
        modalMutation: `vulnerabilityModal/${vulnerabilitiesMutationTypes.REQUEST_ADD_DISMISSAL_COMMENT}`,
      },
      {
        vulnerabilityMutation: `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_ADD_DISMISSAL_COMMENT_SUCCESS}`,
        modalMutation: `vulnerabilityModal/${vulnerabilitiesMutationTypes.RECEIVE_ADD_DISMISSAL_COMMENT_SUCCESS}`,
        payload: { vulnerability: mockData[0] },
      },
      {
        vulnerabilityMutation: `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_ADD_DISMISSAL_COMMENT_ERROR}`,
        modalMutation: `vulnerabilityModal/${vulnerabilitiesMutationTypes.RECEIVE_ADD_DISMISSAL_COMMENT_ERROR}`,
      },
      {
        vulnerabilityMutation: `vulnerabilities/${vulnerabilitiesMutationTypes.REQUEST_REVERT_DISMISSAL}`,
        modalMutation: `vulnerabilityModal/${vulnerabilitiesMutationTypes.REQUEST_REVERT_DISMISSAL}`,
      },
      {
        vulnerabilityMutation: `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_REVERT_DISMISSAL_SUCCESS}`,
        modalMutation: `vulnerabilityModal/${vulnerabilitiesMutationTypes.RECEIVE_REVERT_DISMISSAL_SUCCESS}`,
        payload: { vulnerability: mockData[0] },
      },
      {
        vulnerabilityMutation: `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_REVERT_DISMISSAL_ERROR}`,
        modalMutation: `vulnerabilityModal/${vulnerabilitiesMutationTypes.RECEIVE_REVERT_DISMISSAL_ERROR}`,
        payload: { flashError: true },
      },
      {
        vulnerabilityMutation: `vulnerabilities/${vulnerabilitiesMutationTypes.REQUEST_CREATE_MERGE_REQUEST}`,
        modalMutation: `vulnerabilityModal/${vulnerabilitiesMutationTypes.REQUEST_CREATE_MERGE_REQUEST}`,
      },
      {
        vulnerabilityMutation: `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_CREATE_MERGE_REQUEST_ERROR}`,
        modalMutation: `vulnerabilityModal/${vulnerabilitiesMutationTypes.RECEIVE_CREATE_MERGE_REQUEST_ERROR}`,
        payload: { flashError: true },
      },
    ].forEach(({ vulnerabilityMutation, modalMutation, payload }) => {
      it(`commits ${modalMutation} along with ${vulnerabilityMutation}`, () => {
        const expectedArgs = [modalMutation];
        if (typeof payload !== 'undefined') {
          expectedArgs.push(payload);
        }
        spyOn(store, 'commit').and.callThrough();

        store.commit(vulnerabilityMutation, payload);

        expect(store.commit).toHaveBeenCalledWith(...expectedArgs);

        expect(store.commit).toHaveBeenCalledTimes(2);
      });
    });
  });
});
