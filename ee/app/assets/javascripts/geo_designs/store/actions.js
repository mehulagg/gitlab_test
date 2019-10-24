import * as types from './mutation_types';
// import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import { __ } from '~/locale';

const mockData = [
  {
    id: 1,
    name: __('Zack\'s Design Repo'),
    url: 'http://localhost:3002',
    sync_status: 'synced',
    last_synced_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
    last_verified_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
    last_checked_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
  },
  {
    id: 2,
    name: __('Valery\'s Design Repo'),
    url: 'http://localhost:3002',
    sync_status: 'pending',
    last_synced_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
    last_verified_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
    last_checked_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
  },
  {
    id: 3,
    name: __('Mike\'s Design Repo'),
    url: 'http://localhost:3002',
    sync_status: 'failed',
    last_synced_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
    last_verified_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
    last_checked_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
  },
  {
    id: 4,
    name: __('Rachel\'s Design Repo'),
    url: 'http://localhost:3002',
    sync_status: null,
    last_synced_at: null,
    last_verified_at: null,
    last_checked_at: null,
  },
];

export const setEndpoint = ({ commit }, endpoint) => commit(types.SET_ENDPOINT, endpoint);
export const setFilter = ({ commit }, filterIndex) => commit (types.SET_FILTER, filterIndex);
export const setSearch = ({ commit }, search) => commit (types.SET_SEARCH, search);

export const requestDesigns = ({ commit }) => commit(types.REQUEST_DESIGNS);
export const receiveDesignsSuccess = ({ commit }, data) => commit(types.RECEIVE_DESIGNS_SUCCESS, data);
export const receiveDesignsError = ({ commit }, error) => commit(types.RECEIVE_DESIGNS_ERROR, error);

export const fetchDesigns = ({ state, dispatch }) => {
  dispatch('requestDesigns');

  console.log(`Mocking call to ${state.endpoint}`);

  new Promise(resolve => setTimeout(resolve, 3000))
  .then(() => {
    dispatch('receiveDesignsSuccess', mockData)
  })
  .catch(error => {
    dispatch('receiveDesignsError', error)
    createFlash(__('There was an error'))
  })

  /*
  axios.get(state.endpoint)
    .then(({ data }) => dispatch('receiveDesignsSuccess', data))
    .catch((error) => {
      dispatch('receiveDesignsError', error)
      createFlash(__('There was an error'))
    });
  */
}