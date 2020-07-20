export const diffModes = {
  replaced: 'replaced',
  new: 'new',
  deleted: 'deleted',
  renamed: 'renamed',
};

export const imageViewMode = {
  twoup: 'twoup',
  swipe: 'swipe',
  onion: 'onion',
};

// State machine states
export const RENAMED_STATE_IDLING = 'idle';
export const RENAMED_STATE_LOADING = 'loading';
export const RENAMED_STATE_ERRORED = 'errored';

// State machine transitions
export const RENAMED_TRANSITION_LOAD_START = 'LOAD_START';
export const RENAMED_TRANSITION_LOAD_ERROR = 'LOAD_ERROR';
export const RENAMED_TRANSITION_LOAD_SUCCEED = 'LOAD_SUCCEED';
export const RENAMED_TRANSITION_ACKNOWLEDGE_ERROR = 'ACKNOWLEDGE_ERROR';
