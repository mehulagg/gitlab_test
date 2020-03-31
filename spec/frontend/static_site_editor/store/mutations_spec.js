import createState from '~/static_site_editor/store/state';
import mutations from '~/static_site_editor/store/mutations';
import * as types from '~/static_site_editor/store/mutation_types';
import { LOADING, LOADED, LOADING_ERROR } from '~/static_site_editor/constants';
import { sourceContentTitle as title, sourceContent as content } from '../mock_data';

describe('Static Site Editor Store mutations', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('loadContent', () => {
    beforeEach(() => {
      mutations[types.LOAD_CONTENT](state);
    });

    it('sets current state to LOADING', () => {
      expect(state.status).toBe(LOADING);
    });
  });

  describe('receiveContentSuccess', () => {
    const payload = { title, content };

    beforeEach(() => {
      mutations[types.RECEIVE_CONTENT_SUCCESS](state, payload);
    });

    it('sets current state to LOADING', () => {
      expect(state.status).toBe(LOADED);
    });

    it('sets title', () => {
      expect(state.title).toBe(payload.title);
    });

    it('sets content', () => {
      expect(state.content).toBe(payload.content);
    });
  });

  describe('receiveContentError', () => {
    beforeEach(() => {
      mutations[types.RECEIVE_CONTENT_ERROR](state);
    });

    it('sets current state to LOADING_ERROR', () => {
      expect(state.status).toBe(LOADING_ERROR);
    });
  });
});
