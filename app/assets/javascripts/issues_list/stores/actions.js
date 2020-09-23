import * as types from './mutation_types';
import eventhub from '../eventhub';

export const updateInitializedIssuableCount = ({ commit, state, dispatch }) => {
  commit(types.INCREMENT_INITIALIZED_ISSUABLE_COUNT);

  if (state.initializedIssuableCount >= state.issuableCount) {
    dispatch('resumeAppInitialization');
  }
};

export const resumeAppInitialization = () => {
  setTimeout(() => {
    eventhub.$emit('resumeAppInit');
  }, 100);
};
