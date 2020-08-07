import { __ } from '~/locale';
import * as types from './mutation_types';

export const registerCommands = ({ commit }) => {
  console.log(__('store registering'));
  return commit(types.REGISTER_COMMANDS);
};

export const unregisterCommands = ({ commands }) =>
  console.log(__('store unregistering'), commands);
