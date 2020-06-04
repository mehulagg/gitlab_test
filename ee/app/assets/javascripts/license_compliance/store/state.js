const DEFAULT_SETTINGS = {
  prefix: 'license-check',
};

export default (settings = {}) => ({
  settings: {
    ...DEFAULT_SETTINGS,
    ...settings,
  },
});
