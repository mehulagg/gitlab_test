/**
 * This plugin keeps track of all mounted roots and provides a method to destroy them all
 *
 * **Why?**
 * This helps prevent flaky specs [caused by zombie components][1].
 *
 * [1]: https://gitlab.com/gitlab-org/gitlab/issues/207376#note_295075919
 */
export default class VueDestroyerPlugin {
  constructor() {
    this.instances = [];
  }

  install(Vue) {
    // We have to save off self since `this` is needed in the Vue methods
    const self = this;

    const originalMount = Vue.prototype.$mount;

    Object.assign(Vue.prototype, {
      $mount(...args) {
        if (this === this.$root) {
          self.instances.push(this);
        }
        return originalMount.apply(this, args);
      },
    });
  }

  destroyAll() {
    this.instances.forEach(x => x.$destroy());
    this.instances = [];
  }
}
