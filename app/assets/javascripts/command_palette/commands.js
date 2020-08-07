import { __ } from '~/locale';
import store from './store';

export function registerCommands(commands) {
  console.log(__('registering commands'), commands);
  store.dispatch('registerCommands', commands);
}

export function unregisterCommands(commands) {
  console.log(__('unregistering following commands'), commands);
}
