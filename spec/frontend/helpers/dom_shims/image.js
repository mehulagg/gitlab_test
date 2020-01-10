Object.defineProperty(global.HTMLImageElement.prototype, 'src', {
  get() {
    return this.shimSrc;
  },
  set(val) {
    this.shimSrc = val;

    if (this.onload) {
      this.onload();
    }
  },
});
