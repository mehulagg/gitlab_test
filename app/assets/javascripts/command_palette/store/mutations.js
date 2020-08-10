import * as types from './mutation_types';

export default {
  [types.REGISTER_COMMANDS](state, commands) {
    console.log('mutating commands in', commands);
    console.log('state commands', state.commands)
    state.commands = state.commands.concat(commands);
  },
};
