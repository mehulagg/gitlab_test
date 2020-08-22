export default Vue => {
  Vue.mixin({
    provide: {
      glPaths: { ...(window.gon?.paths || {}) },
    },
  });
};
