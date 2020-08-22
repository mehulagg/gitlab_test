export default () => ({
  inject: {
    glPaths: {
      from: 'glPaths',
      default: () => ({}),
    },
  },
});
