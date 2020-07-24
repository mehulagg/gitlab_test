import { useSmartResource } from './resource';

// eslint-disable-next-line import/prefer-default-export
export const useComponent = setup => useSmartResource(setup, wrapper => wrapper.destroy());
