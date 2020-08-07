import * as types from './mutation_types';

export default {
  [types.REGISTER_COMMANDS](state, commands) {
    state.commands = commands;
  },
};
