import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import testAction from 'helpers/vuex_action_helper';

import createFlash from '~/flash';

import createState from 'ee/security_dashboard/store/modules/projectSelector/state';
import * as types from 'ee/security_dashboard/store/modules/projectSelector/mutation_types';
import * as actions from 'ee/security_dashboard/store/modules/projectSelector/actions';

jest.mock('~/flash', () => jest.fn());

describe('projectSelector actions', () => {
  const getMockProjects = n => [...Array(n).keys()].map(i => ({ id: i, name: `project-${i}` }));

  const mockAddEndpoint = 'mock-add_endpoint';
  const mockListEndpoint = 'mock-list_endpoint';
  const mockResponse = { data: 'mock-data' };

  let mockAxios;
  let mockDispatchContext;
  let state;

  beforeEach(() => {
    mockAxios = new MockAdapter(axios);
    mockDispatchContext = { dispatch: () => {}, commit: () => {}, state };
    state = createState();
  });

  afterEach(() => {
    mockAxios.restore();
    createFlash.mockClear();
  });

  describe('toggleSelectedProject', () => {
    it('adds a project to selectedProjects if it does not already exist in the list', done => {
      const payload = getMockProjects(1);

      testAction(
        actions.toggleSelectedProject,
        payload,
        state,
        [
          {
            type: types.SELECT_PROJECT,
            payload,
          },
        ],
        [],
        done,
      );
    });

    it('removes a project from selectedProjects if it already exist in the list', done => {
      const payload = getMockProjects(1)[0];
      state.selectedProjects = getMockProjects(1);

      testAction(
        actions.toggleSelectedProject,
        payload,
        state,
        [
          {
            type: types.DESELECT_PROJECT,
            payload,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('addProjects', () => {
    it('posts selected project ids to project add endpoint', done => {
      state.projectEndpoints.add = mockAddEndpoint;

      mockAxios.onPost(mockAddEndpoint).replyOnce(200, mockResponse);

      testAction(
        actions.addProjects,
        null,
        state,
        [],
        [
          {
            type: 'requestAddProjects',
          },
          {
            type: 'receiveAddProjectsSuccess',
            payload: mockResponse,
          },
        ],
        done,
      );
    });

    it('calls addProjects error handler on error', done => {
      mockAxios.onPost(mockAddEndpoint).replyOnce(500);

      testAction(
        actions.addProjects,
        null,
        state,
        [],
        [{ type: 'requestAddProjects' }, { type: 'receiveAddProjectsError' }],
        done,
      );
    });
  });

  describe('requestAddProjects', () => {
    it('commits the REQUEST_ADD_PROJECTS mutation', done => {
      testAction(
        actions.requestAddProjects,
        null,
        state,
        [
          {
            type: types.REQUEST_ADD_PROJECTS,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveAddProjectsSuccess', () => {
    beforeEach(() => {
      state.selectedProjects = getMockProjects(3);
    });

    it('fetches projects when new projects are added to the dashboard', done => {
      const addedProject = state.selectedProjects[0];
      const payload = {
        added: [addedProject.id],
        invalid: [],
        duplicate: [],
      };

      testAction(
        actions.receiveAddProjectsSuccess,
        payload,
        state,
        [{ type: types.RECEIVE_ADD_PROJECTS_SUCCESS }],
        [
          {
            type: 'fetchProjects',
          },
        ],
        done,
      );
    });

    it('displays an error when user tries to add one invalid project to dashboard', () => {
      const invalidProject = state.selectedProjects[0];
      const data = {
        added: [],
        invalid: [invalidProject.id],
      };

      actions.receiveAddProjectsSuccess(mockDispatchContext, data);

      expect(createFlash).toHaveBeenCalledWith(`Unable to add ${invalidProject.name}`);
    });

    it('displays an error when user tries to add two invalid projects to dashboard', () => {
      const invalidProject1 = state.selectedProjects[0];
      const invalidProject2 = state.selectedProjects[1];
      const data = {
        added: [],
        invalid: [invalidProject1.id, invalidProject2.id],
      };

      actions.receiveAddProjectsSuccess(mockDispatchContext, data);

      expect(createFlash).toHaveBeenCalledWith(
        `Unable to add ${invalidProject1.name} and ${invalidProject2.name}`,
      );
    });

    it('displays an error when user tries to add more than two invalid projects to dashboard', () => {
      const invalidProject1 = state.selectedProjects[0];
      const invalidProject2 = state.selectedProjects[1];
      const invalidProject3 = state.selectedProjects[2];
      const data = {
        added: [],
        invalid: [invalidProject1.id, invalidProject2.id, invalidProject3.id],
      };

      actions.receiveAddProjectsSuccess(mockDispatchContext, data);

      expect(createFlash).toHaveBeenCalledWith(
        `Unable to add ${invalidProject1.name}, ${invalidProject2.name}, and ${invalidProject3.name}`,
      );
    });
  });

  describe('receiveAddProjectsError', () => {
    it('commits RECEIVE_ADD_PROJECTS_ERROR', done => {
      testAction(
        actions.receiveAddProjectsError,
        null,
        state,
        [
          {
            type: types.RECEIVE_ADD_PROJECTS_ERROR,
          },
        ],
        [],
        done,
      );
    });

    it('shows error message', () => {
      actions.receiveAddProjectsError(mockDispatchContext);

      expect(createFlash).toHaveBeenCalledTimes(1);
      expect(createFlash).toHaveBeenCalledWith(
        'Something went wrong, unable to add projects to dashboard',
      );
    });
  });

  describe('clearSearchResults', () => {
    it('clears all project search results', done => {
      testAction(
        actions.clearSearchResults,
        null,
        state,
        [
          {
            type: types.CLEAR_SEARCH_RESULTS,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('fetchProjects', () => {
    it('calls project list endpoint', done => {
      state.projectEndpoints.list = mockListEndpoint;
      mockAxios.onGet(mockListEndpoint).replyOnce(200);

      testAction(
        actions.fetchProjects,
        null,
        state,
        [],
        [{ type: 'requestProjects' }, { type: 'receiveProjectsSuccess' }],
        done,
      );
    });

    it('handles response errors', done => {
      state.projectEndpoints.list = mockListEndpoint;
      mockAxios.onGet(mockListEndpoint).replyOnce(500);

      testAction(
        actions.fetchProjects,
        null,
        state,
        [],
        [{ type: 'requestProjects' }, { type: 'receiveProjectsError' }],
        done,
      );
    });
  });

  describe('requestProjects', () => {
    it('toggles project loading state', done => {
      testAction(
        actions.requestProjects,
        null,
        state,
        [{ type: types.REQUEST_PROJECTS }],
        [],
        done,
      );
    });
  });

  describe('receiveProjectsSuccess', () => {
    it('sets projects from data on success', done => {
      const payload = {
        projects: [{ id: 0, name: 'mock-name1' }],
      };

      testAction(
        actions.receiveProjectsSuccess,
        payload,
        state,
        [
          {
            type: types.RECEIVE_PROJECTS_SUCCESS,
            payload: payload.projects,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveProjectsError', () => {
    it('clears projects and alerts user of error', done => {
      testAction(
        actions.receiveProjectsError,
        null,
        state,
        [
          {
            type: types.RECEIVE_PROJECTS_ERROR,
          },
        ],
        [],
        done,
      );

      expect(createFlash).toHaveBeenCalledWith('Something went wrong, unable to get projects');
    });
  });

  describe('removeProject', () => {
    const mockRemovePath = 'mock-removePath';

    it('calls project removal path and fetches projects on success', done => {
      mockAxios.onDelete(mockRemovePath).replyOnce(200);

      testAction(
        actions.removeProject,
        mockRemovePath,
        null,
        [],
        [
          { type: 'requestRemoveProject' },
          { type: 'receiveRemoveProjectSuccess' },
          { type: 'fetchProjects' },
        ],
        done,
      );
    });

    it('passes off handling of project removal errors', done => {
      mockAxios.onDelete(mockRemovePath).replyOnce(500);

      testAction(
        actions.removeProject,
        mockRemovePath,
        null,
        [],
        [{ type: 'requestRemoveProject' }, { type: 'receiveRemoveProjectError' }],
        done,
      );
    });
  });

  describe('requestRemoveProject', () => {
    it('commits REQUEST_REMOVE_PROJECT mutation', done => {
      testAction(
        actions.requestRemoveProject,
        null,
        state,
        [
          {
            type: types.REQUEST_REMOVE_PROJECT,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveRemoveProjectSuccess', () => {
    it('commits RECEIVE_REMOVE_PROJECT_SUCCESS mutation', done => {
      testAction(
        actions.receiveRemoveProjectSuccess,
        null,
        state,
        [
          {
            type: types.RECEIVE_REMOVE_PROJECT_SUCCESS,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveRemoveProjectError', () => {
    it('commits REQUEST_REMOVE_PROJECT mutation', done => {
      testAction(
        actions.receiveRemoveProjectError,
        null,
        state,
        [
          {
            type: types.RECEIVE_REMOVE_PROJECT_ERROR,
          },
        ],
        [],
        done,
      );
    });

    it('displays project removal error', () => {
      actions.receiveRemoveProjectError(mockDispatchContext);

      expect(createFlash).toHaveBeenCalledTimes(1);
      expect(createFlash).toHaveBeenCalledWith('Something went wrong, unable to remove project');
    });
  });

  describe('fetchSearchResults', () => {
    it.each([null, undefined, false, NaN])(
      'dispatches minimumQueryMessage if the search query is falsy',
      (searchQuery, done) => {
        state.searchQuery = searchQuery;

        testAction(
          actions.fetchSearchResults,
          null,
          state,
          [],
          [
            {
              type: 'requestSearchResults',
            },
            {
              type: 'minimumQueryMessage',
            },
          ],
          done,
        );
      },
    );

    it('dispatches minimumQueryMessage if the search query was empty', done => {
      state.searchQuery = '';

      testAction(
        actions.fetchSearchResults,
        null,
        state,
        [],
        [
          {
            type: 'requestSearchResults',
          },
          {
            type: 'minimumQueryMessage',
          },
        ],
        done,
      );
    });

    it.each(['a', 'aa'])(
      'dispatches minimumQueryMessage if the search query was not long enough',
      (shortSearchQuery, done) => {
        state.searchQuery = shortSearchQuery;

        testAction(
          actions.fetchSearchResults,
          null,
          state,
          [],
          [
            {
              type: 'requestSearchResults',
            },
            {
              type: 'minimumQueryMessage',
            },
          ],
          done,
        );
      },
    );

    it('dispatches the correct actions when the query is valid', done => {
      const mockProjects = [{ id: 0, name: 'mock-name1' }];
      mockAxios.onAny().replyOnce(200, mockProjects);
      state.searchQuery = 'mock-query';

      testAction(
        actions.fetchSearchResults,
        null,
        state,
        [],
        [
          {
            type: 'requestSearchResults',
          },
          {
            type: 'receiveSearchResultsSuccess',
            payload: mockProjects,
          },
        ],
        done,
      );
    });
  });

  describe('requestSearchResults', () => {
    it('commits the REQUEST_SEARCH_RESULTS mutation', done => {
      testAction(
        actions.requestSearchResults,
        null,
        state,
        [
          {
            type: types.REQUEST_SEARCH_RESULTS,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveSearchResultsSuccess', () => {
    it('commits the RECEIVE_SEARCH_RESULTS_SUCCESS mutation', done => {
      const mockProjects = [{ id: 0, name: 'mock-project1' }];
      testAction(
        actions.receiveSearchResultsSuccess,
        mockProjects,
        state,
        [
          {
            type: types.RECEIVE_SEARCH_RESULTS_SUCCESS,
            payload: mockProjects,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveSearchResultsError', () => {
    it('commits the RECEIVE_SEARCH_RESULTS_ERROR mutation', done => {
      testAction(
        actions.receiveSearchResultsError,
        ['error'],
        state,
        [
          {
            type: types.RECEIVE_SEARCH_RESULTS_ERROR,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('setProjectEndpoints', () => {
    it('commits project list and add endpoints', done => {
      const payload = {
        add: 'add',
        list: 'list',
      };

      testAction(
        actions.setProjectEndpoints,
        payload,
        state,
        [
          {
            type: types.SET_PROJECT_ENDPOINTS,
            payload,
          },
        ],
        [],
        done,
      );
    });
  });
});
