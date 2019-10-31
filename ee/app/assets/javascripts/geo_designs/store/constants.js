// eslint-disable-next-line import/prefer-default-export
export const FILTER_STATES = {
  ALL: 'all',
  SYNCED: 'synced',
  PENDING: 'pending',
  FAILED: 'failed',
  NEVER: 'never',
};

export const ACTION_TYPES = {
  RESYNC: 'resync',
  // Below not implemented yet
  REVERIFY: 'reverify',
  FORCE_REDOWNLOAD: 'force_redownload',
};
